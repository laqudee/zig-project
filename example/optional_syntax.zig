const std = @import("std");
const assert = std.debug.assert;

test "null @intToPtr" {
    const ptr = @intToPtr(?*i32, 0x0);
    assert(ptr == null);
}

pub fn main() void {
    const msg = "hello this is dog";
    var it = std.mem.tokenize(u8, msg, " ");
    while (it.next()) |item| {
        std.debug.print("{s}\n", .{item});
    }
}