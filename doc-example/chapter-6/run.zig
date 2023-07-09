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

test "@Vector" {
    const a = @Vector(4, i32){ 1, 2, 3, 4 };
    try expect(a[2] == 3);
    try expect(@sizeOf(@TypeOf(a)) == 16);
    try expect(@sizeOf(@TypeOf(a[0])) == 4);
}

test "Vector add" {
    var i = @Vector(4, i32){ 1, 2, 3, 4 };
    const j = @Vector(4, i32){ 10, 20, 30, 40 };
    var k = i + j;
    try expect(k[2] == 33);
    try expect(@TypeOf(k) == @Vector(4, i32));
}

test "vector @splat" {
    const scalar: u32 = 5;
    const r = @splat(4, scalar);
    comptime try expect(@TypeOf(r) == @Vector(4, u32));
    try expect(std.mem.eql(u32, &@as([4]u32, r), &[_]u32{ 5, 5, 5, 5 }));
}

test "intger vector reduce" {
    var a = @Vector(4, u32){ 10, 15, 20, 25 };
    const r = @reduce(.Add, a);
    try expect(r == 70);
}

test "bool vector reduce" {
    const a = @Vector(4, i32){ 1, -1, 1, -1 };
    const b = a > @splat(4, @as(i32, 0));
    // b is {true,false,true,false}
    comptime try expect(@TypeOf(b) == @Vector(4, bool));
    const r = @reduce(.And, b);
    comptime try expect(@TypeOf(r) == bool);
    try expect(r == false);
}

const v1 = @Vector(4, u8){ 1, 2, 3, 4 };
const v2 = @Vector(4, u8){ 11, 12, 13, 14 };
const mask = @Vector(4, bool){ true, false, true, false };
test "@selct" {
    const c = @select(u8, mask, v1, v2);
    const c1 = @Vector(4, u8){ 1, 12, 3, 14 };
    const rv = (c == c1);
    const r = @reduce(.And, rv);
    try expect(r);
}

test "vector @shuffle" {
    const a = @Vector(7, u8){ 'o', 'l', 'h', 'e', 'r', 'z', 'w' };
    const b = @Vector(4, u8){ 'w', 'd', '!', 'x' };
    const mask1 = @Vector(5, i32){ 2, 3, 1, 1, 0 };
    const res1: @Vector(5, u8) = @shuffle(u8, a, undefined, mask1);
    try expect(std.mem.eql(u8, &@as([5]u8, res1), "hello"));
    const mask2 = @Vector(6, i32){ -1, 0, 4, 1, -2, -3 };
    const res2: @Vector(6, u8) = @shuffle(u8, a, b, mask2);
    try expect(std.mem.eql(u8, &@as([6]u8, res2), "world!"));
}

test "assiggnment with slice" {
    var a = [_]i32{ 1, 2, 3, 4 };
    var vec: @Vector(2, i32) = a[0..2].*;
    try expect(vec[1] == 2);
    var s: []const i32 = &a;
    var off: usize = 1;
    var vecl: @Vector(2, i32) = s[off..][0..2].*;
    try expect(vecl[0] == 2);
    try expect(vecl[1] == 3);
}
