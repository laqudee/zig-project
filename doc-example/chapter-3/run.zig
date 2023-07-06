const c = @import("std").c;
const std = @import("std");
const expectEqual = @import("std").testing.expectEqual;
const expect = @import("std").testing.expect;
const testp = @import("pubfile.zig");
const builtin = @import("std").builtin;
const native_arch = builtin.cpu.arch;

pub fn main() void {}

pub extern "c" fn @"error"() void;

test "ID" {
    const i: i8 = 10;
    const @"最大月份值" = i + 2; // unicode作为标识符
    try expectEqual(12, @"最大月份值");
}

test "test pub" {
    try expect(testp.foo.x == 15);
    testp.fn2();
    // try expect(testp.foo.y==17);
    // testp.fn1();
    // try expect(testp.foo.z==18);
}

test "using std namespace" {
    const S = struct {
        usingnamespace @import("std");
    };
    try S.testing.expect(true);
}

test "test var type" {
    // var k = 5; // error: variable of type 'comptime_int' must be const or comptime
    // _ = k;
    const x: i32 = 15;
    var y = x + 3;
    try expect(@TypeOf(y) == i32);
}

test "undefined" {
    // const k;
    var x: i32 = undefined;
    _ = x;
}

test "expr and stat" {
    const i: i32 = 5;
    const j = if (i > 10) true else false;
    if (j) {
        try expect(j);
    }
}

test "block nesting and values" {
    const i = {
        const j: i32 = 0;
        {
            const k = j + 1;
            _ = k;
        }
    };
    try expect(@TypeOf(i) == void);
}
test "labeled break from labeled block expression" {
    var y: i32 = 123;
    const x = blk: {
        y += 1;
        break :blk y;
    };
    try expect(x == 124);
    try expect(y == 124);
}

fn nop() void {}

fn add(a: i8, b: i8) i8 {
    if (a == 0) {
        return b;
    }
    return a + b;
}

test "function" {
    const i = add(0, 9);
    try expect(i == 9);
    nop();
    const x: i8 = 10;
    const y: i8 = 20;
    try expect(add(x, y) == 30);
}

// fn test1(i: i32) void {
//     i += 1;
// }

// fn test2(p: *i32) void {
//     p.* += 10;
//     var i: i32 = 1;
//     p = &i;
// }

// test "change parameter" {
//     var i: i32 = 0;
//     test1(i);
//     test2(&i);
// }

fn add2(x: anytype) @TypeOf(x) {
    return x + 42;
}

test "fn type inference" {
    try expect(add2(1) == 43);
    try expect(@TypeOf(add2(1)) == comptime_int);
    var y: i64 = 2;
    try expect(add2(y) == 44);
    try expect(@TypeOf(add2(y)) == i64);
}

const WINAPI: std.builtin.CallingConvention = if (native_arch == .i386) .Stdcall else .C;
extern "kernel32" fn ExitProcess(exit_code: u32) callconv(WINAPI) noreturn;
extern "c" fn atan2(a: f64, b: f64) f64;

export fn sub(a: i8, b: i8) i8 {
    return a - b;
}
pub fn sub2(a: i8, b: i8) i8 {
    return a - b;
}
fn _start() callconv(.Naked) noreturn {
    abort();
}
inline fn shiftl1(a: u32) u32 {
    return a << 1;
}
fn abort() noreturn {
    @setCold(true);
    while (true) {}
}
test "function specifier" {
    try expect(true);
}

fn add3(a: i32, b: i32) i32 {
    return a + b;
}
test "noinline function call" {
    try expect(@call(std.builtin.CallModifier.auto, add3, .{ 3, 9 }) == 12);
}
