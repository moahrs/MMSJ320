#ifndef WFTP_H
#define WFTP_H

#include "netapi.h"

#define SER_RX_SIZE NETAPI_RX_SIZE

#define WFTP_X 36
#define WFTP_Y 42
#define WFTP_W 184
#define WFTP_H 112

#define WFTP_BTN_X (WFTP_X + 61)
#define WFTP_BTN_Y (WFTP_Y + 88)
#define WFTP_BTN_W 62
#define WFTP_BTN_H 14

int ftpd_main(void);
unsigned char wftpAbortExtra(void);

#endif
