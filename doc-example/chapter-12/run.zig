const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const expectError = std.testing.expectError;
const mem = std.mem;
const builtin = std.builtin;

// test "fn reflection" {
//     try expect(@typeInfo(@TypeOf(expect)).Fn.args[0].arg_type.? == bool);
//     try expect(@typeInfo(@TypeOf(expect)).Fn.is_var_args == false);
// }

test "@src" {
    try doTheTest();
}
fn doTheTest() !void {
    const src = @src(); // line17, column 17
    try expect(src.line == 17);
    try expect(src.column == 17);
    try expect(std.mem.endsWith(u8, src.fn_name, "doTheTest"));
    try expect(std.mem.endsWith(u8, src.file, "run.zig"));
}

test "enum reflect" {
    const foo = enum { zero, one, two };
    try expect(@typeInfo(foo).Enum.tag_type == u2);
    try expect(@typeInfo(foo).Enum.fields.len == 3);
    try expect(mem.eql(u8, @typeInfo(foo).Enum.fields[1].name, "one"));
    try expect(mem.eql(u8, @tagName(foo.two), "two"));
}

test "get tag type" {
    const fooTag = enum { ok, notok };
    const foo = union(fooTag) { ok: u8, notok: void };
    try expect(std.meta.Tag(foo) == fooTag);
    try expect(mem.eql(u8, @tagName(foo.ok), "ok"));
}

test "optional child type" {
    const i: ?i32 = 5;
    comptime try expect(@typeInfo(@TypeOf(i)).Optional.child == i32);
}

test "error union reflection" {
    var foo: anyerror!i32 = undefined;
    foo = 1234;
    foo = error.SomeError;
    comptime try expect(@typeInfo(@TypeOf(foo)).ErrorUnion.payload == i32);
    comptime try expect(@typeInfo(@TypeOf(foo)).ErrorUnion.error_set == anyerror);
}

test "pointer reflection" {
    try expect(u32 == @typeInfo(*u32).Pointer.child);
}

test "@Type" {
    try expect(i32 == @Type(@typeInfo(i32)));
}

pub fn main() void {
    print("{}\n", .{@typeInfo(u32)});

    const foo = struct { x: i32, y: i32 };
    print("{s} \n", .{@typeName(foo)});

    const e = error.OutOfMem;
    print("{s} \n", .{@errorName(e)});

    const foo3 = enum { one, two, three };
    print("{s} \n", .{@tagName(foo3.one)});
}

test "no runtime side effects" {
    var data: i32 = 0;
    const T = @TypeOf(foo2(i32, &data));
    comptime try expect(T == i32);
    try expect(data == 0);
}
fn foo2(comptime T: type, ptr: *T) T {
    ptr.* += 1;
    return ptr.*;
}

test "field access by string" {
    const Point = struct {
        x: u32,
        y: u32,
        pub var z: u32 = 1;
        const hi = 1;
    };

    var p = Point{ .x = 0, .y = 0 };
    @field(p, "x") = 4;
    @field(p, "y") = @field(p, "x") + 1;
    try expect(@field(p, "x") == 4);
    try expect(@field(p, "y") == 5);

    try expect(@field(Point, "z") == 1);
    @field(Point, "z") = 2;
    try expect(@field(Point, "z") == 2);

    try expect(!@hasField(Point, "z"));
    try expect(!@hasField(Point, "z"));
    try expect(@hasField(Point, "x"));
    try expect(!@hasDecl(Point, "nope1234"));
}

test "@hasDecl" {
    const Foo = struct {
        nope: i32,
        pub var blah = "xxx";
        const hi = 1;
    };
    try expect(@hasDecl(Foo, "blah"));
    try expect(@hasDecl(Foo, "hi"));
    try expect(!@hasDecl(Foo, "nope"));
    try expect(!@hasDecl(Foo, "nope1234"));
}

test "@sizeOf" {
    try expect(@sizeOf(i32) == 4);
    try expect(@sizeOf(type) == 0);
}

test "@alignOf" {
    const i = @alignOf(u32);
    try expect(i == 4);
    try expect(*u32 == *align(i) u32);
}

test "@offsetOf" {
    const foo = struct { x: i64, y: i32 };
    try expect(@offsetOf(foo, "x") == 0);
    try expect(@offsetOf(foo, "y") == 8);
}

test "@bitOffsetOf" {
    const foo = packed struct { w: u8, x: u3, y: u2, z: u3 };
    try expect(@offsetOf(foo, "y") == 1);
    try expect(@bitOffsetOf(foo, "y") == 11);
}

test "@bitSizeOf" {
    const foo = packed struct { w: u8, x: u3, y: u2, z: u3 };
    const f: foo = undefined;
    try expect(@bitSizeOf(i16) == 16);
    try expect(@bitSizeOf(@TypeOf(f.w)) == 8);
    try expect(@bitSizeOf(@TypeOf(f.y)) == 2);
}

fn List(comptime T: type) type {
    return struct {
        const Self = @This();
        items: []T,
        fn length(self: Self) usize {
            return self.items.len;
        }
    };
}
test "@This" {
    var items = [_]i32{ 1, 2, 3, 4 };
    const list = List(i32){ .items = items[0..] };
    try expect(list.length() == 4);
}
