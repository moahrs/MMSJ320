CC = m68k-elf-gcc
AS = m68k-elf-as
OBJCOPY = m68k-elf-objcopy
OBJDUMP = m68k-elf-objdump

TARGET = basic.elf
BIN = basic.bin
MAP = basic.map
LST = basic.lst
TEXT_ORIGIN ?= 0x00870000

CFLAGS = -m68000 -Wall -Os -std=gnu89 -ffreestanding -nostdlib -w -fcommon -Iinclude -ffunction-sections -fdata-sections -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-strict-aliasing
ASFLAGS_MRI = -m68000 -M --register-prefix-optional --bitwise-or
LDFLAGS = -T linker_basic.ld -nostdlib -Wl,--defsym=__TEXT_ORIGIN=$(TEXT_ORIGIN)
LDLIBS = -lgcc

SRC_C = \
	src/libc_stub.c \
	src/mmsj320mfp.c \
	src/basic.c

SRC_S = \
	src/basic_inic.S \
	src/basic_fpp.S \
	src/motoffp_all.S

OBJ = $(SRC_C:.c=.o) $(SRC_S:.S=.o)

# Ordem de link baseada no basic.prj (obrigatoria)
# 1) basic.a68      -> basic_inic.S
# 2) mmsj320mfp.c
# 3) basic.c
# 4) MotoFFP *.asm  -> motoffp_all.S
# 5) basic_fpp.a68  -> basic_fpp.S
LINK_OBJ = \
	src/basic_inic.o \
	src/libc_stub.o \
	src/mmsj320mfp.o \
	src/basic.o \
	src/motoffp_all.o \
	src/basic_fpp.o

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

src/basic_inic.o: src/basic_inic.S
	$(CC) $(CFLAGS) -c $< -o $@

src/basic_fpp.o: src/basic_fpp.S
	$(CC) $(CFLAGS) -c $< -o $@

src/motoffp_all.o: src/motoffp_all.S
	$(AS) $(ASFLAGS_MRI) -I src -o $@ $<

clean:
	-cmd /c "del /q /f src\*.o *.o *.elf *.bin *.map *.lst 2>nul"

.PHONY: all clean flash ram
