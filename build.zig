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

    const vectorbench_mod = b.createModule(.{
        .root_source_file = b.path("bench/vector.zig"),
        .target = target,
        .optimize = optimize,
    });
    vectorbench_mod.addImport("alea", module);

    const vectorbench = b.addExecutable(.{
        .name = "alea-vectorbench",
        .root_module = vectorbench_mod,
    });
    const run_vectorbench = b.addRunArtifact(vectorbench);
    if (b.args) |args| run_vectorbench.addArgs(args);

    const vectorbench_step = b.step("vectorbench", "Run vector/SIMD microbenchmarks");
    vectorbench_step.dependOn(&run_vectorbench.step);

    const ziggurat_stats_mod = b.createModule(.{
        .root_source_file = b.path("tools/ziggurat_stats.zig"),
        .target = target,
        .optimize = optimize,
    });
    ziggurat_stats_mod.addImport("alea", module);

    const ziggurat_stats = b.addExecutable(.{
        .name = "alea-ziggurat-stats",
        .root_module = ziggurat_stats_mod,
    });
    const run_ziggurat_stats = b.addRunArtifact(ziggurat_stats);
    if (b.args) |args| run_ziggurat_stats.addArgs(args);

    const ziggurat_stats_step = b.step("ziggurat-stats", "Report ziggurat branch frequencies");
    ziggurat_stats_step.dependOn(&run_ziggurat_stats.step);

    const ziggurat_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/ziggurat_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    ziggurat_probe_mod.addImport("alea", module);

    const ziggurat_probe = b.addExecutable(.{
        .name = "alea-ziggurat-probe",
        .root_module = ziggurat_probe_mod,
    });
    const run_ziggurat_probe = b.addRunArtifact(ziggurat_probe);
    if (b.args) |args| run_ziggurat_probe.addArgs(args);

    const ziggurat_probe_step = b.step("ziggurat-probe", "Run ziggurat expression-shape microbenchmarks");
    ziggurat_probe_step.dependOn(&run_ziggurat_probe.step);

    const cauchy_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/cauchy_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    cauchy_probe_mod.addImport("alea", module);

    const cauchy_probe = b.addExecutable(.{
        .name = "alea-cauchy-probe",
        .root_module = cauchy_probe_mod,
    });
    const run_cauchy_probe = b.addRunArtifact(cauchy_probe);
    if (b.args) |args| run_cauchy_probe.addArgs(args);

    const cauchy_probe_step = b.step("cauchy-probe", "Run Cauchy expression-shape microbenchmarks");
    cauchy_probe_step.dependOn(&run_cauchy_probe.step);

    const open_closed_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/open_closed_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    open_closed_probe_mod.addImport("alea", module);

    const open_closed_probe = b.addExecutable(.{
        .name = "alea-open-closed-probe",
        .root_module = open_closed_probe_mod,
    });
    const run_open_closed_probe = b.addRunArtifact(open_closed_probe);
    if (b.args) |args| run_open_closed_probe.addArgs(args);

    const open_closed_probe_step = b.step("open-closed-probe", "Run OpenClosed01 f64 bulk conversion microbenchmarks");
    open_closed_probe_step.dependOn(&run_open_closed_probe.step);

    const log_normal_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/log_normal_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    log_normal_probe_mod.addImport("alea", module);

    const log_normal_probe = b.addExecutable(.{
        .name = "alea-log-normal-probe",
        .root_module = log_normal_probe_mod,
    });
    const run_log_normal_probe = b.addRunArtifact(log_normal_probe);
    if (b.args) |args| run_log_normal_probe.addArgs(args);

    const log_normal_probe_step = b.step("log-normal-probe", "Run LogNormal bulk expression-shape microbenchmarks");
    log_normal_probe_step.dependOn(&run_log_normal_probe.step);

    const nig_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/nig_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    nig_probe_mod.addImport("alea", module);

    const nig_probe = b.addExecutable(.{
        .name = "alea-nig-probe",
        .root_module = nig_probe_mod,
    });
    const run_nig_probe = b.addRunArtifact(nig_probe);
    if (b.args) |args| run_nig_probe.addArgs(args);

    const nig_probe_step = b.step("nig-probe", "Run NormalInverseGaussian bulk expression-shape microbenchmarks");
    nig_probe_step.dependOn(&run_nig_probe.step);

    const inverse_gaussian_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/inverse_gaussian_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    inverse_gaussian_probe_mod.addImport("alea", module);

    const inverse_gaussian_probe = b.addExecutable(.{
        .name = "alea-inverse-gaussian-probe",
        .root_module = inverse_gaussian_probe_mod,
    });
    const run_inverse_gaussian_probe = b.addRunArtifact(inverse_gaussian_probe);
    if (b.args) |args| run_inverse_gaussian_probe.addArgs(args);

    const inverse_gaussian_probe_step = b.step("inverse-gaussian-probe", "Run InverseGaussian bulk expression-shape microbenchmarks");
    inverse_gaussian_probe_step.dependOn(&run_inverse_gaussian_probe.step);

    const skew_normal_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/skew_normal_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    skew_normal_probe_mod.addImport("alea", module);

    const skew_normal_probe = b.addExecutable(.{
        .name = "alea-skew-normal-probe",
        .root_module = skew_normal_probe_mod,
    });
    const run_skew_normal_probe = b.addRunArtifact(skew_normal_probe);
    if (b.args) |args| run_skew_normal_probe.addArgs(args);

    const skew_normal_probe_step = b.step("skew-normal-probe", "Run SkewNormal bulk expression-shape microbenchmarks");
    skew_normal_probe_step.dependOn(&run_skew_normal_probe.step);

    const triangular_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/triangular_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    triangular_probe_mod.addImport("alea", module);

    const triangular_probe = b.addExecutable(.{
        .name = "alea-triangular-probe",
        .root_module = triangular_probe_mod,
    });
    const run_triangular_probe = b.addRunArtifact(triangular_probe);
    if (b.args) |args| run_triangular_probe.addArgs(args);

    const triangular_probe_step = b.step("triangular-probe", "Run Triangular bulk expression-shape microbenchmarks");
    triangular_probe_step.dependOn(&run_triangular_probe.step);

    const rayleigh_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/rayleigh_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    rayleigh_probe_mod.addImport("alea", module);

    const rayleigh_probe = b.addExecutable(.{
        .name = "alea-rayleigh-probe",
        .root_module = rayleigh_probe_mod,
    });
    const run_rayleigh_probe = b.addRunArtifact(rayleigh_probe);
    if (b.args) |args| run_rayleigh_probe.addArgs(args);

    const rayleigh_probe_step = b.step("rayleigh-probe", "Run Rayleigh bulk expression-shape microbenchmarks");
    rayleigh_probe_step.dependOn(&run_rayleigh_probe.step);

    const logistic_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/logistic_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    logistic_probe_mod.addImport("alea", module);

    const logistic_probe = b.addExecutable(.{
        .name = "alea-logistic-probe",
        .root_module = logistic_probe_mod,
    });
    const run_logistic_probe = b.addRunArtifact(logistic_probe);
    if (b.args) |args| run_logistic_probe.addArgs(args);

    const logistic_probe_step = b.step("logistic-probe", "Run Logistic bulk expression-shape microbenchmarks");
    logistic_probe_step.dependOn(&run_logistic_probe.step);

    const laplace_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/laplace_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    laplace_probe_mod.addImport("alea", module);

    const laplace_probe = b.addExecutable(.{
        .name = "alea-laplace-probe",
        .root_module = laplace_probe_mod,
    });
    const run_laplace_probe = b.addRunArtifact(laplace_probe);
    if (b.args) |args| run_laplace_probe.addArgs(args);

    const laplace_probe_step = b.step("laplace-probe", "Run Laplace bulk expression-shape microbenchmarks");
    laplace_probe_step.dependOn(&run_laplace_probe.step);

    const log_logistic_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/log_logistic_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    log_logistic_probe_mod.addImport("alea", module);

    const log_logistic_probe = b.addExecutable(.{
        .name = "alea-log-logistic-probe",
        .root_module = log_logistic_probe_mod,
    });
    const run_log_logistic_probe = b.addRunArtifact(log_logistic_probe);
    if (b.args) |args| run_log_logistic_probe.addArgs(args);

    const log_logistic_probe_step = b.step("log-logistic-probe", "Run LogLogistic bulk expression-shape microbenchmarks");
    log_logistic_probe_step.dependOn(&run_log_logistic_probe.step);

    const power_function_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/power_function_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    power_function_probe_mod.addImport("alea", module);

    const power_function_probe = b.addExecutable(.{
        .name = "alea-power-function-probe",
        .root_module = power_function_probe_mod,
    });
    const run_power_function_probe = b.addRunArtifact(power_function_probe);
    if (b.args) |args| run_power_function_probe.addArgs(args);

    const power_function_probe_step = b.step("power-function-probe", "Run PowerFunction bulk expression-shape microbenchmarks");
    power_function_probe_step.dependOn(&run_power_function_probe.step);

    const kumaraswamy_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/kumaraswamy_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    kumaraswamy_probe_mod.addImport("alea", module);

    const kumaraswamy_probe = b.addExecutable(.{
        .name = "alea-kumaraswamy-probe",
        .root_module = kumaraswamy_probe_mod,
    });
    const run_kumaraswamy_probe = b.addRunArtifact(kumaraswamy_probe);
    if (b.args) |args| run_kumaraswamy_probe.addArgs(args);

    const kumaraswamy_probe_step = b.step("kumaraswamy-probe", "Run Kumaraswamy bulk expression-shape microbenchmarks");
    kumaraswamy_probe_step.dependOn(&run_kumaraswamy_probe.step);

    const gumbel_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/gumbel_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    gumbel_probe_mod.addImport("alea", module);

    const gumbel_probe = b.addExecutable(.{
        .name = "alea-gumbel-probe",
        .root_module = gumbel_probe_mod,
    });
    const run_gumbel_probe = b.addRunArtifact(gumbel_probe);
    if (b.args) |args| run_gumbel_probe.addArgs(args);

    const gumbel_probe_step = b.step("gumbel-probe", "Run Gumbel bulk expression-shape microbenchmarks");
    gumbel_probe_step.dependOn(&run_gumbel_probe.step);

    const frechet_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/frechet_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    frechet_probe_mod.addImport("alea", module);

    const frechet_probe = b.addExecutable(.{
        .name = "alea-frechet-probe",
        .root_module = frechet_probe_mod,
    });
    const run_frechet_probe = b.addRunArtifact(frechet_probe);
    if (b.args) |args| run_frechet_probe.addArgs(args);

    const frechet_probe_step = b.step("frechet-probe", "Run Frechet bulk expression-shape microbenchmarks");
    frechet_probe_step.dependOn(&run_frechet_probe.step);

    const arcsine_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/arcsine_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    arcsine_probe_mod.addImport("alea", module);

    const arcsine_probe = b.addExecutable(.{
        .name = "alea-arcsine-probe",
        .root_module = arcsine_probe_mod,
    });
    const run_arcsine_probe = b.addRunArtifact(arcsine_probe);
    if (b.args) |args| run_arcsine_probe.addArgs(args);

    const arcsine_probe_step = b.step("arcsine-probe", "Run Arcsine bulk expression-shape microbenchmarks");
    arcsine_probe_step.dependOn(&run_arcsine_probe.step);

    const maxwell_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/maxwell_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    maxwell_probe_mod.addImport("alea", module);

    const maxwell_probe = b.addExecutable(.{
        .name = "alea-maxwell-probe",
        .root_module = maxwell_probe_mod,
    });
    const run_maxwell_probe = b.addRunArtifact(maxwell_probe);
    if (b.args) |args| run_maxwell_probe.addArgs(args);

    const maxwell_probe_step = b.step("maxwell-probe", "Run Maxwell bulk expression-shape microbenchmarks");
    maxwell_probe_step.dependOn(&run_maxwell_probe.step);

    const pareto_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/pareto_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    pareto_probe_mod.addImport("alea", module);

    const pareto_probe = b.addExecutable(.{
        .name = "alea-pareto-probe",
        .root_module = pareto_probe_mod,
    });
    const run_pareto_probe = b.addRunArtifact(pareto_probe);
    if (b.args) |args| run_pareto_probe.addArgs(args);

    const pareto_probe_step = b.step("pareto-probe", "Run Pareto bulk expression-shape microbenchmarks");
    pareto_probe_step.dependOn(&run_pareto_probe.step);

    const weibull_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/weibull_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    weibull_probe_mod.addImport("alea", module);

    const weibull_probe = b.addExecutable(.{
        .name = "alea-weibull-probe",
        .root_module = weibull_probe_mod,
    });
    const run_weibull_probe = b.addRunArtifact(weibull_probe);
    if (b.args) |args| run_weibull_probe.addArgs(args);

    const weibull_probe_step = b.step("weibull-probe", "Run Weibull bulk expression-shape microbenchmarks");
    weibull_probe_step.dependOn(&run_weibull_probe.step);

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

    const hypergeo_h2pe_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/hypergeo_h2pe_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    hypergeo_h2pe_probe_mod.addImport("alea", module);

    const hypergeo_h2pe_probe = b.addExecutable(.{
        .name = "alea-hypergeo-h2pe-probe",
        .root_module = hypergeo_h2pe_probe_mod,
    });
    const run_hypergeo_h2pe_probe = b.addRunArtifact(hypergeo_h2pe_probe);
    if (b.args) |args| run_hypergeo_h2pe_probe.addArgs(args);

    const hypergeo_h2pe_probe_step = b.step("hypergeo-h2pe-probe", "Run isolated Hypergeometric H2PE experiments");
    hypergeo_h2pe_probe_step.dependOn(&run_hypergeo_h2pe_probe.step);

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
