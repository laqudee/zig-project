const std = @import("std");

pub fn main() !void {
    const stdout =  std.io.getStdOut().writer();
    try stdout.print("Hello, {s}!\n", .{"world"});
}

test "actually undefined befavior" {
    @setRuntimeSafety(false);
    var x: u8 = 255;
    x += 1;
}