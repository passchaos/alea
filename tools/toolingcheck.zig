const std = @import("std");

const BuildStep = struct {
    name: []const u8,
    build_token: []const u8,
};

const Tool = struct {
    path: []const u8,
    build_token: []const u8 = "",
};

const doccheck_dependencies = [_][]const u8{
    "doccheck_step.dependOn(apicheck_step)",
    "doccheck_step.dependOn(examplecheck_step)",
    "doccheck_step.dependOn(toolingcheck_step)",
    "doccheck_step.dependOn(readmecheck_step)",
    "doccheck_step.dependOn(roadmapcheck_step)",
};

const apicheck_dependencies = [_][]const u8{
    "apicheck_step.dependOn(&run_apicheck_tests.step)",
    "apicheck_step.dependOn(&run_apicheck.step)",
};

const examplecheck_dependencies = [_][]const u8{
    "examplecheck_step.dependOn(&run_examplecheck_tests.step)",
    "examplecheck_step.dependOn(&run_examplecheck.step)",
};

const readmecheck_dependencies = [_][]const u8{
    "readmecheck_step.dependOn(&run_readmecheck_tests.step)",
    "readmecheck_step.dependOn(&run_readmecheck.step)",
};

const statcheck_dependencies = [_][]const u8{
    "statcheck_step.dependOn(&run_statcheck_tests.step)",
    "statcheck_step.dependOn(&run_statcheck.step)",
};

const distcheck_dependencies = [_][]const u8{
    "distcheck_step.dependOn(&run_distcheck_tests.step)",
    "distcheck_step.dependOn(&run_distcheck.step)",
};

const distcheck_libc_dependencies = [_][]const u8{
    "distcheck_libc_step.dependOn(&run_distcheck_libc_tests.step)",
    "distcheck_libc_step.dependOn(&run_distcheck_libc.step)",
};

const surfacecheck_dependencies = [_][]const u8{
    "surfacecheck_step.dependOn(&run_surfacecheck_tests.step)",
    "surfacecheck_step.dependOn(&run_surfacecheck.step)",
};

const runtimecheck_dependencies = [_][]const u8{
    "runtimecheck_step.dependOn(&run_runtimecheck_tests.step)",
    "runtimecheck_step.dependOn(&run_runtimecheck.step)",
};

const toolingcheck_dependencies = [_][]const u8{
    "toolingcheck_step.dependOn(&run_toolingcheck_tests.step)",
    "toolingcheck_step.dependOn(&run_toolingcheck.step)",
};

const roadmapcheck_dependencies = [_][]const u8{
    "roadmapcheck_step.dependOn(&run_roadmapcheck_tests.step)",
    "roadmapcheck_step.dependOn(&run_roadmapcheck.step)",
};

const validate_dependencies = [_][]const u8{
    "validate_step.dependOn(&run_tests.step)",
    "validate_step.dependOn(examples_step)",
    "validate_step.dependOn(doccheck_step)",
    "validate_step.dependOn(statcheck_step)",
    "validate_step.dependOn(distcheck_step)",
    "validate_step.dependOn(distcheck_libc_step)",
    "validate_step.dependOn(&run_profilecheck.step)",
};

const validate_all_dependencies = [_][]const u8{
    "validate_all_step.dependOn(validate_step)",
    "validate_all_step.dependOn(crosscheck_step)",
    "validate_all_step.dependOn(wasi_test_step)",
    "validate_all_step.dependOn(wasi_report_step)",
};

const wasi_report_dependencies = [_][]const u8{
    "wasi_statcheck.step.dependOn(&wasi_repro.step)",
    "wasi_distcheck.step.dependOn(&wasi_statcheck.step)",
    "wasi_profilecheck.step.dependOn(&wasi_distcheck.step)",
    "wasi_profiletailcheck.step.dependOn(&wasi_profilecheck.step)",
    "wasi_profilestresscheck.step.dependOn(&wasi_profiletailcheck.step)",
    "wasi_profilelongcheck.step.dependOn(&wasi_profilestresscheck.step)",
    "wasi_report_step.dependOn(&wasi_profilelongcheck.step)",
    "wasi_report_step.dependOn(&node_missing.step)",
};

const core_guide_validation_tokens = [_][]const u8{
    "Use `zig build validate` for broad native checks",
    "Use `zig build validate-local` for Linux-first local `rand` / `rand_distr`",
    "surfacecheck` and `runtimecheck`",
    "Use `zig build validate-all` for portability-sensitive changes or evidence",
    "refreshes because it adds cross-target compile checks, WASI unit tests",
};

const api_reference_validation_tokens = [_][]const u8{
    "Use `zig build validate` for broad native API checks",
    "Use `zig build",
    "validate-local` when API work changes local `rand` / `rand_distr` comparison",
    "surfacecheck` and `runtimecheck`",
    "Use `zig build",
    "validate-all` for portability-sensitive API evidence",
    "compile checks, WASI unit tests",
};

const runtimecheck_doc_tokens = [_][]const u8{
    "zig build runtimecheck",
    "node",
    "cargo",
    "rustc",
    "qemu-aarch64",
    "qemu-aarch64-static",
    "qemu-riscv64",
    "qemu-riscv64-static",
    "qemu-x86_64",
    "qemu-x86_64-static",
    "wine",
    "wine64",
    "wasmtime",
    "wasmer",
};

const build_steps = [_]BuildStep{
    .{ .name = "run-basic", .build_token = "b.step(\"run-basic\"" },
    .{ .name = "run-vector-profiles", .build_token = "b.step(\"run-vector-profiles\"" },
    .{ .name = "run-lognormal-profiles", .build_token = "b.step(\"run-lognormal-profiles\"" },
    .{ .name = "run-native-f32-profiles", .build_token = "b.step(\"run-native-f32-profiles\"" },
    .{ .name = "run-weighted-sampling", .build_token = "b.step(\"run-weighted-sampling\"" },
    .{ .name = "run-multivariate-sampling", .build_token = "b.step(\"run-multivariate-sampling\"" },
    .{ .name = "run-sequence-sampling", .build_token = "b.step(\"run-sequence-sampling\"" },
    .{ .name = "run-caller-owned-sampling", .build_token = "b.step(\"run-caller-owned-sampling\"" },
    .{ .name = "run-string-generation", .build_token = "b.step(\"run-string-generation\"" },
    .{ .name = "run-unit-geometry", .build_token = "b.step(\"run-unit-geometry\"" },
    .{ .name = "run-distribution-diagnostics", .build_token = "b.step(\"run-distribution-diagnostics\"" },
    .{ .name = "run-reproducible-streams", .build_token = "b.step(\"run-reproducible-streams\"" },
    .{ .name = "run-range-sampling", .build_token = "b.step(\"run-range-sampling\"" },
    .{ .name = "run-discrete-distributions", .build_token = "b.step(\"run-discrete-distributions\"" },
    .{ .name = "run-continuous-distributions", .build_token = "b.step(\"run-continuous-distributions\"" },
    .{ .name = "run-advanced-continuous-distributions", .build_token = "b.step(\"run-advanced-continuous-distributions\"" },
    .{ .name = "run-rank-distributions", .build_token = "b.step(\"run-rank-distributions\"" },
    .{ .name = "examples", .build_token = "b.step(\"examples\"" },
    .{ .name = "bench", .build_token = "b.step(\"bench\"" },
    .{ .name = "bench-libc", .build_token = "b.step(\"bench-libc\"" },
    .{ .name = "vectorbench", .build_token = "b.step(\"vectorbench\"" },
    .{ .name = "ziggurat-stats", .build_token = "b.step(\"ziggurat-stats\"" },
    .{ .name = "ziggurat-probe", .build_token = "b.step(\"ziggurat-probe\"" },
    .{ .name = "cauchy-probe", .build_token = "b.step(\"cauchy-probe\"" },
    .{ .name = "open-closed-probe", .build_token = "b.step(\"open-closed-probe\"" },
    .{ .name = "log-normal-probe", .build_token = "b.step(\"log-normal-probe\"" },
    .{ .name = "nig-probe", .build_token = "b.step(\"nig-probe\"" },
    .{ .name = "inverse-gaussian-probe", .build_token = "b.step(\"inverse-gaussian-probe\"" },
    .{ .name = "poisson-probe", .build_token = "b.step(\"poisson-probe\"" },
    .{ .name = "skew-normal-probe", .build_token = "b.step(\"skew-normal-probe\"" },
    .{ .name = "triangular-probe", .build_token = "b.step(\"triangular-probe\"" },
    .{ .name = "rayleigh-probe", .build_token = "b.step(\"rayleigh-probe\"" },
    .{ .name = "logistic-probe", .build_token = "b.step(\"logistic-probe\"" },
    .{ .name = "laplace-probe", .build_token = "b.step(\"laplace-probe\"" },
    .{ .name = "log-logistic-probe", .build_token = "b.step(\"log-logistic-probe\"" },
    .{ .name = "power-function-probe", .build_token = "b.step(\"power-function-probe\"" },
    .{ .name = "kumaraswamy-probe", .build_token = "b.step(\"kumaraswamy-probe\"" },
    .{ .name = "gumbel-probe", .build_token = "b.step(\"gumbel-probe\"" },
    .{ .name = "frechet-probe", .build_token = "b.step(\"frechet-probe\"" },
    .{ .name = "pert-probe", .build_token = "b.step(\"pert-probe\"" },
    .{ .name = "arcsine-probe", .build_token = "b.step(\"arcsine-probe\"" },
    .{ .name = "maxwell-probe", .build_token = "b.step(\"maxwell-probe\"" },
    .{ .name = "chi-probe", .build_token = "b.step(\"chi-probe\"" },
    .{ .name = "erlang-probe", .build_token = "b.step(\"erlang-probe\"" },
    .{ .name = "pareto-probe", .build_token = "b.step(\"pareto-probe\"" },
    .{ .name = "weibull-probe", .build_token = "b.step(\"weibull-probe\"" },
    .{ .name = "half-normal-probe", .build_token = "b.step(\"half-normal-probe\"" },
    .{ .name = "unit-geometry-probe", .build_token = "b.step(\"unit-geometry-probe\"" },
    .{ .name = "weighted-tree-probe", .build_token = "b.step(\"weighted-tree-probe\"" },
    .{ .name = "standard-fill-probe", .build_token = "b.step(\"standard-fill-probe\"" },
    .{ .name = "exponential-rate-probe", .build_token = "b.step(\"exponential-rate-probe\"" },
    .{ .name = "normal-affine-probe", .build_token = "b.step(\"normal-affine-probe\"" },
    .{ .name = "gamma-shape-probe", .build_token = "b.step(\"gamma-shape-probe\"" },
    .{ .name = "student-t-probe", .build_token = "b.step(\"student-t-probe\"" },
    .{ .name = "fisher-f-probe", .build_token = "b.step(\"fisher-f-probe\"" },
    .{ .name = "beta-special-probe", .build_token = "b.step(\"beta-special-probe\"" },
    .{ .name = "statcheck", .build_token = "b.step(\"statcheck\"" },
    .{ .name = "apicheck", .build_token = "b.step(\"apicheck\"" },
    .{ .name = "examplecheck", .build_token = "b.step(\"examplecheck\"" },
    .{ .name = "toolingcheck", .build_token = "b.step(\"toolingcheck\"" },
    .{ .name = "readmecheck", .build_token = "b.step(\"readmecheck\"" },
    .{ .name = "roadmapcheck", .build_token = "b.step(\"roadmapcheck\"" },
    .{ .name = "surfacecheck", .build_token = "b.step(\"surfacecheck\"" },
    .{ .name = "runtimecheck", .build_token = "b.step(\"runtimecheck\"" },
    .{ .name = "doccheck", .build_token = "b.step(\"doccheck\"" },
    .{ .name = "test", .build_token = "b.step(\"test\"" },
    .{ .name = "crosscheck", .build_token = "b.step(\"crosscheck\"" },
    .{ .name = "test-wasi", .build_token = "b.step(\"test-wasi\"" },
    .{ .name = "wasi-report", .build_token = "b.step(\"wasi-report\"" },
    .{ .name = "wasi-repro", .build_token = "\"repro\", \"tools/repro.zig\"" },
    .{ .name = "wasi-statcheck", .build_token = "\"statcheck\", \"tools/statcheck.zig\"" },
    .{ .name = "wasi-distcheck", .build_token = "\"distcheck\", \"tools/distcheck.zig\"" },
    .{ .name = "wasi-profilecheck", .build_token = "\"profilecheck\", \"tools/profilecheck.zig\"" },
    .{ .name = "wasi-profiletailcheck", .build_token = "\"profiletailcheck\", \"tools/profiletailcheck.zig\"" },
    .{ .name = "wasi-profilestresscheck", .build_token = "\"profilestresscheck\", \"tools/profilestresscheck.zig\"" },
    .{ .name = "wasi-profilelongcheck", .build_token = "\"profilelongcheck\", \"tools/profilelongcheck.zig\"" },
    .{ .name = "stream", .build_token = "b.step(\"stream\"" },
    .{ .name = "distcheck", .build_token = "b.step(\"distcheck\"" },
    .{ .name = "distcheck-libc", .build_token = "b.step(\"distcheck-libc\"" },
    .{ .name = "profilecheck", .build_token = "b.step(\"profilecheck\"" },
    .{ .name = "profilecheck-tail", .build_token = "b.step(\"profilecheck-tail\"" },
    .{ .name = "profilecheck-stress", .build_token = "b.step(\"profilecheck-stress\"" },
    .{ .name = "profilecheck-long", .build_token = "b.step(\"profilecheck-long\"" },
    .{ .name = "validate", .build_token = "b.step(\"validate\"" },
    .{ .name = "validate-local", .build_token = "b.step(\"validate-local\"" },
    .{ .name = "validate-all", .build_token = "b.step(\"validate-all\"" },
    .{ .name = "hypergeo-h2pe-probe", .build_token = "b.step(\"hypergeo-h2pe-probe\"" },
    .{ .name = "repro", .build_token = "b.step(\"repro\"" },
};

const tools = [_]Tool{
    .{ .path = "tools/apicheck.zig", .build_token = "tools/apicheck.zig" },
    .{ .path = "tools/arcsine_probe.zig", .build_token = "tools/arcsine_probe.zig" },
    .{ .path = "tools/beta_special_probe.zig", .build_token = "tools/beta_special_probe.zig" },
    .{ .path = "tools/cauchy_probe.zig", .build_token = "tools/cauchy_probe.zig" },
    .{ .path = "tools/chi_probe.zig", .build_token = "tools/chi_probe.zig" },
    .{ .path = "tools/distcheck.zig", .build_token = "tools/distcheck.zig" },
    .{ .path = "tools/erlang_probe.zig", .build_token = "tools/erlang_probe.zig" },
    .{ .path = "tools/examplecheck.zig", .build_token = "tools/examplecheck.zig" },
    .{ .path = "tools/exponential_rate_probe.zig", .build_token = "tools/exponential_rate_probe.zig" },
    .{ .path = "tools/fisher_f_probe.zig", .build_token = "tools/fisher_f_probe.zig" },
    .{ .path = "tools/frechet_probe.zig", .build_token = "tools/frechet_probe.zig" },
    .{ .path = "tools/gamma_shape_probe.zig", .build_token = "tools/gamma_shape_probe.zig" },
    .{ .path = "tools/gumbel_probe.zig", .build_token = "tools/gumbel_probe.zig" },
    .{ .path = "tools/half_normal_probe.zig", .build_token = "tools/half_normal_probe.zig" },
    .{ .path = "tools/hypergeo_h2pe_probe.zig", .build_token = "tools/hypergeo_h2pe_probe.zig" },
    .{ .path = "tools/inverse_gaussian_probe.zig", .build_token = "tools/inverse_gaussian_probe.zig" },
    .{ .path = "tools/kumaraswamy_probe.zig", .build_token = "tools/kumaraswamy_probe.zig" },
    .{ .path = "tools/laplace_probe.zig", .build_token = "tools/laplace_probe.zig" },
    .{ .path = "tools/log_logistic_probe.zig", .build_token = "tools/log_logistic_probe.zig" },
    .{ .path = "tools/log_normal_probe.zig", .build_token = "tools/log_normal_probe.zig" },
    .{ .path = "tools/logistic_probe.zig", .build_token = "tools/logistic_probe.zig" },
    .{ .path = "tools/maxwell_probe.zig", .build_token = "tools/maxwell_probe.zig" },
    .{ .path = "tools/nig_probe.zig", .build_token = "tools/nig_probe.zig" },
    .{ .path = "tools/normal_affine_probe.zig", .build_token = "tools/normal_affine_probe.zig" },
    .{ .path = "tools/open_closed_probe.zig", .build_token = "tools/open_closed_probe.zig" },
    .{ .path = "tools/pareto_probe.zig", .build_token = "tools/pareto_probe.zig" },
    .{ .path = "tools/pert_probe.zig", .build_token = "tools/pert_probe.zig" },
    .{ .path = "tools/poisson_probe.zig", .build_token = "tools/poisson_probe.zig" },
    .{ .path = "tools/power_function_probe.zig", .build_token = "tools/power_function_probe.zig" },
    .{ .path = "tools/practrand.sh" },
    .{ .path = "tools/profilecheck.zig", .build_token = "tools/profilecheck.zig" },
    .{ .path = "tools/profilelongcheck.zig", .build_token = "tools/profilelongcheck.zig" },
    .{ .path = "tools/profilestresscheck.zig", .build_token = "tools/profilestresscheck.zig" },
    .{ .path = "tools/profiletailcheck.zig", .build_token = "tools/profiletailcheck.zig" },
    .{ .path = "tools/rayleigh_probe.zig", .build_token = "tools/rayleigh_probe.zig" },
    .{ .path = "tools/repro.zig", .build_token = "tools/repro.zig" },
    .{ .path = "tools/readmecheck.zig", .build_token = "tools/readmecheck.zig" },
    .{ .path = "tools/roadmapcheck.zig", .build_token = "tools/roadmapcheck.zig" },
    .{ .path = "tools/runtimecheck.zig", .build_token = "tools/runtimecheck.zig" },
    .{ .path = "tools/run_wasi_test.js", .build_token = "tools/run_wasi_test.js" },
    .{ .path = "tools/skew_normal_probe.zig", .build_token = "tools/skew_normal_probe.zig" },
    .{ .path = "tools/standard_fill_probe.zig", .build_token = "tools/standard_fill_probe.zig" },
    .{ .path = "tools/statcheck.zig", .build_token = "tools/statcheck.zig" },
    .{ .path = "tools/stream.zig", .build_token = "tools/stream.zig" },
    .{ .path = "tools/student_t_probe.zig", .build_token = "tools/student_t_probe.zig" },
    .{ .path = "tools/surfacecheck.zig", .build_token = "tools/surfacecheck.zig" },
    .{ .path = "tools/toolingcheck.zig", .build_token = "tools/toolingcheck.zig" },
    .{ .path = "tools/triangular_probe.zig", .build_token = "tools/triangular_probe.zig" },
    .{ .path = "tools/unit_geometry_probe.zig", .build_token = "tools/unit_geometry_probe.zig" },
    .{ .path = "tools/weibull_probe.zig", .build_token = "tools/weibull_probe.zig" },
    .{ .path = "tools/weighted_tree_probe.zig", .build_token = "tools/weighted_tree_probe.zig" },
    .{ .path = "tools/ziggurat_probe.zig", .build_token = "tools/ziggurat_probe.zig" },
    .{ .path = "tools/ziggurat_stats.zig", .build_token = "tools/ziggurat_stats.zig" },
};

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var stderr_buffer: [2048]u8 = undefined;
    var stderr_file = std.Io.File.stderr().writer(io, &stderr_buffer);
    const stderr = &stderr_file.interface;

    const allocator = std.heap.smp_allocator;
    const build = try std.Io.Dir.cwd().readFileAlloc(io, "build.zig", allocator, .limited(8 * 1024 * 1024));
    defer allocator.free(build);
    const tooling = try std.Io.Dir.cwd().readFileAlloc(io, "docs/tooling.md", allocator, .limited(8 * 1024 * 1024));
    defer allocator.free(tooling);
    const api = try std.Io.Dir.cwd().readFileAlloc(io, "docs/api-reference.md", allocator, .limited(8 * 1024 * 1024));
    defer allocator.free(api);
    const core_guide = try std.Io.Dir.cwd().readFileAlloc(io, "docs/core-guide.md", allocator, .limited(8 * 1024 * 1024));
    defer allocator.free(core_guide);

    var missing: usize = 0;

    for (build_steps) |step| {
        if (std.mem.indexOf(u8, build, step.build_token) == null) {
            try stderr.print("toolingcheck: build.zig missing step token `{s}` for `{s}`\n", .{ step.build_token, step.name });
            missing += 1;
        }
        const doc_token = try std.fmt.allocPrint(allocator, "zig build {s}", .{step.name});
        defer allocator.free(doc_token);
        if (std.mem.indexOf(u8, tooling, doc_token) == null) {
            try stderr.print("toolingcheck: docs/tooling.md missing step `{s}`\n", .{doc_token});
            missing += 1;
        }
    }

    try checkUnlistedBuildSteps(stderr, build, &missing);
    try checkUnlistedWasiToolSteps(stderr, build, &missing);

    for (tools) |tool| {
        std.Io.Dir.cwd().access(io, tool.path, .{}) catch |err| {
            try stderr.print("toolingcheck: missing tool {s}: {s}\n", .{ tool.path, @errorName(err) });
            missing += 1;
            continue;
        };
        if (std.mem.indexOf(u8, tooling, tool.path) == null) {
            try stderr.print("toolingcheck: docs/tooling.md missing tool `{s}`\n", .{tool.path});
            missing += 1;
        }
        if (tool.build_token.len != 0 and std.mem.indexOf(u8, build, tool.build_token) == null) {
            try stderr.print("toolingcheck: build.zig missing tool token `{s}` for `{s}`\n", .{ tool.build_token, tool.path });
            missing += 1;
        }
    }

    var dir = try std.Io.Dir.cwd().openDir(io, "tools", .{ .iterate = true });
    defer dir.close(io);
    var it = dir.iterate();
    while (try it.next(io)) |entry| {
        if (entry.kind != .file) continue;
        if (!(std.mem.endsWith(u8, entry.name, ".zig") or
            std.mem.endsWith(u8, entry.name, ".sh") or
            std.mem.endsWith(u8, entry.name, ".js")))
        {
            continue;
        }
        const path = try std.fmt.allocPrint(allocator, "tools/{s}", .{entry.name});
        defer allocator.free(path);
        if (!knownTool(path)) {
            try stderr.print("toolingcheck: source {s} is not listed in tools/toolingcheck.zig\n", .{path});
            missing += 1;
        }
    }

    if (std.mem.indexOf(u8, api, "docs/tooling.md") == null or
        std.mem.indexOf(u8, api, "zig build toolingcheck") == null)
    {
        try stderr.print("toolingcheck: docs/api-reference.md must link docs/tooling.md and mention `zig build toolingcheck`\n", .{});
        missing += 1;
    }
    inline for (api_reference_validation_tokens) |token| {
        if (std.mem.indexOf(u8, api, token) == null) {
            try stderr.print("toolingcheck: docs/api-reference.md missing validation-guidance token `{s}`\n", .{token});
            missing += 1;
        }
    }
    if (std.mem.indexOf(u8, core_guide, "docs/tooling.md") == null or
        std.mem.indexOf(u8, core_guide, "zig build toolingcheck") == null)
    {
        try stderr.print("toolingcheck: docs/core-guide.md must link docs/tooling.md and mention `zig build toolingcheck`\n", .{});
        missing += 1;
    }
    inline for (core_guide_validation_tokens) |token| {
        if (std.mem.indexOf(u8, core_guide, token) == null) {
            try stderr.print("toolingcheck: docs/core-guide.md missing validation-guidance token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (runtimecheck_doc_tokens) |token| {
        if (std.mem.indexOf(u8, tooling, token) == null) {
            try stderr.print("toolingcheck: docs/tooling.md missing runtimecheck token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (validate_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: validate missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (validate_all_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: validate-all missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (wasi_report_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: wasi-report missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    if (std.mem.indexOf(u8, build, "validate_local_step.dependOn(validate_step)") == null or
        std.mem.indexOf(u8, build, "validate_local_step.dependOn(surfacecheck_step)") == null or
        std.mem.indexOf(u8, build, "validate_local_step.dependOn(runtimecheck_step)") == null)
    {
        try stderr.print("toolingcheck: zig build validate-local must depend on validate, surfacecheck, and runtimecheck\n", .{});
        missing += 1;
    }
    inline for (doccheck_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: doccheck missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (apicheck_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: apicheck missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (examplecheck_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: examplecheck missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (readmecheck_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: readmecheck missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (statcheck_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: statcheck missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (distcheck_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: distcheck missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (distcheck_libc_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: distcheck-libc missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (surfacecheck_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: surfacecheck missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (runtimecheck_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: runtimecheck missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (toolingcheck_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: toolingcheck missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (roadmapcheck_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: roadmapcheck missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }

    if (missing != 0) {
        try stderr.flush();
        return error.ToolingCatalogIncomplete;
    }

    try stdout.print("toolingcheck ok\n", .{});
    try stdout.flush();
}

fn checkUnlistedBuildSteps(stderr: *std.Io.Writer, build: []const u8, missing: *usize) !void {
    const prefix = "b.step(\"";
    var offset: usize = 0;
    while (std.mem.indexOfPos(u8, build, offset, prefix)) |index| {
        const start = index + prefix.len;
        const end = std.mem.indexOfScalarPos(u8, build, start, '"') orelse break;
        const name = build[start..end];
        if (!std.mem.eql(u8, name, "wasi-") and !knownBuildStep(name)) {
            try stderr.print("toolingcheck: build step `{s}` is not listed in tools/toolingcheck.zig\n", .{name});
            missing.* += 1;
        }
        offset = end + 1;
    }
}

fn checkUnlistedWasiToolSteps(stderr: *std.Io.Writer, build: []const u8, missing: *usize) !void {
    const prefix = "addWasiTool(b,";
    var offset: usize = 0;
    while (std.mem.indexOfPos(u8, build, offset, prefix)) |index| {
        const name_quote = std.mem.indexOfScalarPos(u8, build, index + prefix.len, '"') orelse break;
        const name_start = name_quote + 1;
        const name_end = std.mem.indexOfScalarPos(u8, build, name_start, '"') orelse break;
        const name = build[name_start..name_end];

        const source_quote = std.mem.indexOfScalarPos(u8, build, name_end + 1, '"') orelse break;
        const source_start = source_quote + 1;
        const source_end = std.mem.indexOfScalarPos(u8, build, source_start, '"') orelse break;
        const source = build[source_start..source_end];

        var step_buffer: [96]u8 = undefined;
        const step_name = std.fmt.bufPrint(&step_buffer, "wasi-{s}", .{name}) catch {
            try stderr.print("toolingcheck: generated WASI step name for `{s}` is too long\n", .{name});
            missing.* += 1;
            offset = source_end + 1;
            continue;
        };

        if (!knownBuildStep(step_name)) {
            try stderr.print("toolingcheck: WASI build step `{s}` is not listed in tools/toolingcheck.zig\n", .{step_name});
            missing.* += 1;
        }
        if (!knownTool(source)) {
            try stderr.print("toolingcheck: WASI source `{s}` is not listed in tools/toolingcheck.zig\n", .{source});
            missing.* += 1;
        }

        offset = source_end + 1;
    }
}

fn knownBuildStep(name: []const u8) bool {
    for (build_steps) |step| {
        if (std.mem.eql(u8, name, step.name)) return true;
    }
    return false;
}

fn knownTool(path: []const u8) bool {
    for (tools) |tool| {
        if (std.mem.eql(u8, path, tool.path)) return true;
    }
    return false;
}

test "known build steps include validation aggregates" {
    try std.testing.expect(knownBuildStep("toolingcheck"));
    try std.testing.expect(knownBuildStep("validate"));
    try std.testing.expect(knownBuildStep("validate-local"));
    try std.testing.expect(knownBuildStep("validate-all"));
    try std.testing.expect(!knownBuildStep("definitely-missing-step"));
}

test "known tools include tooling and roadmap checkers" {
    try std.testing.expect(knownTool("tools/toolingcheck.zig"));
    try std.testing.expect(knownTool("tools/roadmapcheck.zig"));
    try std.testing.expect(!knownTool("tools/definitely-missing.zig"));
}
