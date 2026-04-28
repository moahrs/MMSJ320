typedef struct LIST_WINDOWS
{
    int id;
    unsigned long loadAddress;
    char zOrder;
    char active;
    char keyTec;
} LIST_WINDOWS; 

unsigned char *mguiIdRequest = 0x008D0000;
unsigned long *mguiRunTask = 0x008D0002; 
LIST_WINDOWS *mguiListWindows = 0x008D0008;
