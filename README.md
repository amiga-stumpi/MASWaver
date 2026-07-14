# MASWaver

Current release: **1.3**

MASWaver is an AmigaOS 1.3 Workbench MP3 stream player for MAS Player Pro compatible hardware.

Current build:

- Classic Intuition window
- Real Intuition button gadgets
- Reads streams from `streams.txt` in the program directory
- Clickable stream list
- Direct MAS Player hardware output based on the original MAS-Player V1.3 approach
- Large 512 KB public-memory playback ring buffer
- CIA-B timer interrupt driven MAS data output embedded in MASWaver
- Demand-driven MAS data output, using the MAS ready signal before sending data
- No `mhimaspro.library` dependency for playback
- Buffers plain HTTP MP3 data and plays it through the embedded MAS backend

Playlist syntax:

```text
Klassik Radio Beats|http://live.streams.klassikradio.de/beats-radio/stream/mp3
Station Name=http://example.com/stream.mp3
http://example.com/stream.mp3
```

Build:

```sh
make
```

Output:

```text
build/MASWaver
build/streams.txt
```

Implementation note:

The current backend uses the proven MAS-Player V1.3 style inside MASWaver: MAS hardware initialization and byte output are handled directly, while playback data is fed from a CIA-B timer interrupt. The current stable path buffers a stream chunk first and then plays it from the embedded MAS buffer.


Playback backend architecture:

MASWaver's player and streaming code uses an internal backend-neutral API. Direct MAS and optional MHI implementations share the same file, network, timing and user-interface paths, while keeping their hardware lifecycle and buffer handling isolated.

## Optional MHI backend (Phase 3)

Local MP3 files and HTTP MP3 streams can use an installed MHI decoder library. The Direct MAS backend remains available unchanged.

`MASWaver.conf` is read from the program directory:

```ini
# Existing Direct MAS behavior
audio_backend=direct

# Require MHI for files and streams
audio_backend=mhi
mhidevice=LIBS:MHI/prismamhi.library

# Prefer MHI for files and streams, fall back to Direct MAS if it cannot start
audio_backend=auto
mhidevice=LIBS:MHI/prismamhi.library
```

For compatibility, `mhi=enabled` also selects required MHI mode. MHI playback uses eight 16 KB public-memory buffers. Both file and network data are replenished immediately in the normal MASWaver event loop when the decoder returns a buffer, so Workbench windows, network traffic and playback timers remain serviced. In `auto` mode, MASWaver falls back to Direct MAS if the configured MHI decoder cannot be opened or initialized.
