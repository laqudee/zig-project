const std = @import("std");
const Allocator = std.mem.Allocator;

const Player = struct {
    id: u64,
    name: []const u8,
    role: []u16,
};

const Move = struct {
    up: u16,
    down: u16,
    left: u16,
    right: u16,
};

pub const Game = struct {
    players: []Player,
    history: []Move,
    allocator: Allocator,

    fn init(allocator: Allocator, player_count: usize) !Game {
        var players = try allocator.alloc(Player, player_count);
        errdefer allocator.free(players);

        // store 10 most recent moves per player
        var history = try allocator.alloc(Move, 10);

        return .{
            .players = players,
            .history = history,
            .allocator = allocator,
        };
    }

    fn deinit(game: Game) void {
        const allocator = game.allocator;
        allocator.free(game.players);
        allocator.free(game.history);
    }
};

pub fn main() !void {
    // const player1 = Player{ .id = 1, .name = "Alice", .role = [_]u16{ 1, 2 } };
    // const player2 = Player{ .id = 1, .name = "Bob", .role = [_]u16{ 1, 2, 3 } };

    // const move1 = Move{ .up = 1, .down = 2, .left = 3, .right = 4 };
    // const move2 = Move{ .up = 2, .down = 3, .left = 4, .right = 0 };

    const new_game = try Game.init(std.heap.page_allocator, 2);
    defer new_game.deinit();
}
