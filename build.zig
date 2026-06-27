const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("alea", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .name = "alea",
        .root_module = module,
    });
    b.installArtifact(lib);

    const tests = b.addTest(.{
        .name = "alea-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const run_tests = b.addRunArtifact(tests);

    const test_step = b.step("test", "Run alea unit tests");
    test_step.dependOn(&run_tests.step);

    const example_mod = b.createModule(.{
        .root_source_file = b.path("examples/basic.zig"),
        .target = target,
        .optimize = optimize,
    });
    example_mod.addImport("alea", module);

    const example = b.addExecutable(.{
        .name = "alea-basic",
        .root_module = example_mod,
    });
    const run_example = b.addRunArtifact(example);
    if (b.args) |args| run_example.addArgs(args);

    const example_step = b.step("run-basic", "Run the basic alea example");
    example_step.dependOn(&run_example.step);

    const bench_mod = b.createModule(.{
        .root_source_file = b.path("bench/throughput.zig"),
        .target = target,
        .optimize = optimize,
    });
    bench_mod.addImport("alea", module);

    const bench = b.addExecutable(.{
        .name = "alea-throughput",
        .root_module = bench_mod,
    });
    const run_bench = b.addRunArtifact(bench);
    if (b.args) |args| run_bench.addArgs(args);

    const bench_step = b.step("bench", "Run the alea throughput benchmark");
    bench_step.dependOn(&run_bench.step);
}
