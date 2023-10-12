const std = @import("std");

pub fn main() !void {
    var buf: [150]u8 = undefined;
    var fa = std.heap.FixedBufferAllocator.init(&buf);
    defer fa.reset();

    const allocator = fa.allocator();

    const json = try std.json.stringifyAlloc(allocator, .{
        .this_is = "an anonymous struct",
        .above = true,
        .last_param = "are options",
    }, .{ .whitespace = .indent_2 });

    std.debug.print("{s}\n", .{json});

    try fmt_buf_print();

    try io_writer();
}

fn fmt_buf_print() !void {
    const name = "Leto";
    var buf_new: [100]u8 = undefined;
    const greeting = try std.fmt.bufPrint(&buf_new, "Hello {s}", .{name});
    std.debug.print("{s}\n", .{greeting});
}

fn io_writer() !void {
    const out = std.io.getStdOut();

    try std.json.stringify(.{
        .this_is = "an anonymous struct",
        .above = true,
        .last_param = "are options",
    }, .{ .whitespace = .indent_2 }, out.writer());
}
