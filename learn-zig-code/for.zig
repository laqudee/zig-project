const std = @import("std");

pub fn main() void {
    const a = [5]u32{ 1, 2, 3, 4, 5 };
    const result = contains(&a, 3);
    std.debug.print("{?} \n", .{result});

    for_range(10);
}

fn contains(haystack: []const u32, needle: u32) ?usize {
    for (haystack, 0..) |item, i| {
        if (item == needle) {
            return i;
        }
    }
    return null;
}

fn for_range(threshold: u32) void {
    for (0..threshold) |i| {
        std.debug.print("{d}\n", .{i});
    }
}
