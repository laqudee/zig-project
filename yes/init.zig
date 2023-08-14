const std = @import("std");

pub fn main() !void {
    const argv = std.os.argv;

    const output: []const u8 = if (argv.len > 1)
        argv.ptr[1][0..std.mem.len(argv.ptr[1])]
    else
        "y";

    const out = std.io.getStdOut();
    var f = out.writer();
    // var f = std.io.bufferedWriter(out.writer());
    while ((try f.write(output)) > 0) {
        _ = try f.write("\n");
    }
}
