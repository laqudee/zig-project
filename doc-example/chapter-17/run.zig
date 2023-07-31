// async function 暂时延后，该功能不能使用
// $ zig test test_suspend.zig -fstage1

const std = @import("std");
const expect = std.testing.expect;

var x: i32 = 1;
test "suspend with no resume" {
    var fr = async foo();
    try expect(x == 2);
    try expect(@TypeOf(fr) == @Frame(foo));
}

fn foo() void {
    x += 1;
    suspend {}
    x += 1;
}

var r: i32 = 0;
test "resume" {
    var fr = async foo2();
    try expect(r == 1);
    r += 1;
    try expect(r == 2);
    resume fr;
    try expect(r == 12);
}
fn foo2() void {
    r += 1;
    suspend {}
    r += 10;
}
