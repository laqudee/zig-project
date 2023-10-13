const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var arr = std.ArrayList(User).init(allocator);
    defer {
        for (arr.items) |user| {
            user.deinit(allocator);
        }
        arr.deinit();
    }

    // stdin is an std.io.Reader
    // the opposite of an std.io.Writer, which we already saw
    const stdin = std.io.getStdIn().reader();

    // stdout is an std.io.Writer
    const stdout = std.io.getStdOut().writer();

    var i: i32 = 0;
    while (true) : (i += 1) {
        var buf: [30]u8 = undefined;
        try stdout.print("Please enter a name: ", .{});
        if (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |name| {
            if (name.len == 1 or name[0] == 'q') {
                break;
            }
            std.debug.print("type of {s}\n", .{name});
            const owned_name = try allocator.dupe(u8, name);
            std.debug.print("type of {s}\n", .{owned_name});
            try arr.append(.{ .name = owned_name, .power = i });
            std.debug.print("{any}\n", .{arr.items});
        }
    }

    var has_leto = false;
    for (arr.items) |user| {
        std.debug.print("name = {s}\n", .{user.name});
        var name_text = "Leto";
        if (std.mem.eql(u8, user.name, name_text)) {
            has_leto = true;
            break;
        }
    }

    std.debug.print("{any}\n", .{has_leto});
}

const User = struct {
    name: []const u8,
    power: i32,

    fn deinit(self: User, allocator: Allocator) void {
        allocator.free(self.name);
    }
};
