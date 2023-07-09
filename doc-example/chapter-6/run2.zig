const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const expectEqualSlices = std.testing.expectEqualSlices;
const expectEqual = std.testing.expectEqual;

pub fn main() void {
    var a = [_]i32{ 1, 2, 3, 4, 5, 6 };
    var le: usize = 4;
    var s = a[0..le];
    // s[5] += 10;
    s.len = 100;
    s.ptr += 5;
    print("{} {} \n", .{ s.ptr[0], s.ptr[9] });
}

test "slice fat pointer" {
    var a = [_]i32{ 1, 2, 3, 4 };
    var le: usize = 2;
    var s = a[0..le];
    try expect(s[1] == 2);
    try expect(@TypeOf(s) == []i32);
    try expect(@TypeOf(s.ptr) == [*]i32);
    try expect(s.len == 2);
}

var a1 = [_]i32{ 1, 2, 3, 4 };
test "comtime *[N]T" {
    const s = a1[1..3];
    try expect(@TypeOf(s) == *[2]i32);
}

test "runtime []T" {
    var le: usize = 3;
    const s = a1[0..le];
    try expect(@TypeOf(s) == []i32);
}

var al = std.testing.allocator;
test "ArrayList init" {
    var list = std.ArrayList(i32).init(al);
    defer list.deinit();
    try expect(list.capacity == 0);
    try expect(list.items.len == 0);
}
test "ArrayList initCapacity" {
    var list = try std.ArrayList(i32).initCapacity(al, 200);
    defer list.deinit();
    try expect(list.capacity >= 200);
    try expect(list.items.len == 0);
}
test "ArrayList clone" {
    var list = std.ArrayList(u8).init(al);
    defer list.deinit();
    try list.appendSlice("abc");
    var new1 = try list.clone();
    defer new1.deinit();
    try expectEqual(list.allocator, new1.allocator);
    try expect(new1.capacity == list.capacity);
    try expectEqualSlices(u8, new1.items, "abc");
}

test "ArrayList field" {
    var list = try std.ArrayList(u8).initCapacity(al, 200);
    defer list.deinit();
    try expectEqual(al, list.allocator);
    try expect(list.capacity >= 200);
    try expect(list.items.len == 0);
    try list.appendSlice("abc");
    try expect(list.items.len == 3);
    list.items[1] = 'B';
    try expectEqualSlices(u8, list.items, "aBc");
}

test "ArrayList append" {
    var list = std.ArrayList(u8).init(al);
    defer list.deinit();
    list.append(10) catch unreachable;
    list.append(20) catch unreachable;
    try list.append(30);
    try expect(list.items.len == 3);
    try expectEqualSlices(u8, list.items, &[_]u8{ 10, 20, 30 });
}

test "ArrayList insert" {
    var list = std.ArrayList(u8).init(al);
    defer list.deinit();
    const a = [_]u8{ 1, 2, 3 };
    try list.appendSlice(&a);
    try list.insert(0, 66);
    const r1 = [_]u8{ 66, 1, 2, 3 };
    try expectEqualSlices(u8, list.items, &r1);
    try list.insert(2, 77);
    const r2 = [_]u8{ 66, 1, 77, 2, 3 };
    try expectEqualSlices(u8, list.items, &r2);
    try list.insert(list.items.len, 88);
    const r3 = [_]u8{ 66, 1, 77, 2, 3, 88 };
    try expectEqualSlices(u8, list.items, &r3);
}

test "ArrayList orderRemove" {
    var list = std.ArrayList(u8).init(al);
    defer list.deinit();
    const a = [_]u8{ 11, 22, 33, 44 };
    try list.appendSlice(&a);
    const b = list.orderedRemove(1);
    try expect(b == 22);
    const r = [_]u8{ 11, 33, 44 };
    try expectEqualSlices(u8, list.items, &r);
}

test "ArrayList swapRemove" {
    var list = std.ArrayList(u8).init(al);
    defer list.deinit();
    const a = [_]u8{ 11, 22, 33, 44, 55 };
    try list.appendSlice(&a);
    const b = list.swapRemove(1);
    try expect(b == 22);
    const r = [_]u8{ 11, 55, 33, 44 };
    try expectEqualSlices(u8, list.items, &r);
}
test "ArrayList popOrNull" {
    var list = std.ArrayList(u8).init(al);
    defer list.deinit();
    const a = [_]u8{ 11, 22 };
    try list.appendSlice(&a);
    try expect(list.items.len == 2);
    var b = list.popOrNull();
    try expect(b.? == 22);
    try expect(list.items.len == 1);
    b = list.popOrNull();
    try expect(b.? == 11);
    try expect(list.items.len == 0);
    b = list.popOrNull();
    try expect(b == null);
    try expect(list.items.len == 0);
}

test "ArrayList replaceRange" {
    const rep = [_]u8{ 55, 66, 77 };
    var list = std.ArrayList(u8).init(al);
    defer list.deinit();
    const a = [_]u8{ 1, 2, 3, 4, 5 };

    try list.appendSlice(&a);
    try list.replaceRange(2, 0, &rep);
    const r1 = [_]u8{ 1, 2, 55, 66, 77, 3, 4, 5 };
    try expectEqualSlices(u8, list.items, &r1);

    list.items.len = 0;
    try list.appendSlice(&a);
    try list.replaceRange(2, 2, &rep);
    const r2 = [_]u8{ 1, 2, 55, 66, 77, 5 };
    try expectEqualSlices(u8, list.items, &r2);

    list.items.len = 0;
    try list.appendSlice(&a);
    try list.replaceRange(2, 3, &rep);
    const r3 = [_]u8{ 1, 2, 55, 66, 77 };
    try expectEqualSlices(u8, list.items, &r3);

    list.items.len = 0;
    try list.appendSlice(&a);
}

test "ArrayList resize" {
    var list = try std.ArrayList(u8).initCapacity(al, 10);
    defer list.deinit();
    try list.append(11);
    try expect(list.items.len == 1);
    try expect(list.capacity >= 10);
    const cap = list.capacity;

    try list.resize(8);
    try expect(list.items.len == 8);
    try expect(list.capacity == cap);

    try list.resize(2000);
    try expect(list.items.len == 2000);
    try expect(list.capacity >= 2000);
    try expect(list.capacity >= cap);
}

test "ArrayList shrinkAndFree" {
    var list = try std.ArrayList(u8).initCapacity(al, 10);
    defer list.deinit();
    try list.appendSlice(&[_]u8{ 1, 2, 3, 4 });
    try expect(list.items.len == 4);
    try expect(list.capacity >= 10);

    list.shrinkAndFree(2);
    try expect(list.items.len == 2);
    try expect(list.capacity == 2);
    try expectEqualSlices(u8, list.items, &[_]u8{ 1, 2 });
}

test "ArrayList writer" {
    var buf = std.ArrayList(u8).init(al);
    defer buf.deinit();
    const writer = buf.writer();
    try expectEqualSlices(u8, buf.items, "");
    const i: i32 = 42;
    try writer.print("i={}\n", .{i});
    try expectEqualSlices(u8, buf.items, "i=42\n");
    try writer.writeAll(" all");
    try expectEqualSlices(u8, buf.items, "i=42\n all");
    try writer.writeAll(" ok!");
    try expectEqualSlices(u8, buf.items, "i=42\n all ok!");
}

test "std.ArrayList(u0)" {
    var fa = std.testing.FailingAllocator.init(al, 0);
    const fall = fa.allocator();
    var list = std.ArrayList(u0).init(fall);
    defer list.deinit();
    try list.append(0);
    try list.append(0);
    try expect(list.items.len == 2);
    var count: usize = 0;
    for (list.items) |x| {
        try expect(x == 0);
        count += 1;
    }
    try expect(count == 2);
}
