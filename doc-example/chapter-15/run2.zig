const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const rbuf = @embedFile("embed.txt");
    print("{s} \n", .{rbuf});
}
