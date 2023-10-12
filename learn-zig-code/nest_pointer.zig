// 嵌套指针
const std = @import("std");

const User = struct {
    id: u64,
    power: i32,
    name: []u8,
    // []const u8 是不可变的， [] u8 是可变的
};

fn levelUp(user: User) void {
    user.name[2] = '!';
}

pub fn main() void {
    var name = [4]u8{ 'a', 'b', 'c', 'd' };
    var user = User{
        .id = 1,
        .power = 100,
        .name = name[0..],
    };
    levelUp(user);
    std.debug.print("{s}\n", .{user.name});
}
