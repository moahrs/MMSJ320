#include <PS2KeyAdvanced.h>

/* PS/2 (fora do barramento D0-D7 / PB0-PB3) */
const int KbdData = 12;
const int KbdClk  = 3;
const int MseClk  = 2;
const int MseData = A5;

/* Barramento 68000 (mapa AT89C51) */
#define PIN_INT_MSE  A0   /* PC0 - INT mouse */
#define PIN_INT_KBD  A1   /* PC1 - INT teclado */
#define PIN_RW       A2   /* R/W: 1=leitura, 0=escrita */
#define PIN_CS       A3   /* CS ativo em 0 */
#define PIN_UDS      13   /* D13 — UDS ativo em 0; barramento só com CS=0 e UDS=0 */
#define PIN_DTACK    A4   /* DTACK: 1=ocioso, 0=ciclo ok */

#define DATA_D0  8    // PB0
#define DATA_D1  9    // PB1
#define DATA_D2  10   // PB2
#define DATA_D3  11   // PB3
#define DATA_D4  4    // PD4
#define DATA_D5  5    // PD5
#define DATA_D6  6    // PD6
#define DATA_D7  7    // PD7

#define DEV_KBD  1
#define DEV_MSE  2

#define QUEUE_SIZE 64

PS2KeyAdvanced keyboard;

typedef struct
{
    unsigned char normal;
    unsigned char shift;
} TKeyMap;

TKeyMap keyMapABNT2[256];

#define PS2_SHIFT    0x4000
#define PS2_CTRL     0x2000
#define PS2_CAPS     0x1000
#define PS2_ALT      0x0800
#define PS2_ALT_GR   0x0400
#define PS2_FUNCTION 0x0100
#define PS2_KEYUP    0x8000
#define PS2_RELEASE  0x8000
#define K_RAW_FLAG   0x8000

unsigned char queueData[QUEUE_SIZE];
unsigned char queueDev[QUEUE_SIZE];
int queueHead = 0;
int queueTail = 0;
int queueCount = 0;

char busIntArmed = 0;
char busIntActive = 0;

volatile unsigned char hostWriteByte = 0;
volatile char hostWritePending = 0;

int c;
volatile char mseDataAvailable;
volatile int dataMse, xmvmt, ymvmt;
long int vtimeoutmouseaux = 0xFFF;
unsigned long vTimeOutCpuReadAux = 0xFFF;
char hasmouseaux = 1;

char queuePush(unsigned char dev, unsigned char b);
void serviceBusRead(void);
void serviceBusWrite(void);
void queuePushKey(unsigned int key);

//----------------------------------------------------
char queuePush(unsigned char dev, unsigned char b)
{
  int next;

  if (queueCount >= QUEUE_SIZE)
    return 0;

  queueData[queueTail] = b;
  queueDev[queueTail] = dev;
  next = queueTail + 1;
  if (next >= QUEUE_SIZE)
    next = 0;
  queueTail = next;
  queueCount++;

  if (!busIntArmed && queueCount > 0 && ((PINC & 0x03) == 0x03))
  {
    busIntActive = queueDev[queueHead];
    busIntArmed = 1;

    if (busIntActive == DEV_KBD)
      PORTC = (unsigned char)((PORTC & ~(unsigned char)0x03) | 0x01); /* Mouse=1 PC0, Key=0 PC1 */
    else
      PORTC = (unsigned char)((PORTC & ~(unsigned char)0x03) | 0x02); /* Mouse=0, Key=1 */

    vTimeOutCpuReadAux = 0xFFF;
  }

  return 1;
}

//----------------------------------------------------
/* 1 byte por interrupcao; so atende se INT ja estiver armada */
void serviceBusRead(void)
{
  unsigned char b;
  int next;

  noInterrupts();

  if (!busIntArmed || queueCount == 0)
    return;

  if (busIntActive == DEV_KBD)
  {
    if (PINC & 0x02)
      return;
  }
  else if (busIntActive == DEV_MSE)
  {
    if (PINC & 0x01)
      return;
  }
  else
    return;

  PORTC |= 0x03; // PC0/PC1 INT high

  b = queueData[queueHead];

  /* INT deve permanecer ativo ate o dado sair e o CS subir; senao o MFP/CPU perdem o enquadramento. */
  __asm__("nop");
  __asm__("nop");

  DDRB |= 0b00001111; // PB0-PB3 como Saida
  DDRD |= 0b11110000; // PD4-PD7 como Saida

  __asm__("nop");
  __asm__("nop");

  PORTB = (PORTB & 0xF0) | (b & 0x0F);
  PORTD = (PORTD & 0x0F) | (b & 0xF0);

  PORTC &= 0b11101111; // DTACK = 0

  while (!(PINC & 0x08));  // Enquanto CS Ativo

  DDRB &= 0b11110000; // PB0-PB3 como Entrada
  DDRD &= 0b00001111; // PD4-PD7 como Entrada

  __asm__("nop");
  __asm__("nop");

  PORTC |= 0b00010000; // DTACK = 1

  __asm__("nop");
  __asm__("nop");

  next = queueHead + 1;
  if (next >= QUEUE_SIZE)
    next = 0;
  queueHead = next;
  queueCount--;

  busIntArmed = 0;
  busIntActive = 0;

  if (queueCount > 0 && ((PINC & 0x03) == 0x03))
  {
    busIntActive = queueDev[queueHead];
    busIntArmed = 1;

    if (busIntActive == DEV_KBD)
      PORTC = (unsigned char)((PORTC & ~(unsigned char)0x03) | 0x01); /* Mouse=1 PC0, Key=0 PC1 */
    else
      PORTC = (unsigned char)((PORTC & ~(unsigned char)0x03) | 0x02); /* Mouse=0, Key=1 */

    vTimeOutCpuReadAux = 0xFFF;
  }

  interrupts();
}

//----------------------------------------------------
void serviceBusWrite(void)
{
  noInterrupts();

  __asm__("nop");
  __asm__("nop");

  DDRB &= 0b11110000; // PB0-PB3 como Entrada
  DDRD &= 0b00001111; // PD4-PD7 como Entrada

  __asm__("nop");
  __asm__("nop");

  hostWriteByte = (PINB & 0x0F) | (PIND & 0xF0);
  hostWritePending = 1;

  __asm__("nop");
  __asm__("nop");

  PORTC &= 0b11101111; // DTACK = 0

  while (!(PINC & 0x08));

  __asm__("nop");
  __asm__("nop");

  PORTC |= 0b00010000; // DTACK = 1

  __asm__("nop");
  __asm__("nop");

  interrupts();  
}

//----------------------------------------------------
void queuePushKey(unsigned int key)
{
  if (key > 0x00 && key <= 0xFF)
  {
    queuePush(DEV_KBD, (unsigned char)key);
  }
  else
  {
    queuePush(DEV_KBD, 0xEF);
    queuePush(DEV_KBD, (unsigned char)(key >> 8));
    queuePush(DEV_KBD, (unsigned char)(key & 0xFF));
  }
}

//----------------------------------------------------
void ps2mseinterrupt(void)
{
  int timeout = 0xFF;

  if (!digitalRead(MseData))
  {
    while (digitalRead(MseData) && --timeout)
      ;
    dataMse = readMsePs2();
    timeout = 0xFF;
    while (digitalRead(MseData) && --timeout)
      ;
    xmvmt = readMsePs2();
    timeout = 0xFF;
    while (digitalRead(MseData) && --timeout)
      ;
    ymvmt = readMsePs2();

    mseDataAvailable = 1;
  }
}

//----------------------------------------------------
void setup()
{
  __asm__("nop");
  __asm__("nop");

  DDRB &= 0b11010000;  // PB0-PB3 dados entrada, PB5/UDS entrada
  DDRD &= 0b00001111;  // PD4-PD7 dados entrada

  PORTB &= 0b11010000; // Sem pull-up nos dados e UDS

  PORTC = (unsigned char)((PORTC & 0b11100000) | 0b00010011); // PC0/PC1 INT high, PC4 DTACK high
  DDRC  = (unsigned char)((DDRC  & 0b11100000) | 0b00010011); // PC0, PC1, PC4 saida; PC2/RW, PC3/CS entrada

  pinMode(MseClk, INPUT);
  pinMode(MseData, INPUT);

  Serial.begin(115200);

  delay(1000);
  writeMsePS2(0xFF);

  if (vtimeoutmouseaux <= 0)
    hasmouseaux = 0;

  if (hasmouseaux)
  {
    dataMse = readMsePs2();
    dataMse = readMsePs2();
    dataMse = readMsePs2();

    writeMsePS2(0xF4);
    dataMse = readMsePs2();

    mseDataAvailable = 0;
  }

  delay(1000);
  initKeyMapABNT2();
  keyboard.begin(KbdData, KbdClk);
  keyboard.setNoRepeat(1);

  if (hasmouseaux)
    attachInterrupt(digitalPinToInterrupt(MseClk), ps2mseinterrupt, FALLING);
}

//----------------------------------------------------
void loop()
{
  int key;

  if (busIntArmed)
  {
    if (!--vTimeOutCpuReadAux)
    {
      PORTC |= 0x03;
      busIntArmed = 0;
      busIntActive = 0;

      if (queueCount > 0 && ((PINC & 0x03) == 0x03))
      {
        busIntActive = queueDev[queueHead];
        busIntArmed = 1;

        if (busIntActive == DEV_KBD)
          PORTC = (unsigned char)((PORTC & ~(unsigned char)0x03) | 0x01);
        else
          PORTC = (unsigned char)((PORTC & ~(unsigned char)0x03) | 0x02);

        vTimeOutCpuReadAux = 0xFFF;
      }
    }
  }

  if ((!(PINC & 0x08)) && (!(PINB & 0x20)) && (PINC & 0x04) && busIntArmed)
    serviceBusRead();

  if ((!(PINC & 0x08)) && (!(PINB & 0x20)) && (!(PINC & 0x04)))
    serviceBusWrite();

  if (keyboard.available())
  {
    c = keyboard.read();
    key = ps2ToAsciiABNT2(c);

    if (key != 0x00)
    {
      queuePushKey(key);
    }
  }

  if (mseDataAvailable)
  {
    mseDataAvailable = 0;

    dataMse = (dataMse & 0b00111111110) >> 1;

    xmvmt = (xmvmt & 0b00111111110) >> 1;
    if ((dataMse & 0b00010000) >> 4)
      xmvmt = -((~xmvmt & 0b11111111) + 1);

    ymvmt = (ymvmt & 0b00111111110) >> 1;
    if ((dataMse & 0b00100000) >> 5)
      ymvmt = -((~ymvmt & 0b11111111) + 1);

    queuePush(DEV_MSE, (unsigned char)dataMse);
    queuePush(DEV_MSE, (unsigned char)xmvmt);
    queuePush(DEV_MSE, (unsigned char)ymvmt);
  }
}

//----------------------------------------------------
unsigned long int readMsePs2()
{
  unsigned long int b = 0;
  int timeoutread = 0xFF;

  for (int i = 0; i < 11; i++)
  {
    timeoutread = 0xFF;
    while (digitalRead(MseClk) == HIGH)
    {
    }

    b += (digitalRead(MseData) << i);

    timeoutread = 0xFF;
    while (digitalRead(MseClk) == LOW)
    {
    }
  }

  if (!timeoutread)
    b = 0;

  return b;
}

//----------------------------------------------------
void writeMsePS2(byte Data)
{
  vtimeoutmouseaux = 0xFFF;

  pinMode(MseClk, OUTPUT);
  digitalWrite(MseClk, LOW);
  delayMicroseconds(200);

  pinMode(MseData, OUTPUT);
  digitalWrite(MseData, LOW);
  delayMicroseconds(50);

  pinMode(MseClk, INPUT);

  while (digitalRead(MseClk) && vtimeoutmouseaux-- > 0)
  {
  }

  if (vtimeoutmouseaux <= 0)
    return;

  int pairck = 0;
  for (int i = 0; i < 8; i++)
  {
    digitalWrite(MseData, (Data & (1 << i)) >> i);
    pairck += ((Data & (1 << i)) >> i);
    while (digitalRead(MseClk) == LOW)
    {
    }
    while (digitalRead(MseClk) == HIGH)
    {
    }
  }

  if (pairck % 2 == 0)
    digitalWrite(MseData, HIGH);
  else
    digitalWrite(MseData, LOW);

  while (digitalRead(MseClk) == LOW)
  {
  }
  while (digitalRead(MseClk) == HIGH)
  {
  }

  pinMode(MseData, INPUT);
  while (digitalRead(MseData) == HIGH)
  {
  }
  while (digitalRead(MseClk) == HIGH)
  {
  }

  while (digitalRead(MseData) == LOW)
  {
  }
  while (digitalRead(MseClk) == LOW)
  {
  }
}

//----------------------------------------------------
void setKeyMap(unsigned char key, unsigned char normal, unsigned char shift)
{
  keyMapABNT2[key].normal = normal;
  keyMapABNT2[key].shift = shift;
}

//----------------------------------------------------
void initKeyMapABNT2(void)
{
  int i;

  for (i = 0; i < 256; i++)
  {
    keyMapABNT2[i].normal = 0;
    keyMapABNT2[i].shift = 0;
  }

  setKeyMap('1', '1', '!');
  setKeyMap('2', '2', '@');
  setKeyMap('3', '3', '#');
  setKeyMap('4', '4', '$');
  setKeyMap('5', '5', '%');
  setKeyMap('6', '6', '^');
  setKeyMap('7', '7', '&');
  setKeyMap('8', '8', '*');
  setKeyMap('9', '9', '(');
  setKeyMap('0', '0', ')');

  setKeyMap(0x3C, '-', '_');
  setKeyMap(0x5F, '=', '+');
  setKeyMap(0x3B, ',', '<');
  setKeyMap(0x3D, '.', '>');
  setKeyMap(0x91, '/', '?');
  setKeyMap(0x3E, ';', ':');
  setKeyMap(0x40, '\'', '"');
  setKeyMap(0x5E, '[', '{');
  setKeyMap(0x5C, ']', '}');
  setKeyMap(0x8B, '\\', '|');
  setKeyMap(0x5D, '´', '`');
  setKeyMap(0x5B, 0x87, 0x80);
  setKeyMap(0x3A, '~', '^');
  setKeyMap(0x3A, '~', '^');
  setKeyMap(0x3A, '~', '^');

  setKeyMap(0x1F, ' ', ' ');
  setKeyMap(0x1E, 13, 13);
  setKeyMap(0x1B, 27, 27);
  setKeyMap(0x1C, 8, 8);
  setKeyMap(0x1A, 127, 127);
  setKeyMap(0x19, 0x11, 0x11);
  setKeyMap(0x1D, 9, 9);
  setKeyMap(0x11, 2, 2);
  setKeyMap(0x13, 0x12, 0x12);
  setKeyMap(0x14, 0x13, 0x13);
  setKeyMap(0x12, 3, 3);

  setKeyMap(0x17, 17, 17);
  setKeyMap(0x18, 19, 19);
  setKeyMap(0x15, 18, 18);
  setKeyMap(0x16, 20, 20);
}

//----------------------------------------------------
unsigned int ps2ToAsciiABNT2(unsigned int k)
{
  unsigned char ch;
  unsigned char out;
  int shift;
  int caps;

  if (k & PS2_RELEASE)
    return 0;

  ch = (unsigned char)(k & 0x00FF);

  if (ch == 0)
    return 0;

  if ((k & PS2_FUNCTION) && ch >= 0x61 && ch <= 0x6C)
    return k & 0x01FF;

  shift = (k & PS2_SHIFT) != 0;
  caps = (k & PS2_CAPS) != 0;

  if (k & (PS2_CTRL | PS2_ALT | PS2_ALT_GR))
    return k | K_RAW_FLAG;

  if (ch >= 'A' && ch <= 'Z')
  {
    if (shift ^ caps)
      return ch;
    else
      return ch + 32;
  }

  if (shift)
    out = keyMapABNT2[ch].shift;
  else
    out = keyMapABNT2[ch].normal;

  return out;
}
