# MASWaver 1.3

## New features and changes since version 1.2

- Added an internal backend-neutral audio architecture.
- Added optional support for MHI-compatible MPEG audio decoder libraries.
- Added MHI playback for local MP3 files.
- Added MHI playback for HTTP MP3 streams.
- Added `audio_backend=direct|mhi|auto` to `MASWaver.conf`.
- Added `mhidevice=` for selecting an MHI decoder library by full path.
- Added `mhi=enabled` as a compatibility setting for selecting MHI mode.
- Added `auto` mode, which prefers MHI and falls back to the built-in Direct MAS backend if MHI cannot be initialized.
- Added a default MHI library path of `LIBS:MHI/prismamhi.library`.
- Added sixteen 16 KB MHI playback buffers allocated in public memory.
- Added signal-driven MHI buffer recycling and immediate refill for uninterrupted playback.
- Integrated MHI signals into the main window and all auxiliary window event loops, keeping playback active while dialogs are open.
- Added MHI support for the existing volume, bass and treble controls when provided by the selected decoder library.
- Added clean MHI decoder allocation, stop, release and library shutdown handling.
- Preserved the existing Direct MAS playback path without changing its configuration or hardware behavior.
- Preserved AmigaOS 1.3 compatibility.
