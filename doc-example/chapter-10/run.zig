const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
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
}
