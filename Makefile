CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-Os -Wall -Wextra -fomit-frame-pointer -mcrt=nix13 -fno-builtin -DAMIGA_OS13 -Iinclude -I/opt/amiga-netinclude/include
LDFLAGS=-mcrt=nix13

BUILD=build
TARGET=$(BUILD)/MASWaver
CORE=$(BUILD)/mwcore
CORE_OBJS=$(BUILD)/main.o $(BUILD)/audio_backend.o $(BUILD)/mas_direct.o $(BUILD)/mas_irq.o
LAUNCHER_OBJS=$(BUILD)/launcher.o
STREAMS=$(BUILD)/streams.txt

.PHONY: all clean

all: $(TARGET) $(CORE) $(STREAMS)

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

$(STREAMS): streams.txt | $(BUILD)
	cp streams.txt $@

clean:
	rm -rf $(BUILD)
