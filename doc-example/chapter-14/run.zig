const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const expectError = std.testing.expectError;
const mem = std.mem;
const builtin = std.builtin;
const t_al = std.testing.allocator; // 测试用内存分配器

// 通用分配器
test "GeneralPurposeAllocator" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const a1 = gpa.allocator();
    _ = a1;
    const result = gpa.deinit();
    print("{}, {} \n", .{ result, @intFromEnum(result) });
    try expect(@intFromEnum(result) == 0);
    defer if (@intFromEnum(result) == 1) @panic("memory leak");
    // const a = try a1.alloc(u8, 8);
    // defer a1.free(a);
}

// 固定缓冲区分配器
test "FixedBufferAllolcator" {
    const le: usize = 16;
    var buf: [le]u8 align(8) = undefined;
    var fba = std.heap.FixedBufferAllocator.init(buf[0..]);
    const a1 = fba.allocator();
    const a = try a1.alloc(u8, 8);
    defer a1.free(a);
}

// arena 分配器
test "ArenaAllocator" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const a = arena.allocator();
    const a1 = try a.alloc(u8, 8);
    _ = a1;
    const a2 = try a.alloc(u32, 18);
    _ = a2;
    const a3 = try a.alloc(f64, 12);
    _ = a3;
}

// 页面分配器
// 以页为单位，不用init函数，也不需要deinit函数
test "page_allocator" {
    var al = std.heap.page_allocator;
    const a1 = try al.alloc(u8, 8);
    al.free(a1);
    const a2 = try al.alloc(u32, 18);
    al.free(a2);
}

// libc分配器c_allocator
// test 时使用命令 "zig test run.zig -lc"
// test "c_allocator" {
//     var al = std.heap.c_allocator;
//     const a1 = try al.alloc(u8, 8);
//     al.free(a1);
//     const a2 = try al.alloc(u32, 18);
//     al.free(a2);
// }

// 测试用分配器
test "c_allocator" {
    var al = std.testing.allocator;
    const a1 = try al.alloc(u8, 8);
    al.free(a1);
    const a2 = try al.alloc(u32, 18);
    al.free(a2);
}

test "memory alloc - alloc free" {
    var s = try t_al.alloc(i32, 15);
    defer t_al.free(s);
    try expect(@TypeOf(s) == []i32);
    try expect(s.len == 15);
    s[3] = 10;
    try expect(s[3] == 10);
}

test "memory alloc - realloc free" {
    var s = try t_al.alloc(i32, 4);
    defer t_al.free(s);
    s = try t_al.realloc(s, 16);
    try expect(s.len == 16);
}

test "memory alloc - destroy" {
    var i = try t_al.create(i32);
    try expect(@TypeOf(i) == *i32);
    defer t_al.destroy(i);
    i.* = 15;
}

test "memory alloc - dupe" {
    const a = [4]i32{ 11, 22, 33, 44 };
    var s = try t_al.dupe(i32, &a);
    defer t_al.free(s);
    try expect(@intFromPtr(s.ptr) != @intFromPtr(&a));
    try expect(s.len == 4);
    try expect(s[2] == a[2]);
}

test "memory alloc - dupe Z" {
    const a = "hello";
    var s = try t_al.dupeZ(u8, a);
    defer t_al.free(s);
    try expect(@intFromPtr(s.ptr) != @intFromPtr(&a));
    try expect(s.len == 5);
    try expect(s[1] == 'e');
}

// @wasmMemoryGrow
// 以无符号的Wasm页面数为单位，按 delta 递增 index 标识的Wasm内存大小，每个Wasm页的大小为64KB
// const native_arch = builtin.target.cpu.arch;
// test "@wasmMemoryGrow" {
//     if (native_arch != .wasm32) return error.SkipZigTest;
//     var prev = @wasmMemorySize(0);
//     try expect(prev == @wasmMemoryGrow(0, 1));
//     try expect(prev + 1 == @wasmMemorySize(0));
// }
