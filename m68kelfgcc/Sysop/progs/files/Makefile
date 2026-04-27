CC = m68k-elf-gcc
AS = m68k-elf-as
OBJCOPY = m68k-elf-objcopy
OBJDUMP = m68k-elf-objdump

TARGET = files.elf
BIN = files.bin
MAP = files.map
LST = files.lst
TEXT_ORIGIN ?= 0x00870000

CFLAGS = -m68000 -Wall -Os -std=gnu89 -ffreestanding -nostdlib -w -fcommon -Iinclude -I../../include -ffunction-sections -fdata-sections -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-strict-aliasing
LDFLAGS = -T linker_files.ld -nostdlib -Wl,--defsym=__TEXT_ORIGIN=$(TEXT_ORIGIN)
LDLIBS = -lgcc

SRC_C = \
	src/libc_stub.c \
	src/mmsj320mfp.c \
	src/files.c

SRC_S = \
	src/files_inic.S

OBJ = $(SRC_C:.c=.o) $(SRC_S:.S=.o)

# Ordem de link baseada no files.prj (obrigatoria)
# 1) monitorapi.a68 -> files_inic.S
# 2) mmsj320mfp.c
# 3) files.c
LINK_OBJ = \
	src/files_inic.o \
	src/libc_stub.o \
	src/mmsj320mfp.o \
	src/files.o

all: $(TARGET) $(BIN) $(LST)

flash: TEXT_ORIGIN=0x00020000
flash: clean all

ram: TEXT_ORIGIN=0x00870000
ram: clean all

$(TARGET): $(OBJ)
	$(CC) $(LDFLAGS) -Wl,-Map=$(MAP) -o $(TARGET) $(LINK_OBJ) $(LDLIBS)

$(BIN): $(TARGET)
	$(OBJCOPY) -O binary $(TARGET) $(BIN)

$(LST): $(TARGET)
	$(OBJDUMP) -x -d $(TARGET) > $(LST)

src/%.o: src/%.c
	$(CC) $(CFLAGS) -c $< -o $@

src/files_inic.o: src/files_inic.S
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	-cmd /c "del /q /f src\*.o *.o *.elf *.bin *.map *.lst 2>nul"

.PHONY: all clean flash ram
