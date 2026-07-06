const std = @import("std");

const RequiredToken = struct {
    token: []const u8,
    reason: []const u8,
};

const required_tokens = [_]RequiredToken{
    .{ .token = "docs/core-guide.md", .reason = "core API guide discovery" },
    .{ .token = "docs/api-reference.md", .reason = "public API reference discovery" },
    .{ .token = "docs/examples.md", .reason = "runnable examples catalog discovery" },
    .{ .token = "docs/tooling.md", .reason = "build/tooling catalog discovery" },
    .{ .token = "compare/results/core-rand-coverage.md", .reason = "living roadmap discovery" },
    .{ .token = "compare/results/performance-triage.md", .reason = "performance evidence discovery" },
    .{ .token = "zig build test", .reason = "unit/documentation validation command" },
    .{ .token = "zig build apicheck", .reason = "API reference checker command" },
    .{ .token = "zig build examplecheck", .reason = "examples catalog checker command" },
    .{ .token = "zig build toolingcheck", .reason = "tooling catalog checker command" },
    .{ .token = "zig build readmecheck", .reason = "README discovery checker command" },
    .{ .token = "zig build roadmapcheck", .reason = "roadmap/audit checker command" },
    .{ .token = "zig build surfacecheck", .reason = "local rand public-surface checker command" },
    .{ .token = "zig build runtimecheck", .reason = "runtime runner availability checker command" },
    .{ .token = "zig build doccheck", .reason = "aggregate documentation checker command" },
    .{ .token = "zig build validate", .reason = "native validation command" },
    .{ .token = "broad native checks including the no-external PractRand wrapper self-test", .reason = "validate PractRand self-test explanation" },
    .{ .token = "zig build validate-local", .reason = "native plus local rand validation command" },
    .{ .token = "comparison work: it runs native validation plus `rand-bench-test`", .reason = "validate-local component explanation" },
    .{ .token = "`rand-bench-smoke-self-test`, `surfacecheck`, and `runtimecheck`", .reason = "validate-local smoke/self-test explanation" },
    .{ .token = "zig build rand-bench-test", .reason = "Rust comparison benchmark helper-test command" },
    .{ .token = "zig build rand-bench-smoke", .reason = "Rust comparison benchmark smoke command" },
    .{ .token = "zig build rand-bench-smoke-dry-run", .reason = "Rust comparison benchmark smoke dry-run command" },
    .{ .token = "zig build rand-bench-smoke-self-test", .reason = "Rust comparison benchmark smoke self-test command" },
    .{ .token = "ALEA_RAND_BENCH_MANIFEST", .reason = "Rust comparison smoke manifest override" },
    .{ .token = "ALEA_RAND_BENCH_EXPECTED_ROW", .reason = "Rust comparison smoke expected-row override" },
    .{ .token = "zig build validate-all", .reason = "broad validation command" },
    .{ .token = "wasm32-wasi`, `aarch64-linux`, `riscv64-linux`", .reason = "README crosscheck Linux/WASI targets" },
    .{ .token = "x86_64-windows", .reason = "README crosscheck Windows target" },
    .{ .token = "x86_64-macos`, and `aarch64-macos`", .reason = "README crosscheck macOS targets" },
    .{ .token = "targets without executing them", .reason = "README crosscheck no-execute guidance" },
    .{ .token = "zig build wasi-dry-run", .reason = "WASI dry-run build step" },
    .{ .token = "zig build wasi-self-test", .reason = "WASI runner self-test build step" },
    .{ .token = "node tools/run_wasi_test.js --self-test", .reason = "direct WASI runner self-test command" },
    .{ .token = "Node WASI runner dry-run and missing-argument paths without wasm", .reason = "WASI self-test usage guidance" },
    .{ .token = "Node WASI runner arguments without", .reason = "WASI dry-run usage guidance" },
    .{ .token = "reading or executing a wasm file", .reason = "WASI dry-run no-execution explanation" },
    .{ .token = "portability-sensitive releases or evidence", .reason = "validate-all usage guidance" },
    .{ .token = "cross-target compile checks, WASI unit", .reason = "validate-all component explanation" },
    .{ .token = "tools/practrand.sh --dry-run", .reason = "PractRand dry-run command" },
    .{ .token = "zig build practrand-dry-run", .reason = "PractRand dry-run build step" },
    .{ .token = "tools/practrand.sh --self-test", .reason = "PractRand wrapper self-test command" },
    .{ .token = "zig build practrand-self-test", .reason = "PractRand wrapper self-test build step" },
    .{ .token = "PRACTRAND_BIN", .reason = "custom PractRand binary guidance" },
    .{ .token = "zig build run-basic", .reason = "runnable example entry point" },
    .{ .token = "zig build examples", .reason = "aggregate examples command" },
    .{ .token = "zig build -l", .reason = "generated build-step list discovery" },
    .{ .token = "rng.chooseIndex", .reason = "quick-start one-shot index choice" },
    .{ .token = "rng.chooseConstPtr", .reason = "quick-start const-pointer choice" },
};

const required_files = [_][]const u8{
    "README.md",
    "docs/core-guide.md",
    "docs/api-reference.md",
    "docs/examples.md",
    "docs/tooling.md",
    "compare/results/core-rand-coverage.md",
    "compare/results/performance-triage.md",
};

fn hasRequiredToken(readme: []const u8, required: RequiredToken) bool {
    return std.mem.indexOf(u8, readme, required.token) != null;
}

fn hasProjectPositioning(readme: []const u8) bool {
    return std.mem.indexOf(u8, readme, "`alea` is a Zig 0.16 random toolkit") != null;
}

fn hasLocalRandNote(readme: []const u8) bool {
    return std.mem.indexOf(u8, readme, "local `rand` checkout") != null and
        std.mem.indexOf(u8, readme, "~/Work/rand") != null;
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var stderr_buffer: [2048]u8 = undefined;
    var stderr_file = std.Io.File.stderr().writer(io, &stderr_buffer);
    const stderr = &stderr_file.interface;

    const allocator = std.heap.smp_allocator;
    const readme = try std.Io.Dir.cwd().readFileAlloc(io, "README.md", allocator, .limited(1024 * 1024));
    defer allocator.free(readme);

    var missing: usize = 0;

    inline for (required_files) |path| {
        std.Io.Dir.cwd().access(io, path, .{}) catch |err| {
            try stderr.print("readmecheck: missing referenced file {s}: {s}\n", .{ path, @errorName(err) });
            missing += 1;
        };
    }

    inline for (required_tokens) |required| {
        if (!hasRequiredToken(readme, required)) {
            try stderr.print("readmecheck: README.md missing `{s}` ({s})\n", .{ required.token, required.reason });
            missing += 1;
        }
    }

    if (!hasProjectPositioning(readme)) {
        try stderr.print("readmecheck: README.md missing Zig 0.16 project positioning\n", .{});
        missing += 1;
    }
    if (!hasLocalRandNote(readme)) {
        try stderr.print("readmecheck: README.md missing local rand comparison note\n", .{});
        missing += 1;
    }

    if (missing != 0) {
        try stderr.flush();
        return error.ReadmeIncomplete;
    }

    try stdout.print("readmecheck ok\n", .{});
    try stdout.flush();
}

test "required-token helper matches exact configured token" {
    const required = RequiredToken{
        .token = "zig build validate-local",
        .reason = "native plus local rand validation command",
    };

    try std.testing.expect(hasRequiredToken("run zig build validate-local before comparing", required));
    try std.testing.expect(!hasRequiredToken("run zig build validate before comparing", required));
}

test "required-token helper covers validate PractRand self-test prose" {
    const required = RequiredToken{
        .token = "broad native checks including the no-external PractRand wrapper self-test",
        .reason = "validate PractRand self-test explanation",
    };

    try std.testing.expect(hasRequiredToken(
        "Use `zig build validate` for broad native checks including the no-external PractRand wrapper self-test.",
        required,
    ));
    try std.testing.expect(!hasRequiredToken("Use `zig build validate` for broad native checks.", required));
}

test "required-token helper covers PractRand dry-run guidance" {
    const dry_run = RequiredToken{
        .token = "tools/practrand.sh --dry-run",
        .reason = "PractRand dry-run command",
    };
    const build_step = RequiredToken{
        .token = "zig build practrand-dry-run",
        .reason = "PractRand dry-run build step",
    };
    const self_test = RequiredToken{
        .token = "tools/practrand.sh --self-test",
        .reason = "PractRand wrapper self-test command",
    };
    const self_test_step = RequiredToken{
        .token = "zig build practrand-self-test",
        .reason = "PractRand wrapper self-test build step",
    };
    const binary = RequiredToken{
        .token = "PRACTRAND_BIN",
        .reason = "custom PractRand binary guidance",
    };

    const text =
        \\sh tools/practrand.sh --dry-run fast 1048576
        \\zig build practrand-dry-run
        \\tools/practrand.sh --self-test
        \\zig build practrand-self-test
        \\set PRACTRAND_BIN when the executable is not named RNG_test
    ;
    try std.testing.expect(hasRequiredToken(text, dry_run));
    try std.testing.expect(hasRequiredToken(text, build_step));
    try std.testing.expect(hasRequiredToken(text, self_test));
    try std.testing.expect(hasRequiredToken(text, self_test_step));
    try std.testing.expect(hasRequiredToken(text, binary));
}

test "required-token helper covers crosscheck target guidance" {
    const targets = RequiredToken{
        .token = "wasm32-wasi`, `aarch64-linux`, `riscv64-linux`",
        .reason = "README crosscheck Linux/WASI targets",
    };
    const no_execute = RequiredToken{
        .token = "targets without executing them",
        .reason = "README crosscheck no-execute guidance",
    };

    const text =
        \\`zig build crosscheck` currently compiles `wasm32-wasi`, `aarch64-linux`, `riscv64-linux`,
        \\`x86_64-macos`, and `aarch64-macos` targets without executing them.
    ;
    try std.testing.expect(hasRequiredToken(text, targets));
    try std.testing.expect(hasRequiredToken(text, no_execute));
}

test "required-token helper covers WASI dry-run guidance" {
    const wasi_dry_run = RequiredToken{
        .token = "zig build wasi-dry-run",
        .reason = "WASI dry-run build step",
    };
    const no_execution = RequiredToken{
        .token = "reading or executing a wasm file",
        .reason = "WASI dry-run no-execution explanation",
    };
    const wasi_self_test = RequiredToken{
        .token = "zig build wasi-self-test",
        .reason = "WASI runner self-test build step",
    };
    const direct_wasi_self_test = RequiredToken{
        .token = "node tools/run_wasi_test.js --self-test",
        .reason = "direct WASI runner self-test command",
    };
    const wasi_self_test_usage = RequiredToken{
        .token = "Node WASI runner dry-run and missing-argument paths without wasm",
        .reason = "WASI self-test usage guidance",
    };

    const text =
        \\Use `zig build wasi-dry-run` to verify the Node WASI runner arguments without
        \\reading or executing a wasm file.
        \\Use `zig build wasi-self-test` or `node tools/run_wasi_test.js --self-test`
        \\to self-test the Node WASI runner dry-run and missing-argument paths without wasm.
    ;
    try std.testing.expect(hasRequiredToken(text, wasi_dry_run));
    try std.testing.expect(hasRequiredToken(text, no_execution));
    try std.testing.expect(hasRequiredToken(text, wasi_self_test));
    try std.testing.expect(hasRequiredToken(text, direct_wasi_self_test));
    try std.testing.expect(hasRequiredToken(text, wasi_self_test_usage));
    try std.testing.expect(!hasRequiredToken("run zig build test-wasi before WASI debugging", wasi_dry_run));
}

test "required-token helper covers Rust comparison bench test guidance" {
    const rand_bench_test = RequiredToken{
        .token = "zig build rand-bench-test",
        .reason = "Rust comparison benchmark helper-test command",
    };
    const validate_local = RequiredToken{
        .token = "comparison work: it runs native validation plus `rand-bench-test`",
        .reason = "validate-local component explanation",
    };
    const validate_local_smoke = RequiredToken{
        .token = "`rand-bench-smoke-self-test`, `surfacecheck`, and `runtimecheck`",
        .reason = "validate-local smoke/self-test explanation",
    };
    const rand_bench_smoke = RequiredToken{
        .token = "zig build rand-bench-smoke",
        .reason = "Rust comparison benchmark smoke command",
    };
    const rand_bench_smoke_dry_run = RequiredToken{
        .token = "zig build rand-bench-smoke-dry-run",
        .reason = "Rust comparison benchmark smoke dry-run command",
    };
    const rand_bench_smoke_self_test = RequiredToken{
        .token = "zig build rand-bench-smoke-self-test",
        .reason = "Rust comparison benchmark smoke self-test command",
    };
    const manifest_override = RequiredToken{
        .token = "ALEA_RAND_BENCH_MANIFEST",
        .reason = "Rust comparison smoke manifest override",
    };
    const expected_override = RequiredToken{
        .token = "ALEA_RAND_BENCH_EXPECTED_ROW",
        .reason = "Rust comparison smoke expected-row override",
    };

    const text =
        \\Use `zig build validate-local` for Linux-first local `rand` / `rand_distr`
        \\comparison work: it runs native validation plus `rand-bench-test`, `rand-bench-smoke`,
        \\`rand-bench-smoke-self-test`, `surfacecheck`, and `runtimecheck`.
        \\Run `zig build rand-bench-test` for focused Rust parser coverage.
        \\Run `zig build rand-bench-smoke` for a tiny filtered Rust comparison run.
        \\Run `zig build rand-bench-smoke-dry-run` to preview the cargo command.
        \\Run `zig build rand-bench-smoke-self-test` to test wrapper arguments.
        \\Set ALEA_RAND_BENCH_MANIFEST and ALEA_RAND_BENCH_EXPECTED_ROW for custom smoke checks.
    ;
    try std.testing.expect(hasRequiredToken(text, rand_bench_test));
    try std.testing.expect(hasRequiredToken(text, validate_local));
    try std.testing.expect(hasRequiredToken(text, validate_local_smoke));
    try std.testing.expect(hasRequiredToken(text, rand_bench_smoke));
    try std.testing.expect(hasRequiredToken(text, rand_bench_smoke_dry_run));
    try std.testing.expect(hasRequiredToken(text, rand_bench_smoke_self_test));
    try std.testing.expect(hasRequiredToken(text, manifest_override));
    try std.testing.expect(hasRequiredToken(text, expected_override));
    try std.testing.expect(!hasRequiredToken("run cargo test directly", rand_bench_test));
    try std.testing.expect(!hasRequiredToken("run cargo run directly", rand_bench_smoke));
    try std.testing.expect(!hasRequiredToken("run shell dry run directly", rand_bench_smoke_dry_run));
    try std.testing.expect(!hasRequiredToken("run shell self test directly", rand_bench_smoke_self_test));
}

test "project positioning and local rand note helpers require full phrases" {
    try std.testing.expect(hasProjectPositioning("`alea` is a Zig 0.16 random toolkit for testing"));
    try std.testing.expect(!hasProjectPositioning("alea is a random toolkit"));

    try std.testing.expect(hasLocalRandNote("Use the local `rand` checkout at ~/Work/rand."));
    try std.testing.expect(!hasLocalRandNote("Use the local `rand` checkout."));
    try std.testing.expect(!hasLocalRandNote("Use ~/Work/rand."));
}
