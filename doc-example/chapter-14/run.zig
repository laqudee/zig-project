const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const expectError = std.testing.expectError;
const mem = std.mem;
const builtin = std.builtin;

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
test "page_allocator" {
    var al = std.heap.page_allocator;
    const a1 = try al.alloc(u8, 8);
    al.free(a1);
    const a2 = try al.alloc(u32, 18);
    al.free(a2);
}

// libc分配器c_allocator
// test 时使用  zig test run.zig -lc
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
