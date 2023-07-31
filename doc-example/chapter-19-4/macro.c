
#define MAKELOCAL(NAME, INIT) int NAME = INIT
int foo(void)
{
    MAKELOCAL(a, 1);
    MAKELOCAL(b, 2);
    return a + b;
}

// use
// zig translate-c macro.c > macro.zig