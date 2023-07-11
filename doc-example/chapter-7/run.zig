const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;
const fmt = std.fmt;

var opt: ?i32 = undefined;
test "assignment payload" {
    const i: i32 = 10;
    opt = i;
    try expect(opt == @as(?i32, 10));

    opt = null;
    try expect(opt == null);

    const j: ?i32 = 11;
    opt = j;
    try expect(opt == @as(?i32, 11));

    // var k: i32 = j;
    // try expect(k == j);
}

const oi: ?i32 = 10;
test "optional compare" {
    var oj: ?i32 = 20;
    try expect(oi != oj);
    oj = 10;
    try expect(oi == oj);

    var ok: i32 = 30;
    try expect(ok != oi);
    ok = 10;
    try expect(ok == oi);
}

test "get payload" {
    var i: ?i32 = 10;
    try expect(i.? == 10);
    i.? += 5;
    try expect(i.? == 15);
    const j = i.?;
    try expect(@TypeOf(j) == i32);
    try expect(j == 15);

    var k: ?i32 = null;
    _ = k;
}

test "null not equal to 0" {
    var i: ?i32 = null;
    var j: i32 = 0;
    try expect(i != j);
}

test "orelse payload" {
    var i: ?i32 = 5;
    const j = i orelse 10;
    try expect(j == 5);
    try expect(@TypeOf(j) == i32);
}

test "orelse null" {
    var i: ?i32 = null;
    const j = i orelse 10;
    try expect(j == 10);
    try expect(@TypeOf(j) == i32);
}

const err1 = error{
    erra0,
    erra1,
};
const err2 = error{erra0};
test "error encode" {
    const x: err1 = err1.erra0;
    const y = err2.erra0;
    try expect(x == y);

    const z = (error{ erra0, erra1 }).erra1;
    try expect(err1.erra0 != z);

    const w = error.erra0;
    const i = @intFromError(w);
    const j = @intFromError(w);
    try expect(i == j);
    try expect(@TypeOf(i) == u16);
}

const FileOpenError = error{
    AccessDenied,
    OutOfMemory,
    FileNotFound,
};
const AllocationError = error{
    OutOfMemory,
};
fn foo(err: AllocationError) FileOpenError {
    return err;
}
test "coerce subset to superset" {
    const err = foo(AllocationError.OutOfMemory);
    try expect(err == FileOpenError.OutOfMemory);
}

// 全局错误集
// anytype
// a || b
const A = error{
    NotDir,
    PathNotFound,
};
const B = error{
    OutOfMemory,
    PathNotFound,
};
const C = A || B;
fn foo1() C!void {
    return error.NotDir;
}
test "merge error sets" {
    if (foo1()) {
        @panic("unexpected");
    } else |err| switch (err) {
        error.OutOfMemory => @panic("unexpected"),
        error.PathNotFound => @panic("unexpected"),
        error.NotDir => {},
    }
}

// errset ! T
// ! T
const foo3 = error{
    notbool,
    notint,
};
fn intobool(i: i32) foo3!bool {
    if (i > 0) {
        return true;
    } else if (i == 0) {
        return false;
    } else {
        return error.notbool;
    }
}
test "error union type" {
    var r = try intobool(10);
    try expect(r == true);
    var e1: foo3 = undefined;
    _ = intobool(-10) catch |e| {
        e1 = e;
    };
    try expect(e1 == foo3.notbool);
}

test "error union catch" {
    var a: anyerror!i32 = error.notbool;
    const b1: i32 = a catch 13;
    try expect(b1 == 13);
    const b4: i32 = a catch |e| @intFromError(e);
    try expect(b4 >= 0);
    a = 1;
    const b2 = a catch 13;
    try expect(b2 == 1);
    const b3 = a catch unreachable;
    try expect(b3 == 1);
}

test "null termined array" {
    const array = [_:0]u8{ 1, 2, 3, 4 };
    try expect(@TypeOf(array) == [4:0]u8);
    try expect(array.len == 4);
    try expect(array[4] == 0);
}

pub fn main() void {
    const s1: [:0]const u8 = "hello";
    print("{} {} \n", .{ s1.len, s1[5] });
    var array = [_]u8{ 3, 2, 0, 13, 12, 0, 23, 22, 0 };
    var l: usize = 5;
    const s2 = array[0..l :0];
    print("{} {}\n", .{ s2.len, @TypeOf(s2) }); // 5 [:0]u8
    print("{} {} {} {}\n", .{ s2[2], s2[3], s2[4], s2[5] }); // 0 13 12 0

    const h: []const u8 = "hello";
    const w: []const u8 = "世界";
    var all: [100]u8 = undefined;
    const alls = all[0..];
    const hw = try fmt.bufPrint(alls, comptime "{s} {s}", .{ h, w });
    print("{s} \n", .{hw});
}

fn foo6(condition: bool, b: u32) void {
    const a = if (condition) b else return;
    _ = a;
    @panic("do something with a");
}
test "noreturn" {
    foo6(false, 1);
}

// const builtin = @import("builtin");
// const native_arch = builtin.cpu.arch;
// const WINAPI: std.builtin.CallingConvention = if (native_arch == .i386) .Stdcall else .C;
// extern "kernel32" fn ExitProcess(exit_code: c_uint) callconv(WINAPI) noreturn;
// test "foo" {
//     const value = bar() catch ExitProcess(1);
//     try expect(value == 1234);
// }
// fn bar() anyerror!u32 {
//     return 1234;
// }
