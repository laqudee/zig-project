pub const add = @import("add.zig").add;

test {
    @import("std").testing.refAllDecls(@This());
}
