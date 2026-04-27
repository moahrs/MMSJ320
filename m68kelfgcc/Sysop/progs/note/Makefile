CC = m68k-elf-gcc
AS = m68k-elf-as
OBJCOPY = m68k-elf-objcopy
OBJDUMP = m68k-elf-objdump

TARGET = note.elf
BIN = note.bin
MAP = note.map
LST = note.lst
TEXT_ORIGIN ?= 0x00880000

CFLAGS = -m68000 -Wall -Os -std=gnu89 -ffreestanding -nostdlib -w -fcommon -Iinclude -I../../include -ffunction-sections -fdata-sections -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-strict-aliasing
LDFLAGS = -T linker_note.ld -nostdlib -Wl,--defsym=__TEXT_ORIGIN=$(TEXT_ORIGIN)
LDLIBS = -lgcc

SRC_C = \
	src/libc_stub.c \
	src/mmsj320mfp.c \
	src/note.c

SRC_S = \
	src/note_inic.S

OBJ = $(SRC_C:.c=.o) $(SRC_S:.S=.o)

# Ordem de link baseada no note.prj (obrigatoria)
# 1) monitorapi.a68 -> note_inic.S
# 2) mmsj320mfp.c
# 3) note.c
LINK_OBJ = \
	src/note_inic.o \
	src/libc_stub.o \
	src/mmsj320mfp.o \
	src/note.o

all: $(TARGET) $(BIN) $(LST)

flash: TEXT_ORIGIN=0x00020000
flash: clean all

ram: TEXT_ORIGIN=0x00880000
ram: clean all

$(TARGET): $(OBJ)
	$(CC) $(LDFLAGS) -Wl,-Map=$(MAP) -o $(TARGET) $(LINK_OBJ) $(LDLIBS)

$(BIN): $(TARGET)
	$(OBJCOPY) -O binary $(TARGET) $(BIN)

$(LST): $(TARGET)
	$(OBJDUMP) -x -d $(TARGET) > $(LST)

src/%.o: src/%.c
	$(CC) $(CFLAGS) -c $< -o $@

src/note_inic.o: src/note_inic.S
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	-cmd /c "del /q /f src\*.o *.o *.elf *.bin *.map *.lst 2>nul"

.PHONY: all clean flash ram