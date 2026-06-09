CC = m68k-elf-gcc
OBJCOPY = m68k-elf-objcopy
OBJDUMP = m68k-elf-objdump

TARGET = wftp.elf
BIN = wftp.bin
MAP = wftp.map
LST = wftp.lst
TEXT_ORIGIN ?= 0x00000000

CFLAGS = -m68000 -Wall -Os -std=gnu89 -ffreestanding -nostdlib -w -fcommon -Iinclude -I../../include -ffunction-sections -fdata-sections -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-strict-aliasing
FTPD_CFLAGS = $(CFLAGS) -Dmain=ftpd_main -DMFTP_LOCAL_ABORT_EXTRA=wftpAbortExtra -DMMSJ320API_DECLARE_ONLY
LDFLAGS = -m68000 -T linker_wftp.ld -nostdlib -Wl,--emit-relocs -Wl,-Map=$(MAP)
LDLIBS = -lgcc

SRC_C = \
	src/libc_stub.c \
	src/mmsj320mfp.c \
	src/wftp.c

SRC_S = \
	src/wftp_inic.S

OBJ = \
	src/libc_stub.o \
	src/mmsj320mfp.o \
	src/wftp.o \
	src/wftp_inic.o

LINK_OBJ = \
	src/wftp_inic.o \
	src/libc_stub.o \
	src/mmsj320mfp.o \
	src/wftp.o

all: $(TARGET) $(BIN) $(LST)

flash: TEXT_ORIGIN=0x00020000
flash: clean all

ram: TEXT_ORIGIN=0x00000000
ram: clean all

$(TARGET): $(OBJ)
	$(CC) $(LDFLAGS) -Wl,-Map=$(MAP) -o $(TARGET) $(LINK_OBJ) $(LDLIBS)

$(BIN): $(TARGET)
	$(OBJCOPY) -O binary $(TARGET) $(BIN)

$(LST): $(TARGET)
	$(OBJDUMP) -x -d $(TARGET) > $(LST)

src/libc_stub.o: src/libc_stub.c
	$(CC) $(CFLAGS) -c $< -o $@

src/mmsj320mfp.o: src/mmsj320mfp.c
	$(CC) $(CFLAGS) -c $< -o $@

src/wftp.o: src/wftp.c
	$(CC) $(CFLAGS) -c $< -o $@

src/ftpd.o: ../../progschar/ftpd/src/ftpd.c
	$(CC) $(FTPD_CFLAGS) -c $< -o $@

src/wftp_inic.o: src/wftp_inic.S
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	powershell -NoProfile -Command "$$p=@('src\*.o','*.o','*.elf','*.bin','*.map','*.lst'); foreach($$x in $$p){ Remove-Item -Force -ErrorAction SilentlyContinue $$x }; exit 0"

.PHONY: all clean flash ram
