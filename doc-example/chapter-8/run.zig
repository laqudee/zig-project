const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;

pub fn main() void {
    const i: *i32 = undefined; // 无意义野指针
    print("{} \n", .{i});

    const a = [_]i32{ 1, 2, 3, 4 };
    var j = &a[1];
    print("{} \n", .{@sizeOf(i32)});
    print("{}\n", .{j});
    j = &a[2];
    print("{}\n", .{j});
}

test "derefence" {
    var i: i32 = 10;
    const j = &i;
    try expect(j.* == 10);
    j.* += 20;
    try expect(i == 30);
}

fn add(a: *i32) void {
    a.* += 5;
}
test "pointer param" {
    var i: i32 = 20;
    add(&i);
    try expect(i == 25);
}

test "*T" {
    var i: i32 = 1;
    var j: *i32 = &i;
    j.* += 3;
    try expect(i == 4);
    var k: i32 = 5;
    j = &k;
    try expect(j.* == 5);
}

test "*const T" {
    const i: i32 = 1;
    var j = &i;
    // j.* += 3;
    var k: i32 = 6;
    j = &k;
    try expect(j.* == 6);
}

test "const *T" {
    var i: i32 = 1;
    const j = &i;
    j.* += 4;
    try expect(i == 5);
    const k: i32 = 5;
    // j = &k;
    try expect(k == 5);
}

test "const *const T" {
    const i: i32 = 1;
    const j = &i;
    _ = j;
    // j.* += 3;
    const k: i32 = 5;
    _ = k;
    // j = &k;
}

// 单项指针single-item pointer
test "single item pointer" {
    var i: i32 = 1;
    var ptr = &i;
    try expect(ptr.* == 1);
    // ptr+=1;
    // try expect(ptr[0]==1);
}

test "single item pointer array" {
    var i = [_]i32{ 1, 2, 3, 4 };
    const ptr = &i[2];
    try expect(@TypeOf(ptr) == *i32);
}

// many item pointer
test "assigned array address comptime slice *[N]T" {
    var a = [_]i32{ 1, 2, 3, 4 };
    const ptr: [*]i32 = &a;
    try expect(ptr[1] == a[1]);
    try expect(ptr[1] == 2);

    const ptr2: [*]i32 = a[1..3];
    try expect(ptr2[1] == a[2]);

    var le: usize = 3;
    const ptr3: [*]i32 = a[1..le].ptr;
    try expect(ptr3[1] == a[2]);
}

test "single-item is assigned to many-item" {
    var i: i32 = 1;
    var ptr: [*]i32 = @ptrCast(&i);
    try expect(ptr[0] == i);
}

test "many-item pointer index" {
    var a = [_]i32{ 1, 2, 3, 4 };
    const ptr: [*]i32 = &a;
    try expect(ptr[1] == 2);
    ptr[2] = 33;
    try expect(a[2] == 33);

    var ptr1: [*]i32 = &a;
    ptr1 += 2;
    ptr1[0] = 333;
    try expect(a[2] == 333);
    ptr1 -= 1;
    try expect(ptr1[0] == 2);
}

test "many-item pointer add" {
    var a = [_]i32{ 1, 2, 3, 4 };
    var ptr: [*]i32 = &a;
    var s = ptr[1..3];
    try expect(@TypeOf(s) == *[2]i32);
    try expect(s.len == 2);
    try expect(s[1] == 3);
}

test "assign array address" {
    var a = [_]i32{ 1, 2, 3, 4 };
    var ptr = &a;
    try expect(@TypeOf(ptr) == *[4]i32);

    var ptr_s = a[1..3];
    try expect(@TypeOf(ptr_s) == *[2]i32);
}

test "array ptr derefernece" {
    var a = [_]i32{ 1, 2, 3, 4 };
    var ptr: *[4]i32 = &a;
    const a1 = ptr.*;
    try expect(@TypeOf(a1) == [4]i32);
    try expect(a1[2] == 3);
}

test "array ptr get slice" {
    var a = [_]i32{ 1, 2, 3, 4 };
    var ptr = &a;
    const s = ptr[1..3];
    try expect(@TypeOf(s) == *[2]i32);
    try expect(s[0] == 2);
}

// optional pointer
test "optional pointer" {
    var i: i32 = 5;
    var j: ?*i32 = &i;
    const k: *i32 = j orelse unreachable;
    const l: i32 = k.*;
    try expect(l == i);
}

test "error union pointer" {
    var i: i32 = 5;
    var j: anyerror!*i32 = &i;
    const k: *i32 = try j;
    const m: i32 = k.*;
    try expect(m == i);
}

test "error union optional pointer" {
    var i: i32 = 5;
    var j: anyerror!?*i32 = &i;
    const k: ?*i32 = try j;
    const l: *i32 = k orelse unreachable;
    const m: i32 = l.*;
    try expect(m == i);
}

// function pointer
fn add5(a: i8) i8 {
    return a + 5;
}
fn sub7(a: i8) i8 {
    return a - 7;
}
const call_op = *const fn (a: i8) i8;
fn do(fn1: call_op, x: i8) i8 {
    return fn1(x);
}
test "function pointer" {
    try expect(do(add5, 10) == 15);
    var f: call_op = sub7;
    try expect(do(f, 17) == 10);
    f = add5;
    try expect(do(f, 17) == 22);
}

// automatic dereference of pointer to substruct
// 结构内属性是指向子结构的指针可自动解引用，可省略.*，属性指向普通类型的指针不能自动解引用
test "automatic deref of pointer to sub struct" {
    const foo1 = struct { x: i32 };
    const foo = struct { ptr: *foo1, ptr1: ?*foo1, ptr2: *i32 };
    var i: i32 = 10;
    var f1 = foo1{ .x = 5 };
    var f2 = foo1{ .x = 10 };
    var f = foo{ .ptr = &f1, .ptr1 = &f2, .ptr2 = &i };
    try expect(f.ptr.*.x == f.ptr.x);
    try expect(f.ptr.x == 5);
    try expect(f.ptr1.?.*.x == f.ptr1.?.x);
    try expect(@TypeOf(f.ptr2.*) == i32);
    try expect(@TypeOf(f.ptr2) == *i32);
}
