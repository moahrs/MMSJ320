/* sheet.c - fonte consolidado */

#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include "mmsj320api.h"
#include "mmsj320vdp.h"
#include "mmsj320mfp.h"
#include "monitor.h"
#include "mmsjos.h"
#include "mgui.h"
#include "mguiapi.h"
#include "monitorapi.h"
#include "mmsjosapi.h"

#include "testes.h"

static NET_HOOK *netHookTable = (NET_HOOK *)0x0060F7BC;

// Short delay to respect DS1307 I2C clock speed (max 100 kHz)
void i2c_delay(void) {
    volatile int i;
    for(i = 0; i < 10; i++); // Adjust based on your 68000 clock speed
}

// Initialize MFP Pins
void i2c_init(void) {
    // Set pins as Inputs initially (floating high via external pull-ups)
    MFP_DDR &= ~(SDA_PIN | SCL_PIN);
    // Write 0 to Data Register so pins pull low when switched to outputs
    MFP_PDR &= ~(SDA_PIN | SCL_PIN); 
}

// Set SDA High (Floating) or Low (Driven)
void set_sda(int high) {
    if (high) {
        MFP_DDR &= ~SDA_PIN; // Input = Float High
    } else {
        MFP_DDR |= SDA_PIN;  // Output = Drives Low
    }
}

// Set SCL High (Floating) or Low (Driven)
void set_scl(int high) {
    if (high) {
        MFP_DDR &= ~SCL_PIN; // Input = Float High
    } else {
        MFP_DDR |= SCL_PIN;  // Output = Drives Low
    }
}

int read_sda(void) {
    return (MFP_PDR & SDA_PIN) ? 1 : 0;
}

// I2C Signaling Protocols
void i2c_start(void) {
    set_sda(1); set_scl(1); i2c_delay();
    set_sda(0); i2c_delay();
    set_scl(0); i2c_delay();
}

void i2c_stop(void) {
    set_sda(0); i2c_delay();
    set_scl(1); i2c_delay();
    set_sda(1); i2c_delay();
}

// Write a byte over I2C and return the ACK status
int i2c_write(unsigned char byte) {
    int i;
    for (i = 0; i < 8; i++) {
        set_sda((byte & 0x80) ? 1 : 0);
        byte <<= 1;
        i2c_delay();
        set_scl(1); i2c_delay();
        set_scl(0); i2c_delay();
    }
    // Read ACK bit
    set_sda(1); i2c_delay();
    set_scl(1); i2c_delay();
    int ack = read_sda();
    set_scl(0); i2c_delay();
    return ack; // 0 means ACK, 1 means NACK
}

int rtc_init_with_sqw(void) {
    // 1. Inicializa os pinos de I/O do MC68901 MFP
    i2c_init(); 
    
    // 2. Inicia a transmissão I2C em modo de escrita
    i2c_start();
    if (i2c_write(DS1307_ADDR_WRITE) != 0) {
        i2c_stop();
        return -1; // Erro de hardware / comunicação
    }
    
    // 3. Aponta para o registrador de Controle (0x07)
    i2c_write(DS1307_REG_CONTROL); 
    
    // 4. Escreve 0x10 (Ativa SQWE e define frequência para 1Hz)
    i2c_write(0x10); 
    
    // 5. Finaliza a transmissão
    i2c_stop();
    
    return 0; // Sucesso!
}

// Convert BCD to regular integer format
int bcd_to_int(unsigned char bcd) {
    return ((bcd >> 4) * 10) + (bcd & 0x0F);
}

// Read raw seconds register from RTC
int rtc_get_seconds(void) {
    unsigned char raw_seconds = 0;
    
    i2c_start();
    if (i2c_write(DS1307_ADDR_WRITE) == 0) { // Select Device
        i2c_write(0x00);                    // Point to Seconds Register (0x00)
        
        i2c_start();                        // Repeated Start
        i2c_write(DS1307_ADDR_READ);        // Set Read Mode
        
        // Read byte with NACK (last byte to read)
        int i;
        set_sda(1); // Ensure float high
        for (i = 0; i < 8; i++) {
            set_scl(1); i2c_delay();
            raw_seconds = (raw_seconds << 1) | read_sda();
            set_scl(0); i2c_delay();
        }
        // Send NACK to terminate transfer
        set_sda(1); set_scl(1); i2c_delay(); set_scl(0); 
    }
    i2c_stop();
    
    return bcd_to_int(raw_seconds & 0x7F); // Strip CH (Clock Halt) bit 7
}

unsigned char int_to_bcd(int val) {
    return (unsigned char)(((val / 10) << 4) | (val % 10));
}

int rtc_set_datetime(DateTimeData *dt) {
    unsigned char bcd_sec, bcd_min, bcd_hour;
    unsigned char bcd_dow, bcd_day, bcd_month, bcd_year;

    // Convert all fields to BCD
    bcd_sec   = int_to_bcd(dt->seconds);
    bcd_min   = int_to_bcd(dt->minutes);
    bcd_hour  = int_to_bcd(dt->hours);
    bcd_dow   = int_to_bcd(dt->day_of_week);
    bcd_day   = int_to_bcd(dt->day);
    bcd_month = int_to_bcd(dt->month);
    bcd_year  = int_to_bcd(dt->year);

    // Ensure Clock Halt (CH) bit 7 is 0 to run the oscillator
    bcd_sec &= 0x7F;

    i2c_start();
    
    // Select DS1307 in Write Mode
    if (i2c_write(DS1307_ADDR_WRITE) != 0) {
        i2c_stop();
        return -1; // Bus error
    }
    
    // Start at register 0x00
    i2c_write(0x00); 
    
    // Write all 7 registers sequentially (internal address auto-increments)
    i2c_write(bcd_sec);   // 0x00
    i2c_write(bcd_min);   // 0x01
    i2c_write(bcd_hour);  // 0x02
    i2c_write(bcd_dow);   // 0x03
    i2c_write(bcd_day);   // 0x04
    i2c_write(bcd_month); // 0x05
    i2c_write(bcd_year);  // 0x06
    
    i2c_stop();
    return 0; // Success
}

int rtc_read_datetime(DateTimeData *dt) {
    unsigned char raw[7];
    int i, j;

    i2c_start();
    if (i2c_write(DS1307_ADDR_WRITE) != 0) {
        i2c_stop();
        return -1;
    }
    
    i2c_write(0x00); // Point to register 0x00
    
    i2c_start(); // Repeated start
    if (i2c_write(DS1307_ADDR_READ) != 0) {
        i2c_stop();
        return -1;
    }
    
    // Read the first 6 registers with ACK
    for (j = 0; j < 6; j++) {
        raw[j] = 0;
        set_sda(1); // Float input
        for (i = 0; i < 8; i++) {
            set_scl(1); i2c_delay();
            raw[j] = (raw[j] << 1) | read_sda();
            set_scl(0); i2c_delay();
        }
        // Send ACK
        set_sda(0); set_scl(1); i2c_delay(); set_scl(0); 
    }

    // Read the 7th register (Year) with NACK to end transmission
    raw[6] = 0;
    set_sda(1); 
    for (i = 0; i < 8; i++) {
        set_scl(1); i2c_delay();
        raw[6] = (raw[6] << 1) | read_sda();
        set_scl(0); i2c_delay();
    }
    // Send NACK
    set_sda(1); set_scl(1); i2c_delay(); set_scl(0); 
    
    i2c_stop();

    // Check Clock Halt bit
    if (raw[0] & 0x80) {
        return -2; // Clock is stopped
    }

    // Convert BCD values back to standard integers
    dt->seconds     = bcd_to_int(raw[0] & 0x7F);
    dt->minutes     = bcd_to_int(raw[1]);
    dt->hours       = bcd_to_int(raw[2] & 0x3F); // 24-hour mode masking
    dt->day_of_week = bcd_to_int(raw[3] & 0x07);
    dt->day         = bcd_to_int(raw[4] & 0x3F);
    dt->month       = bcd_to_int(raw[5] & 0x1F);
    dt->year        = bcd_to_int(raw[6]);

    return 0; // Success
}

void showDateTime(void)
{
    DateTimeData system_clock;
    int status;
    
    status = rtc_read_datetime(&system_clock);
    
    if (status == 0) 
    {
        mprintf("20%d-%d-%d %d:%d:%d (W: %d)\r", 
                system_clock.year, 
                system_clock.month, 
                system_clock.day,
                system_clock.hours, 
                system_clock.minutes, 
                system_clock.seconds,
                system_clock.day_of_week);
    } 
    else if (status == -1) 
    {
        mprintf("Bus Error: Communication failed.\r\n");
    } 
    else if (status == -2) 
    {
        mprintf("Warning: Oscillator is disabled.\r\n");
    }
}

/* -------------------------------------------------- */
/* MAIN                                               */
/* -------------------------------------------------- */
int main(void)
{
    MMSJ_KEYEVENT k;
    int key;
    DateTimeData system_clock;

    /*int i;

    for (i = 0; i < MAX_HOOKS; i++)
    {
        hookTable[i].magic = 0;
        hookTable[i].flags = 0;
        hookTable[i].addr = 0;
    }*/

    //mprintf("Iniciando Ethernet...\r\n");
    //ethStart();

    mprintf("Data e Hora DS1307...\r\n");

    // Setup GPIO
    *(vmfp + Reg_DDR) &= 0xC0; // I7 e I6 do not touoch, I5 - I0 - Input

    // Initialize the MC68901 MFP GPIO lines
    i2c_init();
    mprintf("Initializing 68000 RTC System...\r\n");

    // --- WRITE NEW TIME ONCE TO START CLOCK ---
    // Example setting the clock to 14:30:00 (2:30 PM)
    // Configure a complete starting timestamp (Example: Monday, June 8, 2026 at 10:25:00)
    system_clock.hours       = 10;
    system_clock.minutes     = 25;
    system_clock.seconds     = 0;
    system_clock.day_of_week = 2;  // 2 = Monday
    system_clock.day         = 8;  // 8th
    system_clock.month       = 6;  // June
    system_clock.year        = 26; // 2026

    mprintf("Programming Date and Time to RTC module...\r\n");
    if (rtc_set_datetime(&system_clock) == 0) {
        mprintf("RTC Successfully updated and running!\r\n");
    } else {
        mprintf("Error writing to RTC hardware.\n");
    }

    // Inicializa o MFP e configura o pino SQW para 1Hz
    mprintf("Inicializando sistema e ativando SQW (1Hz)...\r\n");
    if (rtc_init_with_sqw() == 0) {
        mprintf("Pino SQW configurado com sucesso!\r\n");
    } else {
        mprintf("Erro ao configurar pino SQW.\r\n");
    }
    
    *(vmfp + Reg_IMRB) &= (unsigned char)~MFP_GPIO2;
    *(vmfp + Reg_IERB) &= (unsigned char)~MFP_GPIO2;

    netHookTable[HOOK_GPIO2].addr   = &showDateTime;
    netHookTable[HOOK_GPIO2].flags  = HOOKF_ACTIVE | HOOKF_SKIP_OS;
    netHookTable[HOOK_GPIO2].magic  = HOOK_MAGIC;

    *(vmfp + Reg_IERB) |= MFP_GPIO2;
    *(vmfp + Reg_IMRB) |= MFP_GPIO2;
    
    // Infinite loop checking the time
    while(1) {
        key = KEY_NONE;
        
        if (mmsjKeyGet(&k))
        {
            key = k.ascii;
        }

        if (key == 0x1B)    // ESC
            break;
    }

    *(vmfp + Reg_IMRB) &= (unsigned char)~MFP_GPIO2;
    *(vmfp + Reg_IERB) &= (unsigned char)~MFP_GPIO2;

    netHookTable[HOOK_GPIO2].magic  = 0x00;
    netHookTable[HOOK_GPIO2].addr   = 0x00;
    netHookTable[HOOK_GPIO2].flags  = 0x00;

    mprintf("Fim...\r\n");

    /*mprintf("Instalando hooks...\r\n");

    installHook(HOOK_TIMER_BEFORE, myTimerBefore);
    installHook(HOOK_TIMER_AFTER, myTimerAfter);

    installHook(HOOK_KEYBOARD_BEFORE, myKeyboardBefore);
    installHook(HOOK_KEYBOARD_AFTER, myKeyboardAfter);

    mprintf("--- Simulando interrupcao TIMER ---\r\n");
    IntTimer();

    mprintf("--- Simulando interrupcao KEYBOARD ---\r\n");
    IntKeyboard();*/

    return 0;
}