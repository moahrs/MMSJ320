#include <SPI.h>
#include <EthernetENC.h>
#include <EthernetUdp.h>
#include <stdio.h>
#include <string.h>

#define PIN_ETH_CS 5
#define PIN_SPI_SCK  18
#define PIN_SPI_MISO 19
#define PIN_SPI_MOSI 23

#define RXD2 16
#define TXD2 17

#define PIN_LED_ON  25
#define PIN_LED_LAN 26
#define PIN_LED_ACT 27
#define PIN_LED_CONN 32

#define LED_ON_LEVEL  HIGH
#define LED_OFF_LEVEL LOW
#define LED_ACT_MS    80
#define LAN_POLL_MS   1000
#define PLUS_TIMEOUT_MS 1000

byte mac[] = { 0x02, 0x68, 0x00, 0x00, 0x00, 0x45 };

EthernetUDP Udp;
EthernetClient tcpClient;
EthernetServer tcpServer(23);


bool tcpMode = false;
bool tcpListenMode = false;
uint16_t tcpListenPort = 23;
char plusBuf[4];
unsigned char plusPos = 0;

char lineBuf[128];
char vStatusAux[128];
int linePos = 0;

IPAddress remoteIp;
uint16_t remotePort = 0;
uint16_t localPort = 5000;
bool udpOpen = false;
bool ethernetReady = false;
bool ledActOn = false;
unsigned long ledActUntil = 0;
unsigned long lanPollLast = 0;
unsigned long plusLastMs = 0;

#define TCP_RXBUF_SIZE 4096

uint8_t tcpRxBuf[TCP_RXBUF_SIZE];
volatile uint16_t tcpRxHead = 0;
volatile uint16_t tcpRxTail = 0;
volatile uint16_t tcpRxLost = 0;

uint16_t tcpRxFree()
{
    if (tcpRxHead >= tcpRxTail)
        return TCP_RXBUF_SIZE - (tcpRxHead - tcpRxTail) - 1;

    return (tcpRxTail - tcpRxHead) - 1;
}

bool tcpRxPut(uint8_t c)
{
  uint16_t n = (tcpRxHead + 1) % TCP_RXBUF_SIZE;

  if (n == tcpRxTail)
  {
    tcpRxLost++;
    return false;
  }

  tcpRxBuf[tcpRxHead] = c;
  tcpRxHead = n;
  return true;
}

bool tcpRxGet(uint8_t *c)
{
  if (tcpRxHead == tcpRxTail)
    return false;

  *c = tcpRxBuf[tcpRxTail];
  tcpRxTail = (tcpRxTail + 1) % TCP_RXBUF_SIZE;
  return true;
}

void tcpRxClear()
{
  tcpRxHead = 0;
  tcpRxTail = 0;
  tcpRxLost = 0;
}

void ledsInit()
{
  pinMode(PIN_LED_ON, OUTPUT);
  pinMode(PIN_LED_LAN, OUTPUT);
  pinMode(PIN_LED_ACT, OUTPUT);
  pinMode(PIN_LED_CONN, OUTPUT);

  digitalWrite(PIN_LED_ON, LED_ON_LEVEL);
  digitalWrite(PIN_LED_LAN, LED_OFF_LEVEL);
  digitalWrite(PIN_LED_ACT, LED_OFF_LEVEL);
  digitalWrite(PIN_LED_CONN, LED_OFF_LEVEL);
}

void ledActivity()
{
  digitalWrite(PIN_LED_ACT, LED_ON_LEVEL);
  ledActOn = true;
  ledActUntil = millis() + LED_ACT_MS;
}

void ledsPoll()
{
  unsigned long now;

  now = millis();

  if (ledActOn && (long)(now - ledActUntil) >= 0)
  {
    digitalWrite(PIN_LED_ACT, LED_OFF_LEVEL);
    ledActOn = false;
  }

  if ((long)(now - lanPollLast) >= LAN_POLL_MS)
  {
    lanPollLast = now;

    if (ethernetReady && Ethernet.linkStatus() != LinkOFF)
      digitalWrite(PIN_LED_LAN, LED_ON_LEVEL);
    else
      digitalWrite(PIN_LED_LAN, LED_OFF_LEVEL);

    if (tcpMode)
      digitalWrite(PIN_LED_CONN, LED_ON_LEVEL);
    else
      digitalWrite(PIN_LED_CONN, LED_OFF_LEVEL);
  }
}

void endResponse()
{
  Serial2.write((byte)0x04);  // End Of Transmission
  Serial2.flush();
}

void printNetInfo()
{
  Serial2.print("IP: ");
  Serial2.println(Ethernet.localIP());

  Serial2.print("Gateway: ");
  Serial2.println(Ethernet.gatewayIP());

  Serial2.print("Subnet: ");
  Serial2.println(Ethernet.subnetMask());

  Serial2.print("DNS: ");
  Serial2.println(Ethernet.dnsServerIP());
  endResponse();
}

bool parseHostPort(char *s, char *host, uint16_t *port)
{
  char *p;

  p = strchr(s, ':');

  if (!p)
  {
    strcpy(host, s);
    *port = 23;     // Telnet default
    return true;
  }

  *p = 0;
  strcpy(host, s);
  *port = atoi(p + 1);

  if (*port == 0)
    return false;

  return true;
}


void cmdTcpListen(char *arg)
{
  if (tcpListenMode && !tcpMode)
  {
    tcpListenMode = false;
    tcpRxClear();
    linePos = 0;

    while (Serial2.available())
      Serial2.read();

    Serial2.print("OK;LISTEN;OFF");
    endResponse();
    return;
  }

  if (tcpClient.connected())
    tcpClient.stop();

  tcpRxClear();
  linePos = 0;
  tcpListenPort = 23;
  tcpListenMode = true;
  tcpMode = false;
  plusPos = 0;

  tcpServer.begin();

  Serial2.print("OK;LISTEN;ON;23");
  endResponse();
}

void cmdTcpConnect(char *arg)
{
  char host[80];
  uint16_t port;

  if (!parseHostPort(arg, host, &port))
  {
    Serial2.println("ERR;BADADDR");
    endResponse();
    return;
  }

  if (tcpClient.connected())
    tcpClient.stop();

  if (tcpClient.connect(host, port))
  {
    ledActivity();
    digitalWrite(PIN_LED_CONN, LED_ON_LEVEL);
    tcpMode = true;
    plusPos = 0;
    /*Serial2.println("OK;CONNECT");
    endResponse();*/
  }
  else
  {
    Serial2.println("ERR;CONNECT");
    endResponse();
  }
}

void tcpBridgePoll()
{
  int c;
  uint8_t b;
  int count;
  bool tcpTx;

  if (!tcpMode)
    return;

  if (!tcpClient.connected())
  {
    tcpClient.stop();
    tcpMode = false;
    digitalWrite(PIN_LED_CONN, LED_OFF_LEVEL);
    plusPos = 0;
    tcpRxClear();
    Serial2.println("\r\nEVT;DISCONNECT");
    endResponse();
    return;
  }

  tcpTx = false;

  if (plusPos && (long)(millis() - plusLastMs) >= PLUS_TIMEOUT_MS)
  {
    while (plusPos)
    {
      tcpClient.write('+');
      ledActivity();
      tcpTx = true;
      plusPos--;
    }
  }

  /* serial -> TCP */
  while (Serial2.available())
  {
    c = Serial2.read();

    if (c == '+')
    {
      plusPos++;
      plusLastMs = millis();

      if (plusPos >= 3)
      {
        tcpClient.stop();
        tcpMode = false;
        digitalWrite(PIN_LED_CONN, LED_OFF_LEVEL);
        plusPos = 0;
        tcpRxClear();

        while (Serial2.available())
          Serial2.read();

        Serial2.println("\r\nOK;DISCONNECT");
        endResponse();
        return;
      }

      continue;
    }

    while (plusPos)
    {
      tcpClient.write('+');
      ledActivity();
      tcpTx = true;
      plusPos--;
    }

    tcpClient.write((uint8_t)c);
    ledActivity();
    tcpTx = true;
  }

  if (tcpTx)
    tcpClient.flush();

  /* TCP -> buffer, só lê se tiver espaço */
  count = 0;

  while (tcpClient.available() && count < 128)
  {
      if (tcpRxFree() == 0)
          break;   // NÃO lê do TCP, não descarta

      c = tcpClient.read();

      if (c >= 0)
      {
          tcpRxPut((uint8_t)c);
          ledActivity();
      }

      count++;
  }

  /* buffer -> serial */
  count = 0;

  while (count < 1 && tcpRxGet(&b))
  {
      Serial2.write(b);
      delayMicroseconds(1000);
      count++;
  }
}


void tcpListenPoll()
{
  EthernetClient newClient;

  if (!tcpListenMode || tcpMode)
    return;

  newClient = tcpServer.available();

  if (newClient)
  {
    if (tcpClient.connected())
      tcpClient.stop();

    tcpClient = newClient;
    tcpRxClear();
    tcpMode = true;
    plusPos = 0;
    digitalWrite(PIN_LED_CONN, LED_ON_LEVEL);
    ledActivity();

//    Serial2.print("EVT;CONNECT;INBOUND;23");
  }
}

void cmdIpInfo()
{
  Serial2.print("OK;");
  Serial2.print(Ethernet.localIP());
  Serial2.print(";");
  Serial2.print(Ethernet.gatewayIP());
  Serial2.print(";");
  Serial2.print(Ethernet.subnetMask());
  Serial2.print(";");
  Serial2.print(Ethernet.dnsServerIP());
}

void initEthernet()
{
  Serial.println("Initializing Ethernet...");

  Ethernet.init(PIN_ETH_CS);
  delay(1000);

  if (Ethernet.begin(mac) == 0)
  {
    ethernetReady = false;
    digitalWrite(PIN_LED_LAN, LED_OFF_LEVEL);
    Serial.println("DHCP FAIL");
    strcpy(vStatusAux,"DHCP FAIL,");

    if (Ethernet.hardwareStatus() == EthernetNoHardware)
    {
      Serial.println("NO HARDWARE");
      strcat(vStatusAux,"NO HARDWARE");
    }

    if (Ethernet.linkStatus() == LinkOFF)
    {
      Serial.println("LINK OFF");
      strcat(vStatusAux,"LINK OFF");
    }
  }
  else
  {
    ethernetReady = true;
    digitalWrite(PIN_LED_LAN, LED_ON_LEVEL);
    ledActivity();
    Serial.println("DHCP OK");
    strcpy(vStatusAux,"DHCP OK");
  }

  //printNetInfo();

  Udp.begin(localPort);
  /*Serial.print("UDP LOCAL PORT: ");
  Serial.println(localPort);*/
}

bool parseIpPort(char *s, IPAddress &ip, uint16_t &port)
{
  int a, b, c, d, p;

  if (sscanf(s, "%d.%d.%d.%d:%d", &a, &b, &c, &d, &p) != 5)
    return false;

  ip = IPAddress(a, b, c, d);
  port = (uint16_t)p;

  return true;
}

void cmdUdpOpen(char *arg)
{
  if (!parseIpPort(arg, remoteIp, remotePort))
  {
    Serial2.print("ERROR");
    return;
  }

  udpOpen = true;

  Serial2.print("OK;");
  Serial2.print("UDPCONNECT;");
  Serial2.print(remoteIp);
  Serial2.print(":");
  Serial2.print(remotePort);
}

void cmdSend(char *msg)
{
  if (!udpOpen)
  {
    Serial2.print("ERROR;NO UDP");
    return;
  }

  Udp.beginPacket(remoteIp, remotePort);
  Udp.write((const uint8_t *)msg, strlen(msg));
  Udp.endPacket();
  ledActivity();

  Serial2.print("OK");
}

void processCommand(char *cmd)
{
  while (*cmd == ' ') cmd++;
Serial.println(cmd);
  if (strcmp(cmd, "AT") == 0)
  {
    Serial2.print("OK");
    endResponse();
  }
  else if (strcmp(cmd, "ATI") == 0)
  {
    Serial2.print("OK;");
    Serial2.print("MMSJ-NET ESP32 ENC28J60 v0.1");
    endResponse();
  }
  else if (strcmp(cmd, "ATIP?") == 0)
  {
    cmdIpInfo();
    endResponse();
  }
  else if (strcmp(cmd, "ATUDP?") == 0)
  {
    Serial2.print("OK;");
    Serial2.print("UDPLOCALPORT;");
    Serial2.print(localPort);
    endResponse();
  }
  else if (strcmp(cmd, "ATSTAT?") == 0)
  {
    Serial2.print("OK;");
    Serial2.print(vStatusAux);
    endResponse();
  }
  else if (strncmp(cmd, "ATUDP=", 6) == 0)
  {
    cmdUdpOpen(cmd + 6);
    endResponse();
  }
  else if (strncmp(cmd, "SEND ", 5) == 0)
  {
    cmdSend(cmd + 5);
    endResponse();
  }
  else if (strncmp(cmd, "ATLISTEN=", 9) == 0)
  {
    cmdTcpListen(cmd + 9);
  }
  else if (strcmp(cmd, "ATLISTEN") == 0)
  {
    cmdTcpListen((char *)"23");
  }
  else if (strcmp(cmd, "ATLISTEN?") == 0)
  {
    Serial2.print("OK;");
    Serial2.print(tcpListenMode ? "LISTEN" : "OFF");
    Serial2.print(";");
    Serial2.print(tcpListenPort);
    endResponse();
  }
  else if (strcmp(cmd, "ATFLUSH") == 0)
  {
    tcpRxClear();
    linePos = 0;
    plusPos = 0;

    while (Serial2.available())
      Serial2.read();

    Serial2.print("OK;FLUSH");
    endResponse();
  }  
  else if (strncmp(cmd, "ATTCP=", 6) == 0)
  {
    tcpListenMode = false;
    cmdTcpConnect(cmd + 6);
  }
  else if (strcmp(cmd, "ATBUF?") == 0)
  {
    Serial2.print("OK;");
    Serial2.print("LOST;");
    Serial2.print(tcpRxLost);
    endResponse();
  }
  else if (strcmp(cmd, "ATH") == 0)
  {
    if (tcpClient.connected())
      tcpClient.stop();

    udpOpen = false;
    tcpListenMode = false;
    tcpMode = false;
    digitalWrite(PIN_LED_CONN, LED_OFF_LEVEL);
    Serial2.println("OK;DISCONNECT");
    endResponse();
  }  
  else
  {
    Serial2.print("ERROR;CMD_UNKNOW");
    endResponse();
  }
}

void serialPoll()
{
  while (Serial2.available())
  {
    char c = Serial2.read();

    if (c == '\r' || c == '\n')
    {
      if (linePos > 0)
      {
        lineBuf[linePos] = 0;
        processCommand(lineBuf);
        linePos = 0;
      }
    }
    else
    {
      if (linePos < sizeof(lineBuf) - 1)
      {
        lineBuf[linePos++] = c;
      }
    }
  }
}

void udpPoll()
{
  int packetSize = Udp.parsePacket();

  if (packetSize)
  {
    ledActivity();
    Serial2.print("EVT;UDP;");
    Serial2.print(Udp.remoteIP());
    Serial2.print(";");
    Serial2.print(Udp.remotePort());
    Serial2.print(";");
    Serial2.print(packetSize);
    Serial2.print(";");

    while (packetSize--)
    {
      int c = Udp.read();
      if (c >= 0)
        Serial2.write((char)c);
    }

    endResponse();
  }
}

void setup()
{
  ledsInit();

  Serial.begin(115200);
  delay(1000);

  Serial.println();
  Serial.println("MMSJ-NET BOOT");

  Serial2.begin(9600, SERIAL_8N1, RXD2, TXD2);
  delay(1000);
  while (Serial2.available()) Serial2.read(); // Limpar Lixo

  Serial.println("Serial2 is ready.");

  SPI.begin(PIN_SPI_SCK, PIN_SPI_MISO, PIN_SPI_MOSI, PIN_ETH_CS);
  initEthernet();

  Serial.println("READY");
}

void loop()
{
  ledsPoll();

  if (tcpMode)
  {
    tcpBridgePoll();
    return;
  }

  tcpListenPoll();
  serialPoll();
  udpPoll();
}
