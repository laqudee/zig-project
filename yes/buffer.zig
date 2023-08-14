const std = @import("std");

const BUFFER_CAP = 4 * 1024;

fn fillBuffer(buf: []u8, output: []const u8) []const u8 {
    if (output.len + 1 > buf.len / 2) { // plus one newline
        return output;
    }

    std.mem.copy(u8, buf, output);
    std.mem.copy(u8, buf[output.len..], "\n");
    var buffer_size = output.len + 1;
    while (buffer_size < buf.len / 2) {
        std.mem.copy(u8, buf[buffer_size..], buf[0..buffer_size]);
        buffer_size *= 2;
    }

    return buf[0..buffer_size];
}

pub fn main() !void {
    const argv = std.os.argv;

    const output: []const u8 = if (argv.len > 1)
        argv.ptr[1][0..std.mem.len(argv.ptr[1])]
    else
        "y";

    var buffer: [BUFFER_CAP]u8 = undefined;
    const body = fillBuffer(&buffer, output);
    const stdout = std.io.getStdOut();
    var writer = stdout.writer();
    while ((try writer.write(body)) > 0) {}
}
