#ifndef AUDIO_BACKEND_H
#define AUDIO_BACKEND_H

#include <exec/types.h>

int audio_backend_prepare(void);
void audio_backend_reset(void);
void audio_backend_shutdown(void);
void audio_backend_start(void);
void audio_backend_stop(void);
int audio_backend_is_active(void);

void audio_backend_set_volume_step(LONG volume);
void audio_backend_set_bass_step(LONG bass);
void audio_backend_set_treble_step(LONG treble);

ULONG audio_backend_buffer_free(void);
ULONG audio_backend_buffer_used(void);
ULONG audio_backend_bytes_played(void);
ULONG audio_backend_write(const UBYTE *data, ULONG len);
ULONG audio_backend_min_prebuffer(void);

int audio_backend_had_underrun(void);
void audio_backend_clear_underrun(void);
void audio_backend_service(void);
const char *audio_backend_name(void);

#endif
