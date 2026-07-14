#include <exec/types.h>
#include <exec/libraries.h>
#include <exec/memory.h>
#include <proto/exec.h>
#include <libraries/mhi.h>
#include "mhi_calls.h"
#include <string.h>

#include "mhi_backend.h"

#define MHI_BUFFER_COUNT 8
#define MHI_BUFFER_SIZE 16384UL
#define MHI_DRIVER_NAME_SIZE 128

struct Library *MHIBase;

static UBYTE *g_buffers[MHI_BUFFER_COUNT];
static ULONG g_lengths[MHI_BUFFER_COUNT];
static UBYTE g_states[MHI_BUFFER_COUNT];
static char g_driver[MHI_DRIVER_NAME_SIZE] = "DEVS:MHI/prismamhi.device";
static char g_error[96];
static APTR g_handle;
static BYTE g_signal = -1;
static ULONG g_signal_mask;
static ULONG g_buffered;
static ULONG g_played;
static int g_active;
static int g_input_ended;

static void set_error(const char *text)
{
    if (!text) text = "MHI error";
    strncpy(g_error, text, sizeof(g_error) - 1);
    g_error[sizeof(g_error) - 1] = 0;
}

static int buffer_index(APTR ptr)
{
    int i;
    for (i = 0; i < MHI_BUFFER_COUNT; ++i) {
        if (g_buffers[i] == ptr) return i;
    }
    return -1;
}

static void reset_buffers(void)
{
    int i;
    for (i = 0; i < MHI_BUFFER_COUNT; ++i) {
        g_states[i] = 0;
        g_lengths[i] = 0;
    }
    g_buffered = 0;
    g_played = 0;
    g_input_ended = 0;
}

static int allocate_buffers(void)
{
    int i;
    for (i = 0; i < MHI_BUFFER_COUNT; ++i) {
        if (!g_buffers[i]) {
            g_buffers[i] = (UBYTE *)AllocMem(MHI_BUFFER_SIZE, MEMF_PUBLIC);
            if (!g_buffers[i]) return 0;
        }
    }
    return 1;
}

static void free_buffers(void)
{
    int i;
    for (i = 0; i < MHI_BUFFER_COUNT; ++i) {
        if (g_buffers[i]) {
            FreeMem(g_buffers[i], MHI_BUFFER_SIZE);
            g_buffers[i] = 0;
        }
    }
    reset_buffers();
}

static int queue_buffer(int index)
{
    if (!g_handle || index < 0 || index >= MHI_BUFFER_COUNT ||
        g_states[index] != 1 || g_lengths[index] == 0) return 0;
    if (!mhi_call_queue_buffer(g_handle, g_buffers[index], g_lengths[index])) {
        set_error("MHI buffer queue failed");
        return 0;
    }
    g_states[index] = 2;
    return 1;
}

static void queue_partial_buffers(void)
{
    int i;
    for (i = 0; i < MHI_BUFFER_COUNT; ++i) {
        if (g_states[i] == 1 && g_lengths[i] > 0) queue_buffer(i);
    }
}

static void reclaim_buffers(void)
{
    APTR ptr;
    int index;
    if (!g_handle) return;
    while ((ptr = mhi_call_get_empty(g_handle)) != 0) {
        index = buffer_index(ptr);
        if (index >= 0 && g_states[index] == 2) {
            if (g_buffered >= g_lengths[index]) g_buffered -= g_lengths[index];
            else g_buffered = 0;
            g_played += g_lengths[index];
            g_lengths[index] = 0;
            g_states[index] = 0;
        }
    }
}

void mhi_backend_set_driver(const char *name)
{
    if (!name || !name[0]) return;
    strncpy(g_driver, name, sizeof(g_driver) - 1);
    g_driver[sizeof(g_driver) - 1] = 0;
}

int mhi_backend_prepare(void)
{
    g_error[0] = 0;
    if (!MHIBase) {
        MHIBase = OpenLibrary((STRPTR)g_driver, 0);
        if (!MHIBase) { set_error("MHI driver open failed"); return 0; }
    }
    if (g_signal < 0) {
        g_signal = AllocSignal(-1);
        if (g_signal < 0) { set_error("No signal available for MHI"); return 0; }
        g_signal_mask = 1UL << g_signal;
    }
    if (!allocate_buffers()) { set_error("MHI buffer allocation failed"); return 0; }
    reset_buffers();
    if (!g_handle) {
        g_handle = mhi_call_alloc_decoder(FindTask(0), g_signal_mask);
        if (!g_handle) { set_error("MHI decoder allocation failed"); return 0; }
    }
    return 1;
}

void mhi_backend_reset(void)
{
}

void mhi_backend_start(void)
{
    if (!g_handle) return;
    queue_partial_buffers();
    mhi_call_play(g_handle);
    g_active = 1;
}

void mhi_backend_stop(void)
{
    if (g_handle) {
        mhi_call_stop(g_handle);
        mhi_call_free_decoder(g_handle);
        g_handle = 0;
    }
    g_active = 0;
    reset_buffers();
}

void mhi_backend_shutdown(void)
{
    mhi_backend_stop();
    free_buffers();
    if (g_signal >= 0) {
        FreeSignal(g_signal);
        g_signal = -1;
        g_signal_mask = 0;
    }
    if (MHIBase) {
        CloseLibrary(MHIBase);
        MHIBase = 0;
    }
}

int mhi_backend_is_active(void) { return g_active; }

void mhi_backend_set_volume_step(LONG value)
{
    if (value < 0) value = 0;
    if (value > 10) value = 10;
    if (g_handle && mhi_call_query(MHIQ_VOLUME_CONTROL) == MHIF_SUPPORTED)
        mhi_call_set_param(g_handle, MHIP_VOLUME, (ULONG)(value * 10));
}

void mhi_backend_set_bass_step(LONG value)
{
    if (value < -5) value = -5;
    if (value > 5) value = 5;
    if (g_handle && mhi_call_query(MHIQ_BASS_CONTROL) == MHIF_SUPPORTED)
        mhi_call_set_param(g_handle, MHIP_BASS, (ULONG)((value + 5) * 10));
}

void mhi_backend_set_treble_step(LONG value)
{
    if (value < -5) value = -5;
    if (value > 5) value = 5;
    if (g_handle && mhi_call_query(MHIQ_TREBLE_CONTROL) == MHIF_SUPPORTED)
        mhi_call_set_param(g_handle, MHIP_TREBLE, (ULONG)((value + 5) * 10));
}

ULONG mhi_backend_buffer_free(void)
{
    ULONG free_bytes = 0;
    int i;
    reclaim_buffers();
    for (i = 0; i < MHI_BUFFER_COUNT; ++i) {
        if (g_states[i] == 0) free_bytes += MHI_BUFFER_SIZE;
        else if (g_states[i] == 1) free_bytes += MHI_BUFFER_SIZE - g_lengths[i];
    }
    return free_bytes;
}

ULONG mhi_backend_buffer_used(void)
{
    reclaim_buffers();
    return g_buffered;
}

ULONG mhi_backend_bytes_played(void)
{
    reclaim_buffers();
    return g_played;
}

ULONG mhi_backend_write(const UBYTE *data, ULONG len)
{
    ULONG done = 0;
    int i;
    if (!g_handle || !data) return 0;
    reclaim_buffers();
    while (done < len) {
        int index = -1;
        ULONG room;
        ULONG part;
        for (i = 0; i < MHI_BUFFER_COUNT; ++i) {
            if (g_states[i] == 1 && g_lengths[i] < MHI_BUFFER_SIZE) { index = i; break; }
        }
        if (index < 0) {
            for (i = 0; i < MHI_BUFFER_COUNT; ++i) {
                if (g_states[i] == 0) { index = i; g_states[i] = 1; break; }
            }
        }
        if (index < 0) break;
        room = MHI_BUFFER_SIZE - g_lengths[index];
        part = len - done;
        if (part > room) part = room;
        memcpy(g_buffers[index] + g_lengths[index], data + done, part);
        g_lengths[index] += part;
        g_buffered += part;
        done += part;
        if (g_lengths[index] == MHI_BUFFER_SIZE && !queue_buffer(index))
            return done - part;
    }
    if (g_active && g_handle && mhi_call_get_status(g_handle) == MHIF_OUT_OF_DATA) {
        queue_partial_buffers();
        mhi_call_play(g_handle);
    }
    return done;
}

int mhi_backend_had_underrun(void)
{
    if (!g_active || !g_handle) return 0;
    reclaim_buffers();
    return mhi_call_get_status(g_handle) == MHIF_OUT_OF_DATA && g_buffered == 0 && !g_input_ended;
}

void mhi_backend_clear_underrun(void)
{
}

void mhi_backend_service(void)
{
    if (!g_handle) return;
    reclaim_buffers();
    if (g_input_ended) queue_partial_buffers();
    if (g_active && g_buffered > 0 && mhi_call_get_status(g_handle) == MHIF_OUT_OF_DATA)
        mhi_call_play(g_handle);
}

void mhi_backend_end_input(void)
{
    g_input_ended = 1;
    queue_partial_buffers();
}

ULONG mhi_backend_signal_mask(void) { return g_signal_mask; }
const char *mhi_backend_last_error(void) { return g_error; }
