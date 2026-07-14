#include <exec/types.h>

#include "audio_backend.h"
#include "mas_direct.h"

struct AudioBackendOps {
    int (*prepare)(void);
    void (*reset)(void);
    void (*shutdown)(void);
    void (*start)(void);
    void (*stop)(void);
    int (*is_active)(void);
    void (*set_volume)(LONG value);
    void (*set_bass)(LONG value);
    void (*set_treble)(LONG value);
    ULONG (*buffer_free)(void);
    ULONG (*buffer_used)(void);
    ULONG (*bytes_played)(void);
    ULONG (*write)(const UBYTE *data, ULONG len);
    int (*had_underrun)(void);
    void (*clear_underrun)(void);
    void (*service)(void);
    ULONG min_prebuffer;
    const char *name;
};

static const struct AudioBackendOps g_direct_backend = {
    mas_direct_prepare,
    mas_direct_reset,
    mas_direct_shutdown,
    mas_direct_start,
    mas_direct_stop,
    mas_direct_is_active,
    mas_direct_set_volume_step,
    mas_direct_set_bass_step,
    mas_direct_set_treble_step,
    mas_direct_buffer_free,
    mas_direct_buffer_used,
    mas_direct_bytes_played,
    mas_direct_write,
    mas_direct_had_underrun,
    mas_direct_clear_underrun,
    mas_direct_service,
    MAS_DIRECT_NEED_PREBUFFER,
    "Direct MAS"
};

static const struct AudioBackendOps *g_backend = &g_direct_backend;

int audio_backend_prepare(void) { return g_backend->prepare(); }
void audio_backend_reset(void) { g_backend->reset(); }
void audio_backend_shutdown(void) { g_backend->shutdown(); }
void audio_backend_start(void) { g_backend->start(); }
void audio_backend_stop(void) { g_backend->stop(); }
int audio_backend_is_active(void) { return g_backend->is_active(); }
void audio_backend_set_volume_step(LONG value) { g_backend->set_volume(value); }
void audio_backend_set_bass_step(LONG value) { g_backend->set_bass(value); }
void audio_backend_set_treble_step(LONG value) { g_backend->set_treble(value); }
ULONG audio_backend_buffer_free(void) { return g_backend->buffer_free(); }
ULONG audio_backend_buffer_used(void) { return g_backend->buffer_used(); }
ULONG audio_backend_bytes_played(void) { return g_backend->bytes_played(); }
ULONG audio_backend_write(const UBYTE *data, ULONG len) { return g_backend->write(data, len); }
ULONG audio_backend_min_prebuffer(void) { return g_backend->min_prebuffer; }
int audio_backend_had_underrun(void) { return g_backend->had_underrun(); }
void audio_backend_clear_underrun(void) { g_backend->clear_underrun(); }
void audio_backend_service(void) { g_backend->service(); }
const char *audio_backend_name(void) { return g_backend->name; }
