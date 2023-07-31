const std = @import("std");

pub fn build(b: *std.Build) void {
    const lib = b.addSharedLibrary(.{
        .name = "mathtest",
        .root_source_file = .{ .path = "mathtest.zig" },
        .version = .{ .major = 1, .minor = 0, .patch = 0 },
        .target = .{},
        .optimize = .ReleaseFast,
    });
    const exe = b.addExecutable(.{
        .name = "test",
    });
    exe.addCSourceFile("test.c", &[_][]const u8{"-std=c99"});
    exe.linkLibrary(lib);
    exe.linkSystemLibrary("c");

    b.default_step.dependOn(&exe.step);

    const run_cmd = exe.run();

    const test_step = b.step("test", "Test the program");
    test_step.dependOn(&run_cmd.step);
}
