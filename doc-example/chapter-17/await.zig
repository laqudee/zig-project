const print = @import("std").debug.print;
pub fn main() void {
    _ = async amain();
    resume frfoo1;
    resume frfoo2;
}
fn amain() void {
    var fr1 = async foo1();
    print("eeeeee\n", .{});
    var fr2 = async foo2();
    print("ffffff\n", .{});
    const r1 = await fr1;
    print("hhhhhh {}\n", .{r1});
    const r2 = await fr2;
    print("iiiiii {}\n", .{r2});
}
var frfoo1: anyframe = undefined;
fn foo1() i32 {
    print("aaaa\n", .{});
    suspend {
        frfoo1 = @frame();
    }
    print("bbbb\n", .{});
    return 10;
}
var frfoo2: anyframe = undefined;
fn foo2() i32 {
    print("cccc\n", .{});
    suspend {
        frfoo2 = @frame();
    }
    print("dddd\n", .{});
    return 20;
}

// result
// aaaa
// eeeeee
// cccc
// ffffff
// bbbb
// hhhhhh 10
// dddd
// iiiiii 20
