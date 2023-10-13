const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // User -> *const User
    // 传User改为传User的指针
    var lookup = std.StringHashMap(*const User).init(allocator);
    defer lookup.deinit();

    const goku = User{ .power = 9001 };

    // goku -> &goku
    try lookup.put("Goku", &goku);

    // getPtr -> get
    // 复制地址，而不是得到完整的User
    const entry = lookup.get("Goku").?;

    std.debug.print("Goku's power is: {d}\n", .{entry.power});
    _ = lookup.remove("Goku");
    std.debug.print("Goku's power is: {d}\n", .{entry.power});
}

const User = struct {
    power: i32,
};
