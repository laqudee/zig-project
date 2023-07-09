const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const expectEqualSlices = std.testing.expectEqualSlices;
const expectEqual = std.testing.expectEqual;

const foo = struct {
    x: i32,
    y: i32,
    fn nop() void {}
    const z: i64 = -5;
};
test "struct decl" {
    var f: foo = .{ .x = 3, .y = 4 };
    try expect(f.x == 3);
    f.x = f.x + f.y;
    try expect(f.x == 7);
    try expect(foo.z == -5);
    foo.nop();
}
test "struct undefined" {
    var f: foo = undefined;
    try expect(foo.z == -5);
    f.x = 13;
    f.y = foo.z;
    try expect(f.y == -5);
    foo.nop();
}
