const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const calc_module = b.addModule("calc", .{
        .source_file = .{ .path = "../calc/calc.zig" },
    });

    // setup executable
    const exe = b.addExecutable(.{
        .name = "action",
        .target = target,
        .optimize = optimize,
        .root_source_file = .{ .path = "array_list.zig" },
    });

    // add Module
    exe.addModule("calc", calc_module);

    // 安装 `zig build install`
    b.installArtifact(exe);

    // 增加 运行 和 依赖
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Start Array List");
    run_step.dependOn(&run_cmd.step);

    // 添加测试步骤
    const tests = b.addTest(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = .{ .path = "array_list.zig" },
    });

    tests.addModule("calc", calc_module);

    const test_cmd = b.addRunArtifact(tests);
    test_cmd.step.dependOn(b.getInstallStep());
    const test_step = b.step("test", "Run Array List Tests");
    test_step.dependOn(&test_cmd.step);
}
