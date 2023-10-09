/// 运行 命令行zig run
/// 运行测试 命令行 zig test
const print = @import("std").debug.print;
const mem = @import("std").mem;
const expect = @import("std").testing.expect;
const eql = mem.eql;
const assert = @import("std").debug.assert;

fn char_literal() void {
    print("{} {} \n", .{ 'e' == '\x65', @TypeOf('e') });
    print("{X} {} \n", .{ '语', @TypeOf('语') });
}

fn string_literal() void {
    const bytes = "hello";
    print("{} \n", .{@TypeOf(bytes)});
    print("{} {c} {} \n", .{ bytes.len, bytes[1], bytes[5] });
    print("{}   {}\n", .{ ""[0], @TypeOf("") });
}

fn string_vs_char() void {
    print("{s} {}\n", .{ "\xE8\xAF\xAD", @TypeOf("\xE8\xAF\xAD") });
    print("{X} {X} {X} {X}\n", .{ "语"[0], "语"[1], "语"[2], "语"[3] });
    print("{}\n", .{eql(u8, "语", "\xE8\xAF\xAD")});
    const i = '语';
    print("{X}\n", .{i});
}

fn multiline_string_literal() void {
    const multi_str =
        \\#include <stdio.h>
        \\
        \\int main(int argc, char **argv) {
        \\    printf("hello world\n");
        \\    return 0;
        \\}
    ;
    print("{s}", .{multi_str}); // print(fmt, argv); fmt对于字符串要加s
}

fn array_literal() !void {
    const m = [_]u8{ 'h', 'e' };
    const m1 = "he";
    comptime {
        assert(m.len == 2);
        assert(mem.eql(u8, &m, m1));
    }

    var m2 = [4]u16{ 15, 290, 30, 400 };
    assert(m2[1] == 290);
    var m3: [3]u32 = .{ 1, 2, 3 };
    assert(m3[1] == 2);
}

pub fn main() void { // 遇到返回类型!void的函数 或者改变这里的返回类型
    char_literal();
    string_literal();
    string_vs_char();
    multiline_string_literal();
    try array_literal(); // 遇到返回类型!void的函数，在调用时要使用try catch if之一
}

test "single char equal to element" {
    const str = "Zig 语言";
    try expect(str[0] == 'Z');
    try expect(str[2] == 'g');
    try expect(str[3] != '语');
}

test "string_escape" {
    try expect(eql(u8, "hello", "h\x65llo"));
    try expect(eql(u8, "--\x65--\u{8bed}--", "--e--语--"));
}

const foo = struct {
    x: u8,
    y: u64,
    var z: u64 = 5;
};
test "struct literal" {
    const f1 = foo{
        .x = 1,
        .y = 260,
    };
    try expect(f1.y == 260);
    const f2: foo = .{ .x = 2, .y = 470 };
    try expect(f2.x == 2);
    var f3: foo = .{ .x = 3, .y = undefined };
    f3.y = 50;
    try expect(f3.y == 50);
}

fn dump(args: anytype) !void {
    try expect(args.@"0" == 1234);
    try expect(args.@"1" == 12.34);
    try expect(args.@"2");
    try expect(args.@"3"[1] == 'i');
}

test "anonymous list literal" {
    try dump(.{ @as(u32, 1234), @as(f64, 12.34), true, "hi" });
}

test "tuple" {
    const args = (.{ @as(u32, 1234), @as(f64, 12.34), true, "hi" });
    try expect(args[0] == 1234);
    try expect(args[1] == 12.34);
    try expect(args[2] == true);
    try expect(args[3][1] == 'i');
}

test "inline for tuple" {
    const t = (.{ @as(u32, 1234), @as(f64, 12.34), true, "hi" });
    inline for (t, 0..) |v, i| {
        if (i != 2) continue;
        try expect(v);
    }
}

test "enum literal" {
    const foo1 = enum {
        ok,
        not_ok,
    };
    const f1 = foo1.ok;
    const f2: foo1 = .ok;
    try expect(f1 == f2);
}

test "union literal" {
    const foo2 = union { i: i32, f: f64 };
    const f1 = foo2{ .i = 15 };
    try expect(f1.i == 15);
    const f2: foo2 = .{ .f = 3.3 };
    try expect(f2.f == 3.3);
}
