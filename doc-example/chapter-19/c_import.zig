const c = @cImport({
    // See https://github.com/ziglang/zig/issues/515
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("stdio.h");
});

pub fn main() void {
    _ = c.printf("hello\n");
}

// const builtin = @import("builtin");
// const c = @cImport({
//     @cDefine("NDEBUG", builtin.mode == .ReleaseFast);
//     if (something) {
//         @cDefine("_GNU_SOURCE", {});
//     }
//     @cInclude("stdlib.h");
//     if (something) {
//         @cUndef("_GNU_SOURCE");
//     }
//     @cInclude("soundio.h");
// });
