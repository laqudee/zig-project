const std = @import("std");
const print = std.debug.print;

// zig package
const fabinaci_zig = @import("fabinaci.zig").fabinaci;

// c package
const sum_c = @cImport({
    @cInclude("sum.h");
});

// c++ package
const timeit_cpp = @cImport(@cInclude("timeit.h"));

fn fabinaci23() callconv(.C) void {
    _ = fabinaci_zig(20);
}

fn sum_test() callconv(.C) void {
    _ = sum_c.sum(10, 20);
}

pub fn main() !void {
    print("{} + {} = {}\t\t{d:>12.3} ms\n", .{ 20, 10, sum_c.sum(10, 20), timeit_cpp.time_it(sum_test) });

    print("fabinaci({}) = {}\t{d:>12.3} ms\n", .{ 20, fabinaci_zig(20), timeit_cpp.time_it(fabinaci23) });
}
