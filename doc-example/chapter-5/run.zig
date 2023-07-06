const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;

extern fn foo_strict(x: f64) f64;
extern fn foo_optimized(x: f64) f64;

pub fn main() void {
    const x = 0.001;
    print("optimized={}\n", .{foo_optimized(x)});
    print("strict={}\n", .{foo_strict(x)});

    wrapping_add();
    saturating_add();

    addi8(5, 10);
    addi8(127, 1);
    addi8(-128, -1);

    subi8(5, 10);
    subi8(-128, 1);
    subi8(127, -1);

    muli8(5, 10);
    muli8(70, 2);
    muli8(-70, 2);
}

// 回绕加法
fn wrapping_add() void {
    var i: u8 = 255;
    print("{} {}\n", .{ i +% 1, i +% 2 }); // 0, 1
    const j: i8 = -128;
    const j1: i8 = -1;
    print("{} {}\n", .{ j +% j1, j +% (j1 - 1) }); // 127 126
}

// 饱和加法
fn saturating_add() void {
    var i: u8 = 255;
    print("{} {}\n", .{ i +| 1, i +| 2 }); // 255 255
    const j: i8 = -128;
    const j1: i8 = -1;
    print("{} {}\n", .{ j +| j1, j +| (j1 - 1) }); // -128 -128
}

//@addWithOverflow
fn addi8(a: i8, b: i8) void {
    var r: i8 = undefined;
    var ptr = &r;
    const result = @addWithOverflow(a, b);
    // print("{}\n", .{result});
    if (result[1] == 1) {
        print("{}+{} overflow, overflow result={}\n", .{ a, b, ptr.* });
    } else {
        print("{}+{} = {}\n", .{ a, b, ptr.* });
    }
}

// @subWithOverflow
fn subi8(a: i8, b: i8) void {
    var r: i8 = undefined;
    var ptr = &r;
    const result = @subWithOverflow(a, b);
    if (result[1] == 1) {
        print("{}-{} overflow, overflow result={}\n", .{ a, b, ptr.* });
    } else {
        print("{}-{} = {}\n", .{ a, b, ptr.* });
    }
}

test "wrapping negation" {
    var i: i8 = @import("std").math.minInt(i8);
    try expect(i == -128);
    var j = -%i;
    try expect(j == -128);
}

fn muli8(a: i8, b: i8) void {
    var r: i8 = undefined;
    var ptr = &r;
    const result = @mulWithOverflow(a, b);
    if (result[1] == 1) {
        print("{}*{} overflow, overflow result={}\n", .{ a, b, ptr.* });
    } else {
        print("{}*{} = {}\n", .{ a, b, ptr.* });
    }
}

test "mod" {
    try expect((5 % 2) == 1);
    // try expect((-5 % -2) == 0);
    // try expect((6.4 % 3) == 0.4);
}

test "@rem" {
    try expect(@rem(5, 2) == 1);
    try expect(@rem(-5, 2) == -1);
    const i: f32 = 0.4;
    try expect(@rem(6.4, 2) == i);
    const j: f32 = -0.4;
    try expect(@rem(-6.4, 2) == j);
    const k = try @import("std").math.rem(i8, -6, 4);
    try expect(k == -2);
}

test "@mod" {
    try expect(@mod(5, 3) == 2);
    try expect(@mod(-5, 3) == 1);
    const i: f32 = 0.4;
    try expect(@mod(6.4, 2) == i);
    const j: f32 = 1.6;
    try expect(@mod(-6.4, 2) == j);
    const k = try @import("std").math.mod(i8, -6, 4);
    try expect(k == 2);
}

test "bit shift left" {
    var i: u3 = 2;
    var j: u8 = 4;
    try expect(j << i == 16);
    j = 100;
    try expect(j << 2 == 144);
}
