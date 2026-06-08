#ifndef TESTES_H
#define TESTES_H

// Pin Masks for I/O Port
#define SDA_PIN         (1 << 0) // P0
#define SCL_PIN         (1 << 1) // P1

#define DS1307_ADDR_WRITE 0xD0 // (0x68 << 1) | 0
#define DS1307_ADDR_READ  0xD1 // (0x68 << 1) | 1
#define DS1307_REG_CONTROL  0x07

#define MFP_PDR         (*(vmfp + Reg_GPDR)) // Port Data Register
#define MFP_DDR         (*(vmfp + Reg_DDR)) // Data Direction Register

#define MFP_GPIO2 0x04

typedef struct {
    int seconds;
    int minutes;
    int hours;
    int day_of_week; // 1 = Sunday, 2 = Monday, etc.
    int day;         // Day of the month (1-31)
    int month;       // Month (1-12)
    int year;        // Year (0-99, e.g., 26 for 2026)
} DateTimeData;

typedef struct
{
    unsigned long magic;
    unsigned long flags;
    void (*addr)(void);
} NET_HOOK;

void i2c_init(void);
void i2c_start(void);
void i2c_stop(void);
int i2c_write(unsigned char byte);
void i2c_delay(void);
int read_sda(void);
void set_scl(int high);
void set_sda(int high);
unsigned char int_to_bcd(int val);
int bcd_to_int(unsigned char bcd);
int rtc_set_datetime(DateTimeData *dt);
int rtc_read_datetime(DateTimeData *dt);

#endif

