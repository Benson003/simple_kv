const std = @import("std");

pub fn build(b: *std.Build) void {
    const targets = b.standardTargetOptions(.{});

    const optmize = b.standardOptimizeOption(.{});


    const module = b.addModule("kv_store",.{ .target = targets, .optimize = optmize,.root_source_file = b.path("./src/main.zig") },);

    const exe = b.addExecutable(.{.name = "kv_store", .root_module = module});

    b.installArtifact(exe);

    const run_step = b.step("run","Run the app");

    const run_cmd = b.addRunArtifact(exe);

   run_step.dependOn(&run_cmd.step);

   if(b.args) |args| {
       run_cmd.addArgs(args);
   }

   const exe_test = b.addTest(.{.root_module = module });

   const run_exe_tests = b.addRunArtifact(exe_test);

   const test_step = b.step("test","Run the tests");

   test_step.dependOn(&run_exe_tests.step);

}
