// Projeto para Criar / Ler Arquivos .txt junto ao Cartão SD Arduino
// Visite nossa loja através do link www.usinainfo.com.br
// Mais projetos em www.www.usinainfo.com.br/blog/</pre>


/*

  Listfiles

  This example shows how print out the files in a

  directory on a SD card.Pin numbers reflect the default

  SPI pins for Uno and Nano models

  The circuit:

   SD card attached to SPI bus as follows:

 ** SDO - pin 11

 ** SDI - pin 12

 ** CLK - pin 13

 ** CS - depends on your SD card shield or module.

        Pin 10 used here for consistency with other Arduino examples

    (for MKRZero SD: SDCARD_SS_PIN)

  created   Nov 2010

  by David A. Mellis

  modified 9 Apr 2012

  by Tom Igoe

  modified 2 Feb 2014

  by Scott Fitzgerald

  modified 24 July 2020

  by Tom Igoe



  This example code is in the public domain.

*/

#include <SD.h>
#include <SPI.h>

Sd2Card card;
File myFile;

#define INOUT_D0      A0  // PC0
#define INOUT_D1      A1  // PC1
#define INOUT_D2      A2  // PC2
#define INOUT_D3      A3  // PC3
#define INOUT_D4      4   // PD4
#define INOUT_D5      5   // PD5
#define INOUT_D6      6   // PD6
#define INOUT_D7      7   // PD7
#define IN_CS         2   // PD2
#define IN_RW         3   // PD3
#define IN_A1         A4  // PC4
#define OUT_DTACK     A5  // PC5
#define IN_A2         8   // PB0

#define ALL_OK                0x00
#define ERRO_B_START          0xE0
#define ERRO_B_FILE_NOT_FOUND 0xE0
#define ERRO_B_READ_DISK      0xE1
#define ERRO_B_WRITE_DISK     0xE2
#define ERRO_B_OPEN_DISK      0xE3
#define ERRO_B_DIR_NOT_FOUND  0xE5
#define ERRO_B_CREATE_FILE    0xE6
#define ERRO_B_APAGAR_ARQUIVO 0xE7
#define ERRO_B_FILE_FOUND     0xE8
#define ERRO_B_UPDATE_DIR     0xE9
#define ERRO_B_OFFSET_READ    0xEA
#define ERRO_B_DISK_FULL      0xEB
#define ERRO_B_READ_FILE      0xEC
#define ERRO_B_WRITE_FILE     0xED
#define ERRO_B_DIR_FOUND      0xEE
#define ERRO_B_CREATE_DIR     0xEF
#define ERRO_B_NOT_FOUND      0xFF

//#define __DEBUG_CMD__ 1
//#define __DEBUG_DATA__ 1

int pinoSS = 10; // Pin 53 para Mega / Pin 10 para UNO
/*** SDO - pin 11 **
  ** SDI - pin 12 **
  ** CLK - pin 13 ***/

unsigned char databuffer[512];
unsigned char dataCmd[8];
int countDump, qtdDump, offset, qtdf;
long cluster;
char cmd, n, nd;

/*---------------------------------------------------------------------------*/
void setup() 
{ 
    DDRC &= 0b11110000; // PC0-3 All inputs
    DDRD &= 0b00001111; // PD4-7 All inputs

    pinMode(IN_A1,INPUT);   // 0 = Comando / 1 = Data
    pinMode(IN_A2,INPUT);   // Quando A1 = 0:: 0 = Comando / 1 = Param do Comando
    pinMode(IN_RW,INPUT);   // 1 = Leitura / 0 = Escrita
    pinMode(IN_CS,INPUT);   // 0 = Enable Comm / 1 = Disable Comm

    pinMode(OUT_DTACK,INPUT);
    digitalWrite(OUT_DTACK,HIGH);
    pinMode(OUT_DTACK,OUTPUT);

    Serial.begin(9600); // Define BaundRate
    pinMode(pinoSS, OUTPUT); // Declara pinoSS como saída
    
    if (card.init(SPI_HALF_SPEED, pinoSS)) { // Inicializa o SD Card
        #if defined(__DEBUG_CMD__)
            Serial.println("SD Card pronto para uso."); // Imprime na tela
        #endif
    }
    
    else {
        #if defined(__DEBUG_CMD__)
            Serial.println("Falha na inicialização do SD Card.");
        #endif
    
        return;
    }

    if (SD.begin(pinoSS)) 
    {
        #if defined(__DEBUG_CMD__)
            Serial.println("initialization done.");
        #endif
    }
    else
    {
        #if defined(__DEBUG_CMD__)
            Serial.println("initialization failed!");
        #endif
    }
    
    n = 0;
    nd = 0;

    delay(1000);
}

/*---------------------------------------------------------------------------*/
void loop() {
    processComm();
}
 
/*---------------------------------------------------------------------------
 * Comandos:
            Enviar os dados antes depois enviar um dos comandos abaixo
 *      r: r
 *          Ler <cluster [4 Bytes]> com o <offset [2 Bytes]> e a <qtd [2 Bytes]> 
 *          previamente enviados como parametros
 *      w: w
 *          Gravar em <cluster [4 Bytes]> previamente enviados como parametros com
 *          os dados previamente enviados no modo dados
 *---------------------------------------------------------------------------*/
void processComm()
{
    uint8_t vResp;

    cmd = ' ';

    if (!(PIND & 0b00000100)) // CPU coloca 0 no CS
    {
        __asm__("nop");

        if (!(PIND & 0b00001000))  // Escrita
        {
            n++;

            if (!(PINC & 0b00010000))   // Comando
            {
                if (!(PINB & 0b00000001))   // Receber Comando
                    cmd = recByte();
                else                        // Receber Param do Comando
                {
                    if (nd < 8)
                        dataCmd[nd++] = recByte();
                }
            }
            else                        // Data
            {
                if (countDump > qtdDump)
                    countDump = qtdDump;

                databuffer[countDump++] = recByte(); 

                return;
            }
        }
        else                        // Leitura
        {
            if (!(PINC & 0b00010000))   // Comando
            {
                if (nd < 8)
                    sendByte(dataCmd[nd++]);
            }
            else                        // Data
            {
                if (countDump > qtdDump)
                    countDump = qtdDump;

                sendByte(databuffer[countDump++]); 
            }

            return;
        }

        if (n > 0 && cmd != ' ')
        {       
            #if defined(__DEBUG_CMD__)
                Serial.print("**");
                Serial.print(cmd);
                Serial.println("**");
            #endif

            n = 0;
            cmd = tolower(cmd);

            switch (cmd)
            {
                case 'a':   // Abort all
                    sendByteFull(ALL_OK);

                    nd = 0;
                    countDump = 0;
                    qtdDump = 512;

                    break;
                case 'r':   // Read Cluster
                    sendByteFull(ALL_OK);

                    cluster  = (((long)dataCmd[0] << 24) & 0xFF000000);
                    cluster |= (((long)dataCmd[1] << 16) & 0x00FF0000);
                    cluster |= (((long)dataCmd[2] << 8) & 0x0000FF00);
                    cluster |= ((long)dataCmd[3] & 0x000000FF);

                    offset   = (((int)dataCmd[4] << 8) & 0xFF00);
                    offset  |= ((int)dataCmd[5] & 0x00FF);

                    qtdf     = (((int)dataCmd[6] << 8) & 0xFF00);
                    qtdf    |= ((int)dataCmd[7] & 0x00FF);

                    #if defined(__DEBUG_CMD__)
                        Serial.print("##");
                        Serial.print(cluster);
                        Serial.print(':');
                        Serial.print(offset);
                        Serial.print(':');
                        Serial.print(qtdf);
                        Serial.println("##");
                    #endif

                    vResp = card.readData(cluster, offset, qtdf, databuffer);
        
                    if (vResp) 
                    {
                        #if defined(__DEBUG_CMD__)
                            Serial.println("##OK_0##");
                        #endif

                        sendByteFull(ALL_OK);

                        #if defined(__DEBUG_CMD__)
                            Serial.println("##OK_1##");
                        #endif

                        countDump = 0;
                        qtdDump = qtdf;
                    }       
                    else
                        sendByteFull(ERRO_B_READ_DISK);

                    break;
                case 'w':   // Write Cluster
                    sendByteFull(ALL_OK);

                    cluster  = (((long)dataCmd[0] << 24) & 0xFF000000);
                    cluster |= (((long)dataCmd[1] << 16) & 0x00FF0000);
                    cluster |= (((long)dataCmd[2] << 8) & 0x0000FF00);
                    cluster |= ((long)dataCmd[3] & 0x000000FF);

                    vResp = card.writeBlock(cluster, databuffer, 0);

                    if (vResp) 
                        sendByteFull(ALL_OK);
                    else
                        sendByteFull(ERRO_B_WRITE_DISK);

                    break;     
            case 's':   // Send SO File to host
                sendByteFull(ALL_OK);

                myFile = SD.open("mmsjos.sys");
    
                if (myFile) 
                {
                    sendByteFull(ALL_OK);

                    countDump = 0;
                    qtdDump = myFile.read(databuffer, 512);
                    nd = 0;
                    dataCmd[0] = ((qtdDump >> 8) & 0xFF);
                    dataCmd[1] = (qtdDump & 0xFF);
                }       
                else
                    sendByteFull(ERRO_B_FILE_NOT_FOUND);

                break;                    
            case 't':   // Continue Reading SO File
                sendByteFull(ALL_OK);

                if (myFile.available())
                {
                    sendByteFull(ALL_OK);

                    countDump = 0;
                    qtdDump = myFile.read(databuffer, 512);
                    nd = 0;
                    dataCmd[0] = ((qtdDump >> 8) & 0xFF);
                    dataCmd[1] = (qtdDump & 0xFF);        
                
                    if (qtdDump < 512)
                        myFile.close(); // Fecha o Arquivo após ler                
                }
                else
                {
                    nd = 0;
                    dataCmd[0] = 0;
                    dataCmd[1] = 0;
                    myFile.close(); // Fecha o Arquivo após ler                
                }

                break;
            }
        }
    }
}

/*---------------------------------------------------------------------------*/
void sendByte(unsigned char vByte)
{
    //Serial.println("Send---");
    __asm__("nop");
    __asm__("nop");

    DDRC |= 0b00001111; // PC0 - PC3 como Saida
    DDRD |= 0b11110000; // PD4 - PD7 como Saida

    __asm__("nop");
    __asm__("nop");

    PORTC = (PORTC & 0xF0) | (vByte & 0x0F); // Coloca LSB
    PORTD = (PORTD & 0x0F) | (vByte & 0xF0); // Coloca MSB

    PORTC &= 0b11011111;  // Libera CPU pra ler DTACK = 0

    while (!(PIND & 0b00000100)); // Aguarda CPU colocar 1 no CS indicando que já leu

    DDRC &= 0b11110000; // PC0 - PC3 como Entrada
    DDRD &= 0b00001111; // PD4 - PD7 como Entrada

    __asm__("nop");
    __asm__("nop");

    PORTC |= 0b00100000;   // Desabilita Sinal DTACK = 1

    __asm__("nop");
    __asm__("nop");
}

/*---------------------------------------------------------------------------*/
void sendByteFull(unsigned char vByte)
{
    //Serial.println("Send---");
    while (PIND & 0b00000100); // Aguarda CPU colocar 0 no CS Para vir ler

    __asm__("nop");
    __asm__("nop");

    if (PIND & 0b00001000)  // Se for Leitura
    {
        DDRC |= 0b00001111; // PC0 - PC3 como Saida
        DDRD |= 0b11110000; // PD4 - PD7 como Saida

        __asm__("nop");
        __asm__("nop");

        PORTC = (PORTC & 0xF0) | (vByte & 0x0F); // Coloca LSB
        PORTD = (PORTD & 0x0F) | (vByte & 0xF0); // Coloca MSB
    }

    PORTC &= 0b11011111;  // Libera CPU pra ler DTACK = 0

    while (!(PIND & 0b00000100)); // Aguarda CPU colocar 1 no CS indicando que já leu

    DDRC &= 0b11110000; // PC0 - PC3 como Entrada
    DDRD &= 0b00001111; // PD4 - PD7 como Entrada

    __asm__("nop");
    __asm__("nop");

    PORTC |= 0b00100000;   // Desabilita Sinal DTACK = 1

    __asm__("nop");
    __asm__("nop");
}

/*---------------------------------------------------------------------------*/
int recByte()
{
    unsigned char vByte;

    #if defined(__DEBUG_DATA__)
        Serial.println("Rec---");
    #endif

    __asm__("nop");
    __asm__("nop");
    __asm__("nop");
    __asm__("nop");

    vByte  = PINC & 0x0F; // Recebe LSB
    vByte |= PIND & 0xF0; // Recebe MSB

    PORTC &= 0b11011111;  // Libera CPU pra ler DTACK = 0

    while (!(PIND & 0b00000100)); // Aguarda CPU colocar 1 no CS indicando que já leu

    __asm__("nop");
    __asm__("nop");
    __asm__("nop");
    __asm__("nop");

    PORTC |= 0b00100000;   // Desabilita Sinal DTACK = 1

    __asm__("nop");
    __asm__("nop");
    __asm__("nop");
    __asm__("nop");

    #if defined(__DEBUG_DATA__)
        Serial.println(i);
        Serial.println(vByte);
    #endif

    return vByte;
}
