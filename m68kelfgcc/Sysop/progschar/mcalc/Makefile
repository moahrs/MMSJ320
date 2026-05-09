CC = m68k-elf-gcc
AS = m68k-elf-as
OBJCOPY = m68k-elf-objcopy
OBJDUMP = m68k-elf-objdump

TARGET = mcalc.elf
BIN = mcalc.bin
MAP = mcalc.map
LST = mcalc.lst
TEXT_ORIGIN ?= 0x00000000

# Biblioteca local do MotoFFP
LIB_DIR = lib

CFLAGS = -m68000 -Wall -Os -std=gnu89 -ffreestanding -nostdlib -w -fcommon -Iinclude -I../../include -ffunction-sections -fdata-sections -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-strict-aliasing
ASFLAGS_MRI = -m68000 -M --register-prefix-optional --bitwise-or
LDFLAGS = -T linker_mcalc.ld -nostdlib -Wl,--emit-relocs -Wl,-Map=$(MAP)
LDLIBS = -lgcc

SRC_C = \
	src/libc_stub.c \
	src/mmsj320mfp.c \
	src/softf32.c \
	src/mcalc.c

SRC_S = \
	src/mcalc_inic.S

OBJ = $(SRC_C:.c=.o) $(SRC_S:.S=.o) lib/motoffp_all.o lib/mcalc_fpp.o

# Ordem de link:
# 1) mcalc_inic.S
# 2) mmsj320mfp.c
# 3) softf32.c (mantido para referencia futura)
# 4) mcalc.c (usa MotoFFP via wrappers)
# 5) motoffp_all.S (MotoFFP library)
# 6) mcalc_fpp.S (bridge FPP->C)
LINK_OBJ = \
	src/mcalc_inic.o \
	src/libc_stub.o \
	src/mmsj320mfp.o \
	src/softf32.o \
	src/mcalc.o \
	lib/motoffp_all.o \
	lib/mcalc_fpp.o

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

src/mcalc_inic.o: src/mcalc_inic.S
	$(CC) $(CFLAGS) -c $< -o $@

lib/mcalc_fpp.o: lib/mcalc_fpp.S
	$(CC) $(CFLAGS) -c $< -o $@

lib/motoffp_all.o: lib/motoffp_all.S
	$(AS) $(ASFLAGS_MRI) -I $(LIB_DIR) -o $@ $<

clean:
	-cmd /c "del /q /f src\*.o lib\*.o *.o *.elf *.bin *.map *.lst 2>nul"

.PHONY: all clean flash ram
