#include <exec/types.h>
#include <dos/dos.h>
#include <proto/dos.h>

LONG FPuts(BPTR fh, CONST_STRPTR str);

LONG __stack = 8192;

int main(void)
{
    LONG ok;
    ok = Execute((STRPTR)"stack 65000\nmwcore\n", 0, 0);
    if (!ok) {
        FPuts(Output(), (STRPTR)"MASWaver: cannot execute mwcore\n");
        return 20;
    }
    return 0;
}
