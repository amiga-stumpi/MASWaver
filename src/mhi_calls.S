    .text
    .even
    .globl _mhi_call_alloc_decoder
    .globl _mhi_call_free_decoder
    .globl _mhi_call_queue_buffer
    .globl _mhi_call_get_empty
    .globl _mhi_call_get_status
    .globl _mhi_call_play
    .globl _mhi_call_stop
    .globl _mhi_call_pause
    .globl _mhi_call_query
    .globl _mhi_call_set_param
    .extern _MHIBase

_mhi_call_alloc_decoder:
    movem.l a3/a6,-(sp)
    move.l  12(sp),a0
    move.l  16(sp),d0
    move.l  _MHIBase,a6
    jsr     -30(a6)
    movem.l (sp)+,a3/a6
    rts

_mhi_call_free_decoder:
    movem.l a3/a6,-(sp)
    move.l  12(sp),a3
    move.l  _MHIBase,a6
    jsr     -36(a6)
    movem.l (sp)+,a3/a6
    rts

_mhi_call_queue_buffer:
    movem.l a3/a6,-(sp)
    move.l  12(sp),a3
    move.l  16(sp),a0
    move.l  20(sp),d0
    move.l  _MHIBase,a6
    jsr     -42(a6)
    movem.l (sp)+,a3/a6
    rts

_mhi_call_get_empty:
    movem.l a3/a6,-(sp)
    move.l  12(sp),a3
    move.l  _MHIBase,a6
    jsr     -48(a6)
    movem.l (sp)+,a3/a6
    rts

_mhi_call_get_status:
    movem.l a3/a6,-(sp)
    move.l  12(sp),a3
    move.l  _MHIBase,a6
    jsr     -54(a6)
    movem.l (sp)+,a3/a6
    rts

_mhi_call_play:
    movem.l a3/a6,-(sp)
    move.l  12(sp),a3
    move.l  _MHIBase,a6
    jsr     -60(a6)
    movem.l (sp)+,a3/a6
    rts

_mhi_call_stop:
    movem.l a3/a6,-(sp)
    move.l  12(sp),a3
    move.l  _MHIBase,a6
    jsr     -66(a6)
    movem.l (sp)+,a3/a6
    rts

_mhi_call_pause:
    movem.l a3/a6,-(sp)
    move.l  12(sp),a3
    move.l  _MHIBase,a6
    jsr     -72(a6)
    movem.l (sp)+,a3/a6
    rts

_mhi_call_query:
    movem.l a3/a6,-(sp)
    move.l  12(sp),d1
    move.l  _MHIBase,a6
    jsr     -78(a6)
    movem.l (sp)+,a3/a6
    rts

_mhi_call_set_param:
    movem.l a3/a6,-(sp)
    move.l  12(sp),a3
    move.l  16(sp),d0
    move.l  20(sp),d1
    move.l  _MHIBase,a6
    jsr     -84(a6)
    movem.l (sp)+,a3/a6
    rts
