CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-Os -Wall -Wextra -fomit-frame-pointer -mcrt=nix13 -fno-builtin -DAMIGA_OS13 -Iinclude -I/opt/amiga-netinclude/include
LDFLAGS=-mcrt=nix13

BUILD=build
TARGET=$(BUILD)/MASRadio
CORE=$(BUILD)/mcore
CORE_OBJS=$(BUILD)/main.o $(BUILD)/mas_direct.o $(BUILD)/mas_irq.o $(BUILD)/amitls13_client_stubs.o
LAUNCHER_OBJS=$(BUILD)/launcher.o
PLAYLIST=$(BUILD)/playlist.txt

.PHONY: all clean

all: $(TARGET) $(CORE) $(PLAYLIST)

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/%.o: src/%.c | $(BUILD)
	$(CC) $(CFLAGS) -c -o $@ $<

$(BUILD)/%.o: src/%.S | $(BUILD)
	$(CC) $(CFLAGS) -c -o $@ $<

$(CORE): $(CORE_OBJS)
	$(CC) $(LDFLAGS) -o $@ $(CORE_OBJS)

$(TARGET): $(LAUNCHER_OBJS)
	$(CC) $(LDFLAGS) -o $@ $(LAUNCHER_OBJS)

$(PLAYLIST): playlist.txt | $(BUILD)
	cp playlist.txt $@

clean:
	rm -rf $(BUILD)
