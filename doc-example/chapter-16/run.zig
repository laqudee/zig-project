const std = @import("std");
const buildin = std.builtin;
const os = std.Target.Os;

fn getline(r: anytype, buf: []u8) !?[]const u8 {
    var line = (try r.readUntilDelimiterOrEof(buf, '\n')) orelse return null;
    if (os.Tag == enum { windows }) {
        return std.mem.trimRight(u8, line, "\r");
    } else {
        return line;
    }
}

fn run_getline() !void {
    const stdout = std.io.getStdOut();
    const stdin = std.io.getStdIn();
    try stdout.writeAll("Enter you name: ");
    var buf: [100]u8 = undefined;
    const input = (try getline(stdin.reader(), &buf)).?;
    try stdout.writer().print("Your name is: {s}\n", .{input});
}

pub fn main() !void {
    try run_getline();

    try format_print();
}

fn format_print() !void {
    const print = std.debug.print;
    const i: i16 = 0x1A2B;
    const j: u8 = 65;
    print("{1} {0b} {0o} {0x} {0X}\n", .{ i, j });
    print("={:-<10}= ={0x:*>10}= ={0d:^10}=\n", .{j});
    const k: f32 = 1666.15345;
    print("={e:6.2}= ={0:7.3}= ={0d:7.3}= ={0d:8.2}=\n", .{k});
    const m: u21 = 0x8BED; //  UTF-8: 0xE8AFAD
    print("={1u}= ={0c}=\n", .{ j, m });
    const str = "hello world";
    const slice1 = str[0..4];
    print("={s}= ={s}=\n", .{ str, slice1 });
    print("{1*} {2*} {0*}\n", .{ &m, &str, &slice1 });
    print("{any}", .{@TypeOf(str)});
    const p: ?i32 = 15;
    const p1: ?i32 = null;
    print("{?x} {0?} {1?}\n", .{ p, p1 });
    const q: anyerror!i32 = 14;
    const q1: anyerror!i32 = error.eone;
    print("{!x} {0!} {1!}\n", .{ q, q1 });
    print("{{ end }}\n", .{});
}
