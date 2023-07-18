const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const mem = std.mem;
const builtin = std.builtin;

test "type coercion - variable declaration" {
    var a: u8 = 1;
    var b: u16 = a;
    _ = b;
}
fn foo(b: u16) void {
    _ = b;
}
test "type coercion -function call" {
    var a: u8 = 1;
    foo(a);
}

test "type coercion - @as builtin" {
    var a: u8 = 1;
    var b = @as(u16, a);
    _ = b;
}

fn foo1(_: *const i32) void {}
test "const qualification" {
    var a: i32 = 1;
    var b: *i32 = &a;
    foo1(b);
}

test "integer widening" {
    var a: u8 = 250;
    var b: u16 = a;
    var c: u32 = b;
    var d: u64 = c;
    var e: u64 = d;
    var f: u128 = e;
    try expect(f == a);
}

test "implicit unsigned integer to signed intefer" {
    var a: u8 = 250;
    var b: i16 = a;
    try expect(b == 250);
}

test "implicit cast to comptime_int" {
    var f: f32 = 54.0 / 5.0;
    _ = f;
}

test "coerce to optionals" {
    const x: ?i32 = 1234;
    const y: ?i32 = null;
    try expect(x.? == 1234);
    try expect(y == null);
}

test "coerce to optionals wrapped in error union" {
    const x: anyerror!?i32 = 1234;
    const y: anyerror!?i32 = null;
    try expect((try x).? == 1234);
    try expect((try y) == null);
}

test "coercion to error uinion" {
    const x: anyerror!i32 = 1234;
    const y: anyerror!i32 = error.Failure;
    try expect((try x) == 1234);
    try std.testing.expectError(error.Failure, y);
}

test "coercing large integer to smaller one when value is comptime know to fit" {
    const x: u64 = 255;
    const y: u8 = x;
    try expect(y == 255);
}

const E = enum { one, two, three };
const U = union(E) { one: i32, two: f32, three };
test "coercion between unions and enums" {
    var u = U{ .two = 12.34 };
    var e: E = u;
    try expect(e == E.two);
    const three = E.three;
    var otheru: U = three;
    try expect(otheru == E.three);
}

// 数组类指针互转
test "[]T to *[N]T" {
    var a = [4]i32{ 1, 2, 3, 4 };
    var s: []i32 = &(a[0..2].*);
    var a1: *[2]i32 = s.ptr[0..2];
    try expect(@TypeOf(s) == []i32);
    try expect(@TypeOf(a1) == *[2]i32);
}

test "[*]T to *[N]T" {
    var a = [4]i32{ 1, 2, 3, 4 };
    const ptr: [*]i32 = a[1..3];
    const a1: *[2]i32 = ptr[0..2];
    try expect(a1[1] == a[2]);
}

test "*[N]T to []T" {
    var a = [_]i32{ 1, 2, 3, 4 };
    var le: usize = 3;
    const s: []i32 = a[1..le];
    try expect(s[1] == a[2]);
}

test "*[N]T to [*]T" {
    var a = [_]i32{ 1, 2, 3, 4 };
    const ptr: [*]i32 = a[1..3];
    try expect(ptr[1] == a[2]);
}

test "[]T to [*]T" {
    var a = [_]i32{ 1, 2, 3, 4 };
    var le: usize = 3;
    const s: []i32 = a[1..le];
    const ptr: [*]i32 = s.ptr;
    try expect(ptr[1] == a[2]);
}

pub fn main() void {
    const bytes align(@alignOf(u32)) = [_]u8{ 0x12, 0x13, 0x14, 0x15 };
    const u32_value = mem.bytesAsSlice(u32, bytes[0..])[0];
    print("{x}", .{u32_value});
}

test "@intCast" {
    var a: u16 = 12;
    var b: u16 = @intCast(a);
    _ = b;
}

// test "@intCast panic" {
//     var a: u16 = 0xabcd;
//     var b: u8 = @intCast(a);
//     _ = b;
// }

test "integer truncation" {
    var a: u16 = 0xabcd;
    var b: u8 = @truncate(a);
    try expect(b == 0xcd);
}

test "@floatCast" {
    var i: f64 = 13.5;
    var k: f32 = @floatCast(i);
    try expect(k == 13.5);
    i = 1.8e40;
    k = @floatCast(i);
    var j: f32 = 0;
    const inf: f32 = 1.0 / j;
    try expect(k == inf);
}

test "floatToInt" {
    var f: f32 = 5.4;
    var i: u8 = @intFromFloat(f);
    try expect(i == 5);
}

const e1 = enum { one };
const e2 = enum { one, two, three, four };
const union2 = union(enum) { one: i32, two: i64 };
test "@enumToInt" {
    const i = @intFromEnum(e2.two);
    try expect(@TypeOf(i) == u2);
    try expect(i == 1);
}
test "tagged union to integer" {
    const i = @intFromEnum(union2.one);
    try expect(@TypeOf(i) == u1);
    try expect(i == 0);
}

test "one field" {
    const i = @intFromEnum(e1.one);
    try expect(@TypeOf(i) == u0);
    try expect(i == 0);
    // try expect(@TypeOf(i)==comptime_int);
}

test "integer to enum" {
    const i: i32 = 2;
    const j: e2 = @enumFromInt(i);
    try expect(j == e2.three);
}

const err1 = error{ one, two };
test "error set cast" {
    const e = error.two;
    const err0: err1 = @errSetCast(e);
    try expect(@TypeOf(err0) == err1);
}

var i_p: i32 = 0x0A0A_0A0A;
var ptr_p = &i_p;
test "cast *i8" {
    var p: *i8 = @ptrCast(ptr_p);
    try expect(p.* == 0x0A);
}

// 成对类型解析
test "peer resolve int widening" {
    var a: i8 = 12;
    var b: i16 = 34;
    var c = a + b;
    try expect(@TypeOf(c) == i16);

    try expect(mem.eql(u8, boolToStr(true), "true"));
    try expect(mem.eql(u8, boolToStr(false), "false"));
    comptime try expect(mem.eql(u8, boolToStr(true), "true"));
    comptime try expect(mem.eql(u8, boolToStr(false), "false"));
}

fn boolToStr(b: bool) []const u8 {
    return if (b) "true" else "false";
}
