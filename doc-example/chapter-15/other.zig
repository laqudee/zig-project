const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var home = std.fs.cwd();
    defer home.close();
    try home.makeDir("test");
    var dir = try home.openDir("test", .{});
    var s = try dir.stat();
    print("test Stat: {any}\n", .{s});
    _ = try dir.createFile("file1.txt", .{});
    try dir.rename("file1.txt", "file2.txt");
    s = try dir.statFile("file2.txt");
    print("file2 Stat:{any}\n", .{s});
    dir.close();
    try home.deleteTree("test");
}
