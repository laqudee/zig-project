const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const bulitin = std.builtin;

fn max(comptime T: type, a: T, b: T) T {
    if (T == bool) {
        return a or b;
    } else {
        return if (a > b) a else b;
    }
}

fn BiggerInt(a: u64, b: u64) u64 {
    return max(u64, a, b);
}

test "comptime generic" {
    const a: u64 = 1;
    const b: u64 = 5;
    try expect(BiggerInt(a, b) == 5);
    const c: f32 = 1.1;
    const d: f32 = 2.2;
    try expect(max(f32, c, d) == 2.2);

    try expect(max(bool, true, false) == true);
}

const CmdFn = struct {
    name: []const u8,
    func: fn (i32) i32,
};
const fnstr = [_]CmdFn{
    CmdFn{ .name = "one", .func = one },
    CmdFn{ .name = "two", .func = two },
    CmdFn{ .name = "three", .func = three },
};
fn one(v: i32) i32 {
    return v + 1;
}
fn two(v: i32) i32 {
    return v + 2;
}
fn three(v: i32) i32 {
    return v + 3;
}
fn perform(comptime ch: u8, v: i32) i32 {
    var r: i32 = v;
    comptime var i = 0;
    inline while (i < fnstr.len) : (i += 1) {
        if (fnstr[i].name[0] == ch) {
            r = fnstr[i].func(r);
        }
    }
    return r;
}

test "perform fn" {
    try expect(perform('o', 2) == 3);
    try expect(perform('t', 2) == 7);
    try expect(perform('w', 2) == 2);
}

fn fib(i: u32) u32 {
    if (i < 2) return i;
    return fib(i - 1) + fib(i - 2);
}
test "fib func" {
    try expect(fib(7) == 13);
    comptime {
        try expect(fib(7) == 13);
    }
}

const f5 = firstn(5);
const s = sum(&f5);
fn firstn(comptime n: u32) [n]u32 {
    var p1: [n]u32 = undefined;
    var i = 0;
    while (i < 5) : (i += 1) {
        p1[i] = i * 2;
    }

    return p1;
}
fn sum(num: []const u32) u32 {
    var r: u32 = 0;
    for (num) |x| {
        r += x;
    }
    return r;
}
test "variable values" {
    try expect(s == 20);
}

test "comptime pointer" {
    comptime {
        var x: i32 = 1;
        const ptr = &x;
        ptr.* += 1;
        x += 1;
        try expect(ptr.* == 3);
    }
}

test "comptime @intToPtr" {
    comptime {
        const i = 0xdeadbee0;
        const ptr: *i32 = @ptrFromInt(i);
        const addr = @intFromPtr(ptr);
        try expect(@TypeOf(addr) == usize);
        try expect(addr == 0xdeadbee0);
    }
}

fn List(comptime T: type) type {
    return struct {
        pub const Node = struct {
            next: ?*Node,
            data: T,
        };
        head: ?*Node,
        len: usize,
    };
}
const ListInt = List(i32);
test "generic" {
    var l = ListInt{ .head = null, .len = 0 };
    try expect(@TypeOf(l) == List(i32));
    var n = ListInt.Node{ .next = null, .data = 10 };
    l.head = &n;
    l.len = 1;
    try expect(l.head.?.data == 10);
}

// error
// test "not use setevalbranchquota" {
//     comptime {
//         var i = 0;
//         while (i < 1001) : (i += 1) {}
//     }
// }

// use
test "use setevalbranchquota" {
    comptime {
        @setEvalBranchQuota(1001);
        var i = 0;
        while (i < 1001) : (i += 1) {}
    }
}

// 为了防止@compilerLog遗漏在代码库中，
// 构建时@compileLog引发编译错误，这样可以防止生成代码，但不影响解析
// const num1 = blk: {
//     var val1: i32 = 99;
//     @compileLog("comptime val1 = ", val1);
//     val1 += 1;
//     break :blk val1;
// };
// test "main" {
//     @compileLog("comptime in main");
//     print("Runtime in main, num1 = {}\n", .{num1});
// }
// 如果删除所有 @compileLog 调用，或者解析没有遇到这些调用，程序就会成功编译，并测试通过
