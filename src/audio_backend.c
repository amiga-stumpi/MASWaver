#include <exec/types.h>
#include <string.h>

#include "audio_backend.h"
#include "mas_direct.h"
#include "mhi_backend.h"

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
    void (*end_input)(void);
    ULONG (*signal_mask)(void);
    const char *(*last_error)(void);
    ULONG min_prebuffer;
    const char *name;
};

static void direct_end_input(void) { }
static ULONG direct_signal_mask(void) { return 0; }
static const char *direct_last_error(void) { return "Direct MAS initialization failed"; }

static const struct AudioBackendOps g_direct_backend = {
    mas_direct_prepare, mas_direct_reset, mas_direct_shutdown,
    mas_direct_start, mas_direct_stop, mas_direct_is_active,
    mas_direct_set_volume_step, mas_direct_set_bass_step,
    mas_direct_set_treble_step, mas_direct_buffer_free,
    mas_direct_buffer_used, mas_direct_bytes_played, mas_direct_write,
    mas_direct_had_underrun, mas_direct_clear_underrun,
    mas_direct_service, direct_end_input, direct_signal_mask,
    direct_last_error, MAS_DIRECT_NEED_PREBUFFER, "Direct MAS"
};

static const struct AudioBackendOps g_mhi_backend = {
    mhi_backend_prepare, mhi_backend_reset, mhi_backend_shutdown,
    mhi_backend_start, mhi_backend_stop, mhi_backend_is_active,
    mhi_backend_set_volume_step, mhi_backend_set_bass_step,
    mhi_backend_set_treble_step, mhi_backend_buffer_free,
    mhi_backend_buffer_used, mhi_backend_bytes_played, mhi_backend_write,
    mhi_backend_had_underrun, mhi_backend_clear_underrun,
    mhi_backend_service, mhi_backend_end_input, mhi_backend_signal_mask,
    mhi_backend_last_error, 131072UL, "MHI"
};

static const struct AudioBackendOps *g_backend = &g_direct_backend;
static int g_mode = AUDIO_BACKEND_MODE_DIRECT;

static int text_equal(const char *a, const char *b)
{
    while (*a && *b) {
        char ca = *a++;
        char cb = *b++;
        if (ca >= 'A' && ca <= 'Z') ca += 32;
        if (cb >= 'A' && cb <= 'Z') cb += 32;
        if (ca != cb) return 0;
    }
    return *a == 0 && *b == 0;
}

void audio_backend_configure(const char *mode, const char *mhi_driver)
{
    if (mode && text_equal(mode, "mhi")) g_mode = AUDIO_BACKEND_MODE_MHI;
    else if (mode && text_equal(mode, "auto")) g_mode = AUDIO_BACKEND_MODE_AUTO;
    else g_mode = AUDIO_BACKEND_MODE_DIRECT;
    mhi_backend_set_driver(mhi_driver);
}

void audio_backend_select(void)
{
    const struct AudioBackendOps *wanted = &g_direct_backend;
    if (g_mode != AUDIO_BACKEND_MODE_DIRECT) wanted = &g_mhi_backend;
    if (wanted == g_backend) return;
    g_backend->shutdown();
    g_backend = wanted;
}

int audio_backend_prepare(void)
{
    if (g_backend->prepare()) return 1;
    if (g_backend == &g_mhi_backend) {
        g_backend->shutdown();
        if (g_mode == AUDIO_BACKEND_MODE_AUTO) {
            g_backend = &g_direct_backend;
            return g_backend->prepare();
        }
    }
    return 0;
}

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
void audio_backend_end_input(void) { g_backend->end_input(); }
ULONG audio_backend_signal_mask(void) { return g_backend->signal_mask(); }
const char *audio_backend_name(void) { return g_backend->name; }
const char *audio_backend_last_error(void) { return g_backend->last_error(); }
