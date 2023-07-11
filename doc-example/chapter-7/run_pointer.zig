const std = @import("std");

pub extern "c" fn printf(format: [*:0]const u8, ...) c_int;
pub fn main() anyerror!void {
    const msg = "hello,world\n";
    const msg1: [msg.len]u8 = msg.*;
    _ = printf(&msg);
    _ = printf(&msg1);
}
