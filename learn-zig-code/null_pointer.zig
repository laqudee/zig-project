const std = @import("std");

pub const User = struct {
    id: u64,
    power: i32,

    fn init(id: u64, power: i32) *User {
        var user = User{
            .id = id,
            .power = power,
        };
        return &user;
    }
    // init()执行完成，弹出调用栈，所有数据会被销毁，局部变量user也是，所以&user变为悬垂引用
};

pub fn main() void {
    var user1 = User.init(1, 10);
    var user2 = User.init(2, 20);

    std.debug.print("User {d} has power of {d}\n", .{ user1.id, user1.power });
    std.debug.print("User {d} has power of {d}\n", .{ user2.id, user2.power });

    // user1 继承了 user2 的值。user2变得无意义了
}
