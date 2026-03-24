# Compilador e opções
CC = m68k-elf-gcc
AS = m68k-elf-as
OBJCOPY = m68k-elf-objcopy
CFLAGS = -c
LDFLAGS = -T linker.ld -z noexecstack
OBJCOPYFLAGS = -O binary

# Arquivos
SOURCES = main.c math.c
ASM_SOURCES = startup.S
OBJECTS = $(ASM_SOURCES:.S=.o) $(SOURCES:.c=.o)
OUTPUT = output.elf
BINARY = output.bin

# Regra padrão
all: $(BINARY)

# Regra para gerar o binário
$(BINARY): $(OUTPUT)
	$(OBJCOPY) $(OBJCOPYFLAGS) $(OUTPUT) $(BINARY)

# Regra para linkar os objetos
$(OUTPUT): $(OBJECTS)
	$(CC) $(LDFLAGS) -o $(OUTPUT) $(OBJECTS)

# Regra para compilar arquivos .c
%.o: %.c
	$(CC) $(CFLAGS) $< -o $@

# Regra para compilar arquivos .S
%.o: %.S
	$(AS) $< -o $@

# Limpeza dos arquivos gerados
clean:
	rm -f $(OBJECTS) $(OUTPUT) $(BINARY)

# Fim do Makefile