const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lookup = std.StringHashMap(User).init(allocator);
    defer lookup.deinit();

    // stdin is an std.io.Reader
    // the opposite of an std.io.Writer, which we already saw
    const stdin = std.io.getStdIn().reader();

    // stdout is an std.io.Writer
    const stdout = std.io.getStdOut().writer();

    var i: i32 = 0;
    var while_tag = true;
    while (while_tag) : (i += 1) {
        var buf: [30]u8 = undefined;
        try stdout.print("Please enter a name: ", .{});
        if (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |name| {
            std.debug.print("name: {any}\n", .{name});
            if (name.len == 1) {
                while_tag = false;
                break;
            }
            // replace the existing lookup.put with the these two lines
            const owned_name = try allocator.dupe(u8, name);
            // name -> owned_name
            try lookup.put(owned_name, .{ .power = i });
        }
    }

    // var it = lookup.iterator();
    // while (it.next()) |entry| {
    //     try stdout.print("{s} = {any}\n", .{ entry.key_ptr.*, entry.value_ptr.power });
    // }

    const has_leto = lookup.contains("Leto");
    std.debug.print("{any}\n", .{has_leto});
}

const User = struct {
    power: i32,
};
