const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var arr = try allocator.alloc(usize, try getRandomCount());
    defer allocator.free(arr);

    for (0..arr.len) |i| {
        arr[i] = i;
    }
    std.debug.print("{any}\n", .{arr});
}

fn getRandomCount() !u8 {
    var seed: u64 = undefined;
    try std.os.getrandom(std.mem.asBytes(&seed));
    var random = std.rand.DefaultPrng.init(seed);
    return random.random().uintAtMost(u8, 5) + 5;
}
