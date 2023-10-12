const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Something = struct {
    allocator: Allocator,
    state: State,
    input: []const u8,
};

const NestType = struct {};

pub const State = struct {
    buf: []u8,
    nesting: []NestType,
};

pub fn parse(allocator: Allocator, input: []const u8) !Something {
    // create an ArenaAllocator from the supplied allocator
    var arena = std.heap.ArenaAllocator.init(allocator);

    // this will free anything created from this arena
    defer arena.deinit();

    // create an std.mem.Allocator from the arena,this will be
    // the allocator we'll use internally
    const aa = arena.allocator();

    var state = State{
        .buf = try aa.alloc(u8, 512),
        .nesting = try aa.alloc(NestType, 10),
    };

    return parseInternal(aa, state, input);
}

fn parseInternal(allocator: Allocator, state: State, input: []const u8) !Something {
    return .{
        .allocator = allocator,
        .state = state,
        .input = input,
    };
}
