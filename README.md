# MASRadio

MASRadio is an AmigaOS 1.3 Workbench MP3 stream player for MAS Player Pro compatible hardware.

Current build:

- Classic Intuition window
- Real Intuition button gadgets
- Reads streams from `playlist.txt` in the program directory
- Clickable stream list
- Direct MAS Player hardware output based on the original MAS-Player V1.3 approach
- Large 1 MB public-memory playback buffer
- CIA-B timer interrupt driven MAS data output embedded in MASRadio
- Demand-driven MAS data output, using the MAS ready signal before sending data
- No `mhimaspro.library` dependency for playback
- Buffers plain HTTP MP3 data and plays it through the embedded MAS backend
- Rejects HTTPS stream playback with a clear status message for now

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
build/MASRadio
build/playlist.txt
```

Implementation note:

The current backend uses the proven MAS-Player V1.3 style inside MASRadio: MAS hardware initialization and byte output are handled directly, while playback data is fed from a CIA-B timer interrupt. The current stable path buffers a stream chunk first and then plays it from the embedded MAS buffer.
