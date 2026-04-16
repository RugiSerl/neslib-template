PROJECT_NAME = Template
ROM = $(PROJECT_NAME).nes
BUILD_DIR = bin
NESLIB_DIR = neslib
SRC_DIR = src
ASSETS_DIR = assets
CONFIG_DIR = config
TARGET = $(BUILD_DIR)/$(ROM)

CC65_ROOT = tools/cc65
CC = $(CC65_ROOT)/bin/cc65
AS = $(CC65_ROOT)/bin/ca65
LD = $(CC65_ROOT)/bin/ld65

CFLAGS = -t nes -Oirs

INCLUDE = -I $(CC65_ROOT)/include -I $(NESLIB_DIR)
ASMINC = -I $(CC65_ROOT)/libsrc/nes

SOURCES_C   = $(wildcard $(SRC_DIR)/*.c)
SOURCES_ASM = $(wildcard $(NESLIB_DIR)/*.s)
OBJS = $(SOURCES_C:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o) \
       $(SOURCES_ASM:$(NESLIB_DIR)/%.s=$(BUILD_DIR)/%.o) \
       $(BUILD_DIR)/chr_rom.o

$(TARGET): $(CONFIG_DIR)/ld65.cfg mkdir_build $(OBJS)
	$(LD) -C $(CONFIG_DIR)/ld65.cfg $(OBJS) nes.lib -m $(BUILD_DIR)/link.log -o $@

clean:
	rm -rf $(BUILD_DIR)

mkdir_build:
	if [ ! -d "$(BUILD_DIR)" ]; then mkdir $(BUILD_DIR) ; fi 

submodules:
	git submodule update --init --recursive

build_cc65: submodules
	$(MAKE) -C tools/cc65

build_tools:
	$(MAKE) -C tools

setup: build_cc65 build_tools

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) $< --add-source $(INCLUDE) -o $(BUILD_DIR)/$*.s
	$(AS) $(BUILD_DIR)/$*.s $(ASMINC) -o $@

$(BUILD_DIR)/%.o: $(NESLIB_DIR)/%.s
	$(AS) $< $(ASMINC) -o $@

$(BUILD_DIR)/%.chr: $(ASSETS_DIR)/%.png
	tools/png2chr $< ; mv $(ASSETS_DIR)/*.chr $(BUILD_DIR)

$(BUILD_DIR)/chr_rom.o: $(BUILD_DIR)/tiles.chr $(BUILD_DIR)/sprites.chr
	cp $(ASSETS_DIR)/chr_rom.s $(BUILD_DIR)/chr_rom.s
	$(AS) $(BUILD_DIR)/chr_rom.s -o $@

run: $(TARGET)
	fceux $(TARGET)
