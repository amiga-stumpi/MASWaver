#ifndef MAS_DIRECT_H
#define MAS_DIRECT_H

#include <exec/types.h>

#define MAS_DIRECT_BUFFER_SIZE 1048576UL
#define MAS_DIRECT_NEED_PREBUFFER 32768UL

int mas_direct_init(void);
void mas_direct_shutdown(void);
void mas_direct_reset(void);
void mas_direct_start(void);
void mas_direct_stop(void);
int mas_direct_is_active(void);
ULONG mas_direct_buffer_free(void);
ULONG mas_direct_buffer_used(void);
ULONG mas_direct_write(const UBYTE *data, ULONG len);
void mas_direct_service(void);

#endif
