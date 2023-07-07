const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;

pub fn main() void {
    try array_for();

    array_while();
}

fn array_for() !void {
    var m = [_]u8{ 4, 3, 2, 1 };
    var m1: [4]u8 = undefined;
    for (&m, 0..) |*item, i| {
        item.* += 3;
        m1[i] = m[i] * 2;
    }
    print("{any}\n", .{m});
    print("{any}\n", .{m1});
    var sum: u16 = 0;
    for (m1) |item| {
        sum += item;
    }
    print("{}\n", .{sum});
}

fn array_while() void {
    const a = [_]u8{ 1, 2, 3, 4 };
    const b = [_]u8{ 10, 20, 30, 40 };
    var c: [4]u8 = undefined;
    var i: usize = 0;
    while (i < a.len) : (i += 1) {
        c[i] = a[i] + b[i];
    }
    print("{any}\n", .{c});
}

test "array" {
    var a = [_]u8{ 10, 20 };
    try expect(a.len == 2);
    try expect(a[0] == 10);
    a[1] += 5;
    try expect(a[1] == 25);
}

// use comptime code to initialize an array
var fancy_array = init: {
    var initial_value: [10]Point = undefined;
    for (&initial_value, 0..) |*pt, i| {
        pt.* = Point{
            .x = @as(i32, @intCast(i)),
            .y = @as(i32, @intCast(i)) * 2,
        };
    }
    break :init initial_value;
};

const Point = struct {
    x: i32,
    y: i32,
};

test "compile-time array initialization" {
    try expect(fancy_array[4].x == 4);
    try expect(fancy_array[4].y == 8);
}

// call a function to initialize an array
var more_points = [_]Point{makePoint(3)} ** 10;

fn makePoint(x: i32) Point {
    return Point{
        .x = x,
        .y = x * 2,
    };
}

test "array initialization width function calls" {
    try expect(more_points[4].x == 3);
    try expect(more_points[4].y == 6);
    try expect(more_points.len == 10);
}

const mat4x4 = [4][4]f32{
    [_]f32{ 1.0, 0.0, 0.0, 0.0 },
    [_]f32{ 0.0, 1.0, 0.0, 1.0 },
    [_]f32{ 0.0, 0.0, 1.0, 0.0 },
    [_]f32{ 0.0, 0.0, 0.0, 1.0 },
};

test "multidimensional arrays" {
    try expect(mat4x4[1][1] == 1.0);
    for (mat4x4, 0..) |row, row_index| {
        for (row, 0..) |cell, column_index| {
            if (row_index == column_index) {
                try expect(cell == 1.0);
            }
        }
    }
}

// 数组粘接 concat a++b
fn aeql(comptime T: type, a: T, b: T) bool {
    for (a, 0..) |v, i| {
        if (b[i] != v) {
            return false;
        }
    }
    return true;
}

test "array concat1" {
    const a1 = [_]u32{ 1, 2 };
    const a2 = [_]u32{ 3, 4 };
    const a = a1 ++ a2;
    const b = [_]u32{ 1, 2, 3, 4 };
    try expect(aeql([4]u32, a, b));
}

test "array concat2" {
    const m = "he" ++ "--" ++ "wo";
    const n = "he--wo";
    try expect(aeql(*const [6:0]u8, m, n));
}

// 数组重复 repeat
fn arepb(comptime T: type, a: T, b: T) bool {
    for (a, 0..) |v, i| {
        if (b[i] != v) {
            return false;
        }
    }
    return true;
}

test "array repeat1" {
    const a = [_]u32{ 1, 2 } ** 2;
    const b = [_]u32{ 1, 2, 1, 2 };
    try expect(arepb([4]u32, a, b));
}

test "array repeat3" {
    const m = "abc" ** 2;
    const n = "abcabc";
    try expect(arepb(*const [6:0]u8, m, n));
}
