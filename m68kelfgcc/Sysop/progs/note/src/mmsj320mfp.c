#include "mmsj320mfp.h"

unsigned char *vmfp  = 0x00400020;
unsigned char *mfpgpdr = 0x00400021;
unsigned char *mfpddr  = 0x00400221;

unsigned short Reg_UCR   =  0x1401;
unsigned short Reg_UDR   =  0x1701;
unsigned short Reg_RSR   =  0x1501;
unsigned short Reg_TSR   =  0x1601;

unsigned short Reg_VR    =  0x0B01;
unsigned short Reg_IERA  =  0x0301;
unsigned short Reg_IERB  =  0x0401;
unsigned short Reg_IPRA  =  0x0501;
unsigned short Reg_IPRB  =  0x0601;
unsigned short Reg_IMRA  =  0x0901;
unsigned short Reg_IMRB  =  0x0A01;
unsigned short Reg_ISRA  =  0x0701;
unsigned short Reg_ISRB  =  0x0801;

unsigned short Reg_TADR  =  0x0F01;
unsigned short Reg_TBDR  =  0x1001;
unsigned short Reg_TCDR  =  0x1101;
unsigned short Reg_TDDR  =  0x1201;
unsigned short Reg_TACR  =  0x0C01;
unsigned short Reg_TBCR  =  0x0D01;
unsigned short Reg_TCDCR =  0x0E01;

unsigned short Reg_GPDR  =  0x0001;
unsigned short Reg_AER   =  0x0101;
unsigned short Reg_DDR   =  0x0201;