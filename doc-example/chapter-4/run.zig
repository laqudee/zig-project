const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const Alloc = std.mem.Allocator;
const talloc = std.testing.allocator;
const expectError = std.testing.expectError;
const expectEqual = std.testing.expectEqual;
const gvar = @import("global_var.zig");
const assert = std.debug.assert;
const mem = @import("std").mem;

pub fn main() void {
    deferUnwind();

    deferError(false) catch {};
    deferError(true) catch {};
    deferErrorCap() catch {};

    var xptr: u8 align(4) = 100;
    var ptr = &xptr;
    print("{}\n", .{@TypeOf(ptr)});
    var ptr1: *u8 = ptr;
    print("{} {}\n", .{ @TypeOf(ptr1), ptr1.* }); // *u8 100
}

fn deferUnwind() void {
    defer {
        print("defer1 ", .{});
    }
    defer {
        print("defer2 ", .{});
    }
    if (false) {
        defer {
            print("defer3 ", .{});
        }
    }
}

fn deferError(i: bool) !void {
    print("{}: start of function\n", .{i});
    defer {
        print("{}: end of function\n", .{i});
    }
    errdefer {
        print("{}: encountered an error!\n", .{i});
    }
    if (i) {
        return error.DeferError;
    }
}
fn deferErrorCap() !void {
    errdefer |e| {
        print("the error is {s}\n", .{@errorName(e)});
    }
    return error.DeferError;
}

fn defer1() !i32 {
    var a: i32 = 1;
    {
        defer a = 2;
        a = 1;
    }
    try expect(a == 2);
    a = 5;
    return a;
}

test " defer basic" {
    try expect(try defer1() == 5);
}

const foo = struct { i: i32 };
fn createfoo(a: Alloc, i: i32) !*foo {
    const f = getf: {
        var f = try a.create(foo);
        errdefer a.destroy(f);
        f.i = 15;
        break :getf f;
    };
    errdefer a.destroy(f);
    if (i > 1000) return error.invalid;
    return f;
}

test "errdefer leap" {
    try expectError(error.invalid, createfoo(talloc, 1001));
}

test "comptime variable" {
    comptime var y: i32 = 1;
    y += 1;
    try expect(y == 2);
    if (y != 2) {
        @compileError("wrong y value");
    }
}

test "not comptime local var" {
    var x: i32 = 1;
    x += 1;
    try expect(x == 2);
    // if (x != 2) {
    //     @compileError("wrong x value");
    // }
    // 因x的值是运行期可知，编译期不可知，编译期不能求得 x!=2 的值，不能解析出 if(x!=2) 肯定不会运行，所以需要解析到if语句内，导致触发@compileError，编译中止
}

test "global var" {
    try expect(gvar.j == 4);
    gvar.foo();
}

test "file level var" {
    try expect(add1() == 2);
    try expect(x1 == 2);
    try expect(add2() == 4);
    try expect(x1 == 4);
}
fn add1() i32 {
    x1 += 1;
    return x1;
}
fn add2() i32 {
    x1 += 2;
    return x1;
}
var x1: i32 = 1;

test "namespaced container level variable" {
    try expect(foo1() == 1235);
    try expect(foo1() == 1236);
}
const S = struct {
    var x: i32 = 1234;
};
fn foo1() i32 {
    S.x += 1;
    return S.x;
}

test "static local variable" {
    try expect(foo2() == 1235);
    try expect(foo2() == 1236);
    try expect(foo3() == 1235);
    try expect(foo3() == 1235);
}
fn foo2() i32 {
    const S2 = struct {
        var x: i32 = 1234;
    };
    S2.x += 1;
    return S2.x;
}
fn foo3() i32 {
    var x: i32 = 1234;
    x += 1;
    return x;
}

threadlocal var xtls: i32 = 1234;
test "thread local storage" {
    const thread1 = try std.Thread.spawn(.{}, testTls, .{});
    const thread2 = try std.Thread.spawn(.{}, testTls, .{});
    testTls();
    thread1.join();
    thread2.join();
}

fn testTls() void {
    assert(xtls == 1234);
    xtls += 1;
    assert(xtls == 1235);
}

test "align value" {
    if (@import("builtin").target.cpu.arch == .x86_64) {
        try expect(4 == @typeInfo(*i32).Pointer.alignment);
        try expect(8 == @alignOf(*i32));
        try expect(8 == @alignOf(*u8));
        try expect(4 == @alignOf(i32));
        try expect(1 == @alignOf(u8));
        var x: i64 = 1;
        try expect(8 == @alignOf(@TypeOf(x)));
    }
}

fn noop() align(@sizeOf(usize) * 2) void {}
test "set align" {
    var i: u8 align(4) = 100;
    const j = &i;
    var m: u8 = 200;
    const n = &m;
    try expect(@TypeOf(j) == *align(4) u8);
    try expect(@TypeOf(n) == *u8);
    try expect(1 == @alignOf(u8));
    try expect(@TypeOf(j) != @TypeOf(n));
    try expect(@alignOf(@TypeOf(noop)) == @alignOf(usize) * 2);
    noop();
}

test "aligned struct field" {
    const S3 = struct { a: u32 align(2), b: u32 align(64) };
    var foo4 = S3{ .a = 1, .b = 2 };
    try expectEqual(64, @alignOf(S3));
    try expectEqual(*align(2) u32, @TypeOf(&foo4.a));
    try expectEqual(*align(64) u32, @TypeOf(&foo4.b));
}

test "omit ptr align" {
    var i: u16 = 1;
    var j: *u16 = &i;
    const a = @alignOf(@TypeOf(i));
    try expect(a == 2);
    try expect(*u16 == *align(a) u16);
    try expect(@TypeOf(j) == *align(a) u16);
}
