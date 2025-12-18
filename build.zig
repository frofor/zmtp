const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libmtp_mod = b.addModule("libmtp", .{
        .root_source_file = b.path("src/libmtp.zig"),
        .target = target,
    });

    const mod = b.addModule("zmtp", .{
        .root_source_file = b.path("src/root.zig"),
        .imports = &.{.{ .name = "libmtp", .module = libmtp_mod }},
        .target = target,
    });

    const command_mod = b.addModule("command", .{
        .root_source_file = b.path("src/command.zig"),
        .imports = &.{
            .{ .name = "zmtp", .module = mod },
            .{ .name = "libmtp", .module = libmtp_mod },
        },
    });

    const exe = b.addExecutable(.{
        .name = "zmtp",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "zmtp", .module = mod },
                .{ .name = "command", .module = command_mod },
            },
            .link_libc = true,
        }),
    });

    exe.root_module.linkSystemLibrary("mtp", .{});

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const mod_tests = b.addTest(.{ .root_module = mod });
    const run_mod_tests = b.addRunArtifact(mod_tests);

    const exe_tests = b.addTest(.{ .root_module = exe.root_module });
    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);
}
