const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var dest = allocLower(allocator, "admin");
    std.debug.print("{!s}\n", .{dest});

    // 内存泄漏
    var isSame = isSpecial(allocator, "admin");
    std.debug.print("{any}\n", .{isSame});
}

fn allocLower(allocator: Allocator, str: []const u8) ![]const u8 {
    var dest = try allocator.alloc(u8, str.len);
    errdefer allocator.free(dest);

    for (str, 0..) |c, i| {
        dest[i] = switch (c) {
            'A'...'Z' => c + 32,
            else => c,
        };
    }

    return dest;
}

fn isSpecial(allocator: Allocator, name: []const u8) !bool {
    const lower = try allocLower(allocator, name);
    defer allocator.free(lower);
    return std.mem.eql(u8, lower, "admin");
}
