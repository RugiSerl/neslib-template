PROJECT_NAME = Template
ROM = $(PROJECT_NAME).nes
BUILD_DIR = bin
TARGET = $(BUILD_DIR)/$(ROM)

CC65_ROOT = tools/cc65
CC = $(CC65_ROOT)/bin/cc65
AS = $(CC65_ROOT)/bin/ca65
LD = $(CC65_ROOT)/bin/ld65

CFLAGS = -t nes -Oirs

INCLUDE = $(CC65_ROOT)/include
ASMINC = $(CC65_ROOT)/libsrc/nes

SRC = main.c
ASMSRC = neslib/crt0.s
OBJS = $(ASMSRC:.s=.o) $(SRC:.c=.o) chr_rom.o

$(TARGET): ld65.cfg $(OBJS) mkdir_build
	$(LD) -C ld65.cfg $(OBJS) nes.lib -m link.log -o $@

clean:
	rm -rf $(BUILD_DIR)
	rm -f *.chr
	rm -f link.log

mkdir_build:
	if [ ! -d "$(BUILD_DIR)" ]; then mkdir $(BUILD_DIR) ; fi 

submodules:
	git submodule update --init --recursive

build_cc65: submodules
	pushd tools/cc65; make; popd

build_tools:
	pushd tools; make; popd

setup: build_cc65 build_tools


%.s: %.c
	$(CC) $(CFLAGS) $< --add-source -I $(INCLUDE) -o $@

%.o: %.s
	$(AS) $< -I $(ASMINC) -o $@

%.chr: %.png
	tools/png2chr $<

chr_rom.o: tiles.chr sprites.chr

# Cancel built in rule for .c files.
%.o: %.c

run: $(ROM)
	fceux $(ROM)
