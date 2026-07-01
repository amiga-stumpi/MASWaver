# MASWaver

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
- Optional HTTPS stream playback through `amitls13.library`; HTTP playback remains unchanged when AmiTLS13 is not installed

Playlist syntax:

```text
Klassik Radio Beats|http://live.streams.klassikradio.de/beats-radio/stream/mp3
Station Name=http://example.com/stream.mp3
http://example.com/stream.mp3
Secure Station|https://example.com/stream.mp3
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

HTTPS support:

MASWaver opens `amitls13.library` only for `https://` playlist entries. If the library is missing, MASWaver shows a clear install message and leaves normal `http://` streaming unchanged.
