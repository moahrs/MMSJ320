CC = m68k-elf-gcc
AS = m68k-elf-as
OBJCOPY = m68k-elf-objcopy
OBJDUMP = m68k-elf-objdump

TARGET = mmsjos.elf
BIN = mmsjos.bin
MAP = mmsjos.map
LST = mmsjos.lst
TEXT_ORIGIN ?= 0x00800000

CFLAGS = -m68000 -Wall -Os -std=gnu89 -ffreestanding -nostdlib -w -fcommon -fleading-underscore -I../include -I../uCOSII -ffunction-sections -fdata-sections -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-strict-aliasing
ASFLAGS_MRI = -m68000 -M --register-prefix-optional --bitwise-or
LDFLAGS = -T linker_mmsjos.ld -nostdlib -Wl,--defsym=__TEXT_ORIGIN=$(TEXT_ORIGIN)
LDLIBS = -lgcc

SRC_C = \
	src/libc_stub.c \
	../uCOSII/os_cpu_c.c \
	../uCOSII/ucos_ii.c \
	src/mmsj320mfp.c \
	src/mmsjos.c \
	src/mgui.c

SRC_A68 = \
	src/mmsjos_boot.a68 \
	../uCOSII/os_cpu_a.asm \
	src/mguifunc.a68 \
	src/mmsjos_ram.a68 \
	src/mgui_sprite.a68 \
	src/mmsjos_ucosii.a68

SRC_S = \
	src/gcc_builtins_shim.S

OBJ = $(SRC_C:.c=.o) $(SRC_A68:.a68=.o) $(SRC_S:.S=.o)
OBJ := $(OBJ:.asm=.o)

# Ordem de link baseada no mmsjos.prj (obrigatoria)
# 1) mmsjos.a68
# 2) os_cpu_a.asm
# 3) os_cpu_c.c
# 4) ucos_ii.c
# 5) mguifunc.a68
# 6) mmsj320mfp.c
# 7) mmsjos.c
# 8) mgui.c
# 9) mmsjos_ram.a68
# 10) mgui_sprite.a68
# 11) mmsjos_ucosii.a68
# 12) std68k.lib (substituida por libc_stub.c + -lgcc)
LINK_OBJ = \
	src/mmsjos_boot.o \
	../uCOSII/os_cpu_a.o \
	../uCOSII/os_cpu_c.o \
	../uCOSII/ucos_ii.o \
	src/mguifunc.o \
	src/libc_stub.o \
	src/gcc_builtins_shim.o \
	src/mmsj320mfp.o \
	src/mmsjos.o \
	src/mgui.o \
	src/mmsjos_ram.o \
	src/mgui_sprite.o \
	src/mmsjos_ucosii.o

all: $(TARGET) $(BIN) $(LST)

flash: TEXT_ORIGIN=0x00020000
flash: clean all

ram: TEXT_ORIGIN=0x00800000
ram: clean all

$(TARGET): $(OBJ)
	$(CC) $(LDFLAGS) -Wl,-Map=$(MAP) -o $(TARGET) $(LINK_OBJ) $(LDLIBS)

$(BIN): $(TARGET)
	$(OBJCOPY) -O binary $(TARGET) $(BIN)

$(LST): $(TARGET)
	$(OBJDUMP) -x -d $(TARGET) > $(LST)

src/%.o: src/%.c
	$(CC) $(CFLAGS) -c $< -o $@
src/%.o: src/%.S
	$(CC) $(CFLAGS) -c $< -o $@


../uCOSII/%.o: ../uCOSII/%.c
	$(CC) $(CFLAGS) -c $< -o $@

src/%.o: src/%.a68
	$(AS) $(ASFLAGS_MRI) -I src -o $@ $<

../uCOSII/%.o: ../uCOSII/%.asm
	$(AS) $(ASFLAGS_MRI) -I ../uCOSII -o $@ $<

clean:
	-cmd /c "del /q /f src\*.o ..\uCOSII\*.o *.o *.elf *.bin *.map *.lst 2>nul"

.PHONY: all clean flash ram
