typedef struct LIST_WINDOWS
{
    int id;
    unsigned long loadAddress;
    char zOrder;
    char active;
    int keyTec;
} LIST_WINDOWS; 

#define MGUI_APP_WINDOW_SLOTS   6
#define MGUI_WINDOW_MGUI_SLOT   6
#define MGUI_WINDOW_MAX_SLOT    6

unsigned char *mguiIdRequest = 0x008D0000;
unsigned long *mguiRunTask = 0x008D0002; 
LIST_WINDOWS *mguiListWindows = 0x008D0008;
