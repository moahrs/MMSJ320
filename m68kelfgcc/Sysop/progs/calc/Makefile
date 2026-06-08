CC = m68k-elf-gcc
OBJCOPY = m68k-elf-objcopy
OBJDUMP = m68k-elf-objdump

TARGET = calc.elf
BIN = calc.bin
MAP = calc.map
LST = calc.lst
TEXT_ORIGIN ?= 0x00000000

CFLAGS = -m68000 -Wall -Os -std=gnu89 -ffreestanding -nostdlib -w -fcommon -Iinclude -I../../include -ffunction-sections -fdata-sections -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-strict-aliasing
LDFLAGS = -m68000 -T linker_calc.ld -nostdlib -Wl,--emit-relocs -Wl,-Map=$(MAP)
LDLIBS = -lgcc

SRC_C = \
	src/libc_stub.c \
	src/mmsj320mfp.c \
	src/calc.c

SRC_S = \
	src/calc_inic.S

OBJ = $(SRC_C:.c=.o) $(SRC_S:.S=.o)

LINK_OBJ = \
	src/calc_inic.o \
	src/libc_stub.o \
	src/mmsj320mfp.o \
	src/calc.o

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

src/calc_inic.o: src/calc_inic.S
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	powershell -NoProfile -Command "$$p=@('src\*.o','*.o','*.elf','*.bin','*.map','*.lst'); foreach($$x in $$p){ Remove-Item -Force -ErrorAction SilentlyContinue $$x }; exit 0"

.PHONY: all clean flash ram
