const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    try directoryOperator();

    try fileOperator();
}

fn directoryOperator() !void {
    var home = std.fs.cwd();
    defer home.close();
    try home.makeDir("testdir");
    var dir = try home.openDir("testdir", .{});
    try dir.makeDir("d1");
    try dir.makeDir("d2");
    _ = try dir.createFile("f1", .{});
    dir.close();
    var idir = try home.openIterableDir("testdir", .{});
    var iter = idir.iterate();
    while (try iter.next()) |e| {
        print("Entry: name={s} kind={any}\n", .{ e.name, e.kind });
    }
    idir.close();
    try home.deleteTree("testdir");
}

fn fileOperator() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const al = gpa.allocator();
    const result = gpa.deinit();
    defer if (@intFromEnum(result) == 1) @panic("memory leak");
    var home = std.fs.cwd();
    defer home.close();
    try home.makeDir("testdir");
    var dir = try home.openDir("testdir", .{});
    var file = try dir.createFile("testfile", .{});
    file.close();
    file = try dir.openFile("testfile", .{ .mode = .read_write });
    _ = try file.writeAll("hello        world");
    try file.seekTo(6);
    _ = try file.writeAll("wang");
    var buf: [100]u8 = undefined;
    try file.seekTo(0);
    const len = try file.readAll(&buf);
    const s = buf[0..len];
    print("{s}\n", .{s});
    try file.seekTo(0);
    const buf1 = try file.readToEndAlloc(al, 1024);
    defer al.free(buf1);
    print("{} {s}\n", .{ buf1.len, buf1 });
    file.close();
    try dir.deleteFile("testfile");
    dir.close();
    try home.deleteTree("testdir");
}
