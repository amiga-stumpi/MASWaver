#include <exec/types.h>
#include <exec/libraries.h>
#include <dos/dos.h>
#include <proto/dos.h>
#include <proto/exec.h>

LONG FPuts(BPTR fh, CONST_STRPTR str);

LONG __stack = 8192;

static int amitls_installed(void)
{
    struct Library *lib = OpenLibrary((STRPTR)"amitls13.library", 2);
    if (!lib) return 0;
    CloseLibrary(lib);
    return 1;
}

int main(void)
{
    LONG ok;
    if (amitls_installed()) {
        ok = Execute((STRPTR)"stack 262144\nmcore\n", 0, 0);
    } else {
        ok = Execute((STRPTR)"stack 65000\nmcore\n", 0, 0);
    }
    if (!ok) {
        FPuts(Output(), (STRPTR)"MASRadio: cannot execute mcore\n");
        return 20;
    }
    return 0;
}
