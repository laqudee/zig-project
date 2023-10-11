const std = @import("std");

pub const User = struct {
    id: u64,
    power: i32,

    fn levelUpSelf(user: *User) void {
        user.power += 1;
    }
};

fn levelUp(user: *User) void {
    user.power += 1;
}

pub fn main() void {
    var user = User{
        .id = 1,
        .power = 100,
    };

    // this line has been added
    levelUp(&user);

    // method
    user.levelUpSelf();

    std.debug.print("User {d} has power of {d}\n", .{ user.id, user.power });

    std.debug.print("{*}\n{*}\n{*}\n", .{ &user, &user.id, &user.power });

    const user_p = &user;
    std.debug.print("{any}\n", .{@TypeOf(user_p)});
}
