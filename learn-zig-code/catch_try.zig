const std = @import("std");

const Response = struct { status: u16, body: []const u8 };

pub fn main() void {
    var res = Response{ .status = 200, .body = "Hello World" };
    action("POST", res) catch |err| {
        if (err == error.BrokenPipe or err == error.ConnectionResetByPeer) {
            return;
        } else if (err == error.BodyTooBig) {
            res.status = 431;
            res.body = "Request Body Too Big";
        } else {
            res.status = 500;
            res.body = "Internal Server Error";
        }
    };
}

fn action(req: []const u8, res: Response) !void {
    if (std.mem.eql(u8, req, "GET")) {
        std.debug.print("{}", .{res});
        return;
    } else {
        return error.BodyTooBig;
    }
}
