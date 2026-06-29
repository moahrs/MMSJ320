CC = m68k-elf-gcc
AS = m68k-elf-as
OBJCOPY = m68k-elf-objcopy
OBJDUMP = m68k-elf-objdump

TARGET = monitor.elf
BIN = monitor.bin
MAP = monitor.map
LST = monitor.lst

CFLAGS = -m68000 -Wall -Os -std=gnu89 -ffreestanding -nostdlib -w -fcommon -fleading-underscore -Iinclude -Isrc -ffunction-sections -fdata-sections -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-strict-aliasing -fno-builtin
ASFLAGS_MRI = -m68000 -M --register-prefix-optional --bitwise-or
LDFLAGS = -m68000 -T linker_monitor.ld -nostdlib
LDLIBS = -lgcc

SRC_C = \
	src/libc_stub.c \
	src/mmsj320mfp.c \
	src/mmsj320vdp.c \
	src/monitor.c

SRC_A68 = \
	src/monitor_ram.a68 \
	src/monitor_fontes.a68

SRC_S = \
	src/monitor_boot.S \
	src/gcc_builtins_shim.S

OBJ = $(SRC_C:.c=.o) $(SRC_A68:.a68=.o) $(SRC_S:.S=.o)

# Ordem obrigatoria: vetores/boot primeiro, depois rotinas fixas/tabelas.
LINK_OBJ = \
	src/monitor_boot.o \
	src/monitor_ram.o \
	src/monitor_fontes.o \
	src/libc_stub.o \
	src/gcc_builtins_shim.o \
	src/mmsj320mfp.o \
	src/mmsj320vdp.o \
	src/monitor.o

all: $(TARGET) $(BIN) $(LST)

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

src/%.o: src/%.a68
	$(AS) $(ASFLAGS_MRI) -I src -o $@ $<

clean:
	-cmd /c "del /q /f src\*.o *.o *.elf *.bin *.map *.lst 2>nul"

.PHONY: all clean
