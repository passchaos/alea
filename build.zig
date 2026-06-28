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

    const statcheck_mod = b.createModule(.{
        .root_source_file = b.path("tools/statcheck.zig"),
        .target = target,
        .optimize = optimize,
    });
    statcheck_mod.addImport("alea", module);

    const statcheck = b.addExecutable(.{
        .name = "alea-statcheck",
        .root_module = statcheck_mod,
    });
    const run_statcheck = b.addRunArtifact(statcheck);
    if (b.args) |args| run_statcheck.addArgs(args);

    const statcheck_step = b.step("statcheck", "Run extended statistical smoke checks");
    statcheck_step.dependOn(&run_statcheck.step);

    const stream_mod = b.createModule(.{
        .root_source_file = b.path("tools/stream.zig"),
        .target = target,
        .optimize = optimize,
    });
    stream_mod.addImport("alea", module);

    const stream = b.addExecutable(.{
        .name = "alea-stream",
        .root_module = stream_mod,
    });
    const run_stream = b.addRunArtifact(stream);
    if (b.args) |args| run_stream.addArgs(args);

    const stream_step = b.step("stream", "Write raw RNG bytes to stdout for external statistical tools");
    stream_step.dependOn(&run_stream.step);

    const distcheck_mod = b.createModule(.{
        .root_source_file = b.path("tools/distcheck.zig"),
        .target = target,
        .optimize = optimize,
    });
    distcheck_mod.addImport("alea", module);

    const distcheck = b.addExecutable(.{
        .name = "alea-distcheck",
        .root_module = distcheck_mod,
    });
    const run_distcheck = b.addRunArtifact(distcheck);
    if (b.args) |args| run_distcheck.addArgs(args);

    const distcheck_step = b.step("distcheck", "Run parameter-grid distribution checks");
    distcheck_step.dependOn(&run_distcheck.step);

    const repro_mod = b.createModule(.{
        .root_source_file = b.path("tools/repro.zig"),
        .target = target,
        .optimize = optimize,
    });
    repro_mod.addImport("alea", module);

    const repro = b.addExecutable(.{
        .name = "alea-repro",
        .root_module = repro_mod,
    });
    const run_repro = b.addRunArtifact(repro);
    if (b.args) |args| run_repro.addArgs(args);

    const repro_step = b.step("repro", "Print deterministic reproducibility snapshots");
    repro_step.dependOn(&run_repro.step);
}
