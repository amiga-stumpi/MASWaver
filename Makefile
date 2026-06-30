CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-Os -Wall -Wextra -fomit-frame-pointer -mcrt=nix13 -fno-builtin -DAMIGA_OS13 -Iinclude -I/opt/amiga-netinclude/include
LDFLAGS=-mcrt=nix13

BUILD=build
TARGET=$(BUILD)/MASRadio
OBJS=$(BUILD)/main.o $(BUILD)/mas_direct.o $(BUILD)/mas_irq.o
PLAYLIST=$(BUILD)/playlist.txt
REF_MAS_INIT=$(BUILD)/MAS-Init
REF_MAS_PLAY=$(BUILD)/MAS-Play
REF_MAS_SAMPLE=$(BUILD)/Sound96kbps.MP3

.PHONY: all clean

all: $(TARGET) $(PLAYLIST) $(REF_MAS_INIT) $(REF_MAS_PLAY) $(REF_MAS_SAMPLE)

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/%.o: src/%.c | $(BUILD)
	$(CC) $(CFLAGS) -c -o $@ $<

$(BUILD)/%.o: src/%.S | $(BUILD)
	$(CC) $(CFLAGS) -c -o $@ $<

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS)

$(PLAYLIST): playlist.txt | $(BUILD)
	cp playlist.txt $@

$(REF_MAS_INIT): cli-commands/MAS-Init | $(BUILD)
	cp cli-commands/MAS-Init $@

$(REF_MAS_PLAY): cli-commands/MAS-Play | $(BUILD)
	cp cli-commands/MAS-Play $@

$(REF_MAS_SAMPLE): MAS-PlayerV1.3/Source/Sound96kbps.MP3 | $(BUILD)
	cp MAS-PlayerV1.3/Source/Sound96kbps.MP3 $@

clean:
	rm -rf $(BUILD)
