#define pinMA0 22      // PA0
#define pinMA1 23      // PA1
#define pinMA2 24      // PA2
#define pinMA3 25      // PA3
#define pinMA4 26      // PA4
#define pinMA5 27      // PA5
#define pinMA6 28      // PA6
#define pinMA7 29      // PA7
#define pinMA8 37      // PC0
#define pinMA9 36      // PC1
#define pinMA10 35     // PC2

#define pinRAS0 53    // PB0
#define pinRAS2 52    // PB1
#define pinCAS0_2 51  // PB2
#define pinCAS1_3 50  // PB3
#define pinRAS1 41    // PG0
#define pinRAS3 40    // PG1
#define pinWE 49      // PL0

#define pinD0 A0    // PF0
#define pinD1 A1    // PF1
#define pinD2 A2    // PF2
#define pinD3 A3    // PF3
#define pinD4 A4    // PF4
#define pinD5 A5    // PF5
#define pinD6 A6    // PF6
#define pinD7 A7    // PF7
#define pinD8 A8    // PK0
#define pinD9 A9    // PK1
#define pinD10 A10  // PK2
#define pinD11 A11  // PK3
#define pinD12 A12  // PK4
#define pinD13 A13  // PK5
#define pinD14 A14  // PK6
#define pinD15 A15  // PK7

//#define __USE_INT__ Yes

unsigned long addrCount = 0x00;
unsigned int dataWrite = 0xFFFF;
unsigned int dataRead = 0x0000;
unsigned int dataRead1 = 0x0000;
unsigned int dataRead2 = 0x0000;
unsigned long timeIni = 0;

extern "C" void write_func();
extern "C" unsigned long read_func();
extern "C" void write_block_func(uint8_t bloco, uint16_t valor);
extern "C" unsigned long read_block_func(uint8_t bloco, uint16_t valor);
extern "C" void cbr_rfsh_func();
extern "C" void cbr_rfsh_func_unique_int();
extern "C" void cbr_rfsh_func_unique();
extern "C" void cbr_rfsh_func_start();

void setupRefreshTimer1()
{
    noInterrupts();

    TCCR1A = 0;
    TCCR1B = 0;
    TCNT1  = 0;

    /*
      Arduino Mega = 16 MHz
      Prescaler 8 = 2 MHz
      1 tick = 0,5 us

      Para 10 us:
      10 us / 0,5 us = 20 ticks
      OCR1A = 20 - 1 = 19
    */
    OCR1A = 19;

    TCCR1B |= (1 << WGM12);  // CTC
    TCCR1B |= (1 << CS11);   // prescaler 8

    TIMSK1 |= (1 << OCIE1A); // habilita interrupção Compare A

    interrupts();
}

ISR(TIMER1_COMPA_vect)
{
    //cbr_rfsh_func_unique_int();

    PORTL |= 0x01;   // WE high

    PORTB &= ~(1 << 2); // CAS0 low
    PORTB &= ~(1 << 3); // CAS1 low

    asm volatile("nop\nnop\n");

    PORTB &= ~(1 << 0); // RAS0 low

    asm volatile("nop\nnop\nnop\nnop\n");

    PORTB |= (1 << 0);  // RAS0 high

    asm volatile("nop\nnop\n");

    PORTB |= (1 << 2);  // CAS0 high
    PORTB |= (1 << 3);  // CAS1 high    
}

void setup() 
{
  pinMode(pinMA0, OUTPUT);
  pinMode(pinMA1, OUTPUT);
  pinMode(pinMA2, OUTPUT);
  pinMode(pinMA3, OUTPUT);
  pinMode(pinMA4, OUTPUT);
  pinMode(pinMA5, OUTPUT);
  pinMode(pinMA6, OUTPUT);
  pinMode(pinMA7, OUTPUT);
  pinMode(pinMA8, OUTPUT);
  pinMode(pinMA9, OUTPUT);
  pinMode(pinMA10, OUTPUT);

  pinMode(pinRAS0, OUTPUT);
  pinMode(pinRAS2, OUTPUT);
  pinMode(pinRAS1, OUTPUT);
  pinMode(pinRAS3, OUTPUT);
  pinMode(pinCAS0_2, OUTPUT);
  pinMode(pinCAS1_3, OUTPUT);
  pinMode(pinWE, OUTPUT);

  pinMode(pinD0, INPUT);
  pinMode(pinD1, INPUT);
  pinMode(pinD2, INPUT);
  pinMode(pinD3, INPUT);
  pinMode(pinD4, INPUT);
  pinMode(pinD5, INPUT);
  pinMode(pinD6, INPUT);
  pinMode(pinD7, INPUT);
  pinMode(pinD8, INPUT);
  pinMode(pinD9, INPUT);
  pinMode(pinD10, INPUT);
  pinMode(pinD11, INPUT);
  pinMode(pinD12, INPUT);
  pinMode(pinD13, INPUT);
  pinMode(pinD14, INPUT);
  pinMode(pinD15, INPUT);

  digitalWrite(pinMA0, LOW);
  digitalWrite(pinMA1, LOW);
  digitalWrite(pinMA2, LOW);
  digitalWrite(pinMA3, LOW);
  digitalWrite(pinMA4, LOW);
  digitalWrite(pinMA5, LOW);
  digitalWrite(pinMA6, LOW);
  digitalWrite(pinMA7, LOW);
  digitalWrite(pinMA8, LOW);
  digitalWrite(pinMA9, LOW);
  digitalWrite(pinMA10, LOW);

  digitalWrite(pinRAS0, HIGH);
  digitalWrite(pinRAS2, HIGH);
  digitalWrite(pinRAS1, HIGH);
  digitalWrite(pinRAS3, HIGH);
  digitalWrite(pinCAS0_2, HIGH);
  digitalWrite(pinCAS1_3, HIGH);
  digitalWrite(pinWE, HIGH);

  Serial.begin(115200);
  Serial.println("Ready...");

  // 100mS
  delay(100);
  
  // 100uS para inicializar a memoria
  delayMicroseconds(500);  

  // Min 8 ciclos de refresh antes de inciar a usar
  cbr_rfsh_func_start();

  setupRefreshTimer1();
}

void loop() 
{
  unsigned long vRet;
  unsigned long vStatus;
  uint16_t vData;

  Serial.println(" ");
  Serial.println("Testing Block's");

  for (uint8_t runaux = 0; runaux < 6; runaux++)
  {
    switch (runaux)
    {
      case 0:
        vData = 0x0000;
        break;
      case 1:
        vData = 0x5555;
        break;
      case 2:
        vData = 0xAAAA;
        break;
      case 3:
        vData = 0x00FF;
        break;
      case 4:
        vData = 0xFF00;
        break;
      case 5:
        vData = 0xFFFF;
        break;
    }

    for (uint8_t bloco = 0; bloco <= 127; bloco++)
    {
        Serial.print("Block: ");
        Serial.print(bloco, HEX);
        Serial.print("h ...Writing ");
        Serial.print(vData, HEX);
        Serial.print("h ");

        write_block_func(bloco, vData);
        //cbr_rfsh_func();

        Serial.print("...Reading ");
        unsigned long ret = read_block_func(bloco, vData);

        uint8_t status = ret & 0xFF;
        uint8_t dadoLow = (ret >> 8) & 0xFF;
        uint8_t dadoHigh = (ret >> 16) & 0xFF;
        uint8_t blocoErro = (ret >> 24) & 0xFF;

        if (status == 0xEE)
        {
            unsigned int dadoLido = ((unsigned int)dadoHigh << 8) | dadoLow;

            Serial.print("...Erro bloco: ");
            Serial.print(blocoErro, HEX);

            Serial.print(" ...Dado lido: ");
            Serial.println(dadoLido, HEX);
            //break;
        }
        else
          Serial.println("...Done ");

        cbr_rfsh_func();
    }
  }
/*
  Serial.println("Writing...");
  write_func();

  Serial.println("Reading...");
  vRet = read_func();
  Serial.print("Retorno Reading: ");
  Serial.println(vRet, HEX);
  vStatus = vRet & 0x000000FF;
  vRet = vRet >> 8;

  if (!vStatus)
  {
    Serial.print("Error... Addr: ");
    Serial.println(vRet, HEX);
  }
  else
    Serial.println("Success...");

  Serial.println("Finish...");
*/

  for(;;);
}
