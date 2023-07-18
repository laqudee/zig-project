const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const expectError = std.testing.expectError;
const mem = std.mem;
const builtin = std.builtin;

test "switch expression" {
    const i = true;
    const j: u8 = switch (i) {
        true => 1,
        false => 0,
    };
    try expect(j == 1);
}

test "switch statement" {
    var i = true;
    switch (i) {
        true => {
            try expect(i);
        },
        false => {
            try expect(!i);
        },
    }
}

test "if expression" {
    const a: u32 = 5;
    const r = if (a != 0) 15 else 100;
    try expect(r == 15);
}

test "if nest and block" {
    const a: u32 = 5;
    const b: u32 = 10;
    if (a != b) {
        try expect(true);
    } else if (b == 10) {
        try expect(true);
    } else {
        unreachable;
    }
}

test "while basic" {
    var i: i32 = 0;
    while (i < 10) {
        i += 1;
    }
    try expect(i == 10);

    var j: i32 = 0;
    while (true) {
        if (j == 8) break;
        j += 1;
    }
    try expect(j == 8);

    var k: i32 = 0;
    var sum: i32 = 0;
    while (k < 5) : (k += 1) {
        if (k == 2) continue;
        sum += k;
    }
    try expect(sum == 8);
}

fn hasnum(num: i32) bool {
    var i: i32 = 0;
    const j = while (i < 10) : (i += 1) {
        if (i == num) {
            break true;
        }
    } else false;
    return j;
}

test "while else" {
    try expect(hasnum(5));
    try expect(!hasnum(-5));
}

// 遍历结束时运行else语句，break时则不运行
test "for" {
    var a = [_]i32{ 1, 2, 3, 4 };
    var i: i32 = 0;
    for (a) |v| {
        i += v;
    } else {
        try expect(i == 10);
    }
}

fn sw(a: u64) u64 {
    const zz: u64 = 103;
    return switch (a) {
        1, 2, 3 => 0,
        5...100 => 1,
        101 => blk: {
            const c: u64 = 5;
            break :blk c * 2 + 1;
        },
        zz => zz,
        blk: {
            const d: u32 = 5;
            const e: u32 = 100;
            break :blk d + e;
        } => 107,
        else => 9,
    };
}
test "switch simple" {
    try expect(sw(0) == 9);
    try expect(sw(1) == 0);
    try expect(sw(2) == 0);
    try expect(sw(3) == 0);
    try expect(sw(4) == 9);
    try expect(sw(5) == 1);
    try expect(sw(6) == 1);
    try expect(sw(99) == 1);
    try expect(sw(100) == 1);
    try expect(sw(101) == 11);
    try expect(sw(103) == 103);
    try expect(sw(105) == 107);
    try expect(sw(200) == 9);
}

test "condition is enum or tagged union" {
    const uni = union(enum) { a1: u32, a2: i64, a3: u32, b: bool };
    const i = uni{ .b = false };
    switch (i) {
        .a1, .a3 => {},
        uni.a2 => {},
        .b => try expect(!i.b),
    }
}

pub fn main() void {
    var i: i32 = 0;
    while (i < 5) : (i += 1) {
        if (i == 2) continue;
        print("{}\n", .{i});
    }
    var j: i32 = 1;
    while (i + j < 20) : ({
        i *= 2;
        j *= 3;
    }) {
        print("{} {}\n", .{ i, j });
    }

    labeled_loop();
}
fn labeled_loop() void {
    var i: i32 = 0;
    outer1: while (true) {
        while (i < 5) : (i += 1) {
            print("loop.1 i={} \n", .{i});
            if (i == 1) break :outer1;
        }
        print("break out,not output\n", .{});
    }
    i = 0;
    outer2: while (i < 3) : (i += 1) {
        var j: i32 = i + 1;
        while (j >= 0) : (j -= 1) {
            print("loop.2 i={},j={}\n", .{ i, j });
            if (j == 1) continue :outer2;
        }
        print("continue skip,not output\n", .{});
    }
}

test "capture v" {
    const a: i32 = 5;
    const r = switch (a) {
        0...4 => false,
        else => |v| if (v == 5) true else false,
    };
    try expect(r);
}

test "capture index" {
    const a = [_]i32{ 11, 1, 33, 44 };
    for (a, 0..) |v, i| {
        if (v == i) {
            try expect(i == 1);
        }
    }
}

test "capture pointer" {
    var a = [_]i32{ 1, 2, 3, 4 };
    for (&a) |*v| {
        v.* += 10;
    }
    const r = [_]i32{ 11, 12, 13, 14 };
    for (a, 0..) |v, i| {
        try expect(v == r[i]);
    }
}

test "capture in switch" {
    var a = [_]i32{ 11, 22, 33, 44 };
    try expect(foo(&a, 0) == 11);
    try expect(foo(&a, 1) == 22);
    try expect(foo(&a, 2) == 43);
    try expect(a[2] == 43);
}
fn foo(addr: *[4]i32, b: usize) i32 {
    switch (addr[b]) {
        0...30 => |v| return v,
        31...50 => |*v| {
            v.* += 10;
            return v.*;
        },
        else => return 100,
    }
}

test "if" {
    const i: ?i32 = 5;
    if (i) |v| {
        try expect(v == 5);
    } else {
        try expect(false);
    }

    const j: ?u32 = null;
    if (j) |_| {
        unreachable;
    } else {
        try expect(j == null);
    }
}

test "while" {
    var i: ?u32 = 5;
    var num: i32 = 0;
    while (i) |*v| : (num += 1) {
        if (v.* == 2) {
            i = null;
        } else {
            v.* -= 1;
        }
    } else {
        try expect(i == null);
        try expect(num == 4);
    }
}

test "if error union capture" {
    var a: anyerror!i32 = 1;
    if (a) |v| {
        try expect(v == 1);
    } else |_| {
        unreachable;
    }

    if (a) |v| {
        try expect(v == 1);
    } else |_| {}
    a = error.BadValue;
    if (a) |_| {} else |e| {
        try expect(e == error.BadValue);
    }
}

test "while error union capture" {
    var i: anyerror!u32 = 5;
    var num: i32 = 0;
    while (i) |*v| : (num += 1) {
        if (v.* == 2) {
            i = error.BadValue;
        } else {
            v.* -= 1;
        }
    } else |e| {
        try expect(e == error.BadValue);
        try expect(i == error.BadValue);
        try expect(num == 4);
    }
}

test "if capture values type is optional" {
    const a: anyerror!?i32 = 1;
    if (a) |v| {
        try expect(v.? == 1);
    } else |_| {}
}

test "if a pointer capture" {
    var a: anyerror!?i32 = 1;
    if (a) |*v| {
        v.*.? = 2;
    } else |_| {}
    try expect((a catch @as(i32, 0)).? == 2);
}

test "if null" {
    const a: anyerror!?i32 = null;
    if (a) |v| {
        try expect(v == null);
    } else |_| {}
}
test "if error" {
    const a: anyerror!?i32 = error.BadValue;
    if (a) |_| {} else |e| {
        try expect(e == error.BadValue);
    }
}

test "while error union" {
    var i: anyerror!?u32 = 5;
    var num: i32 = 0;
    while (i) |*v| : (num += 1) {
        if (v.*.? == 2) {
            i = error.BadValue;
        } else {
            v.*.? -= 1;
        }
    } else |e| {
        try expect(e == error.BadValue);
        try expect(i == error.BadValue);
        try expect(num == 4);
    }
}

test "inline while loop" {
    comptime var i = 0;
    var sum: usize = 0;
    inline while (i < 3) : (i += 1) {
        const T = switch (i) {
            0 => f32, // 3 => 2**3
            1 => i8, // 2 => 2**2
            2 => bool, // 4 => 2**4
            else => unreachable,
        };
        print("{}.len: {} \n", .{ T, @typeName(T).len });
        sum += @typeName(T).len;
    }
    try expect(sum == 9);
}

test "inline for loop" {
    const nums = [_]i32{ 2, 4, 6 };
    var sum: usize = 0;
    inline for (nums) |v| {
        const T = switch (v) {
            2 => f32,
            4 => i8,
            6 => bool,
            else => unreachable,
        };
        sum += @typeName(T).len;
    }
    try expect(sum == 9);
}

// 不可达unreachable
test "basic math" {
    const x = 1;
    const y = 2;
    if (x + y != 3) {
        unreachable;
    }
}
// fn assert(ok: bool) void {
//     if (!ok) unreachable;
// }
// test "this will fail" {
//     assert(false);
// }
