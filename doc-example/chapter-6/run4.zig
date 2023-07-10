const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const expectEqualSlices = std.testing.expectEqualSlices;
const expectEqual = std.testing.expectEqual;

//enum
const state = enum {
    ok,
    notok,
    const p: i32 = 1;
    fn nop() void {}
};
test "enum" {
    try expect(@intFromEnum(state.ok) == 0);
    try expect(@intFromEnum(state.notok) == 1);
    try expect(u1 == @TypeOf(@intFromEnum(state.ok)));
    const s = state.ok;
    const s1: state = .ok;
    try expect(s == s1);
    try expect(state.p == 1);
    state.nop();
}

test "enum switch" {
    var i = state.ok;
    var r = switch (i) {
        .ok => true,
        .notok => false,
    };
    try expect(r);
}

// enum tag type
test "set enum ordinal value" {
    const foo = enum(u32) { i1 = 100, i2, i3, i4 = 1100 };
    try expect(@intFromEnum(foo.i1) == 100);
    try expect(@intFromEnum(foo.i2) == 101);
    try expect(@intFromEnum(foo.i3) == 102);
    try expect(@intFromEnum(foo.i4) == 1100);
}

// 枚举方法
const foo3 = enum {
    ok,
    notok,
    fn isok(self: foo3) bool {
        return self == foo3.ok;
    }
};
test "enum Methods" {
    const f = foo3.ok;
    try expect(f.isok());
    try expect(foo3.isok(f));
}

// non-exhausitive enum
const en = enum(u8) {
    one,
    two,
    _,
};
test "switch on non-exhausting enum" {
    var f = en.one;
    var r = switch (f) {
        .one => true,
        .two => false,
        _ => false,
    };
    try expect(r);
    r = switch (f) {
        .one => true,
        else => false,
    };
    try expect(r);
    f = @enumFromInt(12);
    r = switch (f) {
        .one => false,
        .two => false,
        _ => true,
    };
    try expect(r);
}

// extern enum 不保证与C ABI接口兼容
// 明确枚举的标签类型，可以与C ABI接口兼容
const foo5 = enum(c_int) { a, b, c };
export fn entry(f: foo5) void {
    _ = f;
    _ = foo5;
}

const foo6 = union {
    score: u8,
    notscore: void,
    fn pass(self: foo6) bool {
        return self.score >= 60;
    }
};
test "union" {
    var f1 = foo6{ .score = 70 };
    try expect(foo6.pass(f1));
    f1.score = 55;
    try expect(!f1.pass());
}

// @unionInit
const foo7 = union {
    x: i32,
    y: f64,
};
test "@unionInt" {
    const i = foo7{ .x = 10 };
    const j = @unionInit(foo7, "x", 10);
    try expect(i.x == j.x);
}

// active field
test "not active field" {
    const foo = union { i: i64, f: f64, b: bool };
    var f1 = foo{ .i = 1234 };
    f1.i += 1;
    // var f2 = f1.f; // 未激活不能使用
    // _ = f2;

    // 重新激活
    f1 = foo{ .f = 12.5 };
    f1.f += 0.5;
}

// 也可以使用 @ptrCast、外部联合或压缩联合，来访问非激活属性
test "packed not active field" {
    const foo = packed union {
        i: i64,
        f: f64,
        b: bool,
    };
    var f1 = foo{ .i = 1234 };
    const f2 = f1.f;
    _ = f2;
}

// 标记联合 tagged union
const fooTag = enum { ok, notok };
const foo8 = union(fooTag) {
    ok: u8,
    notok: void,
};
test "switch on tagged union" {
    const f = foo8{ .ok = 5 };
    switch (f) {
        fooTag.ok => |v| try expect(v == 5),
        fooTag.notok => undefined,
    }
}
test "modify tagged union in switch" {
    var f = foo8{ .ok = 6 };
    switch (f) {
        .ok => |*v| v.* += 1,
        .notok => unreachable,
    }
    try expect(f.ok == 7);
}

// 推导枚举标价类型infer enum tag type
const foo9 = union(enum) {
    i: i32,
    b: bool,
    none,
    fn truthy(self: foo9) bool {
        return switch (self) {
            foo9.i => |x| x != 0,
            foo9.b => |x| x,
            foo9.none => false,
        };
    }
};
test "union method" {
    var f1 = foo9{ .i = 1 };
    var f2 = foo9{ .b = false };
    try expect(f1.truthy());
    try expect(!f2.truthy());
}

// tagged union cast
// @as
const foo10 = union(fooTag) { ok: u8, notok: void };
test "cast tag type" {
    const f = foo10{ .ok = 2 };
    try expect(@as(fooTag, f) == fooTag.ok);
}
test "coerce to enum" {
    const f1 = foo10{ .ok = 4 };
    const f2 = foo10.notok;
    try expect(f1 == .ok);
    try expect(f2 == .notok);
}
