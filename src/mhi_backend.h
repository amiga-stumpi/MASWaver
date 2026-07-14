#ifndef MHI_BACKEND_H
#define MHI_BACKEND_H

#include <exec/types.h>

void mhi_backend_set_driver(const char *name);
int mhi_backend_prepare(void);
void mhi_backend_reset(void);
void mhi_backend_shutdown(void);
void mhi_backend_start(void);
void mhi_backend_stop(void);
int mhi_backend_is_active(void);
void mhi_backend_set_volume_step(LONG value);
void mhi_backend_set_bass_step(LONG value);
void mhi_backend_set_treble_step(LONG value);
ULONG mhi_backend_buffer_free(void);
ULONG mhi_backend_buffer_used(void);
ULONG mhi_backend_bytes_played(void);
ULONG mhi_backend_write(const UBYTE *data, ULONG len);
int mhi_backend_had_underrun(void);
void mhi_backend_clear_underrun(void);
void mhi_backend_service(void);
void mhi_backend_end_input(void);
ULONG mhi_backend_signal_mask(void);
const char *mhi_backend_last_error(void);

#endif
