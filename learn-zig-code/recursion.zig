// 递归结构
const std = @import("std");

pub const User = struct {
    id: u64,
    power: i32,
    // changed from ?const User -> ?*const User
    manager: ?*const User,
};

pub fn main() void {
    const leto = User{
        .id = 1,
        .power = 9001,
        .manager = null,
    };
    const duncan = User{
        .id = 1,
        .power = 9001,
        .manager = &leto,
    };

    std.debug.print("{any}\n{any}\n", .{ leto, duncan });
}
