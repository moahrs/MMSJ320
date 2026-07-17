/********************************************************************************
*    Programa    : flashprog.c
*    Objetivo    : Rotina para gravar memoria flash no modulo MMSJ300 - SERIAL
*    Criado em   : 31/08/2022
*    Programador : Moacir Jr.
*--------------------------------------------------------------------------------
*   ------------------------------------------
*   PROTOCOLO DE COMUNICACAO:
*   ------------------------------------------
*   SENTIDO  
*    PC/PIC  COMANDO  FUNÇÃO
*       ->   DDDD     INICIA COMUNICACAO
*    <-      DDDD     COMUNICACAO ESTABELECIDA
*    <- ->   DDdd     RECEBE OU ENVIA DADO (dd)
*       ->   EE00     DADO VERIFICADO COM SUCESSO
*       ->   EE01     ERRO NA VERIFICAÇÃO DO DADO
*    <-      EE69     ENVIAR BYTE
*    <-      EE70     INICIO DO PROCESSO DE GRAVAÇÃO
*    <-      EE71     GRAVAÇÃO BYTE OK
*    <-      EE72     GRAVAÇÃO BYTE COM ERRO
*    <-      EE73     TERMINO DO PROCESSO DE GRAVAÇÃO
*       ->   EEDD     ENCERRA COMUNICACAO
*   ------------------------------------------
*   
*   ------------------------------------------
*   SENDROM deve enviar de 2 em 2 (0x00, 0x02, 0x04 ou 0x01, 0x03, 0x05 e etc...)
*   ------------------------------------------
*--------------------------------------------------------------------------------
* Data        Responsavel  Motivo
* 31/08/2022  Moacir Jr.   Desenvolvimento
********************************************************************************/

#define OUT_RW      49  // PL0
#define OUT_AS      48  // PL1
#define OUT_LDS     47  // PL2
#define OUT_UDS     46  // PL3
#define OUT_BG      45  // PL4  <-
#define OUT_BR      44  // PL5  ->
#define OUT_BGACK   43  // PL6  ->

#define Pin_D0      22  // PA0
#define Pin_D1      23  // PA1
#define Pin_D2      24  // PA2
#define Pin_D3      25  // PA3
#define Pin_D4      26  // PA4
#define Pin_D5      27  // PA5
#define Pin_D6      28  // PA6
#define Pin_D7      29  // PA7
#define Pin_D8      37  // PC0
#define Pin_D9      36  // PC1
#define Pin_D10     35  // PC2
#define Pin_D11     34  // PC3
#define Pin_D12     33  // PC4
#define Pin_D13     32  // PC5
#define Pin_D14     31  // PC6
#define Pin_D15     30  // PC7

#define OUT_A1      A1  // PF1
#define OUT_A2      A2  // PF2
#define OUT_A3      A3  // PF3
#define OUT_A4      A4  // PF4
#define OUT_A5      A5  // PF5
#define OUT_A6      A6  // PF6
#define OUT_A7      A7  // PF7
#define OUT_A8      A8  // PK0
#define OUT_A9      A9  // PK1
#define OUT_A10     A10 // PK2
#define OUT_A11     A11 // PK3
#define OUT_A12     A12 // PK4
#define OUT_A13     A13 // PK5
#define OUT_A14     A14 // PK6
#define OUT_A15     A15 // PK7
#define OUT_A16     21  // PD0
#define OUT_A17     20  // PD1
#define OUT_A18     17  // PH0

#define OUT_A21     2   // PE4
#define OUT_A22     3   // PE5
#define OUT_A23     7   // PE5

#define OUT_FC0      4  // PE6
#define OUT_FC1      5  // PE7
#define OUT_FC2      6  // PE8

//--- Constante para Gravação Final ou Testes na FLASH ATMEL AT29C020
#define __AT29C020__
#define __AT29C020_SDP__
#define __INVERT__

//--- VARIAVEIS DE USO GLOBAL
unsigned char pbyteler0[129];
unsigned char pbyteler1[129];
unsigned char pbyteler2[129];
unsigned char pbyteler3[129];
unsigned char vendmsb, vendmsb2, vendlsb;
unsigned char pDMA = 0;
unsigned char pVerifyOnly = 0;

#define VERIFY_OK_PASSES 1

#define CTRL_RW   0x01  // PL0
#define CTRL_AS   0x02  // PL1
#define CTRL_LDS  0x04  // PL2
#define CTRL_UDS  0x08  // PL3
#define CTRL_ALL  (CTRL_RW | CTRL_AS | CTRL_LDS | CTRL_UDS)
#define MAX_POLLING_ATTEMPTS 50000UL
#define FLASH_POST_WRITE_SETTLE_MS 50
#define FLASH_READ_SETTLE_US 50
#define FLASH_READ_GAP_US 200

void setup() {
  DDRA = 0b00000000;
  DDRC = 0b00000000;
  PORTA = 0b00000000;
  PORTC = 0b00000000;
  DDRF = 0b00000000;
  DDRK = 0b00000000;

  pinMode(OUT_RW,INPUT);
  pinMode(OUT_AS,INPUT);
  pinMode(OUT_LDS,INPUT);
  pinMode(OUT_UDS,INPUT);
  pinMode(OUT_FC0,INPUT);
  pinMode(OUT_FC1,INPUT);
  pinMode(OUT_FC2,INPUT);
  pinMode(OUT_BR,OUTPUT);
  digitalWrite(OUT_BR,HIGH);
  pinMode(OUT_BG,INPUT);
  pinMode(OUT_BGACK,OUTPUT);
  digitalWrite(OUT_BGACK,HIGH);

  pinMode(OUT_A16,INPUT);
  pinMode(OUT_A17,INPUT);
  pinMode(OUT_A18,INPUT);
  pinMode(OUT_A21,INPUT);
  pinMode(OUT_A22,INPUT);
  pinMode(OUT_A23,INPUT);

  Serial.begin(9600);
  Serial1.begin(19200);

  Serial.println("Start....");
}

void loop() {
  ComunicarSerial();
}

//------------------------------------------------------------
void ComunicarSerial(void)
{
  unsigned char inputBuffer, vdados, vcom, vinicio, vvar, vvira, vctrl;
  unsigned char vendlsba, vendmsba, vendmsba2, vreclsb, vrecmsb, vrecmsb2;
  unsigned int cc, dd, vcont;

  inputBuffer = 0;
  vinicio = 0x00;
  vdados = 0;
  vcom = 1;
  vcont = 0x01;
  vreclsb = 0;
  vrecmsb = 0;
  vrecmsb2 = 0;
  vvar = 1;
  vvira = 0;
  vctrl = 0;

  vendlsb = 0x00;
  vendmsb = 0x00;
  vendmsb2 = 0x00;

  while(vcom)
  {
    inputBuffer = 0;

    while(!(Serial1.available() > 0));

    inputBuffer = Serial1.read();

    if (vdados == 0 && inputBuffer == 0xEE) {
      vctrl = 1;
      continue;
    }

    if (vdados == 0 && vctrl) {
      vctrl = 0;

      if (inputBuffer == 0x56) {
        pVerifyOnly = 1;
        Serial.println("Verify only mode....");
        Serial1.write(0xEE);
        Serial1.write(0x69);
        continue;
      }
      else if (inputBuffer == 0x57) {
        pVerifyOnly = 0;
        Serial.println("Write mode....");
        Serial1.write(0xEE);
        Serial1.write(0x69);
        continue;
      }
      else if (inputBuffer == 0xDD) {
        vcom = 0;
        continue;
      }
    }

    if (vdados == 0 && inputBuffer == 0xDD) {
      if (vinicio == 0x00)
        vinicio = 0x01;
      else if (vinicio == 0x01) {
        vinicio = 0x02;

        Serial1.write(0xDD);
        Serial1.write(0xDD);
      }
      else if (vinicio == 0x02)
        vdados = 1;
      else if (vinicio == 0x03)
        vcom = 0;
    }
    else if (vdados == 0 && inputBuffer == 0x00) {
      // Comparação nos Bytes PC OK
      vinicio = 0x02;

      if (!vreclsb) {
        vreclsb = 1;

        Serial1.write(0xEE);  // Avisa PC para continuar enviando Byte's
        Serial1.write(0x69);
      }
      else if (!vrecmsb) {
        vrecmsb = 1;

        Serial1.write(0xEE);  // Avisa PC para continuar enviando Byte's
        Serial1.write(0x69);
      }
      else if (!vrecmsb2) {
        vrecmsb2 = 1;

        Serial1.write(0xEE);  // Avisa PC para continuar enviando Byte's
        Serial1.write(0x69);
      }
      else if (vreclsb && vrecmsb && vrecmsb2) {
        if (vvar == 4 && vcont == 128) {
          EnviarDados();
  
          vcont = 1;
          vvar = 1;
        }
        else {
          Serial1.write(0xEE);  // Avisa PC para continuar enviando Byte's
          Serial1.write(0x69);
          
          vcont++;

          if (vcont == 129) {
              vvar += 1;
              vcont = 1;
          }       
        }
      }
    }
    else if (vdados == 0 && inputBuffer == 0x01) {
      // Erro de Comparação nos Bytes PC
      vinicio = 0x02;
    }
    else if (vdados == 1) {
      vdados = 0;

      if (!vreclsb) {
        vendlsb = inputBuffer;
        char buf2[80];
        snprintf(buf2, 80, "Start Address LSB: %02X - ", vendlsb);
        Serial.println(buf2);
      }
      else if (!vrecmsb) {
        vendmsb = inputBuffer;
        char buf2[80];
        snprintf(buf2, 80, "Start Address MSB: %02X - ", vendmsb);
        Serial.println(buf2);
      }
      else if (!vrecmsb2) {
        vendmsb2 = inputBuffer;
        char buf2[80];
        snprintf(buf2, 80, "Start Address MSB2: %02X - ", vendmsb2);
        Serial.println(buf2);
      }
      else if (vreclsb && vrecmsb && vrecmsb2) {
        switch (vvar) {
          case 1:
            pbyteler0[vcont] = inputBuffer;
            break;
          case 2:
            pbyteler1[vcont] = inputBuffer;
            break;
          case 3:
            pbyteler2[vcont] = inputBuffer;
            break;
          case 4:
            pbyteler3[vcont] = inputBuffer;
            break;
        }   
      }
            
      Serial1.write(0xDD);
      Serial1.write(inputBuffer);
    }
  }

  if (vcont != 0x01) {
    vcont--;
    EnviarDados();
  }
  else{
    Serial1.write(0xEE);  // Avisa PC para continuar enviando Byte's
    Serial1.write(0x69);
  }
}

//------------------------------------------------------------
void EnviarDados(void)
{
  unsigned char vbytelsb, vbytemsb, verro, verroc, vqtda;
  unsigned char vendlsba, vendmsba, vendmsba2, vendlsbr, vendmsbr, vendmsbr2;
  unsigned char verrolsb, verromsb, verromsb2;
  unsigned char cc, dd;
  unsigned int vbyte, vdado, verrobyte, verrodado, tentativa;
  unsigned char verifyOkPasses;

  if (!pDMA)
  {
    if (digitalRead(OUT_BG))
      Serial.println("BG High....");
    else
      Serial.println("BG Low....");

    Serial.println("Bus Requesting....");
    
    // Ativa BR
    digitalWrite(OUT_BR,LOW);

    // Aguarda BG
    while (digitalRead(OUT_BG));

    Serial.println("Bus Granted....");

    // Ativa BGACK
    digitalWrite(OUT_BGACK,LOW);

    pDMA = 1;

    delay(2);

    DDRF = 0b11111111;
    DDRK = 0b11111111;

    pinMode(OUT_A16,OUTPUT);
    pinMode(OUT_A17,OUTPUT);
    pinMode(OUT_A18,OUTPUT);    
    pinMode(OUT_A21,OUTPUT);
    pinMode(OUT_A22,OUTPUT);
    pinMode(OUT_A23,OUTPUT);
    pinMode(OUT_FC0,OUTPUT);
    pinMode(OUT_FC1,OUTPUT);
    pinMode(OUT_FC2,OUTPUT);
    pinMode(OUT_RW,OUTPUT);
    pinMode(OUT_AS,OUTPUT);
    pinMode(OUT_LDS,OUTPUT);
    pinMode(OUT_UDS,OUTPUT);

    digitalWrite(OUT_A16,LOW);
    digitalWrite(OUT_A17,LOW);
    digitalWrite(OUT_A18,LOW);
    digitalWrite(OUT_A21,LOW);
    digitalWrite(OUT_A22,LOW);
    digitalWrite(OUT_A23,LOW);
    digitalWrite(OUT_FC0,LOW);
    digitalWrite(OUT_FC1,LOW);
    digitalWrite(OUT_FC2,LOW);
    ControleOcioso();
  }

  Serial1.write(0xEE);  // Avisa PC que iniciou o processo de gravação
  Serial1.write(0x70);

  verro = 1;
  verrolsb = 0;
  verromsb = 0;
  verromsb2 = 0;
  verrobyte = 0;
  verrodado = 0;

  vendlsba = vendlsb;
  vendmsba = vendmsb;
  vendmsba2 = vendmsb2;
  tentativa = 0;
  verifyOkPasses = 0;

  if (pVerifyOnly) {
    verro = 0;
    vendlsb = vendlsba;
    vendmsb = vendmsba;
    vendmsb2 = vendmsba2;

    for (dd = 1; dd <= 4; dd++){
        for (cc = 1; cc <= 127; cc += 2){
          delayMicroseconds(FLASH_READ_GAP_US);
          vbyte = LeDado();
          vbytelsb = (unsigned char)(vbyte & 0x00FF);
          vbytemsb = (unsigned char)((vbyte & 0xFF00) >> 8);

          switch (dd) {
            case 1:
                vdado = (pbyteler0[cc] | (pbyteler0[cc + 1] << 8));
                break;
            case 2:
                vdado = (pbyteler1[cc] | (pbyteler1[cc + 1] << 8));
                break;
            case 3:
                vdado = (pbyteler2[cc] | (pbyteler2[cc + 1] << 8));
                break;
            case 4:
                vdado = (pbyteler3[cc] | (pbyteler3[cc + 1] << 8));
                break;
          }

          if (vbyte != vdado)
          {
            if (!verro) {
              verrolsb = vendlsb;
              verromsb = vendmsb;
              verromsb2 = vendmsb2;
              verrobyte = vbyte;
              verrodado = vdado;
            }

            verro = 1;
            char buf2[80];
            snprintf(buf2, 80, "Verify Error At Addr: %02X%02X%02X - ", vendmsb2, vendmsb, vendlsb);
            Serial.print(buf2);
            snprintf(buf2, 80, "Expected: %04X, Read: %04X", vdado, vbyte );
            Serial.println(buf2);
          }

          if (vendlsb == 0xFE && vendmsb == 0xFF)
          {
            vendmsb2++;
            vendmsb = 0x00;
            vendlsb = 0x00;
          }
          else
          {
            if (vendlsb == 0xFE)
            {
              vendmsb++;
              vendlsb = 0x00;
            }
            else
              vendlsb += 2;
          }
        }
    }

    if (verro) {
      Serial1.write(0xEE);
      Serial1.write(0x72);
      Serial1.write(0xEE);
      Serial1.write(verrolsb);
      Serial1.write(0xEE);
      Serial1.write((unsigned char)(verrodado & 0x00FF));
      Serial1.write(0xEE);
      Serial1.write((unsigned char)(verrobyte & 0x00FF));
    }
    else {
      Serial1.write(0xEE);
      Serial1.write(0x71);
    }

    Serial1.write(0xEE);
    Serial1.write(0x73);
    return;
  }

  // Gravando Chip. So sai desta rotina depois que o bloco inteiro conferir.
  while (1) {
    //--- PORTA A e C como Saida
    DDRA = 0b11111111;
    DDRC = 0b11111111;

    noInterrupts();

    #ifdef __AT29C020_SDP__
      //--- Libera comando de gravacao com SDP ativo.
      //--- Deve ser enviado antes da carga dos 256 bytes do setor.
      FlashSdpUnlock();
    #endif

    //--- Inicia Gravação de 256 bytes em Sequencia
    vendlsb = vendlsba;
    vendmsb = vendmsba;
    vendmsb2 = vendmsba2;

    for (dd = 1; dd <= 4; dd++){
        for (cc = 1; cc <= 127; cc += 2){
          //--- Envia Dados
          switch (dd) {
            case 1:
              GravaDado(pbyteler0[cc], pbyteler0[cc + 1]);
              break;
            case 2:
              GravaDado(pbyteler1[cc], pbyteler1[cc + 1]);
              break;
            case 3:
              GravaDado(pbyteler2[cc], pbyteler2[cc + 1]);
              break;
            case 4:
              GravaDado(pbyteler3[cc], pbyteler3[cc + 1]);
              break;
          }

          if (dd != 4 || cc != 127) {
            if (vendlsb == 0xFE && vendmsb == 0xFF)
            {
              vendmsb2++;
              vendmsb = 0x00;
              vendlsb = 0x00;
            }
            else {
              if (vendlsb == 0xFE)
              {
                vendmsb++;
                vendlsb = 0x00;
              }
              else
                vendlsb += 2;
            }
          }
        }
    }       

    interrupts();
        
    #ifdef __AT29C020__
      delay(1);

      if (!AguardaFimGravacao(pbyteler3[127], pbyteler3[128]))
        Serial.println("Polling timeout, retrying block");
    #endif

    delay(FLASH_POST_WRITE_SETTLE_MS);

#if 0
    #ifdef __AT29C020__ 
      // delay conservador para as duas flashs terminarem programacao
      delay(100);

      //--- Verifica se Processo de Gravação Terminou
      verroc = 1;
      vqtda = 0;

      SetaEndereco();

      //--- PORTA A e C como Entrada
      BarramentoDadosEntrada();

      while (verroc && vqtda <= 0x7F) {
        vbyte = LeDado();
        vbytelsb = (unsigned char)(vbyte & 0x00FF);
        vbytemsb = (unsigned char)((vbyte & 0xFF00) >> 8);
    
        //--- Compara se IO7 = IO7 do byte gravado
        if ((vbytelsb & 0x80) == (pbyteler3[127] & 0x80) && (vbytemsb & 0x80) == (pbyteler3[128] & 0x80)) 
        {
          //--- Compara se byte lido = byte recebido
          if (vbytelsb == pbyteler3[127] && vbytemsb == pbyteler3[128])
            verroc = 0;
        }
        vqtda++;
      }
    #endif

 #endif

    if (vendlsb == 0xFE && vendmsb == 0xFF)
    {
      vendmsb2++;
      vendmsb = 0x00;
      vendlsb = 0x00;
    }
    else
    {
      if (vendlsb == 0xFE)
      {
        vendmsb++;
        vendlsb = 0x00;
      }
      else
        vendlsb += 2;
    }
    
    //--- Inicia Leitura dos 256 Bytes Gravados pra ver se Esta OK
    verro = 0;

    vendlsbr = vendlsb;
    vendmsbr = vendmsb;
    vendmsbr2 = vendmsb2;

    vendlsb = vendlsba;
    vendmsb = vendmsba;
    vendmsb2 = vendmsba2;

    for (dd = 1; dd <= 4; dd++){
        for (cc = 1; cc <= 127; cc += 2){
          delayMicroseconds(FLASH_READ_GAP_US);
          vbyte = LeDado();
          vbytelsb = (unsigned char)(vbyte & 0x00FF);
          vbytemsb = (unsigned char)((vbyte & 0xFF00) >> 8);
      
          //--- Compara se byte lido = byte recebido
          switch (dd) {
            case 1:
                vdado = (pbyteler0[cc] | (pbyteler0[cc + 1] << 8));
                break;
            case 2:
                vdado = (pbyteler1[cc] | (pbyteler1[cc + 1] << 8));
                break;
            case 3:
                vdado = (pbyteler2[cc] | (pbyteler2[cc + 1] << 8));
                break;
            case 4:
                vdado = (pbyteler3[cc] | (pbyteler3[cc + 1] << 8));
                break;
          }

          if (vbyte != vdado)
          {
            verro = 1;
            verrolsb = vendlsb;
            verromsb = vendmsb;
            verromsb2 = vendmsb2;
            verrobyte = vbyte;
            verrodado = vdado;
            char buf2[80];
            snprintf(buf2, 80, "Error At Addr: %02X%02X%02X - ", vendmsb2, vendmsb, vendlsb);
            Serial.print(buf2);
            snprintf(buf2, 80, "Write: %02X, Read: %02X", vdado, vbyte );
            Serial.println(buf2);
            break;
          }
    
          if (vendlsb == 0xFE && vendmsb == 0xFF)
          {
            vendmsb2++;
            vendmsb = 0x00;
            vendlsb = 0x00;
          }
          else
          {
            if (vendlsb == 0xFE)
            {
              vendmsb++;
              vendlsb = 0x00;
            }
            else
              vendlsb += 2;
          }
        }

        if (verro)
          break;
    } 

    if (verro) {
      tentativa++;
      verifyOkPasses = 0;

      char buf2[80];
      snprintf(buf2, 80, "Retry Block At Addr: %02X%02X%02X - Try: %u", vendmsba2, vendmsba, vendlsba, tentativa);
      Serial.println(buf2);

      vendlsb = vendlsba;
      vendmsb = vendmsba;
      vendmsb2 = vendmsba2;
      delay(100);
      continue;

      Serial1.write(0xEE);  // Avisa PC que Gravação Byte Falhou, Tentando Novamente
      Serial1.write(0x72);
      Serial1.write(0xEE);
      Serial1.write(verrolsb);
      Serial1.write(0xEE);
      Serial1.write((unsigned char)(verrodado & 0x00FF));
      Serial1.write(0xEE);
      Serial1.write((unsigned char)(verrobyte & 0x00FF));

      vendlsb = vendlsba;
      vendmsb = vendmsba;
      vendmsb2 = vendmsba2;
      delay(20);
      continue;
    }

    verifyOkPasses++;
    if (verifyOkPasses < VERIFY_OK_PASSES) {
      vendlsb = vendlsba;
      vendmsb = vendmsba;
      vendmsb2 = vendmsba2;
      delay(20);
      continue;
    }

    vendlsb = vendlsbr;
    vendmsb = vendmsbr;
    vendmsb2 = vendmsbr2;
    break;
  }   

  Serial1.write(0xEE);  // Avisa PC que Gravação Byte OK
  Serial1.write(0x71);

  Serial1.write(0xEE);  // Avisa PC que acabou gravação e que pode enviar mais 256 Bytes
  Serial1.write(0x73);
}


//------------------------------------------------------------
void FlashSdpUnlock(void)
{
  unsigned char oldlsb, oldmsb, oldmsb2;

  oldlsb = vendlsb;
  oldmsb = vendmsb;
  oldmsb2 = vendmsb2;

  // AT29C020 SDP:
  //   AA em 0x5555, 55 em 0x2AAA, A0 em 0x5555.
  //
  // Como no MMSJ320 as flashs ficam em barramento de 16 bits:
  //   A0 da flash <- A1 do 68000
  //
  // Entao os enderecos vistos pelo barramento sao:
  //   0x5555 << 1 = 0xAAAA
  //   0x2AAA << 1 = 0x5554

  vendmsb2 = 0x00;

  vendmsb = 0xAA;
  vendlsb = 0xAA;
  GravaDado(0xAA, 0xAA);

  vendmsb = 0x55;
  vendlsb = 0x54;
  GravaDado(0x55, 0x55);

  vendmsb = 0xAA;
  vendlsb = 0xAA;
  GravaDado(0xA0, 0xA0);

  vendlsb = oldlsb;
  vendmsb = oldmsb;
  vendmsb2 = oldmsb2;
}

//------------------------------------------------------------
void SetaEndereco(void)
{
  //--- Envia Endereço LSB
  PORTF = vendlsb;
  PORTK = vendmsb;
  if (vendmsb2 & 0x01)
    PORTD |= 0x01;
  else
    PORTD &= ~0x01;

  if (vendmsb2 & 0x02)
    PORTD |= 0x02;
  else
    PORTD &= ~0x02;

  if (vendmsb2 & 0x04)
    PORTH |= 0x01;
  else
    PORTH &= ~0x01;
}

//------------------------------------------------------------
void ControleOcioso(void)
{
  PORTL |= CTRL_ALL;
}

//------------------------------------------------------------
void ControleLeituraAtivo(void)
{
  PORTL |= CTRL_RW;
  PORTL &= ~(CTRL_LDS | CTRL_UDS | CTRL_AS);
}

//------------------------------------------------------------
void ControleEscritaPulso(void)
{
  PORTL &= ~CTRL_RW;
  PORTL &= ~(CTRL_LDS | CTRL_UDS | CTRL_AS);
  asm("nop");
  asm("nop");
  asm("nop");
  PORTL |= (CTRL_AS | CTRL_LDS | CTRL_UDS | CTRL_RW);
}

//------------------------------------------------------------
void BarramentoDadosEntrada(void)
{
  // Descarrega o barramento com a flash desabilitada antes de ler.
  // Isso evita falso OK por capacitancia/latch com o ultimo dado escrito.
  ControleOcioso();
  PORTA = 0b00000000;
  PORTC = 0b00000000;
  DDRA = 0b11111111;
  DDRC = 0b11111111;
  asm("nop");
  asm("nop");
  asm("nop");

  // Ao trocar de saida para entrada, manter PORT=0 evita pull-ups internos
  // no Arduino Mega. Pull-up ligado aqui pode contaminar leitura da flash.
  DDRA = 0b00000000;
  DDRC = 0b00000000;
}

//------------------------------------------------------------
unsigned int LeDado(void)
{
  unsigned char vbytelsb, vbytemsb;
  unsigned int vbyte1, vbyte2, vbyte3;

  SetaEndereco();
  BarramentoDadosEntrada();

  ControleLeituraAtivo();
  delayMicroseconds(FLASH_READ_SETTLE_US);

  #ifdef __INVERT__
    vbytemsb = PINA;
    vbytelsb = PINC;
  #else
    vbytelsb = PINA;
    vbytemsb = PINC;
  #endif
  vbyte1 = (vbytelsb | (vbytemsb << 8));

  asm("nop");
  asm("nop");
  asm("nop");

  #ifdef __INVERT__
    vbytemsb = PINA;
    vbytelsb = PINC;
  #else
    vbytelsb = PINA;
    vbytemsb = PINC;
  #endif
  vbyte2 = (vbytelsb | (vbytemsb << 8));

  asm("nop");
  asm("nop");
  asm("nop");

  #ifdef __INVERT__
    vbytemsb = PINA;
    vbytelsb = PINC;
  #else
    vbytelsb = PINA;
    vbytemsb = PINC;
  #endif
  vbyte3 = (vbytelsb | (vbytemsb << 8));

  if (vbyte1 == vbyte2 || vbyte1 == vbyte3)
    vbyte3 = vbyte1;
  else if (vbyte2 == vbyte3)
    vbyte3 = vbyte2;

  asm("nop");
  ControleOcioso();

  return vbyte3;
}

//------------------------------------------------------------
unsigned char AguardaDataPolling(unsigned char expectedLsb, unsigned char expectedMsb)
{
  unsigned long attempts;
  unsigned int current;
  unsigned char currentLsb, currentMsb;
  unsigned char targetLsbB7, targetMsbB7;
  unsigned char lsbReady, msbReady;

  targetLsbB7 = expectedLsb & 0x80;
  targetMsbB7 = expectedMsb & 0x80;
  lsbReady = 0;
  msbReady = 0;

  for (attempts = 0; attempts < MAX_POLLING_ATTEMPTS; attempts++) {
    current = LeDado();
    currentLsb = (unsigned char)(current & 0x00FF);
    currentMsb = (unsigned char)((current & 0xFF00) >> 8);

    if ((currentLsb & 0x80) == targetLsbB7)
      lsbReady = 1;

    if ((currentMsb & 0x80) == targetMsbB7)
      msbReady = 1;

    if (lsbReady && msbReady)
      return 1;
  }

  return 0;
}

//------------------------------------------------------------
unsigned char AguardaToggleBit(void)
{
  unsigned long attempts;
  unsigned int read1, read2;
  unsigned char lsb1, lsb2, msb1, msb2;
  unsigned char lsbReady, msbReady;

  lsbReady = 0;
  msbReady = 0;

  for (attempts = 0; attempts < MAX_POLLING_ATTEMPTS; attempts++) {
    read1 = LeDado();
    read2 = LeDado();

    lsb1 = (unsigned char)(read1 & 0x00FF);
    msb1 = (unsigned char)((read1 & 0xFF00) >> 8);
    lsb2 = (unsigned char)(read2 & 0x00FF);
    msb2 = (unsigned char)((read2 & 0xFF00) >> 8);

    if ((lsb1 & 0x40) == (lsb2 & 0x40))
      lsbReady = 1;

    if ((msb1 & 0x40) == (msb2 & 0x40))
      msbReady = 1;

    if (lsbReady && msbReady)
      return 1;
  }

  return 0;
}

//------------------------------------------------------------
unsigned char AguardaFimGravacao(unsigned char expectedLsb, unsigned char expectedMsb)
{
  if (AguardaDataPolling(expectedLsb, expectedMsb))
    return 1;

  return AguardaToggleBit();
}

//------------------------------------------------------------
void GravaDado(unsigned char vbytelsb, unsigned char vbytemsb)
{
  SetaEndereco();

  #ifdef __INVERT__
    PORTA = vbytemsb;
    PORTC = vbytelsb;
  #else
    PORTA = vbytelsb;
    PORTC = vbytemsb;
  #endif

  ControleEscritaPulso();
}
