const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;

pub fn main() void {
    const i: *i32 = undefined; // 无意义野指针
    print("{} \n", .{i});

    const a = [_]i32{ 1, 2, 3, 4 };
    var j = &a[1];
    print("{} \n", .{@sizeOf(i32)});
    print("{}\n", .{j});
    j = &a[2];
    print("{}\n", .{j});
}

test "derefence" {
    var i: i32 = 10;
    const j = &i;
    try expect(j.* == 10);
    j.* += 20;
    try expect(i == 30);
}

fn add(a: *i32) void {
    a.* += 5;
}
test "pointer param" {
    var i: i32 = 20;
    add(&i);
    try expect(i == 25);
}
