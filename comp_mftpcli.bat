cls
c:\borland\bcc55\bin\bcc32 -c -tWC -I"c:\borland\bcc55\include" -L"c:\borland\bcc55\lib" mftpcli.cpp
c:\borland\bcc55\bin\ilink32 -ap -c -x -Gn -L"c:\borland\bcc55\lib" mftpcli.obj c0x32.obj,mftpcli.exe,,import32.lib cw32.lib ws2_32.lib
