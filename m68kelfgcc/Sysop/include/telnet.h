#ifndef MMSJ_TELNET_H
#define MMSJ_TELNET_H

#define TELNET_CONSOLE_MAGIC 0x54454C4EUL /* TELN */

void telnetInit(void);
void telnetPoll(void);
void telnetTimerHook(void);
unsigned char telnetConsoleActive(void);
unsigned char telnetIsEnabled(void);
unsigned char telnetSetEnabled(unsigned char enabled);
unsigned char telnetSuspend(void);
void telnetResume(unsigned char wasEnabled);

#endif
