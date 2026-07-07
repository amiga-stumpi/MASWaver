#ifndef MAS_DIRECT_H
#define MAS_DIRECT_H

#include <exec/types.h>

#define MAS_DIRECT_BUFFER_SIZE 524190UL
#define MAS_DIRECT_NEED_PREBUFFER 32768UL
#define MAS_DIRECT_STATUS_ACTIVE 1
#define MAS_DIRECT_STATUS_UNDERRUN 2

int mas_direct_prepare(void);
int mas_direct_init(void);
void mas_direct_shutdown(void);
void mas_direct_reset(void);
void mas_direct_set_volume_step(LONG volume);
void mas_direct_set_bass_step(LONG bass);
void mas_direct_set_treble_step(LONG treble);
void mas_direct_start(void);
void mas_direct_stop(void);
int mas_direct_is_active(void);
int mas_direct_had_underrun(void);
void mas_direct_clear_underrun(void);
ULONG mas_direct_buffer_free(void);
ULONG mas_direct_buffer_used(void);
ULONG mas_direct_bytes_played(void);
ULONG mas_direct_write(const UBYTE *data, ULONG len);
void mas_direct_service(void);

#endif
