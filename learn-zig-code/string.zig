const std = @import("std");

pub fn main() void {
    // an array of 3 booleans with false as the sentinel value
    const a = [3:false]bool{ false, true, false };

    std.debug.print("{any}\n", .{std.mem.asBytes(&a).*});

    std.debug.print("{any}\n", .{@TypeOf(.{ .year = 2023, .mouth = 8 })});
    // out: struct{comptime year: comptime_int = 2023, comptime mouth: comptime_int = 8}
}
