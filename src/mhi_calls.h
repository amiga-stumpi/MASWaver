#ifndef MHI_CALLS_H
#define MHI_CALLS_H
#include <exec/types.h>
#include <exec/tasks.h>
APTR mhi_call_alloc_decoder(struct Task *task, ULONG signal_mask);
void mhi_call_free_decoder(APTR handle);
BOOL mhi_call_queue_buffer(APTR handle, APTR buffer, ULONG size);
APTR mhi_call_get_empty(APTR handle);
UBYTE mhi_call_get_status(APTR handle);
void mhi_call_play(APTR handle);
void mhi_call_stop(APTR handle);
void mhi_call_pause(APTR handle);
ULONG mhi_call_query(ULONG query);
void mhi_call_set_param(APTR handle, UWORD param, ULONG value);
#endif
