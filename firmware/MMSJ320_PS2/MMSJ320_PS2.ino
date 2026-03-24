#include <PS2Keyboard.h>

const int KbdData = 8;
const int KbdClk =  3;
const int MseClk = 2;
const int MseData = 10;

#define OUT_D4    4   // PD4
#define OUT_D5    5   // PD5
#define OUT_D6    6   // PD6
#define OUT_D7    7   // PD7
#define OUT_RDYM  A0  // PC0
#define OUT_RDYK  A1  // PC1
#define OUT_ACK   A2  // PC2
#define IN_CS     A3  // PC3

#define OUT_YEL   11
#define OUT_RED   12
#define OUT_GRE   A5
#define OUT_RED2  A4

PS2Keyboard keyboard;

unsigned char vBufferKey[16] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
unsigned char vBufferMse[60] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
int vCountK = 0, vCountM = 0, c;
char ix;
char mseDataAvailablePend, kbdDataAvailablePend;
unsigned char vMove;
unsigned char stqtam[10];
volatile char mseDataAvailable;
volatile int dataMse, xmvmt, ymvmt;
long int vtimeoutmouseaux = 0xFFF;
unsigned long vTimeOutCpuReadAux = 0xFFF;
char hasmouseaux = 1;

//----------------------------------------------------
// The ISR for the external interrupt Mouse
//----------------------------------------------------
void ps2mseinterrupt(void)
{
  int timeout = 0xFF;
    //Serial.println("A");
    digitalWrite(OUT_RED,HIGH);
  if (!digitalRead(MseData))
  {
    digitalWrite(OUT_GRE,HIGH);
    //Serial.println("Z");
    while (digitalRead(MseData) && --timeout);
    dataMse = readMsePs2();
    timeout = 0xFF;
    while (digitalRead(MseData) && --timeout);
    xmvmt = readMsePs2();
    timeout = 0xFF;
    while (digitalRead(MseData) && --timeout);
    ymvmt = readMsePs2();

    mseDataAvailable = 1;
    digitalWrite(OUT_GRE,LOW);
  }
    digitalWrite(OUT_RED,LOW);
}

//----------------------------------------------------
// Initialization
//----------------------------------------------------
void setup() 
{
  pinMode(OUT_YEL,OUTPUT);
  digitalWrite(OUT_YEL,HIGH);
  pinMode(OUT_RED,OUTPUT);
  digitalWrite(OUT_RED,HIGH);
  pinMode(OUT_GRE,OUTPUT);
  digitalWrite(OUT_GRE,HIGH);
  pinMode(OUT_RED2,OUTPUT);
  digitalWrite(OUT_RED2,HIGH);

  digitalWrite(OUT_RDYK,HIGH);
  pinMode(OUT_RDYK,OUTPUT);
  digitalWrite(OUT_RDYM,HIGH);
  pinMode(OUT_RDYM,OUTPUT);
  digitalWrite(OUT_ACK,HIGH);
  pinMode(OUT_ACK,OUTPUT);
  pinMode(IN_CS,INPUT);
  pinMode(OUT_D4,OUTPUT);
  pinMode(OUT_D5,OUTPUT);
  pinMode(OUT_D6,OUTPUT);
  pinMode(OUT_D7,OUTPUT);
  pinMode(MseClk, INPUT);
  pinMode(MseData, INPUT);

  PIND &= 0x0F;

  Serial.begin(115200);

delay(1000);
  // Start Mouse
  writeMsePS2(0xFF);    // reset mouse
  
  if (vtimeoutmouseaux <= 0)
    hasmouseaux = 0;
digitalWrite(OUT_RED2,LOW);
  if (hasmouseaux)
  {
    //Serial.println("B");
    digitalWrite(OUT_RED2,HIGH);
    
    dataMse = readMsePs2(); // acknowledge: should be 0xFA
    dataMse = readMsePs2(); // self test:   should be 0xAA
    dataMse = readMsePs2(); // mouse id:    Should be 0x00
     
    writeMsePS2(0xF4);    // Enable mouse
    dataMse = readMsePs2(); // acknowledge: should be 0xFA
  
    mseDataAvailable = 0;
    mseDataAvailablePend = 0;
    kbdDataAvailablePend = 0;
  }
  
  // Start Keyboard
  delay(1000);
  keyboard.begin(KbdData, KbdClk);

  if (hasmouseaux)
    attachInterrupt(digitalPinToInterrupt(MseClk), ps2mseinterrupt, FALLING);

  //Serial.println("Monitorando...");
  digitalWrite(OUT_YEL,LOW);
  digitalWrite(OUT_RED,LOW);
  digitalWrite(OUT_GRE,LOW);
    
}

//----------------------------------------------------
// loop principal
//----------------------------------------------------
void loop() 
{
  if (!(PINC & 0b00000010) || !(PINC & 0b00000001))
  {
          //Serial.println(vTimeOutCpuReadAux);
    if (!--vTimeOutCpuReadAux)
    {
      //Serial.println("C");
      digitalWrite(OUT_RDYK,HIGH);
      digitalWrite(OUT_RDYM,HIGH);
      vTimeOutCpuReadAux = 0xFFF;
    }      
  }

  // Send Kbd Data to Host
  if (!(PINC & 0b00001000) && !(PINC & 0b00000010))  // CS = 0 e DTRDYK = 0 (leitura tecla lida)
  {
    digitalWrite(OUT_RDYK,HIGH);
    //Serial.println("D");
    vTimeOutCpuReadAux = 0xFFF;
       
    while (vCountK > 0 && !(PINC & 0b00001000)) // Envia todos os Bytes do buffer
    {
      // Envia proxima tecla no buffer
      sendData(vBufferKey[0]);
  
      // Move buffer 1 casa pra baixo
      for (ix = 0; ix < 15; ix++)
      {
        vMove = vBufferKey[ix + 1];
        vBufferKey[ix] = vMove;
      }
      
      vCountK --;
    }

    // Envia 0 indicando que nao tem mais nada
    sendData(0x00);

    while (!(PINC & 0b00001000)); // Enquanto CS = 0M
  }  
  
  // Send Mouse Data to Host
  if (hasmouseaux && !(PINC & 0b00001000) && !(PINC & 0b00000001))  // CS = 0 e DTRDYM = 0 (leitura mouse lida)
  {
    digitalWrite(OUT_YEL,LOW);
    vTimeOutCpuReadAux = 0xFFF;
//Serial.println("E");
    while (vCountM > 0 && !(PINC & 0b00001000)) // Envia todos os Bytes do buffer
    {
//Serial.println("F");
      // Envia proxima tecla no buffer
      sendData(vBufferMse[0]);
//Serial.println("G");
  
      // Move buffer 1 casa pra baixo
      for (ix = 0; ix < 59; ix++)
      {
        vMove = vBufferMse[ix + 1];
        vBufferMse[ix] = vMove;
      }
      
      vCountM --;
    }
//Serial.println("H");

    // Send Mouse Data to Host
    digitalWrite(OUT_RDYM,HIGH);
    
    //delayMicroseconds(200);
    
    // Envia 0 indicando que nao tem mais nada
    //sendData(0x00);

    while (!(PINC & 0b00001000)); // Enquanto CS = 0
  }
  
  // Read Keyboard 
  if (keyboard.available()) {    
    // read the next key
    c = keyboard.read();

    //Serial.print(c);
    
    if (c != 0x00 && c < 0x80)
    {
      vBufferKey[vCountK] = c;
      if (vCountK < 15)
        vCountK++;
        
      // Indica Processador que tem uma tecla lida
      kbdDataAvailablePend = 1;
    }
  }

  if (kbdDataAvailablePend && (PINC & 0b00000011))
  {
    kbdDataAvailablePend = 0;
    digitalWrite(OUT_RDYK,LOW);
  }

  // Read Mouse
  if (mseDataAvailable)
  {
        digitalWrite(OUT_YEL,HIGH);

    mseDataAvailable = 0;
    
    dataMse = (dataMse & 0b00111111110) >> 1;     //take off pairity, start & stop bits
    
    xmvmt = (xmvmt & 0b00111111110) >> 1;         // take off pairity, start & stop bits
    if((dataMse & 0b00010000) >> 4)               // if negative, process 9-bit 2s complement to regular signed int type
      xmvmt = -((~xmvmt & 0b11111111) + 1);
    
    ymvmt = (ymvmt & 0b00111111110) >> 1;         // take off pairity, start & stop bits
    if((dataMse & 0b00100000) >> 5)               // if negative, process 9-bit 2s complement to regular signed int type
      ymvmt = -((~ymvmt &0b11111111) + 1);

    vBufferMse[vCountM] = dataMse;
    if (vCountM < 59)
      vCountM++;

    vBufferMse[vCountM] = xmvmt;
    if (vCountM < 59)
      vCountM++;

    vBufferMse[vCountM] = ymvmt;
    if (vCountM < 59)
      vCountM++;

//Serial.println(vBufferMse[vCountM - 3]);
//Serial.println(vBufferMse[vCountM - 2]);
//Serial.println(vBufferMse[vCountM - 1]);
        
    // Indica Processador que tem dados mouse lidos
    mseDataAvailablePend = 1;
  }

  if (mseDataAvailablePend && (PINC & 0b00000011))
  {
    mseDataAvailablePend = 0;
    digitalWrite(OUT_RDYM,LOW);
  }  

/*  if (!(PINC & 0b00000011))
  {
    digitalWrite(OUT_RDYM,HIGH);
    digitalWrite(OUT_RDYK,HIGH);    
  }*/
}

//----------------------------------------------------
// read 11 byte packet from the mouse
//----------------------------------------------------
unsigned long int readMsePs2 () {
  unsigned long int b;
  int timeoutread = 0xFF;
    
  // shift in 11 bits from MSB to LSB
  for(int i = 0; i < 11 ; i++) {
    timeoutread = 0xFF;
    while(digitalRead(MseClk) == HIGH /*&& --timeoutread*/ ){} // wait for the clock to go LOW

    b += (digitalRead(MseData) << i);    // shift in a bit 

    timeoutread = 0xFF;
    while(digitalRead(MseClk) == LOW /*&& --timeoutread*/ ){}  // wait here while the clock is still low
  }

  if (!timeoutread)
    b = 0;
    
  return b;
}

//----------------------------------------------------
// write a byte to the mouse
//----------------------------------------------------
void writeMsePS2( byte Data) {
  vtimeoutmouseaux = 0xFFF;
  
  // bring the clock low to stop mouse from communicating
  pinMode(MseClk, OUTPUT); 
  digitalWrite(MseClk, LOW);
  delayMicroseconds(200); // wait for mouse

  // bring MseData low to tell mouse that the host wants to communicate
  pinMode(MseData, OUTPUT);
  digitalWrite(MseData, LOW);
  delayMicroseconds(50);
  
  // release control of clock by putting it back to a input
  pinMode(MseClk, INPUT_PULLUP);

  // now MseClk is high because of pullup
  
  while(digitalRead(MseClk) && vtimeoutmouseaux-- > 0){} // wait for clock to go low again

  if (vtimeoutmouseaux <= 0)
    return;
      
  // when the mouse brings clock low again, it is ready to communicate

  // shift out byte from LSB to MSB
  int pairck = 0;                               // track # of 1s in byte for pairity
  for(int i = 0; i < 8; i++) {
    digitalWrite(MseData, (Data & (1 <<i))  >> i); // shift out a bit when clock is low
    pairck += ((Data & (1 <<i))  >> i);         // count if 1 for pairity check later
    while(digitalRead(MseClk) == LOW){}            // wait for clock to go high
    while(digitalRead(MseClk) == HIGH){}           // wait for clock to go low
  }
    
  // add pairity bit if needed so that the number of 1s in the byte shifted out plus the pairity bit is always odd
  if(pairck %2 == 0) {
    digitalWrite(MseData, HIGH);
  }
  else {
    digitalWrite(MseData, LOW);
  }
  while(digitalRead(MseClk) == LOW){} // wait for clock to go high
  while(digitalRead(MseClk) == HIGH){} // wait for clock to go low
  

  pinMode(MseData, INPUT_PULLUP);       // release control of MseData
  while(digitalRead(MseData) == HIGH){} // wait for MseData to go low
  while(digitalRead(MseClk)  == HIGH){} // wait for MseClk to go low
  
  while(digitalRead(MseData) == LOW){} // wait for MseData to go high again
  while(digitalRead(MseClk) == LOW){}  // wait for MseClk to go high again
  
}

//----------------------------------------------------
// send byte, each 4 bits, to host
//----------------------------------------------------
void sendData(unsigned char pKey)
{
  int timeoutSD;

//Serial.print(">");
//Serial.println(pKey);
  
  PORTD = (PORTD & 0x0F) | ((pKey << 4) & 0xF0); // Coloca LSB

  digitalWrite(OUT_ACK,LOW);  // Libera CPU pra ler

  timeoutSD = 0x1FF;
  while (!(PINC & 0b00001000) && timeoutSD--); // Aguarda CPU colocar 1 no CS indicando que já leu
//Serial.println(timeoutSD);
  PORTD = (PORTD & 0x0F) | (pKey & 0xF0); // Coloca MSB

  digitalWrite(OUT_ACK,HIGH); // Libera CPU pra ler

  timeoutSD = 0x1FF;
  while (PINC & 0b00001000 && timeoutSD--); // Aguarda CPU colocar 0 no CS indicando que já leu
//Serial.println(timeoutSD);
}
