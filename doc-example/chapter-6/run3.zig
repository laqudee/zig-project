const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const expectEqualSlices = std.testing.expectEqualSlices;
const expectEqual = std.testing.expectEqual;

const foo = struct {
    x: i32,
    y: i32,
    fn nop() void {}
    const z: i64 = -5;
};
test "struct decl" {
    var f: foo = .{ .x = 3, .y = 4 };
    try expect(f.x == 3);
    f.x = f.x + f.y;
    try expect(f.x == 7);
    try expect(foo.z == -5);
    foo.nop();
}
test "struct undefined" {
    var f: foo = undefined;
    try expect(foo.z == -5);
    f.x = 13;
    f.y = foo.z;
    try expect(f.y == -5);
    foo.nop();
}

const foo2 = struct { a: i32 = 15, b: i32 };
test "default field value" {
    var f: foo2 = .{ .b = 10 };
    try expect(f.a == f.b + 5);
    var f1: foo2 = .{ .a = 5, .b = 6 };
    try expect(f1.a + f1.b == 11);
}

// struct infer type
// 匿名结构字面值是有属性名的，而元组可能没有
fn dump(args: anytype) !void {
    try expect(args.int == 1234);
    try expect(args.float == 12.34);
    try expect(args.b);
    try expect(args.s[0] == 'h');
    try expect(args.s[1] == 'i');
}
test "fully anonymous struct" {
    try dump(.{ .int = @as(u32, 1234), .float = @as(f64, 12.34), .b = true, .s = "hi" });
}

// 结构中嵌套子结构
const foo3 = struct { x: i32, y: struct {
    m: f32,
    n: struct { i: bool },
} };
test "struct nesting" {
    var f: foo3 = .{ .x = 1, .y = .{
        .m = 3.2,
        .n = .{ .i = true },
    } };
    try expect(f.y.m == 3.2);
    try expect(f.y.n.i);
}

// struct name
// 所有的结构都是匿名的。根据定义方式，可以用变量表达式、返回函数值、匿名结构字面值来命名结构类型的名称
const foo4 = struct {
    x: i32,
    y: struct { i: i8 },
};
fn list(comptime T: type) type {
    return struct { z: T };
}

pub fn main() void {
    const f = .{ .x = 1, .y = .{
        .i = @as(i8, 2),
    } };
    print("variable: {s} \n", .{@typeName(foo4)});
    print("sub struct:{s}\n", .{@typeName(@TypeOf(f.y))});
    print("anonymous:{s}\n", .{@typeName(struct {})});
    print("function:{s}\n", .{@typeName(list(i32))});
}

// 结构比特位长struct size
// 结构类型对应的内存单元（比特位长）仅包括其属性，不包括结构内定义的静态变量和函数
const foo5 = struct {
    x: i32,
    const y: i64 = 5;
    fn nop() void {}
};
test "struct size" {
    var f: foo5 = .{ .x = 1 };
    const s = @sizeOf(@TypeOf(f.x));
    try expect(@sizeOf(foo5) == s);
}

const foo6 = struct { x: i32, y: i8, z: i64 };
test "size not equal" {
    const f: foo6 = .{ .x = 1, .y = 2, .z = 3 };
    const sx = @sizeOf(@TypeOf(f.x));
    const sy = @sizeOf(@TypeOf(f.y));
    const sz = @sizeOf(@TypeOf(f.z));
    try expect(sx == 4);
    try expect(sy == 1);
    try expect(sz == 8);
    const s = @sizeOf(foo6);
    try expect(s == 16);
    try expect(s != sx + sy + sz);
}

const foo7 = struct { x: i8, y: i8 };
test "size equal" {
    const f: foo7 = .{ .x = 11, .y = 12 };
    const sx = @sizeOf(@TypeOf(f.x));
    const sy = @sizeOf(@TypeOf(f.y));
    try expect(sx == 1);
    try expect(sy == 1);
    const s = @sizeOf(foo7);
    try expect(s == 2);
    try expect(s == sx + sy);
}

// method
const foo8 = struct {
    x: i32,
    fn init(x: i32) foo8 {
        return foo8{ .x = x };
    }
    fn plus(self: foo8, p: i32) i32 {
        return self.x + p;
    }
};
test "struct method self" {
    const f = foo8.init(1);
    try expect(f.x == 1);
    const i = foo8.plus(f, 15);
    const j = f.plus(15);
    try expect(i == j);
}

// 属性数量0
const empty = struct {};
pub const mathconst = struct {
    pub const pi = 3.14;
    pub const e = 2.72;
};
test "null struct" {
    const nothing: empty = .{};
    try expect(0 == @sizeOf(@TypeOf(nothing)));
    try expect(@sizeOf(mathconst) == 0);
    const c = 2 * mathconst.pi;
    try expect(c == 6.28);
}

// get struct pointer from field pointer
// @fieldparent
const point = struct {
    x: f32,
    y: f32,
};
fn setYBaseOnX(ptrx: *f32, v: f32) void {
    const p = @fieldParentPtr(point, "x", ptrx);
    p.y = v;
}
test "fieldParentPtr" {
    var p = point{ .x = 0.1234, .y = undefined };
    setYBaseOnX(&p.x, 0.9);
    try expect(p.y == 0.9);
}

// packed struct
// 压缩结构可以用@bitCast或@ptrCast重新解读内存信息，在编译期也适用
