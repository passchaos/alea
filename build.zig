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

    const vector_profiles_example_mod = b.createModule(.{
        .root_source_file = b.path("examples/vector_profiles.zig"),
        .target = target,
        .optimize = optimize,
    });
    vector_profiles_example_mod.addImport("alea", module);

    const vector_profiles_example = b.addExecutable(.{
        .name = "alea-vector-profiles",
        .root_module = vector_profiles_example_mod,
    });
    const run_vector_profiles_example = b.addRunArtifact(vector_profiles_example);
    if (b.args) |args| run_vector_profiles_example.addArgs(args);

    const vector_profiles_example_step = b.step("run-vector-profiles", "Run the vector profile alea example");
    vector_profiles_example_step.dependOn(&run_vector_profiles_example.step);

    const lognormal_profiles_example_mod = b.createModule(.{
        .root_source_file = b.path("examples/lognormal_profiles.zig"),
        .target = target,
        .optimize = optimize,
    });
    lognormal_profiles_example_mod.addImport("alea", module);

    const lognormal_profiles_example = b.addExecutable(.{
        .name = "alea-lognormal-profiles",
        .root_module = lognormal_profiles_example_mod,
    });
    const run_lognormal_profiles_example = b.addRunArtifact(lognormal_profiles_example);
    if (b.args) |args| run_lognormal_profiles_example.addArgs(args);

    const lognormal_profiles_example_step = b.step("run-lognormal-profiles", "Run the LogNormal profile alea example");
    lognormal_profiles_example_step.dependOn(&run_lognormal_profiles_example.step);

    const native_f32_profiles_example_mod = b.createModule(.{
        .root_source_file = b.path("examples/native_f32_profiles.zig"),
        .target = target,
        .optimize = optimize,
    });
    native_f32_profiles_example_mod.addImport("alea", module);

    const native_f32_profiles_example = b.addExecutable(.{
        .name = "alea-native-f32-profiles",
        .root_module = native_f32_profiles_example_mod,
    });
    const run_native_f32_profiles_example = b.addRunArtifact(native_f32_profiles_example);
    if (b.args) |args| run_native_f32_profiles_example.addArgs(args);

    const native_f32_profiles_example_step = b.step("run-native-f32-profiles", "Run the native-f32 profile alea example");
    native_f32_profiles_example_step.dependOn(&run_native_f32_profiles_example.step);

    const weighted_sampling_example_mod = b.createModule(.{
        .root_source_file = b.path("examples/weighted_sampling.zig"),
        .target = target,
        .optimize = optimize,
    });
    weighted_sampling_example_mod.addImport("alea", module);

    const weighted_sampling_example = b.addExecutable(.{
        .name = "alea-weighted-sampling",
        .root_module = weighted_sampling_example_mod,
    });
    const run_weighted_sampling_example = b.addRunArtifact(weighted_sampling_example);
    if (b.args) |args| run_weighted_sampling_example.addArgs(args);

    const weighted_sampling_example_step = b.step("run-weighted-sampling", "Run the weighted sampling alea example");
    weighted_sampling_example_step.dependOn(&run_weighted_sampling_example.step);

    const multivariate_sampling_example_mod = b.createModule(.{
        .root_source_file = b.path("examples/multivariate_sampling.zig"),
        .target = target,
        .optimize = optimize,
    });
    multivariate_sampling_example_mod.addImport("alea", module);

    const multivariate_sampling_example = b.addExecutable(.{
        .name = "alea-multivariate-sampling",
        .root_module = multivariate_sampling_example_mod,
    });
    const run_multivariate_sampling_example = b.addRunArtifact(multivariate_sampling_example);
    if (b.args) |args| run_multivariate_sampling_example.addArgs(args);

    const multivariate_sampling_example_step = b.step("run-multivariate-sampling", "Run the multivariate sampling alea example");
    multivariate_sampling_example_step.dependOn(&run_multivariate_sampling_example.step);

    const sequence_sampling_example_mod = b.createModule(.{
        .root_source_file = b.path("examples/sequence_sampling.zig"),
        .target = target,
        .optimize = optimize,
    });
    sequence_sampling_example_mod.addImport("alea", module);

    const sequence_sampling_example = b.addExecutable(.{
        .name = "alea-sequence-sampling",
        .root_module = sequence_sampling_example_mod,
    });
    const run_sequence_sampling_example = b.addRunArtifact(sequence_sampling_example);
    if (b.args) |args| run_sequence_sampling_example.addArgs(args);

    const sequence_sampling_example_step = b.step("run-sequence-sampling", "Run the sequence sampling alea example");
    sequence_sampling_example_step.dependOn(&run_sequence_sampling_example.step);

    const string_generation_example_mod = b.createModule(.{
        .root_source_file = b.path("examples/string_generation.zig"),
        .target = target,
        .optimize = optimize,
    });
    string_generation_example_mod.addImport("alea", module);

    const string_generation_example = b.addExecutable(.{
        .name = "alea-string-generation",
        .root_module = string_generation_example_mod,
    });
    const run_string_generation_example = b.addRunArtifact(string_generation_example);
    if (b.args) |args| run_string_generation_example.addArgs(args);

    const string_generation_example_step = b.step("run-string-generation", "Run the string generation alea example");
    string_generation_example_step.dependOn(&run_string_generation_example.step);

    const unit_geometry_example_mod = b.createModule(.{
        .root_source_file = b.path("examples/unit_geometry.zig"),
        .target = target,
        .optimize = optimize,
    });
    unit_geometry_example_mod.addImport("alea", module);

    const unit_geometry_example = b.addExecutable(.{
        .name = "alea-unit-geometry",
        .root_module = unit_geometry_example_mod,
    });
    const run_unit_geometry_example = b.addRunArtifact(unit_geometry_example);
    if (b.args) |args| run_unit_geometry_example.addArgs(args);

    const unit_geometry_example_step = b.step("run-unit-geometry", "Run the unit geometry alea example");
    unit_geometry_example_step.dependOn(&run_unit_geometry_example.step);

    const distribution_diagnostics_example_mod = b.createModule(.{
        .root_source_file = b.path("examples/distribution_diagnostics.zig"),
        .target = target,
        .optimize = optimize,
    });
    distribution_diagnostics_example_mod.addImport("alea", module);

    const distribution_diagnostics_example = b.addExecutable(.{
        .name = "alea-distribution-diagnostics",
        .root_module = distribution_diagnostics_example_mod,
    });
    const run_distribution_diagnostics_example = b.addRunArtifact(distribution_diagnostics_example);
    if (b.args) |args| run_distribution_diagnostics_example.addArgs(args);

    const distribution_diagnostics_example_step = b.step("run-distribution-diagnostics", "Run the distribution diagnostics alea example");
    distribution_diagnostics_example_step.dependOn(&run_distribution_diagnostics_example.step);

    const reproducible_streams_example_mod = b.createModule(.{
        .root_source_file = b.path("examples/reproducible_streams.zig"),
        .target = target,
        .optimize = optimize,
    });
    reproducible_streams_example_mod.addImport("alea", module);

    const reproducible_streams_example = b.addExecutable(.{
        .name = "alea-reproducible-streams",
        .root_module = reproducible_streams_example_mod,
    });
    const run_reproducible_streams_example = b.addRunArtifact(reproducible_streams_example);
    if (b.args) |args| run_reproducible_streams_example.addArgs(args);

    const reproducible_streams_example_step = b.step("run-reproducible-streams", "Run the reproducible streams alea example");
    reproducible_streams_example_step.dependOn(&run_reproducible_streams_example.step);

    const range_sampling_example_mod = b.createModule(.{
        .root_source_file = b.path("examples/range_sampling.zig"),
        .target = target,
        .optimize = optimize,
    });
    range_sampling_example_mod.addImport("alea", module);

    const range_sampling_example = b.addExecutable(.{
        .name = "alea-range-sampling",
        .root_module = range_sampling_example_mod,
    });
    const run_range_sampling_example = b.addRunArtifact(range_sampling_example);
    if (b.args) |args| run_range_sampling_example.addArgs(args);

    const range_sampling_example_step = b.step("run-range-sampling", "Run the range sampling alea example");
    range_sampling_example_step.dependOn(&run_range_sampling_example.step);

    const discrete_distributions_example_mod = b.createModule(.{
        .root_source_file = b.path("examples/discrete_distributions.zig"),
        .target = target,
        .optimize = optimize,
    });
    discrete_distributions_example_mod.addImport("alea", module);

    const discrete_distributions_example = b.addExecutable(.{
        .name = "alea-discrete-distributions",
        .root_module = discrete_distributions_example_mod,
    });
    const run_discrete_distributions_example = b.addRunArtifact(discrete_distributions_example);
    if (b.args) |args| run_discrete_distributions_example.addArgs(args);

    const discrete_distributions_example_step = b.step("run-discrete-distributions", "Run the discrete distributions alea example");
    discrete_distributions_example_step.dependOn(&run_discrete_distributions_example.step);

    const continuous_distributions_example_mod = b.createModule(.{
        .root_source_file = b.path("examples/continuous_distributions.zig"),
        .target = target,
        .optimize = optimize,
    });
    continuous_distributions_example_mod.addImport("alea", module);

    const continuous_distributions_example = b.addExecutable(.{
        .name = "alea-continuous-distributions",
        .root_module = continuous_distributions_example_mod,
    });
    const run_continuous_distributions_example = b.addRunArtifact(continuous_distributions_example);
    if (b.args) |args| run_continuous_distributions_example.addArgs(args);

    const continuous_distributions_example_step = b.step("run-continuous-distributions", "Run the continuous distributions alea example");
    continuous_distributions_example_step.dependOn(&run_continuous_distributions_example.step);

    const advanced_continuous_distributions_example_mod = b.createModule(.{
        .root_source_file = b.path("examples/advanced_continuous_distributions.zig"),
        .target = target,
        .optimize = optimize,
    });
    advanced_continuous_distributions_example_mod.addImport("alea", module);

    const advanced_continuous_distributions_example = b.addExecutable(.{
        .name = "alea-advanced-continuous-distributions",
        .root_module = advanced_continuous_distributions_example_mod,
    });
    const run_advanced_continuous_distributions_example = b.addRunArtifact(advanced_continuous_distributions_example);
    if (b.args) |args| run_advanced_continuous_distributions_example.addArgs(args);

    const advanced_continuous_distributions_example_step = b.step("run-advanced-continuous-distributions", "Run the advanced continuous distributions alea example");
    advanced_continuous_distributions_example_step.dependOn(&run_advanced_continuous_distributions_example.step);

    const rank_distributions_example_mod = b.createModule(.{
        .root_source_file = b.path("examples/rank_distributions.zig"),
        .target = target,
        .optimize = optimize,
    });
    rank_distributions_example_mod.addImport("alea", module);

    const rank_distributions_example = b.addExecutable(.{
        .name = "alea-rank-distributions",
        .root_module = rank_distributions_example_mod,
    });
    const run_rank_distributions_example = b.addRunArtifact(rank_distributions_example);
    if (b.args) |args| run_rank_distributions_example.addArgs(args);

    const rank_distributions_example_step = b.step("run-rank-distributions", "Run the rank distributions alea example");
    rank_distributions_example_step.dependOn(&run_rank_distributions_example.step);

    const examples_step = b.step("examples", "Run all alea examples");
    examples_step.dependOn(&run_example.step);
    examples_step.dependOn(&run_vector_profiles_example.step);
    examples_step.dependOn(&run_lognormal_profiles_example.step);
    examples_step.dependOn(&run_native_f32_profiles_example.step);
    examples_step.dependOn(&run_weighted_sampling_example.step);
    examples_step.dependOn(&run_multivariate_sampling_example.step);
    examples_step.dependOn(&run_sequence_sampling_example.step);
    examples_step.dependOn(&run_string_generation_example.step);
    examples_step.dependOn(&run_unit_geometry_example.step);
    examples_step.dependOn(&run_distribution_diagnostics_example.step);
    examples_step.dependOn(&run_reproducible_streams_example.step);
    examples_step.dependOn(&run_range_sampling_example.step);
    examples_step.dependOn(&run_discrete_distributions_example.step);
    examples_step.dependOn(&run_continuous_distributions_example.step);
    examples_step.dependOn(&run_advanced_continuous_distributions_example.step);
    examples_step.dependOn(&run_rank_distributions_example.step);

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

    const libc_module = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const bench_libc_mod = b.createModule(.{
        .root_source_file = b.path("bench/throughput.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    bench_libc_mod.addImport("alea", libc_module);

    const bench_libc = b.addExecutable(.{
        .name = "alea-throughput-libc",
        .root_module = bench_libc_mod,
    });
    const run_bench_libc = b.addRunArtifact(bench_libc);
    if (b.args) |args| run_bench_libc.addArgs(args);

    const bench_libc_step = b.step("bench-libc", "Run the libc-linked alea throughput benchmark");
    bench_libc_step.dependOn(&run_bench_libc.step);

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
        .link_libc = true,
    });
    if (target.result.cpu.arch == .x86_64 and target.result.os.tag == .linux and target.result.abi.isGnu()) {
        log_normal_probe_mod.linkSystemLibrary("mvec", .{});
    }
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

    const poisson_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/poisson_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    poisson_probe_mod.addImport("alea", module);

    const poisson_probe = b.addExecutable(.{
        .name = "alea-poisson-probe",
        .root_module = poisson_probe_mod,
    });
    const run_poisson_probe = b.addRunArtifact(poisson_probe);
    if (b.args) |args| run_poisson_probe.addArgs(args);

    const poisson_probe_step = b.step("poisson-probe", "Run Poisson lambda=20 profile microbenchmarks");
    poisson_probe_step.dependOn(&run_poisson_probe.step);

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

    const pert_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/pert_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    pert_probe_mod.addImport("alea", module);

    const pert_probe = b.addExecutable(.{
        .name = "alea-pert-probe",
        .root_module = pert_probe_mod,
    });
    const run_pert_probe = b.addRunArtifact(pert_probe);
    if (b.args) |args| run_pert_probe.addArgs(args);

    const pert_probe_step = b.step("pert-probe", "Run PERT special-case microbenchmarks");
    pert_probe_step.dependOn(&run_pert_probe.step);

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

    const chi_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/chi_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    chi_probe_mod.addImport("alea", module);

    const chi_probe = b.addExecutable(.{
        .name = "alea-chi-probe",
        .root_module = chi_probe_mod,
    });
    const run_chi_probe = b.addRunArtifact(chi_probe);
    if (b.args) |args| run_chi_probe.addArgs(args);

    const chi_probe_step = b.step("chi-probe", "Run Chi bulk expression-shape microbenchmarks");
    chi_probe_step.dependOn(&run_chi_probe.step);

    const erlang_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/erlang_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    erlang_probe_mod.addImport("alea", module);

    const erlang_probe = b.addExecutable(.{
        .name = "alea-erlang-probe",
        .root_module = erlang_probe_mod,
    });
    const run_erlang_probe = b.addRunArtifact(erlang_probe);
    if (b.args) |args| run_erlang_probe.addArgs(args);

    const erlang_probe_step = b.step("erlang-probe", "Run Erlang bulk expression-shape microbenchmarks");
    erlang_probe_step.dependOn(&run_erlang_probe.step);

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

    const half_normal_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/half_normal_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    half_normal_probe_mod.addImport("alea", module);

    const half_normal_probe = b.addExecutable(.{
        .name = "alea-half-normal-probe",
        .root_module = half_normal_probe_mod,
    });
    const run_half_normal_probe = b.addRunArtifact(half_normal_probe);
    if (b.args) |args| run_half_normal_probe.addArgs(args);

    const half_normal_probe_step = b.step("half-normal-probe", "Run HalfNormal bulk expression-shape microbenchmarks");
    half_normal_probe_step.dependOn(&run_half_normal_probe.step);

    const unit_geometry_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/unit_geometry_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    unit_geometry_probe_mod.addImport("alea", module);

    const unit_geometry_probe = b.addExecutable(.{
        .name = "alea-unit-geometry-probe",
        .root_module = unit_geometry_probe_mod,
    });
    const run_unit_geometry_probe = b.addRunArtifact(unit_geometry_probe);
    if (b.args) |args| run_unit_geometry_probe.addArgs(args);

    const unit_geometry_probe_step = b.step("unit-geometry-probe", "Run unit geometry bulk expression-shape microbenchmarks");
    unit_geometry_probe_step.dependOn(&run_unit_geometry_probe.step);

    const weighted_tree_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/weighted_tree_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    weighted_tree_probe_mod.addImport("alea", module);

    const weighted_tree_probe = b.addExecutable(.{
        .name = "alea-weighted-tree-probe",
        .root_module = weighted_tree_probe_mod,
    });
    const run_weighted_tree_probe = b.addRunArtifact(weighted_tree_probe);
    if (b.args) |args| run_weighted_tree_probe.addArgs(args);

    const weighted_tree_probe_step = b.step("weighted-tree-probe", "Run WeightedTree expression-shape microbenchmarks");
    weighted_tree_probe_step.dependOn(&run_weighted_tree_probe.step);

    const standard_fill_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/standard_fill_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    standard_fill_probe_mod.addImport("alea", module);

    const standard_fill_probe = b.addExecutable(.{
        .name = "alea-standard-fill-probe",
        .root_module = standard_fill_probe_mod,
    });
    const run_standard_fill_probe = b.addRunArtifact(standard_fill_probe);
    if (b.args) |args| run_standard_fill_probe.addArgs(args);

    const standard_fill_probe_step = b.step("standard-fill-probe", "Run standard distribution fill microbenchmarks");
    standard_fill_probe_step.dependOn(&run_standard_fill_probe.step);

    const exponential_rate_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/exponential_rate_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    exponential_rate_probe_mod.addImport("alea", module);

    const exponential_rate_probe = b.addExecutable(.{
        .name = "alea-exponential-rate-probe",
        .root_module = exponential_rate_probe_mod,
    });
    const run_exponential_rate_probe = b.addRunArtifact(exponential_rate_probe);
    if (b.args) |args| run_exponential_rate_probe.addArgs(args);

    const exponential_rate_probe_step = b.step("exponential-rate-probe", "Run exponential rate bulk microbenchmarks");
    exponential_rate_probe_step.dependOn(&run_exponential_rate_probe.step);

    const normal_affine_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/normal_affine_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    normal_affine_probe_mod.addImport("alea", module);

    const normal_affine_probe = b.addExecutable(.{
        .name = "alea-normal-affine-probe",
        .root_module = normal_affine_probe_mod,
    });
    const run_normal_affine_probe = b.addRunArtifact(normal_affine_probe);
    if (b.args) |args| run_normal_affine_probe.addArgs(args);

    const normal_affine_probe_step = b.step("normal-affine-probe", "Run normal affine bulk microbenchmarks");
    normal_affine_probe_step.dependOn(&run_normal_affine_probe.step);

    const gamma_shape_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/gamma_shape_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    gamma_shape_probe_mod.addImport("alea", module);

    const gamma_shape_probe = b.addExecutable(.{
        .name = "alea-gamma-shape-probe",
        .root_module = gamma_shape_probe_mod,
    });
    const run_gamma_shape_probe = b.addRunArtifact(gamma_shape_probe);
    if (b.args) |args| run_gamma_shape_probe.addArgs(args);

    const gamma_shape_probe_step = b.step("gamma-shape-probe", "Run gamma shape-specialization microbenchmarks");
    gamma_shape_probe_step.dependOn(&run_gamma_shape_probe.step);

    const student_t_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/student_t_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    student_t_probe_mod.addImport("alea", module);

    const student_t_probe = b.addExecutable(.{
        .name = "alea-student-t-probe",
        .root_module = student_t_probe_mod,
    });
    const run_student_t_probe = b.addRunArtifact(student_t_probe);
    if (b.args) |args| run_student_t_probe.addArgs(args);

    const student_t_probe_step = b.step("student-t-probe", "Run StudentT special-case microbenchmarks");
    student_t_probe_step.dependOn(&run_student_t_probe.step);

    const fisher_f_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/fisher_f_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    fisher_f_probe_mod.addImport("alea", module);

    const fisher_f_probe = b.addExecutable(.{
        .name = "alea-fisher-f-probe",
        .root_module = fisher_f_probe_mod,
    });
    const run_fisher_f_probe = b.addRunArtifact(fisher_f_probe);
    if (b.args) |args| run_fisher_f_probe.addArgs(args);

    const fisher_f_probe_step = b.step("fisher-f-probe", "Run Fisher-F special-case microbenchmarks");
    fisher_f_probe_step.dependOn(&run_fisher_f_probe.step);

    const beta_special_probe_mod = b.createModule(.{
        .root_source_file = b.path("tools/beta_special_probe.zig"),
        .target = target,
        .optimize = optimize,
    });
    beta_special_probe_mod.addImport("alea", module);

    const beta_special_probe = b.addExecutable(.{
        .name = "alea-beta-special-probe",
        .root_module = beta_special_probe_mod,
    });
    const run_beta_special_probe = b.addRunArtifact(beta_special_probe);
    if (b.args) |args| run_beta_special_probe.addArgs(args);

    const beta_special_probe_step = b.step("beta-special-probe", "Run Beta special-case microbenchmarks");
    beta_special_probe_step.dependOn(&run_beta_special_probe.step);

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

    const apicheck_mod = b.createModule(.{
        .root_source_file = b.path("tools/apicheck.zig"),
        .target = target,
        .optimize = optimize,
    });

    const apicheck = b.addExecutable(.{
        .name = "alea-apicheck",
        .root_module = apicheck_mod,
    });
    const run_apicheck = b.addRunArtifact(apicheck);
    if (b.args) |args| run_apicheck.addArgs(args);

    const apicheck_step = b.step("apicheck", "Check public API reference coverage");
    apicheck_step.dependOn(&run_apicheck.step);

    const examplecheck_mod = b.createModule(.{
        .root_source_file = b.path("tools/examplecheck.zig"),
        .target = target,
        .optimize = optimize,
    });

    const examplecheck = b.addExecutable(.{
        .name = "alea-examplecheck",
        .root_module = examplecheck_mod,
    });
    const run_examplecheck = b.addRunArtifact(examplecheck);
    if (b.args) |args| run_examplecheck.addArgs(args);

    const examplecheck_step = b.step("examplecheck", "Check runnable examples catalog coverage");
    examplecheck_step.dependOn(&run_examplecheck.step);

    const toolingcheck_mod = b.createModule(.{
        .root_source_file = b.path("tools/toolingcheck.zig"),
        .target = target,
        .optimize = optimize,
    });

    const toolingcheck = b.addExecutable(.{
        .name = "alea-toolingcheck",
        .root_module = toolingcheck_mod,
    });
    const run_toolingcheck = b.addRunArtifact(toolingcheck);
    if (b.args) |args| run_toolingcheck.addArgs(args);

    const toolingcheck_step = b.step("toolingcheck", "Check build/tooling catalog coverage");
    toolingcheck_step.dependOn(&run_toolingcheck.step);

    const readmecheck_mod = b.createModule(.{
        .root_source_file = b.path("tools/readmecheck.zig"),
        .target = target,
        .optimize = optimize,
    });

    const readmecheck = b.addExecutable(.{
        .name = "alea-readmecheck",
        .root_module = readmecheck_mod,
    });
    const run_readmecheck = b.addRunArtifact(readmecheck);
    if (b.args) |args| run_readmecheck.addArgs(args);

    const readmecheck_step = b.step("readmecheck", "Check README discovery coverage");
    readmecheck_step.dependOn(&run_readmecheck.step);

    const roadmapcheck_mod = b.createModule(.{
        .root_source_file = b.path("tools/roadmapcheck.zig"),
        .target = target,
        .optimize = optimize,
    });

    const roadmapcheck = b.addExecutable(.{
        .name = "alea-roadmapcheck",
        .root_module = roadmapcheck_mod,
    });
    const run_roadmapcheck = b.addRunArtifact(roadmapcheck);
    if (b.args) |args| run_roadmapcheck.addArgs(args);

    const roadmapcheck_step = b.step("roadmapcheck", "Check roadmap and audit evidence coverage");
    roadmapcheck_step.dependOn(&run_roadmapcheck.step);

    const doccheck_step = b.step("doccheck", "Run documentation, catalog, and roadmap coverage checks");
    doccheck_step.dependOn(&run_apicheck.step);
    doccheck_step.dependOn(&run_examplecheck.step);
    doccheck_step.dependOn(&run_toolingcheck.step);
    doccheck_step.dependOn(&run_readmecheck.step);
    doccheck_step.dependOn(&run_roadmapcheck.step);

    const test_step = b.step("test", "Run alea unit tests and documentation checks");
    test_step.dependOn(&run_tests.step);
    test_step.dependOn(doccheck_step);

    const crosscheck_step = b.step("crosscheck", "Compile unit tests for secondary targets without executing them");
    inline for (cross_compile_targets) |cross_target| {
        const cross_tests = b.addTest(.{
            .name = b.fmt("alea-tests-{s}", .{cross_target.name}),
            .root_module = b.createModule(.{
                .root_source_file = b.path("src/root.zig"),
                .target = b.resolveTargetQuery(cross_target.query),
                .optimize = optimize,
            }),
        });
        cross_tests.generated_bin = null;
        crosscheck_step.dependOn(&cross_tests.step);
    }

    const wasi_test_step = b.step("test-wasi", "Run wasm32-wasi unit tests through Node's WASI runtime");
    const wasi_report_step = b.step("wasi-report", "Run wasm32-wasi repro/statcheck/distcheck through Node's WASI runtime");
    if (b.findProgram(&.{"node"}, &.{})) |node_path| {
        const wasi_tests = b.addTest(.{
            .name = "alea-tests-wasm32-wasi-node",
            .root_module = b.createModule(.{
                .root_source_file = b.path("src/root.zig"),
                .target = b.resolveTargetQuery(wasi_test_target),
                .optimize = optimize,
            }),
        });
        wasi_tests.setExecCmd(&.{ node_path, "--no-warnings", "tools/run_wasi_test.js", null });

        const run_wasi_tests = b.addRunArtifact(wasi_tests);
        run_wasi_tests.addFileInput(b.path("tools/run_wasi_test.js"));
        wasi_test_step.dependOn(&run_wasi_tests.step);

        const wasi_alea_mod = b.createModule(.{
            .root_source_file = b.path("src/root.zig"),
            .target = b.resolveTargetQuery(wasi_test_target),
            .optimize = optimize,
        });
        const wasi_repro = addWasiTool(b, optimize, node_path, wasi_alea_mod, "repro", "tools/repro.zig");
        const wasi_statcheck = addWasiTool(b, optimize, node_path, wasi_alea_mod, "statcheck", "tools/statcheck.zig");
        const wasi_distcheck = addWasiTool(b, optimize, node_path, wasi_alea_mod, "distcheck", "tools/distcheck.zig");
        const wasi_profilecheck = addWasiTool(b, optimize, node_path, wasi_alea_mod, "profilecheck", "tools/profilecheck.zig");
        const wasi_profiletailcheck = addWasiTool(b, optimize, node_path, wasi_alea_mod, "profiletailcheck", "tools/profiletailcheck.zig");
        const wasi_profilestresscheck = addWasiTool(b, optimize, node_path, wasi_alea_mod, "profilestresscheck", "tools/profilestresscheck.zig");
        const wasi_profilelongcheck = addWasiTool(b, optimize, node_path, wasi_alea_mod, "profilelongcheck", "tools/profilelongcheck.zig");
        wasi_statcheck.step.dependOn(&wasi_repro.step);
        wasi_distcheck.step.dependOn(&wasi_statcheck.step);
        wasi_profilecheck.step.dependOn(&wasi_distcheck.step);
        wasi_profiletailcheck.step.dependOn(&wasi_profilecheck.step);
        wasi_profilestresscheck.step.dependOn(&wasi_profiletailcheck.step);
        wasi_profilelongcheck.step.dependOn(&wasi_profilestresscheck.step);
        wasi_report_step.dependOn(&wasi_profilelongcheck.step);
    } else |_| {
        const node_missing = b.addFail("zig build test-wasi and zig build wasi-report require node with node:wasi support");
        wasi_test_step.dependOn(&node_missing.step);
        wasi_report_step.dependOn(&node_missing.step);
    }

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

    const distcheck_libc_mod = b.createModule(.{
        .root_source_file = b.path("tools/distcheck.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    distcheck_libc_mod.addImport("alea", libc_module);

    const distcheck_libc = b.addExecutable(.{
        .name = "alea-distcheck-libc",
        .root_module = distcheck_libc_mod,
    });
    const run_distcheck_libc = b.addRunArtifact(distcheck_libc);
    if (b.args) |args| run_distcheck_libc.addArgs(args);

    const distcheck_libc_step = b.step("distcheck-libc", "Run libc-linked distribution checks");
    distcheck_libc_step.dependOn(&run_distcheck_libc.step);

    const profilecheck_mod = b.createModule(.{
        .root_source_file = b.path("tools/profilecheck.zig"),
        .target = target,
        .optimize = optimize,
    });
    profilecheck_mod.addImport("alea", module);

    const profilecheck = b.addExecutable(.{
        .name = "alea-profilecheck",
        .root_module = profilecheck_mod,
    });
    const run_profilecheck = b.addRunArtifact(profilecheck);
    if (b.args) |args| run_profilecheck.addArgs(args);

    const profilecheck_step = b.step("profilecheck", "Run accepted vector profile distribution checks");
    profilecheck_step.dependOn(&run_profilecheck.step);

    const profiletailcheck_mod = b.createModule(.{
        .root_source_file = b.path("tools/profiletailcheck.zig"),
        .target = target,
        .optimize = optimize,
    });
    profiletailcheck_mod.addImport("alea", module);

    const profiletailcheck = b.addExecutable(.{
        .name = "alea-profiletailcheck",
        .root_module = profiletailcheck_mod,
    });
    const run_profiletailcheck = b.addRunArtifact(profiletailcheck);
    if (b.args) |args| run_profiletailcheck.addArgs(args);

    const profiletailcheck_step = b.step("profilecheck-tail", "Run accepted vector profile tail checks");
    profiletailcheck_step.dependOn(&run_profiletailcheck.step);

    const profilestresscheck_mod = b.createModule(.{
        .root_source_file = b.path("tools/profilestresscheck.zig"),
        .target = target,
        .optimize = optimize,
    });
    profilestresscheck_mod.addImport("alea", module);

    const profilestresscheck = b.addExecutable(.{
        .name = "alea-profilestresscheck",
        .root_module = profilestresscheck_mod,
    });
    const run_profilestresscheck = b.addRunArtifact(profilestresscheck);
    if (b.args) |args| run_profilestresscheck.addArgs(args);

    const profilestresscheck_step = b.step("profilecheck-stress", "Run accepted vector profile multi-seed stress checks");
    profilestresscheck_step.dependOn(&run_profilestresscheck.step);

    const profilelongcheck_mod = b.createModule(.{
        .root_source_file = b.path("tools/profilelongcheck.zig"),
        .target = target,
        .optimize = optimize,
    });
    profilelongcheck_mod.addImport("alea", module);

    const profilelongcheck = b.addExecutable(.{
        .name = "alea-profilelongcheck",
        .root_module = profilelongcheck_mod,
    });
    const run_profilelongcheck = b.addRunArtifact(profilelongcheck);
    if (b.args) |args| run_profilelongcheck.addArgs(args);

    const profilelongcheck_step = b.step("profilecheck-long", "Run accepted vector profile long stress checks");
    profilelongcheck_step.dependOn(&run_profilelongcheck.step);

    const validate_step = b.step("validate", "Run unit, API, statistical, and distribution checks");
    validate_step.dependOn(&run_tests.step);
    validate_step.dependOn(examples_step);
    validate_step.dependOn(doccheck_step);
    validate_step.dependOn(&run_statcheck.step);
    validate_step.dependOn(&run_distcheck.step);
    validate_step.dependOn(&run_distcheck_libc.step);
    validate_step.dependOn(&run_profilecheck.step);

    const validate_all_step = b.step("validate-all", "Run native validation plus cross-target and WASI runtime checks");
    validate_all_step.dependOn(validate_step);
    validate_all_step.dependOn(crosscheck_step);
    validate_all_step.dependOn(wasi_test_step);
    validate_all_step.dependOn(wasi_report_step);

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

fn addWasiTool(
    b: *std.Build,
    optimize: std.builtin.OptimizeMode,
    node_path: []const u8,
    alea_mod: *std.Build.Module,
    comptime name: []const u8,
    comptime source_path: []const u8,
) *std.Build.Step.Run {
    const tool_mod = b.createModule(.{
        .root_source_file = b.path(source_path),
        .target = b.resolveTargetQuery(wasi_test_target),
        .optimize = optimize,
    });
    tool_mod.addImport("alea", alea_mod);

    const tool = b.addExecutable(.{
        .name = "alea-wasi-" ++ name,
        .root_module = tool_mod,
    });

    const run_tool = b.addSystemCommand(&.{ node_path, "--no-warnings", "tools/run_wasi_test.js" });
    run_tool.addArtifactArg(tool);
    run_tool.addFileInput(b.path("tools/run_wasi_test.js"));

    const tool_step = b.step("wasi-" ++ name, "Run wasm32-wasi " ++ name ++ " through Node's WASI runtime");
    tool_step.dependOn(&run_tool.step);
    return run_tool;
}

const CrossCompileTarget = struct {
    name: []const u8,
    query: std.Target.Query,
};

const wasi_test_target: std.Target.Query = .{
    .cpu_arch = .wasm32,
    .os_tag = .wasi,
    .abi = .musl,
};

const cross_compile_targets = [_]CrossCompileTarget{
    .{
        .name = "wasm32-wasi",
        .query = wasi_test_target,
    },
    .{
        .name = "aarch64-linux",
        .query = .{
            .cpu_arch = .aarch64,
            .os_tag = .linux,
        },
    },
    .{
        .name = "riscv64-linux",
        .query = .{
            .cpu_arch = .riscv64,
            .os_tag = .linux,
        },
    },
    .{
        .name = "x86_64-windows",
        .query = .{
            .cpu_arch = .x86_64,
            .os_tag = .windows,
        },
    },
    .{
        .name = "x86_64-macos",
        .query = .{
            .cpu_arch = .x86_64,
            .os_tag = .macos,
        },
    },
    .{
        .name = "aarch64-macos",
        .query = .{
            .cpu_arch = .aarch64,
            .os_tag = .macos,
        },
    },
};
