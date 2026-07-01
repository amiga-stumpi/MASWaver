#include <exec/types.h>
#include <exec/memory.h>
#include <exec/interrupts.h>
#include <exec/nodes.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <graphics/gfxbase.h>
#include <string.h>

#include "mas_direct.h"

extern struct GfxBase *GfxBase;
extern void mas_interrupt_entry(void);

#define MAS_HARDWARE_PRO 2
#define MAS_INTERRUPT_NUM 13

static volatile UBYTE * const ciaa_prb = (volatile UBYTE *)0xBFE101;
static volatile UBYTE * const ciaa_ddrb = (volatile UBYTE *)0xBFE301;
static volatile UBYTE * const ciab_ddra = (volatile UBYTE *)0xBFD200;
static volatile UBYTE * const ciab_cra = (volatile UBYTE *)0xBFDE00;
static volatile UBYTE * const ciab_talo = (volatile UBYTE *)0xBFD400;
static volatile UBYTE * const ciab_tahi = (volatile UBYTE *)0xBFD500;
static volatile UBYTE * const ciab_icr = (volatile UBYTE *)0xBFDD00;

struct MasIrqState {
    UBYTE *base;
    ULONG size;
    volatile ULONG read_pos;
    volatile ULONG used;
    UBYTE hardware;
    UBYTE pad[3];
    volatile ULONG linear_pos;
    volatile ULONG status;
};

static UBYTE *g_ring;
static volatile ULONG g_write_pos;
static volatile int g_active;
static volatile int g_started;
static struct MasIrqState g_irq_state;
static struct Interrupt g_interrupt;
static int g_interrupt_added;

static void start_cia_timer_interrupt(void);
static void stop_cia_timer_interrupt(void);

static void short_delay(void)
{
    volatile UWORD i;
    for (i = 0; i < 80; ++i) { }
}

static void vbeam_delay(void)
{
    ULONG p;
    if (!GfxBase) {
        short_delay();
        return;
    }
    p = VBeamPos();
    while ((ULONG)VBeamPos() == p) { }
}

static void iic_start(void)
{
    *ciaa_prb = 0xff; vbeam_delay();
    *ciaa_prb = 0xf7; vbeam_delay();
    *ciaa_prb = 0xf3; vbeam_delay();
}

static void iic_stop(void)
{
    *ciaa_prb = 0xf3; vbeam_delay();
    *ciaa_prb = 0xf7; vbeam_delay();
    *ciaa_prb = 0xff; vbeam_delay();
}

static void iic_bit_one(void)
{
    *ciaa_prb = 0xf3; vbeam_delay();
    *ciaa_prb = 0xfb; vbeam_delay();
    *ciaa_prb = 0xff; vbeam_delay();
    *ciaa_prb = 0xfb; vbeam_delay();
    *ciaa_prb = 0xf3; vbeam_delay();
}

static void iic_bit_zero(void)
{
    *ciaa_prb = 0xf3; vbeam_delay();
    *ciaa_prb = 0xf3; vbeam_delay();
    *ciaa_prb = 0xf7; vbeam_delay();
    *ciaa_prb = 0xf3; vbeam_delay();
    *ciaa_prb = 0xf3; vbeam_delay();
}

static void iic_write_byte(UBYTE v)
{
    int i;
    for (i = 0; i < 8; ++i) {
        if (v & 0x80) iic_bit_one(); else iic_bit_zero();
        v <<= 1;
    }
    iic_bit_zero();
}

static void iic_write_cmd(const UBYTE *bytes, UWORD len)
{
    UWORD i;
    iic_start();
    for (i = 0; i < len; ++i) iic_write_byte(bytes[i]);
    iic_stop();
}

void mas_direct_reset(void)
{
    static const UBYTE ser_init[] = {0x3a,0x68,0x93,0xb0,0x00,0x02};
    static const UBYTE run_cmd[] = {0x3a,0x68,0x00,0x01};
    static const UBYTE startup[] = {0x3a,0x68,0x9e,0x62,0x00,0x00};
    UWORD i;

    *ciaa_ddrb = 0xff;
    *ciab_ddra = 0xc0;
    *ciaa_prb = 0xff;
    for (i = 0; i < 5; ++i) *ciaa_prb = 0xef;
    *ciaa_prb = 0xff;

    Delay(25);
    iic_write_cmd(ser_init, sizeof(ser_init));
    iic_write_cmd(run_cmd, sizeof(run_cmd));
    Delay(25);
    iic_write_cmd(startup, sizeof(startup));
}

int mas_direct_prepare(void)
{
    if (g_ring) return 1;
    g_ring = (UBYTE *)AllocMem(MAS_DIRECT_BUFFER_SIZE, MEMF_PUBLIC);
    if (!g_ring) return 0;
    g_write_pos = 0;
    g_active = 0;
    g_started = 0;
    g_irq_state.base = g_ring;
    g_irq_state.size = MAS_DIRECT_BUFFER_SIZE;
    g_irq_state.read_pos = 0;
    g_irq_state.used = 0;
    g_irq_state.hardware = MAS_HARDWARE_PRO;
    g_irq_state.linear_pos = 0;
    g_irq_state.status = 0;
    return 1;
}

int mas_direct_init(void)
{
    if (!mas_direct_prepare()) return 0;
    mas_direct_reset();
    return 1;
}

void mas_direct_shutdown(void)
{
    mas_direct_stop();
    if (g_ring) {
        FreeMem(g_ring, MAS_DIRECT_BUFFER_SIZE);
        g_ring = 0;
    }
}

void mas_direct_start(void)
{
    g_irq_state.status &= ~MAS_DIRECT_STATUS_UNDERRUN;
    g_irq_state.status |= MAS_DIRECT_STATUS_ACTIVE;
    g_active = 1;
    g_started = 1;
    start_cia_timer_interrupt();
}

void mas_direct_stop(void)
{
    stop_cia_timer_interrupt();
    Disable();
    g_active = 0;
    g_started = 0;
    g_irq_state.read_pos = 0;
    g_write_pos = 0;
    g_irq_state.used = 0;
    g_irq_state.linear_pos = 0;
    g_irq_state.status = 0;
    Enable();
}

int mas_direct_had_underrun(void)
{
    int r;
    Disable();
    r = (g_irq_state.status & MAS_DIRECT_STATUS_UNDERRUN) != 0;
    Enable();
    return r;
}

void mas_direct_clear_underrun(void)
{
    Disable();
    g_irq_state.status &= ~MAS_DIRECT_STATUS_UNDERRUN;
    Enable();
}

int mas_direct_is_active(void)
{
    return g_active;
}

ULONG mas_direct_buffer_free(void)
{
    ULONG free_bytes;
    Disable();
    if (g_irq_state.used >= MAS_DIRECT_BUFFER_SIZE) free_bytes = 0;
    else free_bytes = MAS_DIRECT_BUFFER_SIZE - g_irq_state.used;
    Enable();
    return free_bytes;
}

ULONG mas_direct_buffer_used(void)
{
    ULONG used;
    Disable();
    used = g_irq_state.used;
    Enable();
    return used;
}

ULONG mas_direct_write(const UBYTE *data, ULONG len)
{
    ULONG done = 0;
    if (!g_ring || !data) return 0;

    while (done < len) {
        ULONG free_bytes;
        ULONG pos;
        ULONG chunk;

        Disable();
        free_bytes = (g_irq_state.used >= MAS_DIRECT_BUFFER_SIZE) ? 0 : (MAS_DIRECT_BUFFER_SIZE - g_irq_state.used);
        pos = g_write_pos;
        Enable();

        if (!free_bytes) break;
        chunk = len - done;
        if (chunk > free_bytes) chunk = free_bytes;
        if (chunk > MAS_DIRECT_BUFFER_SIZE - pos) chunk = MAS_DIRECT_BUFFER_SIZE - pos;

        memcpy(g_ring + pos, data + done, chunk);

        Disable();
        pos += chunk;
        if (pos >= MAS_DIRECT_BUFFER_SIZE) pos = 0;
        g_write_pos = pos;
        g_irq_state.used += chunk;
        if (g_irq_state.used > MAS_DIRECT_BUFFER_SIZE) g_irq_state.used = MAS_DIRECT_BUFFER_SIZE;
        Enable();

        done += chunk;
    }
    return done;
}

static void start_cia_timer_interrupt(void)
{
    if (g_interrupt_added) return;
    memset(&g_interrupt, 0, sizeof(g_interrupt));
    g_interrupt.is_Node.ln_Type = NT_INTERRUPT;
    g_interrupt.is_Node.ln_Pri = 5;
    g_interrupt.is_Node.ln_Name = (char *)"MASRadio MAS feed";
    g_interrupt.is_Data = (APTR)&g_irq_state;
    g_interrupt.is_Code = (VOID (*)())mas_interrupt_entry;
    AddIntServer(MAS_INTERRUPT_NUM, &g_interrupt);
    *ciab_cra = 0x11;
    *ciab_talo = 0x00;
    *ciab_tahi = 0x04;
    *ciab_icr = 0x81;
    g_interrupt_added = 1;
}

static void stop_cia_timer_interrupt(void)
{
    if (!g_interrupt_added) return;
    *ciab_cra = 0x10;
    *ciab_icr = 0x81;
    RemIntServer(MAS_INTERRUPT_NUM, &g_interrupt);
    g_interrupt_added = 0;
}

void mas_direct_service(void)
{
    if (g_active && g_started && !g_interrupt_added) start_cia_timer_interrupt();
}
