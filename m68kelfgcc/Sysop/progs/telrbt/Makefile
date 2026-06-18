CC = m68k-elf-gcc
OBJCOPY = m68k-elf-objcopy
OBJDUMP = m68k-elf-objdump

TARGET = telrbt.elf
BIN = telrbt.bin
MAP = telrbt.map
LST = telrbt.lst
TEXT_ORIGIN ?= 0x00000000

CFLAGS = -m68000 -Wall -Os -std=gnu89 -ffreestanding -nostdlib -w -fcommon -Iinclude -I../../include -ffunction-sections -fdata-sections -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-strict-aliasing
LDFLAGS = -m68000 -T linker_telrbt.ld -nostdlib -Wl,--emit-relocs -Wl,-Map=$(MAP)
LDLIBS = -lgcc

OBJ = \
	src/libc_stub.o \
	src/mmsj320mfp.o \
	src/netcomm_runtime.o \
	src/netcomm_resident.o \
	src/telrbt.o \
	src/telrbt_inic.o

LINK_OBJ = \
	src/telrbt_inic.o \
	src/libc_stub.o \
	src/mmsj320mfp.o \
	src/netcomm_resident.o \
	src/netcomm_runtime.o \
	src/telrbt.o

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

src/netcomm_runtime.o: ../../common/netcomm_runtime.c
	$(CC) $(CFLAGS) -c $< -o $@

src/netcomm_resident.o: ../../progschar/net/src/netcomm_resident.S
	$(CC) $(CFLAGS) -c $< -o $@

src/telrbt.o: src/telrbt.c
	$(CC) $(CFLAGS) -c $< -o $@

src/telrbt_inic.o: src/telrbt_inic.S
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	powershell -NoProfile -Command "$$p=@('src\*.o','*.o','*.elf','*.bin','*.map','*.lst'); foreach($$x in $$p){ Remove-Item -Force -ErrorAction SilentlyContinue $$x }; exit 0"

.PHONY: all clean flash ram
