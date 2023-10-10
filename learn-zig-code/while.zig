const std = @import("std");

pub fn main() void {
    const src = [_]u8{ 'a', 'b', 'c', '\\', 'd' };
    const result = while_run(&src);
    std.debug.print("{any}\n", .{result});
}

fn while_run(src: []const u8) struct { escape_count: usize, i: usize } {
    var i: usize = 0;
    var escape_count: usize = 0;
    while (i < src.len) : (i += 1) {
        if (src[i] == '\\') {
            i += 1;
            escape_count += 1;
        }
    }

    return .{ .escape_count = escape_count, .i = i };
}
