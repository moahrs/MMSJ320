CC = m68k-elf-gcc
AS = m68k-elf-as
OBJCOPY = m68k-elf-objcopy
OBJDUMP = m68k-elf-objdump

TARGET = ftpd.elf
BIN = ftpd.bin
MAP = ftpd.map
LST = ftpd.lst
TEXT_ORIGIN ?= 0x00000000

CFLAGS = -m68000 -Wall -Os -std=gnu89 -ffreestanding -nostdlib -w -fcommon -Iinclude -I../../include -ffunction-sections -fdata-sections -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-strict-aliasing
ASFLAGS_MRI = -m68000 -M --register-prefix-optional --bitwise-or
LDFLAGS = -m68000 -T linker_ftpd.ld -nostdlib -Wl,--emit-relocs -Wl,-Map=$(MAP)
LDLIBS = -lgcc

SRC_C = \
	src/libc_stub.c \
	src/mmsj320mfp.c \
	src/ftpd.c

SRC_S = \
	src/ftpd_inic.S

OBJ = $(SRC_C:.c=.o) $(SRC_S:.S=.o)
OBJ += src/netcomm_runtime.o src/netcomm_resident.o

# Ordem de link:
# 1) ftpd_inic.S
# 2) mmsj320mfp.c
# 3) ftpd.c
LINK_OBJ = \
	src/ftpd_inic.o \
	src/libc_stub.o \
	src/mmsj320mfp.o \
	src/netcomm_resident.o \
	src/netcomm_runtime.o \
	src/ftpd.o

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

src/%.o: src/%.c
	$(CC) $(CFLAGS) -c $< -o $@

src/netcomm_runtime.o: ../../common/netcomm_runtime.c
	$(CC) $(CFLAGS) -c $< -o $@

src/netcomm_resident.o: ../net/src/netcomm_resident.S
	$(CC) $(CFLAGS) -c $< -o $@

src/ftpd_inic.o: src/ftpd_inic.S
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	powershell -NoProfile -Command "$$p=@('src\*.o','lib\*.o','*.o','*.elf','*.bin','*.map','*.lst'); foreach($$x in $$p){ Remove-Item -Force -ErrorAction SilentlyContinue $$x }; exit 0"

.PHONY: all clean flash ram
