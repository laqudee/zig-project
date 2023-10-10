const std = @import("std");

const Stage = enum {
    validate,
    awaiting_confirmation,
    confirmed,
    completed,
    err,

    fn isComplete(self: Stage) bool {
        return self == .confirmed or self == .err;
    }
};

pub fn main() void {
    const stage1 = Stage.validate;
    const stage2 = Stage.confirmed;

    std.debug.print("{}\n", .{stage1.isComplete()});
    std.debug.print("{}\n", .{stage2.isComplete()});
}
