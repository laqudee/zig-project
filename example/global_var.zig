var y: i32 = add(10, x);
const x = add(12, 34);

test "global var" {
    assert(x == 46);
    assert(y == 56);
}

fn add(a: i32, b: i32) i32 {
    return a + b;
}

const std = @import("std");
const assert = std.debug.assert;