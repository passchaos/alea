const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const test_filter = b.option([]const u8, "test-filter", "Only run unit tests whose name contains this substring");

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
        .filters = if (test_filter) |filter| &.{filter} else &.{},
    });
    const run_tests = b.addRunArtifact(tests);

    const run_example = addToolRun(b, target, optimize, module, "alea-basic", "examples/basic.zig");

    const example_step = b.step("run-basic", "Run the basic alea example");
    example_step.dependOn(&run_example.step);

    const run_vector_profiles_example = addToolRun(b, target, optimize, module, "alea-vector-profiles", "examples/vector_profiles.zig");

    const vector_profiles_example_step = b.step("run-vector-profiles", "Run the vector profile alea example");
    vector_profiles_example_step.dependOn(&run_vector_profiles_example.step);

    const run_lognormal_profiles_example = addToolRun(b, target, optimize, module, "alea-lognormal-profiles", "examples/lognormal_profiles.zig");

    const lognormal_profiles_example_step = b.step("run-lognormal-profiles", "Run the LogNormal profile alea example");
    lognormal_profiles_example_step.dependOn(&run_lognormal_profiles_example.step);

    const run_native_f32_profiles_example = addToolRun(b, target, optimize, module, "alea-native-f32-profiles", "examples/native_f32_profiles.zig");

    const native_f32_profiles_example_step = b.step("run-native-f32-profiles", "Run the native-f32 profile alea example");
    native_f32_profiles_example_step.dependOn(&run_native_f32_profiles_example.step);

    const run_weighted_sampling_example = addToolRun(b, target, optimize, module, "alea-weighted-sampling", "examples/weighted_sampling.zig");

    const weighted_sampling_example_step = b.step("run-weighted-sampling", "Run the weighted sampling alea example");
    weighted_sampling_example_step.dependOn(&run_weighted_sampling_example.step);

    const run_multivariate_sampling_example = addToolRun(b, target, optimize, module, "alea-multivariate-sampling", "examples/multivariate_sampling.zig");

    const multivariate_sampling_example_step = b.step("run-multivariate-sampling", "Run the multivariate sampling alea example");
    multivariate_sampling_example_step.dependOn(&run_multivariate_sampling_example.step);

    const run_sequence_sampling_example = addToolRun(b, target, optimize, module, "alea-sequence-sampling", "examples/sequence_sampling.zig");

    const sequence_sampling_example_step = b.step("run-sequence-sampling", "Run the sequence sampling alea example");
    sequence_sampling_example_step.dependOn(&run_sequence_sampling_example.step);

    const run_caller_owned_sampling_example = addToolRun(b, target, optimize, module, "alea-caller-owned-sampling", "examples/caller_owned_sampling.zig");

    const caller_owned_sampling_example_step = b.step("run-caller-owned-sampling", "Run the caller-owned sampling alea example");
    caller_owned_sampling_example_step.dependOn(&run_caller_owned_sampling_example.step);

    const run_string_generation_example = addToolRun(b, target, optimize, module, "alea-string-generation", "examples/string_generation.zig");

    const string_generation_example_step = b.step("run-string-generation", "Run the string generation alea example");
    string_generation_example_step.dependOn(&run_string_generation_example.step);

    const run_unit_geometry_example = addToolRun(b, target, optimize, module, "alea-unit-geometry", "examples/unit_geometry.zig");

    const unit_geometry_example_step = b.step("run-unit-geometry", "Run the unit geometry alea example");
    unit_geometry_example_step.dependOn(&run_unit_geometry_example.step);

    const run_distribution_diagnostics_example = addToolRun(b, target, optimize, module, "alea-distribution-diagnostics", "examples/distribution_diagnostics.zig");

    const distribution_diagnostics_example_step = b.step("run-distribution-diagnostics", "Run the distribution diagnostics alea example");
    distribution_diagnostics_example_step.dependOn(&run_distribution_diagnostics_example.step);

    const run_reproducible_streams_example = addToolRun(b, target, optimize, module, "alea-reproducible-streams", "examples/reproducible_streams.zig");

    const reproducible_streams_example_step = b.step("run-reproducible-streams", "Run the reproducible streams alea example");
    reproducible_streams_example_step.dependOn(&run_reproducible_streams_example.step);

    const run_range_sampling_example = addToolRun(b, target, optimize, module, "alea-range-sampling", "examples/range_sampling.zig");

    const range_sampling_example_step = b.step("run-range-sampling", "Run the range sampling alea example");
    range_sampling_example_step.dependOn(&run_range_sampling_example.step);

    const run_discrete_distributions_example = addToolRun(b, target, optimize, module, "alea-discrete-distributions", "examples/discrete_distributions.zig");

    const discrete_distributions_example_step = b.step("run-discrete-distributions", "Run the discrete distributions alea example");
    discrete_distributions_example_step.dependOn(&run_discrete_distributions_example.step);

    const run_continuous_distributions_example = addToolRun(b, target, optimize, module, "alea-continuous-distributions", "examples/continuous_distributions.zig");

    const continuous_distributions_example_step = b.step("run-continuous-distributions", "Run the continuous distributions alea example");
    continuous_distributions_example_step.dependOn(&run_continuous_distributions_example.step);

    const run_advanced_continuous_distributions_example = addToolRun(b, target, optimize, module, "alea-advanced-continuous-distributions", "examples/advanced_continuous_distributions.zig");

    const advanced_continuous_distributions_example_step = b.step("run-advanced-continuous-distributions", "Run the advanced continuous distributions alea example");
    advanced_continuous_distributions_example_step.dependOn(&run_advanced_continuous_distributions_example.step);

    const run_rank_distributions_example = addToolRun(b, target, optimize, module, "alea-rank-distributions", "examples/rank_distributions.zig");

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
    examples_step.dependOn(&run_caller_owned_sampling_example.step);
    examples_step.dependOn(&run_string_generation_example.step);
    examples_step.dependOn(&run_unit_geometry_example.step);
    examples_step.dependOn(&run_distribution_diagnostics_example.step);
    examples_step.dependOn(&run_reproducible_streams_example.step);
    examples_step.dependOn(&run_range_sampling_example.step);
    examples_step.dependOn(&run_discrete_distributions_example.step);
    examples_step.dependOn(&run_continuous_distributions_example.step);
    examples_step.dependOn(&run_advanced_continuous_distributions_example.step);
    examples_step.dependOn(&run_rank_distributions_example.step);

    const run_bench = addToolRun(b, target, optimize, module, "alea-throughput", "bench/throughput.zig");

    const bench_tests = b.addTest(.{
        .name = "alea-bench-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("bench/throughput.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "alea", .module = module }},
        }),
    });
    const run_bench_tests = b.addRunArtifact(bench_tests);

    const bench_step = b.step("bench", "Run the alea throughput benchmark");
    bench_step.dependOn(&run_bench_tests.step);
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

    const bench_libc_tests = b.addTest(.{
        .name = "alea-bench-libc-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("bench/throughput.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .imports = &.{.{ .name = "alea", .module = libc_module }},
        }),
    });
    const run_bench_libc_tests = b.addRunArtifact(bench_libc_tests);

    const bench_libc_step = b.step("bench-libc", "Run the libc-linked alea throughput benchmark");
    bench_libc_step.dependOn(&run_bench_libc_tests.step);
    bench_libc_step.dependOn(&run_bench_libc.step);

    const run_vectorbench = addToolRun(b, target, optimize, module, "alea-vectorbench", "bench/vector.zig");

    const vectorbench_tests = b.addTest(.{
        .name = "alea-vectorbench-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("bench/vector.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "alea", .module = module }},
        }),
    });
    const run_vectorbench_tests = b.addRunArtifact(vectorbench_tests);

    const vectorbench_step = b.step("vectorbench", "Run vector/SIMD microbenchmarks");
    vectorbench_step.dependOn(&run_vectorbench_tests.step);
    vectorbench_step.dependOn(&run_vectorbench.step);

    const rand_bench_test_step = b.step("rand-bench-test", "Run Rust comparison benchmark helper tests");
    if (b.findProgram(&.{"cargo"}, &.{})) |_| {
        const run_rand_bench_tests = b.addSystemCommand(&.{ "cargo", "test", "--manifest-path", "compare/rand_bench/Cargo.toml" });
        run_rand_bench_tests.addFileInput(b.path("compare/rand_bench/Cargo.toml"));
        run_rand_bench_tests.addFileInput(b.path("compare/rand_bench/Cargo.lock"));
        run_rand_bench_tests.addFileInput(b.path("compare/rand_bench/src/main.rs"));
        rand_bench_test_step.dependOn(&run_rand_bench_tests.step);
    } else |_| {
        const cargo_missing = b.addFail("zig build rand-bench-test requires cargo");
        rand_bench_test_step.dependOn(&cargo_missing.step);
    }

    const rand_bench_smoke_step = b.step("rand-bench-smoke", "Run a tiny filtered Rust comparison benchmark smoke test");
    if (b.findProgram(&.{"cargo"}, &.{})) |_| {
        const run_rand_bench_smoke = b.addSystemCommand(&.{ "tools/rand_bench_smoke.sh", "1024", "standard-normal" });
        run_rand_bench_smoke.addFileInput(b.path("tools/rand_bench_smoke.sh"));
        run_rand_bench_smoke.addFileInput(b.path("compare/rand_bench/Cargo.toml"));
        run_rand_bench_smoke.addFileInput(b.path("compare/rand_bench/Cargo.lock"));
        run_rand_bench_smoke.addFileInput(b.path("compare/rand_bench/src/main.rs"));
        rand_bench_smoke_step.dependOn(&run_rand_bench_smoke.step);
    } else |_| {
        const cargo_missing = b.addFail("zig build rand-bench-smoke requires cargo");
        rand_bench_smoke_step.dependOn(&cargo_missing.step);
    }

    const run_rand_bench_smoke_dry_run = b.addSystemCommand(&.{ "tools/rand_bench_smoke.sh", "--dry-run", "1024", "standard-normal" });
    run_rand_bench_smoke_dry_run.addFileInput(b.path("tools/rand_bench_smoke.sh"));
    const rand_bench_smoke_dry_run_step = b.step("rand-bench-smoke-dry-run", "Print the Rust comparison benchmark smoke command without running cargo");
    rand_bench_smoke_dry_run_step.dependOn(&run_rand_bench_smoke_dry_run.step);

    const run_rand_bench_smoke_self_test = b.addSystemCommand(&.{ "tools/rand_bench_smoke.sh", "--self-test" });
    run_rand_bench_smoke_self_test.addFileInput(b.path("tools/rand_bench_smoke.sh"));
    const rand_bench_smoke_self_test_step = b.step("rand-bench-smoke-self-test", "Run Rust comparison smoke wrapper self-tests without cargo");
    rand_bench_smoke_self_test_step.dependOn(&run_rand_bench_smoke_self_test.step);

    const run_ziggurat_stats = addToolRun(b, target, optimize, module, "alea-ziggurat-stats", "tools/ziggurat_stats.zig");

    const ziggurat_stats_step = b.step("ziggurat-stats", "Report ziggurat branch frequencies");
    ziggurat_stats_step.dependOn(&run_ziggurat_stats.step);

    const run_ziggurat_probe = addToolRun(b, target, optimize, module, "alea-ziggurat-probe", "tools/ziggurat_probe.zig");

    const ziggurat_probe_step = b.step("ziggurat-probe", "Run ziggurat expression-shape microbenchmarks");
    ziggurat_probe_step.dependOn(&run_ziggurat_probe.step);

    const run_cauchy_probe = addToolRun(b, target, optimize, module, "alea-cauchy-probe", "tools/cauchy_probe.zig");

    const cauchy_probe_step = b.step("cauchy-probe", "Run Cauchy expression-shape microbenchmarks");
    cauchy_probe_step.dependOn(&run_cauchy_probe.step);

    const run_open_closed_probe = addToolRun(b, target, optimize, module, "alea-open-closed-probe", "tools/open_closed_probe.zig");

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

    const run_nig_probe = addToolRun(b, target, optimize, module, "alea-nig-probe", "tools/nig_probe.zig");

    const nig_probe_step = b.step("nig-probe", "Run NormalInverseGaussian bulk expression-shape microbenchmarks");
    nig_probe_step.dependOn(&run_nig_probe.step);

    const run_inverse_gaussian_probe = addToolRun(b, target, optimize, module, "alea-inverse-gaussian-probe", "tools/inverse_gaussian_probe.zig");

    const inverse_gaussian_probe_step = b.step("inverse-gaussian-probe", "Run InverseGaussian bulk expression-shape microbenchmarks");
    inverse_gaussian_probe_step.dependOn(&run_inverse_gaussian_probe.step);

    const run_poisson_probe = addToolRun(b, target, optimize, module, "alea-poisson-probe", "tools/poisson_probe.zig");

    const poisson_probe_step = b.step("poisson-probe", "Run Poisson lambda=20 profile microbenchmarks");
    poisson_probe_step.dependOn(&run_poisson_probe.step);

    const run_skew_normal_probe = addToolRun(b, target, optimize, module, "alea-skew-normal-probe", "tools/skew_normal_probe.zig");

    const skew_normal_probe_step = b.step("skew-normal-probe", "Run SkewNormal bulk expression-shape microbenchmarks");
    skew_normal_probe_step.dependOn(&run_skew_normal_probe.step);

    const run_triangular_probe = addToolRun(b, target, optimize, module, "alea-triangular-probe", "tools/triangular_probe.zig");

    const triangular_probe_step = b.step("triangular-probe", "Run Triangular bulk expression-shape microbenchmarks");
    triangular_probe_step.dependOn(&run_triangular_probe.step);

    const run_rayleigh_probe = addToolRun(b, target, optimize, module, "alea-rayleigh-probe", "tools/rayleigh_probe.zig");

    const rayleigh_probe_step = b.step("rayleigh-probe", "Run Rayleigh bulk expression-shape microbenchmarks");
    rayleigh_probe_step.dependOn(&run_rayleigh_probe.step);

    const run_logistic_probe = addToolRun(b, target, optimize, module, "alea-logistic-probe", "tools/logistic_probe.zig");

    const logistic_probe_step = b.step("logistic-probe", "Run Logistic bulk expression-shape microbenchmarks");
    logistic_probe_step.dependOn(&run_logistic_probe.step);

    const run_laplace_probe = addToolRun(b, target, optimize, module, "alea-laplace-probe", "tools/laplace_probe.zig");

    const laplace_probe_step = b.step("laplace-probe", "Run Laplace bulk expression-shape microbenchmarks");
    laplace_probe_step.dependOn(&run_laplace_probe.step);

    const run_log_logistic_probe = addToolRun(b, target, optimize, module, "alea-log-logistic-probe", "tools/log_logistic_probe.zig");

    const log_logistic_probe_step = b.step("log-logistic-probe", "Run LogLogistic bulk expression-shape microbenchmarks");
    log_logistic_probe_step.dependOn(&run_log_logistic_probe.step);

    const run_power_function_probe = addToolRun(b, target, optimize, module, "alea-power-function-probe", "tools/power_function_probe.zig");

    const power_function_probe_step = b.step("power-function-probe", "Run PowerFunction bulk expression-shape microbenchmarks");
    power_function_probe_step.dependOn(&run_power_function_probe.step);

    const run_kumaraswamy_probe = addToolRun(b, target, optimize, module, "alea-kumaraswamy-probe", "tools/kumaraswamy_probe.zig");

    const kumaraswamy_probe_step = b.step("kumaraswamy-probe", "Run Kumaraswamy bulk expression-shape microbenchmarks");
    kumaraswamy_probe_step.dependOn(&run_kumaraswamy_probe.step);

    const run_gumbel_probe = addToolRun(b, target, optimize, module, "alea-gumbel-probe", "tools/gumbel_probe.zig");

    const gumbel_probe_step = b.step("gumbel-probe", "Run Gumbel bulk expression-shape microbenchmarks");
    gumbel_probe_step.dependOn(&run_gumbel_probe.step);

    const run_frechet_probe = addToolRun(b, target, optimize, module, "alea-frechet-probe", "tools/frechet_probe.zig");

    const frechet_probe_step = b.step("frechet-probe", "Run Frechet bulk expression-shape microbenchmarks");
    frechet_probe_step.dependOn(&run_frechet_probe.step);

    const run_pert_probe = addToolRun(b, target, optimize, module, "alea-pert-probe", "tools/pert_probe.zig");

    const pert_probe_step = b.step("pert-probe", "Run PERT special-case microbenchmarks");
    pert_probe_step.dependOn(&run_pert_probe.step);

    const run_arcsine_probe = addToolRun(b, target, optimize, module, "alea-arcsine-probe", "tools/arcsine_probe.zig");

    const arcsine_probe_step = b.step("arcsine-probe", "Run Arcsine bulk expression-shape microbenchmarks");
    arcsine_probe_step.dependOn(&run_arcsine_probe.step);

    const run_maxwell_probe = addToolRun(b, target, optimize, module, "alea-maxwell-probe", "tools/maxwell_probe.zig");

    const maxwell_probe_step = b.step("maxwell-probe", "Run Maxwell bulk expression-shape microbenchmarks");
    maxwell_probe_step.dependOn(&run_maxwell_probe.step);

    const run_chi_probe = addToolRun(b, target, optimize, module, "alea-chi-probe", "tools/chi_probe.zig");

    const chi_probe_step = b.step("chi-probe", "Run Chi bulk expression-shape microbenchmarks");
    chi_probe_step.dependOn(&run_chi_probe.step);

    const run_erlang_probe = addToolRun(b, target, optimize, module, "alea-erlang-probe", "tools/erlang_probe.zig");

    const erlang_probe_step = b.step("erlang-probe", "Run Erlang bulk expression-shape microbenchmarks");
    erlang_probe_step.dependOn(&run_erlang_probe.step);

    const run_pareto_probe = addToolRun(b, target, optimize, module, "alea-pareto-probe", "tools/pareto_probe.zig");

    const pareto_probe_step = b.step("pareto-probe", "Run Pareto bulk expression-shape microbenchmarks");
    pareto_probe_step.dependOn(&run_pareto_probe.step);

    const run_weibull_probe = addToolRun(b, target, optimize, module, "alea-weibull-probe", "tools/weibull_probe.zig");

    const weibull_probe_step = b.step("weibull-probe", "Run Weibull bulk expression-shape microbenchmarks");
    weibull_probe_step.dependOn(&run_weibull_probe.step);

    const run_half_normal_probe = addToolRun(b, target, optimize, module, "alea-half-normal-probe", "tools/half_normal_probe.zig");

    const half_normal_probe_step = b.step("half-normal-probe", "Run HalfNormal bulk expression-shape microbenchmarks");
    half_normal_probe_step.dependOn(&run_half_normal_probe.step);

    const run_unit_geometry_probe = addToolRun(b, target, optimize, module, "alea-unit-geometry-probe", "tools/unit_geometry_probe.zig");

    const unit_geometry_probe_step = b.step("unit-geometry-probe", "Run unit geometry bulk expression-shape microbenchmarks");
    unit_geometry_probe_step.dependOn(&run_unit_geometry_probe.step);

    const run_weighted_tree_probe = addToolRun(b, target, optimize, module, "alea-weighted-tree-probe", "tools/weighted_tree_probe.zig");

    const weighted_tree_probe_step = b.step("weighted-tree-probe", "Run WeightedTree expression-shape microbenchmarks");
    weighted_tree_probe_step.dependOn(&run_weighted_tree_probe.step);

    const run_standard_fill_probe = addToolRun(b, target, optimize, module, "alea-standard-fill-probe", "tools/standard_fill_probe.zig");

    const standard_fill_probe_step = b.step("standard-fill-probe", "Run standard distribution fill microbenchmarks");
    standard_fill_probe_step.dependOn(&run_standard_fill_probe.step);

    const run_exponential_rate_probe = addToolRun(b, target, optimize, module, "alea-exponential-rate-probe", "tools/exponential_rate_probe.zig");

    const exponential_rate_probe_step = b.step("exponential-rate-probe", "Run exponential rate bulk microbenchmarks");
    exponential_rate_probe_step.dependOn(&run_exponential_rate_probe.step);

    const run_normal_affine_probe = addToolRun(b, target, optimize, module, "alea-normal-affine-probe", "tools/normal_affine_probe.zig");

    const normal_affine_probe_step = b.step("normal-affine-probe", "Run normal affine bulk microbenchmarks");
    normal_affine_probe_step.dependOn(&run_normal_affine_probe.step);

    const run_gamma_shape_probe = addToolRun(b, target, optimize, module, "alea-gamma-shape-probe", "tools/gamma_shape_probe.zig");

    const gamma_shape_probe_step = b.step("gamma-shape-probe", "Run gamma shape-specialization microbenchmarks");
    gamma_shape_probe_step.dependOn(&run_gamma_shape_probe.step);

    const run_student_t_probe = addToolRun(b, target, optimize, module, "alea-student-t-probe", "tools/student_t_probe.zig");

    const student_t_probe_step = b.step("student-t-probe", "Run StudentT special-case microbenchmarks");
    student_t_probe_step.dependOn(&run_student_t_probe.step);

    const run_fisher_f_probe = addToolRun(b, target, optimize, module, "alea-fisher-f-probe", "tools/fisher_f_probe.zig");

    const fisher_f_probe_step = b.step("fisher-f-probe", "Run Fisher-F special-case microbenchmarks");
    fisher_f_probe_step.dependOn(&run_fisher_f_probe.step);

    const run_beta_special_probe = addToolRun(b, target, optimize, module, "alea-beta-special-probe", "tools/beta_special_probe.zig");

    const beta_special_probe_step = b.step("beta-special-probe", "Run Beta special-case microbenchmarks");
    beta_special_probe_step.dependOn(&run_beta_special_probe.step);

    const run_statcheck = addToolRun(b, target, optimize, module, "alea-statcheck", "tools/statcheck.zig");

    const statcheck_tests = b.addTest(.{
        .name = "alea-statcheck-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/statcheck.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "alea", .module = module }},
        }),
    });
    const run_statcheck_tests = b.addRunArtifact(statcheck_tests);

    const statcheck_step = b.step("statcheck", "Run extended statistical smoke checks");
    statcheck_step.dependOn(&run_statcheck_tests.step);
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

    const apicheck_tests = b.addTest(.{
        .name = "alea-apicheck-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/apicheck.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const run_apicheck_tests = b.addRunArtifact(apicheck_tests);

    const apicheck_step = b.step("apicheck", "Check public API reference coverage");
    apicheck_step.dependOn(&run_apicheck_tests.step);
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

    const examplecheck_tests = b.addTest(.{
        .name = "alea-examplecheck-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/examplecheck.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const run_examplecheck_tests = b.addRunArtifact(examplecheck_tests);

    const examplecheck_step = b.step("examplecheck", "Check runnable examples catalog coverage");
    examplecheck_step.dependOn(&run_examplecheck_tests.step);
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

    const toolingcheck_tests = b.addTest(.{
        .name = "alea-toolingcheck-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/toolingcheck.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const run_toolingcheck_tests = b.addRunArtifact(toolingcheck_tests);

    const toolingcheck_step = b.step("toolingcheck", "Check build/tooling catalog coverage");
    toolingcheck_step.dependOn(&run_toolingcheck_tests.step);
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

    const readmecheck_tests = b.addTest(.{
        .name = "alea-readmecheck-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/readmecheck.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const run_readmecheck_tests = b.addRunArtifact(readmecheck_tests);

    const readmecheck_step = b.step("readmecheck", "Check README discovery coverage");
    readmecheck_step.dependOn(&run_readmecheck_tests.step);
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

    const roadmapcheck_tests = b.addTest(.{
        .name = "alea-roadmapcheck-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/roadmapcheck.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const run_roadmapcheck_tests = b.addRunArtifact(roadmapcheck_tests);

    const roadmapcheck_step = b.step("roadmapcheck", "Check roadmap and audit evidence coverage");
    roadmapcheck_step.dependOn(&run_roadmapcheck_tests.step);
    roadmapcheck_step.dependOn(&run_roadmapcheck.step);

    const rand_status_mod = b.createModule(.{
        .root_source_file = b.path("tools/rand_status.zig"),
        .target = target,
        .optimize = optimize,
    });

    const rand_status = b.addExecutable(.{
        .name = "alea-rand-status",
        .root_module = rand_status_mod,
    });
    const run_rand_status = b.addRunArtifact(rand_status);
    if (b.args) |args| run_rand_status.addArgs(args);

    const rand_status_tests = b.addTest(.{
        .name = "alea-rand-status-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/rand_status.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const run_rand_status_tests = b.addRunArtifact(rand_status_tests);

    const rand_status_step = b.step("rand-status", "Print current local rand/rand_distr comparison status");
    rand_status_step.dependOn(&run_rand_status_tests.step);
    rand_status_step.dependOn(&run_rand_status.step);

    const run_rand_status_json = b.addRunArtifact(rand_status);
    run_rand_status_json.addArg("--json");

    const rand_status_json_step = b.step("rand-status-json", "Print current local rand/rand_distr comparison status as JSON");
    rand_status_json_step.dependOn(&run_rand_status_tests.step);
    rand_status_json_step.dependOn(&run_rand_status_json.step);

    const run_rand_status_schema_version = b.addRunArtifact(rand_status);
    run_rand_status_schema_version.addArg("--schema-version");

    const rand_status_schema_version_step = b.step("rand-status-schema-version", "Print rand-status JSON schema version");
    rand_status_schema_version_step.dependOn(&run_rand_status_tests.step);
    rand_status_schema_version_step.dependOn(&run_rand_status_schema_version.step);

    const run_rand_status_self_test = b.addRunArtifact(rand_status);
    run_rand_status_self_test.addArg("--self-test");

    const rand_status_self_test_step = b.step("rand-status-self-test", "Run rand-status text/JSON/help self-tests");
    rand_status_self_test_step.dependOn(&run_rand_status_tests.step);
    rand_status_self_test_step.dependOn(&run_rand_status_self_test.step);

    const surfacecheck_mod = b.createModule(.{
        .root_source_file = b.path("tools/surfacecheck.zig"),
        .target = target,
        .optimize = optimize,
    });

    const surfacecheck = b.addExecutable(.{
        .name = "alea-surfacecheck",
        .root_module = surfacecheck_mod,
    });
    const run_surfacecheck = b.addRunArtifact(surfacecheck);
    if (b.args) |args| run_surfacecheck.addArgs(args);

    const surfacecheck_tests = b.addTest(.{
        .name = "alea-surfacecheck-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/surfacecheck.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const run_surfacecheck_tests = b.addRunArtifact(surfacecheck_tests);

    const surfacecheck_step = b.step("surfacecheck", "Check local Rust rand/rand_distr public-surface manifest coverage");
    surfacecheck_step.dependOn(&run_surfacecheck_tests.step);
    surfacecheck_step.dependOn(&run_surfacecheck.step);

    const runtimecheck_mod = b.createModule(.{
        .root_source_file = b.path("tools/runtimecheck.zig"),
        .target = target,
        .optimize = optimize,
    });

    const runtimecheck = b.addExecutable(.{
        .name = "alea-runtimecheck",
        .root_module = runtimecheck_mod,
    });
    const run_runtimecheck = b.addRunArtifact(runtimecheck);
    if (b.args) |args| run_runtimecheck.addArgs(args);

    const runtimecheck_tests = b.addTest(.{
        .name = "alea-runtimecheck-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/runtimecheck.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const run_runtimecheck_tests = b.addRunArtifact(runtimecheck_tests);

    const runtimecheck_step = b.step("runtimecheck", "Check S4-M11 runtime runner availability");
    runtimecheck_step.dependOn(&run_runtimecheck_tests.step);
    runtimecheck_step.dependOn(&run_runtimecheck.step);

    const doccheck_step = b.step("doccheck", "Run documentation, catalog, and roadmap coverage checks");
    doccheck_step.dependOn(apicheck_step);
    doccheck_step.dependOn(examplecheck_step);
    doccheck_step.dependOn(toolingcheck_step);
    doccheck_step.dependOn(readmecheck_step);
    doccheck_step.dependOn(roadmapcheck_step);

    const test_step = b.step("test", "Run alea unit tests and documentation checks");
    test_step.dependOn(&run_tests.step);
    test_step.dependOn(doccheck_step);

    const fmt_paths = &[_][]const u8{ "build.zig", "src", "tools", "bench", "examples" };
    const fmt_step = b.step("fmt", "Format project Zig sources in place");
    const fmt = b.addFmt(.{ .paths = fmt_paths });
    fmt_step.dependOn(&fmt.step);

    const fmt_check_step = b.step("fmt-check", "Fail when project Zig sources are not formatted");
    const fmt_check = b.addFmt(.{ .paths = fmt_paths, .check = true });
    fmt_check_step.dependOn(&fmt_check.step);

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
    const wasi_dry_run_step = b.step("wasi-dry-run", "Print Node WASI runner argv without executing wasm");
    const wasi_self_test_step = b.step("wasi-self-test", "Run Node WASI runner self-tests without wasm");
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

        const wasi_dry_run = b.addSystemCommand(&.{ node_path, "--no-warnings", "tools/run_wasi_test.js", "--dry-run", "sample.wasm", "--flag" });
        wasi_dry_run.addFileInput(b.path("tools/run_wasi_test.js"));
        wasi_dry_run_step.dependOn(&wasi_dry_run.step);

        const wasi_self_test = b.addSystemCommand(&.{ node_path, "--no-warnings", "tools/run_wasi_test.js", "--self-test" });
        wasi_self_test.addFileInput(b.path("tools/run_wasi_test.js"));
        wasi_self_test_step.dependOn(&wasi_self_test.step);

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
        const node_missing = b.addFail("zig build test-wasi, zig build wasi-report, zig build wasi-dry-run, and zig build wasi-self-test require node with node:wasi support");
        wasi_test_step.dependOn(&node_missing.step);
        wasi_report_step.dependOn(&node_missing.step);
        wasi_dry_run_step.dependOn(&node_missing.step);
        wasi_self_test_step.dependOn(&node_missing.step);
    }

    const run_stream = addToolRun(b, target, optimize, module, "alea-stream", "tools/stream.zig");

    const stream_tests = b.addTest(.{
        .name = "alea-stream-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/stream.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "alea", .module = module }},
        }),
    });
    const run_stream_tests = b.addRunArtifact(stream_tests);

    const stream_step = b.step("stream", "Write raw RNG bytes to stdout for external statistical tools");
    stream_step.dependOn(&run_stream_tests.step);
    stream_step.dependOn(&run_stream.step);

    const run_practrand_dry_run = b.addSystemCommand(&.{ "tools/practrand.sh", "--dry-run", "fast", "1048576" });
    run_practrand_dry_run.addFileInput(b.path("tools/practrand.sh"));
    const practrand_dry_run_step = b.step("practrand-dry-run", "Print the PractRand stream pipeline without running PractRand");
    practrand_dry_run_step.dependOn(&run_practrand_dry_run.step);

    const run_practrand_self_test = b.addSystemCommand(&.{ "tools/practrand.sh", "--self-test" });
    run_practrand_self_test.addFileInput(b.path("tools/practrand.sh"));
    const practrand_self_test_step = b.step("practrand-self-test", "Run PractRand wrapper self-tests without RNG_test");
    practrand_self_test_step.dependOn(&run_practrand_self_test.step);

    const run_distcheck = addToolRun(b, target, optimize, module, "alea-distcheck", "tools/distcheck.zig");

    const distcheck_tests = b.addTest(.{
        .name = "alea-distcheck-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/distcheck.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "alea", .module = module }},
        }),
    });
    const run_distcheck_tests = b.addRunArtifact(distcheck_tests);

    const distcheck_step = b.step("distcheck", "Run parameter-grid distribution checks");
    distcheck_step.dependOn(&run_distcheck_tests.step);
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

    const distcheck_libc_tests = b.addTest(.{
        .name = "alea-distcheck-libc-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/distcheck.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .imports = &.{.{ .name = "alea", .module = libc_module }},
        }),
    });
    const run_distcheck_libc_tests = b.addRunArtifact(distcheck_libc_tests);

    const distcheck_libc_step = b.step("distcheck-libc", "Run libc-linked distribution checks");
    distcheck_libc_step.dependOn(&run_distcheck_libc_tests.step);
    distcheck_libc_step.dependOn(&run_distcheck_libc.step);

    const run_profilecheck = addToolRun(b, target, optimize, module, "alea-profilecheck", "tools/profilecheck.zig");

    const profilecheck_tests = b.addTest(.{
        .name = "alea-profilecheck-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/profilecheck.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "alea", .module = module }},
        }),
    });
    const run_profilecheck_tests = b.addRunArtifact(profilecheck_tests);

    const profilecheck_step = b.step("profilecheck", "Run accepted vector profile distribution checks");
    profilecheck_step.dependOn(&run_profilecheck_tests.step);
    profilecheck_step.dependOn(&run_profilecheck.step);

    const run_profiletailcheck = addToolRun(b, target, optimize, module, "alea-profiletailcheck", "tools/profiletailcheck.zig");

    const profiletailcheck_tests = b.addTest(.{
        .name = "alea-profiletailcheck-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/profiletailcheck.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "alea", .module = module }},
        }),
    });
    const run_profiletailcheck_tests = b.addRunArtifact(profiletailcheck_tests);

    const profiletailcheck_step = b.step("profilecheck-tail", "Run accepted vector profile tail checks");
    profiletailcheck_step.dependOn(&run_profiletailcheck_tests.step);
    profiletailcheck_step.dependOn(&run_profiletailcheck.step);

    const run_profilestresscheck = addToolRun(b, target, optimize, module, "alea-profilestresscheck", "tools/profilestresscheck.zig");

    const profilestresscheck_tests = b.addTest(.{
        .name = "alea-profilestresscheck-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/profilestresscheck.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "alea", .module = module }},
        }),
    });
    const run_profilestresscheck_tests = b.addRunArtifact(profilestresscheck_tests);

    const profilestresscheck_step = b.step("profilecheck-stress", "Run accepted vector profile multi-seed stress checks");
    profilestresscheck_step.dependOn(&run_profilestresscheck_tests.step);
    profilestresscheck_step.dependOn(&run_profilestresscheck.step);

    const run_profilelongcheck = addToolRun(b, target, optimize, module, "alea-profilelongcheck", "tools/profilelongcheck.zig");

    const profilelongcheck_tests = b.addTest(.{
        .name = "alea-profilelongcheck-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/profilelongcheck.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "alea", .module = module }},
        }),
    });
    const run_profilelongcheck_tests = b.addRunArtifact(profilelongcheck_tests);

    const profilelongcheck_step = b.step("profilecheck-long", "Run accepted vector profile long stress checks");
    profilelongcheck_step.dependOn(&run_profilelongcheck_tests.step);
    profilelongcheck_step.dependOn(&run_profilelongcheck.step);

    const validate_step = b.step("validate", "Run native unit, docs, statistical, distribution, profile, and wrapper checks");
    validate_step.dependOn(&run_tests.step);
    validate_step.dependOn(examples_step);
    validate_step.dependOn(doccheck_step);
    validate_step.dependOn(statcheck_step);
    validate_step.dependOn(distcheck_step);
    validate_step.dependOn(distcheck_libc_step);
    validate_step.dependOn(profilecheck_step);
    validate_step.dependOn(practrand_self_test_step);

    const validate_local_step = b.step("validate-local", "Run native validation plus local Rust comparison, status, and runtime checks");
    validate_local_step.dependOn(validate_step);
    validate_local_step.dependOn(rand_bench_test_step);
    validate_local_step.dependOn(rand_bench_smoke_step);
    validate_local_step.dependOn(rand_bench_smoke_self_test_step);
    validate_local_step.dependOn(rand_status_step);
    validate_local_step.dependOn(rand_status_json_step);
    validate_local_step.dependOn(rand_status_schema_version_step);
    validate_local_step.dependOn(rand_status_self_test_step);
    validate_local_step.dependOn(surfacecheck_step);
    validate_local_step.dependOn(runtimecheck_step);

    const validate_all_step = b.step("validate-all", "Run native validation plus cross-target, WASI dry/self, and runtime checks");
    validate_all_step.dependOn(validate_step);
    validate_all_step.dependOn(crosscheck_step);
    validate_all_step.dependOn(wasi_test_step);
    validate_all_step.dependOn(wasi_dry_run_step);
    validate_all_step.dependOn(wasi_self_test_step);
    validate_all_step.dependOn(wasi_report_step);

    const run_hypergeo_h2pe_probe = addToolRun(b, target, optimize, module, "alea-hypergeo-h2pe-probe", "tools/hypergeo_h2pe_probe.zig");

    const hypergeo_h2pe_probe_step = b.step("hypergeo-h2pe-probe", "Run isolated Hypergeometric H2PE experiments");
    hypergeo_h2pe_probe_step.dependOn(&run_hypergeo_h2pe_probe.step);

    const run_repro = addToolRun(b, target, optimize, module, "alea-repro", "tools/repro.zig");

    const repro_tests = b.addTest(.{
        .name = "alea-repro-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/repro.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "alea", .module = module }},
        }),
    });
    const run_repro_tests = b.addRunArtifact(repro_tests);

    const repro_step = b.step("repro", "Print deterministic reproducibility snapshots");
    repro_step.dependOn(&run_repro_tests.step);
    repro_step.dependOn(&run_repro.step);
}

fn addToolRun(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    alea_mod: *std.Build.Module,
    comptime exe_name: []const u8,
    comptime source_path: []const u8,
) *std.Build.Step.Run {
    const tool_mod = b.createModule(.{
        .root_source_file = b.path(source_path),
        .target = target,
        .optimize = optimize,
    });
    tool_mod.addImport("alea", alea_mod);

    const tool = b.addExecutable(.{
        .name = exe_name,
        .root_module = tool_mod,
    });
    const run_tool = b.addRunArtifact(tool);
    if (b.args) |args| run_tool.addArgs(args);
    return run_tool;
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
