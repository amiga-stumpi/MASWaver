    .text
    .globl _AmiTLS13_Init
_AmiTLS13_Init:
    move.l a6,-(sp)
    move.l _AmiTLS13Base,a6
    jsr -30(a6)
    move.l (sp)+,a6
    rts

    .globl _AmiTLS13_Exit
_AmiTLS13_Exit:
    move.l a6,-(sp)
    move.l _AmiTLS13Base,a6
    jsr -36(a6)
    move.l (sp)+,a6
    rts

    .globl _AmiTLS13_SetDebugOutput
_AmiTLS13_SetDebugOutput:
    move.l a6,-(sp)
    move.l 8(sp),d0
    move.l _AmiTLS13Base,a6
    jsr -42(a6)
    move.l (sp)+,a6
    rts

    .globl _AmiTLS13_Connect
_AmiTLS13_Connect:
    move.l a6,-(sp)
    move.l 8(sp),a0
    move.l 12(sp),d0
    move.l 16(sp),d1
    move.l _AmiTLS13Base,a6
    jsr -48(a6)
    move.l (sp)+,a6
    rts

    .globl _AmiTLS13_Write
_AmiTLS13_Write:
    move.l a6,-(sp)
    move.l 8(sp),a0
    move.l 12(sp),a1
    move.l 16(sp),d0
    move.l _AmiTLS13Base,a6
    jsr -54(a6)
    move.l (sp)+,a6
    rts

    .globl _AmiTLS13_Read
_AmiTLS13_Read:
    move.l a6,-(sp)
    move.l 8(sp),a0
    move.l 12(sp),a1
    move.l 16(sp),d0
    move.l _AmiTLS13Base,a6
    jsr -60(a6)
    move.l (sp)+,a6
    rts

    .globl _AmiTLS13_Close
_AmiTLS13_Close:
    move.l a6,-(sp)
    move.l 8(sp),a0
    move.l _AmiTLS13Base,a6
    jsr -66(a6)
    move.l (sp)+,a6
    rts

    .globl _AmiTLS13_GetLastError
_AmiTLS13_GetLastError:
    move.l a6,-(sp)
    move.l 8(sp),a0
    move.l _AmiTLS13Base,a6
    jsr -72(a6)
    move.l (sp)+,a6
    rts

    .globl _AmiTLS13_SocketErrno
_AmiTLS13_SocketErrno:
    move.l a6,-(sp)
    move.l _AmiTLS13Base,a6
    jsr -78(a6)
    move.l (sp)+,a6
    rts

    .globl _AmiTLS13_HTTPGet
_AmiTLS13_HTTPGet:
    move.l a6,-(sp)
    move.l 8(sp),a0
    move.l 12(sp),a1
    move.l 16(sp),d0
    move.l _AmiTLS13Base,a6
    jsr -84(a6)
    move.l (sp)+,a6
    rts

    .globl _AmiTLS13_SetPublicKeyPinSHA256
_AmiTLS13_SetPublicKeyPinSHA256:
    move.l a6,-(sp)
    move.l 8(sp),a0
    move.l 12(sp),d0
    move.l _AmiTLS13Base,a6
    jsr -90(a6)
    move.l (sp)+,a6
    rts

    .globl _AmiTLS13_GetLastPeerPublicKeySHA256
_AmiTLS13_GetLastPeerPublicKeySHA256:
    move.l a6,-(sp)
    move.l 8(sp),a0
    move.l 12(sp),d0
    move.l _AmiTLS13Base,a6
    jsr -96(a6)
    move.l (sp)+,a6
    rts
    .globl _AmiTLS13_StartTLS
_AmiTLS13_StartTLS:
    move.l a6,-(sp)
    move.l 8(sp),a0
    move.l 12(sp),a1
    move.l _AmiTLS13Base,a6
    jsr -102(a6)
    move.l (sp)+,a6
    rts

