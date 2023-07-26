const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const expectError = std.testing.expectError;
const mem = std.mem;
const builtin = std.builtin;
const math = std.math;

pub fn main() void {
    // 本块内启用安全检查
    // 即使在 ReleaseFast 和 ReleaseSmall 模式下，也进行安全检查
    @setRuntimeSafety(true);
    // var y: u8 = 255;
    // y += 1;

    {
        // 安全检查是否启用可以在任何作用域内被改写，所以本块关闭安全检查，整数溢出在任何模式下不会被捕获。
        @setRuntimeSafety(false);
        var z: u8 = 255;
        z += 1;
    }
}

// fn foo(b: bool) void {
//     if (!b) unreachable;
// }
// comptime {
//     foo(false);
// }
