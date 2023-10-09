const std = @import("std");
const print = std.debug.print;
const user = @import("modules/user.zig");
const User = user.User;
const MAX_POWER = user.MAX_POWER;

pub fn main() void {
    const laqudee = User{
        .power = 9001,
        .name = "Laqudee",
    };

    print("{s}'s power is {d}\n", .{ laqudee.name, laqudee.power });
    print("The maximum power is {d}", .{MAX_POWER});
}
