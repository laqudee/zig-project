pub const j = i + 3;

const i: i32 = 1;

pub fn foo() void {
    @import("std").debug.print("{} + {} = {}", .{ i, j, j + i });
}
