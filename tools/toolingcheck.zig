const std = @import("std");

const BuildStep = struct {
    name: []const u8,
    build_token: []const u8,
};

const Tool = struct {
    path: []const u8,
    build_token: []const u8 = "",
};

const test_doc_tokens = [_][]const u8{
    "Run unit tests plus the full `doccheck` aggregate",
    "API, examples, tooling, README, and roadmap checks",
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

const bench_dependencies = [_][]const u8{
    "bench_step.dependOn(&run_bench_tests.step)",
    "bench_step.dependOn(&run_bench.step)",
};

const bench_libc_dependencies = [_][]const u8{
    "bench_libc_step.dependOn(&run_bench_libc_tests.step)",
    "bench_libc_step.dependOn(&run_bench_libc.step)",
};

const vectorbench_dependencies = [_][]const u8{
    "vectorbench_step.dependOn(&run_vectorbench_tests.step)",
    "vectorbench_step.dependOn(&run_vectorbench.step)",
};

const rand_bench_test_dependencies = [_][]const u8{
    "b.addSystemCommand(&.{ \"cargo\", \"test\", \"--manifest-path\", \"compare/rand_bench/Cargo.toml\" })",
    "run_rand_bench_tests.addFileInput(b.path(\"compare/rand_bench/Cargo.toml\"))",
    "run_rand_bench_tests.addFileInput(b.path(\"compare/rand_bench/Cargo.lock\"))",
    "run_rand_bench_tests.addFileInput(b.path(\"compare/rand_bench/src/main.rs\"))",
    "rand_bench_test_step.dependOn(&run_rand_bench_tests.step)",
    "zig build rand-bench-test requires cargo",
};

const rand_bench_doc_tokens = [_][]const u8{
    "zig build rand-bench-test",
    "cargo test --manifest-path compare/rand_bench/Cargo.toml",
    "Rust comparison benchmark helper tests",
};

const rand_bench_smoke_dependencies = [_][]const u8{
    "b.addSystemCommand(&.{ \"tools/rand_bench_smoke.sh\", \"1024\", \"standard-normal\" })",
    "run_rand_bench_smoke.addFileInput(b.path(\"tools/rand_bench_smoke.sh\"))",
    "run_rand_bench_smoke.addFileInput(b.path(\"compare/rand_bench/Cargo.toml\"))",
    "run_rand_bench_smoke.addFileInput(b.path(\"compare/rand_bench/Cargo.lock\"))",
    "run_rand_bench_smoke.addFileInput(b.path(\"compare/rand_bench/src/main.rs\"))",
    "rand_bench_smoke_step.dependOn(&run_rand_bench_smoke.step)",
    "zig build rand-bench-smoke requires cargo",
};

const rand_bench_smoke_doc_tokens = [_][]const u8{
    "zig build rand-bench-smoke",
    "zig build rand-bench-smoke-dry-run",
    "zig build rand-bench-smoke-self-test",
    "tools/rand_bench_smoke.sh 1024 standard-normal",
    "tools/rand_bench_smoke.sh --dry-run 1024 standard-normal",
    "tiny filtered Rust comparison benchmark smoke test",
    "ALEA_RAND_BENCH_MANIFEST",
    "ALEA_RAND_BENCH_EXPECTED_ROW",
};

const rand_bench_smoke_dry_run_dependencies = [_][]const u8{
    "b.addSystemCommand(&.{ \"tools/rand_bench_smoke.sh\", \"--dry-run\", \"1024\", \"standard-normal\" })",
    "run_rand_bench_smoke_dry_run.addFileInput(b.path(\"tools/rand_bench_smoke.sh\"))",
    "b.step(\"rand-bench-smoke-dry-run\"",
    "rand_bench_smoke_dry_run_step.dependOn(&run_rand_bench_smoke_dry_run.step)",
};

const rand_bench_smoke_self_test_dependencies = [_][]const u8{
    "b.addSystemCommand(&.{ \"tools/rand_bench_smoke.sh\", \"--self-test\" })",
    "run_rand_bench_smoke_self_test.addFileInput(b.path(\"tools/rand_bench_smoke.sh\"))",
    "b.step(\"rand-bench-smoke-self-test\"",
    "rand_bench_smoke_self_test_step.dependOn(&run_rand_bench_smoke_self_test.step)",
};

const rand_bench_smoke_script_tokens = [_][]const u8{
    "--dry-run",
    "rand_bench_smoke.sh --self-test",
    "--self-test validates wrapper argument parsing",
    "--self-test",
    "mktemp",
    "trap",
    "cargo run --manifest-path",
    "expected row substring",
    "rand_bench_smoke self-test ok",
    "ALEA_RAND_BENCH_MANIFEST",
    "ALEA_RAND_BENCH_EXPECTED_ROW",
};

const stream_dependencies = [_][]const u8{
    "stream_step.dependOn(&run_stream_tests.step)",
    "stream_step.dependOn(&run_stream.step)",
};

const repro_dependencies = [_][]const u8{
    "repro_step.dependOn(&run_repro_tests.step)",
    "repro_step.dependOn(&run_repro.step)",
};

const distcheck_dependencies = [_][]const u8{
    "distcheck_step.dependOn(&run_distcheck_tests.step)",
    "distcheck_step.dependOn(&run_distcheck.step)",
};

const distcheck_libc_dependencies = [_][]const u8{
    "distcheck_libc_step.dependOn(&run_distcheck_libc_tests.step)",
    "distcheck_libc_step.dependOn(&run_distcheck_libc.step)",
};

const profilecheck_dependencies = [_][]const u8{
    "profilecheck_step.dependOn(&run_profilecheck_tests.step)",
    "profilecheck_step.dependOn(&run_profilecheck.step)",
};

const profiletailcheck_dependencies = [_][]const u8{
    "profiletailcheck_step.dependOn(&run_profiletailcheck_tests.step)",
    "profiletailcheck_step.dependOn(&run_profiletailcheck.step)",
};

const profilestresscheck_dependencies = [_][]const u8{
    "profilestresscheck_step.dependOn(&run_profilestresscheck_tests.step)",
    "profilestresscheck_step.dependOn(&run_profilestresscheck.step)",
};

const profilelongcheck_dependencies = [_][]const u8{
    "profilelongcheck_step.dependOn(&run_profilelongcheck_tests.step)",
    "profilelongcheck_step.dependOn(&run_profilelongcheck.step)",
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

const rand_status_dependencies = [_][]const u8{
    "rand_status_step.dependOn(&run_rand_status_tests.step)",
    "rand_status_step.dependOn(&run_rand_status.step)",
};

const rand_status_json_dependencies = [_][]const u8{
    "run_rand_status_json.addArg(\"--json\")",
    "rand_status_json_step.dependOn(&run_rand_status_tests.step)",
    "rand_status_json_step.dependOn(&run_rand_status_json.step)",
};

const rand_status_schema_version_dependencies = [_][]const u8{
    "run_rand_status_schema_version.addArg(\"--schema-version\")",
    "rand_status_schema_version_step.dependOn(&run_rand_status_tests.step)",
    "rand_status_schema_version_step.dependOn(&run_rand_status_schema_version.step)",
};

const rand_status_self_test_dependencies = [_][]const u8{
    "run_rand_status_self_test.addArg(\"--self-test\")",
    "rand_status_self_test_step.dependOn(&run_rand_status_tests.step)",
    "rand_status_self_test_step.dependOn(&run_rand_status_self_test.step)",
};

const rand_status_doc_tokens = [_][]const u8{
    "zig build rand-status",
    "zig build rand-status-json",
    "zig build rand-status-schema-version",
    "zig build rand-status-self-test",
    "current local `rand` / `rand_distr` comparison status summary",
    "pass `-- --json` for stable JSON",
    "stable JSON",
    "validates text, JSON, help, and bad-argument",
    "`schema_version`, `date`, `baseline.rand`, `baseline.rand_distr`, `latest_gate`",
    "`validate_local_passes`, `public_surface`, `rust_comparison`, `runtime_runners`",
    "`opportunity_runners_available`, `current_conclusion`",
    "`no_known_unblocked_gap`, `remaining_blocker`, `s4_m11_blocked`, `details`",
    "`local_rand_status`, `blocker_audit`, and `latest_validate_local_evidence`",
    "tools/rand_status.zig",
};

const rand_status_source_tokens = [_][]const u8{
    "--json prints the current local rand/rand_distr status as stable JSON",
    "--schema-version prints the stable JSON schema version",
    "--self-test validates text, JSON, help, and bad-argument paths without Rust tools",
    "--definitely-bad",
    "rand-status self-test ok",
    "Alea local rand/rand_distr status (2026-07-10)",
    "\"baseline\"",
    "\"schema_version\"",
    "\"validate_local_passes\"",
    "\"opportunity_runners_available\"",
    "\"current_conclusion\"",
    "\"no_known_unblocked_gap\"",
    "\"remaining_blocker\"",
    "\"s4_m11_blocked\"",
    "\"local_rand_status\"",
    "\"blocker_audit\"",
    "compare/results/s4-m11-blocker-audit.md",
    "\"latest_validate_local_evidence\"",
    "compare/results/s4-m1180-typed-static-weighted-diagnostics.md",
    "Baseline: ~/Work/rand plus cached rand_distr 0.6.0",
    "Latest gate: zig build validate-local passes",
    "Public surface: surfacecheck ok for rand/rand_core/rand_distr manifests",
    "Rust comparison: parser tests and rand-bench-smoke pass",
    "Runtime runners: node/cargo/rustc found; Wasmtime 31.0.0 profilelongcheck evidence recorded",
    "Current conclusion: S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1180 follow-ups closed for current bar",
    "Next bar: S4-M1181 post-S4-M1180 exact/default dense SIMD, broader runtime, or new local Rust gap",
    "Details: compare/results/s4-m420-current-rand-status.md",
};

const validate_dependencies = [_][]const u8{
    "validate_step.dependOn(&run_tests.step)",
    "validate_step.dependOn(examples_step)",
    "validate_step.dependOn(doccheck_step)",
    "validate_step.dependOn(statcheck_step)",
    "validate_step.dependOn(distcheck_step)",
    "validate_step.dependOn(distcheck_libc_step)",
    "validate_step.dependOn(profilecheck_step)",
    "validate_step.dependOn(practrand_self_test_step)",
};

const validate_all_dependencies = [_][]const u8{
    "validate_all_step.dependOn(validate_step)",
    "validate_all_step.dependOn(crosscheck_step)",
    "validate_all_step.dependOn(wasi_test_step)",
    "validate_all_step.dependOn(wasi_dry_run_step)",
    "validate_all_step.dependOn(wasi_self_test_step)",
    "validate_all_step.dependOn(wasi_report_step)",
};

const validate_doc_tokens = [_][]const u8{
    "Run native unit, example, catalog, API, statistical, distribution, libc, accepted-profile",
    "no-external PractRand-wrapper self-test checks",
};

const validate_local_status_tokens = [_][]const u8{
    "compare/results/s4-m420-current-rand-status.md",
    "compare/results/s4-m450-rand-status-command-matrix.md",
    "current local `rand` /",
    "`rand_distr` comparison status",
    "latest status",
    "command matrix evidence",
};

const validate_all_doc_tokens = [_][]const u8{
    "Run native validation plus cross-target compile checks, WASI unit execution",
    "WASI dry/self tests, and the chained WASI report",
};

const validate_description_tokens = [_][]const u8{
    "Run native unit, docs, statistical, distribution, profile, and wrapper checks",
    "Run native validation plus local Rust comparison, status, and runtime checks",
    "Run native validation plus cross-target, WASI dry/self, and runtime checks",
};

const crosscheck_target_tokens = [_][]const u8{
    "wasm32-wasi",
    "aarch64-linux",
    "riscv64-linux",
    "x86_64-windows",
    "x86_64-macos",
    "aarch64-macos",
};

const wasi_dry_run_dependencies = [_][]const u8{
    "b.addSystemCommand(&.{ node_path, \"--no-warnings\", \"tools/run_wasi_test.js\", \"--dry-run\", \"sample.wasm\", \"--flag\" })",
    "wasi_dry_run.addFileInput(b.path(\"tools/run_wasi_test.js\"))",
    "wasi_dry_run_step.dependOn(&wasi_dry_run.step)",
    "wasi_dry_run_step.dependOn(&node_missing.step)",
};

const wasi_self_test_dependencies = [_][]const u8{
    "b.addSystemCommand(&.{ node_path, \"--no-warnings\", \"tools/run_wasi_test.js\", \"--self-test\" })",
    "wasi_self_test.addFileInput(b.path(\"tools/run_wasi_test.js\"))",
    "b.step(\"wasi-self-test\"",
    "wasi_self_test_step.dependOn(&wasi_self_test.step)",
    "wasi_self_test_step.dependOn(&node_missing.step)",
};

const wasi_runner_file_input_tokens = [_][]const u8{
    "run_wasi_tests.addFileInput(b.path(\"tools/run_wasi_test.js\"))",
    "run_tool.addFileInput(b.path(\"tools/run_wasi_test.js\"))",
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
    "includes `zig build practrand-self-test`",
    "Use `zig build validate-local` for Linux-first local `rand` / `rand_distr`",
    "rand-bench-test`, `rand-bench-smoke`,",
    "`rand-bench-smoke-self-test`, `rand-status`, `rand-status-json`, `rand-status-schema-version`, `rand-status-self-test`, `surfacecheck`, and",
    "ALEA_RAND_BENCH_MANIFEST",
    "`runtimecheck`",
    "Use `zig build validate-all` for portability-sensitive changes or evidence",
    "refreshes because it adds cross-target compile checks, WASI unit tests",
    "WASI unit tests, WASI",
    "dry/self tests",
    "zig build rand-status",
    "zig build rand-status -- --json",
    "compare/results/s4-m420-current-rand-status.md",
    "compare/results/s4-m450-rand-status-command-matrix.md",
    "current local",
    "`rand` / `rand_distr` comparison status snapshot",
};

const api_reference_wasi_tokens = [_][]const u8{
    "zig build wasi-self-test",
    "node tools/run_wasi_test.js --self-test",
    "dry-run, help-output, and missing-argument paths without wasm",
};

const api_reference_validation_tokens = [_][]const u8{
    "Use `zig build validate` for broad native API checks",
    "including `zig build practrand-self-test`",
    "no-external PractRand wrapper validation",
    "Use `zig build",
    "validate-local` when API work changes local `rand` / `rand_distr` comparison",
    "rand-bench-test`, `rand-bench-smoke`, `rand-bench-smoke-self-test`, `rand-status`, `rand-status-json`, `rand-status-schema-version`, `rand-status-self-test`, `surfacecheck`, and `runtimecheck`",
    "ALEA_RAND_BENCH_EXPECTED_ROW",
    "Use `zig build",
    "validate-all` for portability-sensitive API evidence",
    "compile checks, WASI unit tests",
    "WASI dry/self tests",
    "zig build rand-status",
    "zig build rand-status -- --json",
    "node tools/run_wasi_test.js --dry-run <test.wasm>",
    "without reading or executing a",
    "wasm file",
    "compare/results/s4-m420-current-rand-status.md",
    "compare/results/s4-m450-rand-status-command-matrix.md",
    "current local `rand` / `rand_distr` comparison status",
};

const practrand_doc_tokens = [_][]const u8{
    "tools/practrand.sh --dry-run",
    "tools/practrand.sh --self-test",
    "zig build practrand-self-test",
    "PRACTRAND_BIN",
};

const core_guide_practrand_tokens = [_][]const u8{
    "tools/practrand.sh --dry-run fast 1048576",
    "tools/practrand.sh --self-test",
    "zig build practrand-dry-run",
    "zig build practrand-self-test",
    "PRACTRAND_BIN",
};

const core_guide_wasi_tokens = [_][]const u8{
    "zig build wasi-dry-run",
    "node tools/run_wasi_test.js --dry-run <test.wasm>",
    "zig build wasi-self-test",
    "node tools/run_wasi_test.js --self-test",
    "dry-run, help-output, and missing-argument paths without wasm",
    "without reading or executing a",
    "wasm file",
};

const core_guide_crosscheck_tokens = [_][]const u8{
    "crosscheck` compiles `wasm32-wasi`",
    "`aarch64-linux`, `riscv64-linux`, `x86_64-windows`, `x86_64-macos`, and",
    "`aarch64-macos` without executing them",
};

const api_reference_practrand_tokens = [_][]const u8{
    "tools/practrand.sh --dry-run fast 1048576",
    "tools/practrand.sh --self-test",
    "zig build practrand-dry-run",
    "zig build practrand-self-test",
};

const api_reference_crosscheck_tokens = [_][]const u8{
    "crosscheck` compiles `wasm32-wasi`, `aarch64-linux`, `riscv64-linux`",
    "`x86_64-windows`, `x86_64-macos`, and `aarch64-macos` without executing them",
};

const practrand_script_tokens = [_][]const u8{
    "--dry-run",
    "--self-test",
    "validates dry-run command construction without requiring RNG_test",
    "mktemp",
    "trap",
    "practrand self-test ok",
    "PRACTRAND_BIN",
    "RNG_test",
    "zig build -Doptimize=ReleaseFast stream -- --engine",
};

const practrand_dry_run_dependencies = [_][]const u8{
    "b.addSystemCommand(&.{ \"tools/practrand.sh\", \"--dry-run\", \"fast\", \"1048576\" })",
    "run_practrand_dry_run.addFileInput(b.path(\"tools/practrand.sh\"))",
    "practrand_dry_run_step.dependOn(&run_practrand_dry_run.step)",
};

const practrand_self_test_dependencies = [_][]const u8{
    "b.addSystemCommand(&.{ \"tools/practrand.sh\", \"--self-test\" })",
    "run_practrand_self_test.addFileInput(b.path(\"tools/practrand.sh\"))",
    "practrand_self_test_step.dependOn(&run_practrand_self_test.step)",
};

const tooling_wasi_dry_run_tokens = [_][]const u8{
    "| `zig build wasi-self-test` | Run Node WASI runner self-tests for dry-run output, help output, and missing-argument usage without reading or executing wasm. |",
    "node tools/run_wasi_test.js --dry-run <test.wasm> [args...]",
    "node tools/run_wasi_test.js --self-test",
    "zig build wasi-self-test",
    "verify WASI runner arguments without reading or executing a wasm file",
    "dry-run and missing-argument paths without wasm",
};

const wasi_runner_tokens = [_][]const u8{
    "--dry-run",
    "--self-test",
    "prints WASI argv without reading or executing wasm",
    "validates dry-run and missing-argument paths without wasm",
    "run_wasi_test self-test ok",
    "help usage mismatch",
    "--help",
    "dryRunLine",
    "usage: run_wasi_test.js [--dry-run] <test.wasm> [args...]",
};

const tooling_wasi_runner_tool_tokens = [_][]const u8{
    "`tools/run_wasi_test.js` | Node WASI runner used by WASI build steps, with `--dry-run` argument reporting and `--self-test` coverage for dry-run and missing-argument paths without wasm.",
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
    .{ .name = "rand-bench-test", .build_token = "b.step(\"rand-bench-test\"" },
    .{ .name = "rand-bench-smoke", .build_token = "b.step(\"rand-bench-smoke\"" },
    .{ .name = "rand-bench-smoke-dry-run", .build_token = "b.step(\"rand-bench-smoke-dry-run\"" },
    .{ .name = "rand-bench-smoke-self-test", .build_token = "b.step(\"rand-bench-smoke-self-test\"" },
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
    .{ .name = "rand-status", .build_token = "b.step(\"rand-status\"" },
    .{ .name = "rand-status-json", .build_token = "b.step(\"rand-status-json\"" },
    .{ .name = "rand-status-schema-version", .build_token = "b.step(\"rand-status-schema-version\"" },
    .{ .name = "rand-status-self-test", .build_token = "b.step(\"rand-status-self-test\"" },
    .{ .name = "surfacecheck", .build_token = "b.step(\"surfacecheck\"" },
    .{ .name = "runtimecheck", .build_token = "b.step(\"runtimecheck\"" },
    .{ .name = "doccheck", .build_token = "b.step(\"doccheck\"" },
    .{ .name = "test", .build_token = "b.step(\"test\"" },
    .{ .name = "crosscheck", .build_token = "b.step(\"crosscheck\"" },
    .{ .name = "test-wasi", .build_token = "b.step(\"test-wasi\"" },
    .{ .name = "wasi-dry-run", .build_token = "b.step(\"wasi-dry-run\"" },
    .{ .name = "wasi-self-test", .build_token = "b.step(\"wasi-self-test\"" },
    .{ .name = "wasi-report", .build_token = "b.step(\"wasi-report\"" },
    .{ .name = "wasi-repro", .build_token = "\"repro\", \"tools/repro.zig\"" },
    .{ .name = "wasi-statcheck", .build_token = "\"statcheck\", \"tools/statcheck.zig\"" },
    .{ .name = "wasi-distcheck", .build_token = "\"distcheck\", \"tools/distcheck.zig\"" },
    .{ .name = "wasi-profilecheck", .build_token = "\"profilecheck\", \"tools/profilecheck.zig\"" },
    .{ .name = "wasi-profiletailcheck", .build_token = "\"profiletailcheck\", \"tools/profiletailcheck.zig\"" },
    .{ .name = "wasi-profilestresscheck", .build_token = "\"profilestresscheck\", \"tools/profilestresscheck.zig\"" },
    .{ .name = "wasi-profilelongcheck", .build_token = "\"profilelongcheck\", \"tools/profilelongcheck.zig\"" },
    .{ .name = "stream", .build_token = "b.step(\"stream\"" },
    .{ .name = "practrand-dry-run", .build_token = "b.step(\"practrand-dry-run\"" },
    .{ .name = "practrand-self-test", .build_token = "b.step(\"practrand-self-test\"" },
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
    .{ .path = "tools/rand_bench_smoke.sh", .build_token = "tools/rand_bench_smoke.sh" },
    .{ .path = "tools/rand_status.zig", .build_token = "tools/rand_status.zig" },
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
        if (isShellTool(tool.path) and !isExecutable(io, tool.path)) {
            try stderr.print("toolingcheck: shell tool {s} must be executable\n", .{tool.path});
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
    inline for (practrand_doc_tokens) |token| {
        if (std.mem.indexOf(u8, tooling, token) == null) {
            try stderr.print("toolingcheck: docs/tooling.md missing PractRand token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (core_guide_practrand_tokens) |token| {
        if (std.mem.indexOf(u8, core_guide, token) == null) {
            try stderr.print("toolingcheck: docs/core-guide.md missing PractRand token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (core_guide_wasi_tokens) |token| {
        if (std.mem.indexOf(u8, core_guide, token) == null) {
            try stderr.print("toolingcheck: docs/core-guide.md missing WASI token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (core_guide_crosscheck_tokens) |token| {
        if (std.mem.indexOf(u8, core_guide, token) == null) {
            try stderr.print("toolingcheck: docs/core-guide.md missing crosscheck token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (api_reference_practrand_tokens) |token| {
        if (std.mem.indexOf(u8, api, token) == null) {
            try stderr.print("toolingcheck: docs/api-reference.md missing PractRand token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (api_reference_crosscheck_tokens) |token| {
        if (std.mem.indexOf(u8, api, token) == null) {
            try stderr.print("toolingcheck: docs/api-reference.md missing crosscheck token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (api_reference_wasi_tokens) |token| {
        if (std.mem.indexOf(u8, api, token) == null) {
            try stderr.print("toolingcheck: docs/api-reference.md missing WASI self-test token `{s}`\n", .{token});
            missing += 1;
        }
    }
    const practrand_source = try std.Io.Dir.cwd().readFileAlloc(io, "tools/practrand.sh", allocator, .limited(64 * 1024));
    defer allocator.free(practrand_source);
    inline for (practrand_script_tokens) |token| {
        if (std.mem.indexOf(u8, practrand_source, token) == null) {
            try stderr.print("toolingcheck: tools/practrand.sh missing token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (tooling_wasi_dry_run_tokens) |token| {
        if (std.mem.indexOf(u8, tooling, token) == null) {
            try stderr.print("toolingcheck: docs/tooling.md missing WASI dry-run token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (practrand_dry_run_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: practrand-dry-run missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (practrand_self_test_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: practrand-self-test missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    const wasi_runner_source = try std.Io.Dir.cwd().readFileAlloc(io, "tools/run_wasi_test.js", allocator, .limited(64 * 1024));
    defer allocator.free(wasi_runner_source);
    inline for (wasi_runner_tokens) |token| {
        if (std.mem.indexOf(u8, wasi_runner_source, token) == null) {
            try stderr.print("toolingcheck: tools/run_wasi_test.js missing token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (tooling_wasi_runner_tool_tokens) |token| {
        if (std.mem.indexOf(u8, tooling, token) == null) {
            try stderr.print("toolingcheck: docs/tooling.md missing WASI runner tool token `{s}`\n", .{token});
            missing += 1;
        }
    }
    const rand_status_source = try std.Io.Dir.cwd().readFileAlloc(io, "tools/rand_status.zig", allocator, .limited(64 * 1024));
    defer allocator.free(rand_status_source);
    inline for (rand_status_source_tokens) |token| {
        if (std.mem.indexOf(u8, rand_status_source, token) == null) {
            try stderr.print("toolingcheck: tools/rand_status.zig missing token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (runtimecheck_doc_tokens) |token| {
        if (std.mem.indexOf(u8, tooling, token) == null) {
            try stderr.print("toolingcheck: docs/tooling.md missing runtimecheck token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (test_doc_tokens) |token| {
        if (std.mem.indexOf(u8, tooling, token) == null) {
            try stderr.print("toolingcheck: docs/tooling.md missing test-step token `{s}`\n", .{token});
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
    inline for (validate_description_tokens) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: build.zig missing validation description token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (validate_doc_tokens) |token| {
        if (std.mem.indexOf(u8, tooling, token) == null) {
            try stderr.print("toolingcheck: docs/tooling.md missing validate row token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (validate_local_status_tokens) |token| {
        if (std.mem.indexOf(u8, tooling, token) == null) {
            try stderr.print("toolingcheck: docs/tooling.md missing validate-local status token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (rand_status_doc_tokens) |token| {
        if (std.mem.indexOf(u8, tooling, token) == null) {
            try stderr.print("toolingcheck: docs/tooling.md missing rand-status token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (validate_all_doc_tokens) |token| {
        if (std.mem.indexOf(u8, tooling, token) == null) {
            try stderr.print("toolingcheck: docs/tooling.md missing validate-all row token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (crosscheck_target_tokens) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: build.zig missing crosscheck target `{s}`\n", .{token});
            missing += 1;
        }
        if (std.mem.indexOf(u8, tooling, token) == null) {
            try stderr.print("toolingcheck: docs/tooling.md missing crosscheck target `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (wasi_dry_run_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: wasi-dry-run missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (wasi_self_test_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: wasi-self-test missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (wasi_runner_file_input_tokens) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: build.zig missing WASI runner file input token `{s}`\n", .{token});
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
        std.mem.indexOf(u8, build, "validate_local_step.dependOn(rand_bench_test_step)") == null or
        std.mem.indexOf(u8, build, "validate_local_step.dependOn(rand_bench_smoke_step)") == null or
        std.mem.indexOf(u8, build, "validate_local_step.dependOn(rand_bench_smoke_self_test_step)") == null or
        std.mem.indexOf(u8, build, "validate_local_step.dependOn(rand_status_step)") == null or
        std.mem.indexOf(u8, build, "validate_local_step.dependOn(rand_status_json_step)") == null or
        std.mem.indexOf(u8, build, "validate_local_step.dependOn(rand_status_schema_version_step)") == null or
        std.mem.indexOf(u8, build, "validate_local_step.dependOn(rand_status_self_test_step)") == null or
        std.mem.indexOf(u8, build, "validate_local_step.dependOn(surfacecheck_step)") == null or
        std.mem.indexOf(u8, build, "validate_local_step.dependOn(runtimecheck_step)") == null)
    {
        try stderr.print("toolingcheck: zig build validate-local must depend on validate, rand-bench-test, rand-bench-smoke, rand-bench-smoke-self-test, rand-status, rand-status-json, rand-status-schema-version, rand-status-self-test, surfacecheck, and runtimecheck\n", .{});
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
    inline for (bench_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: bench missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (bench_libc_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: bench-libc missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (vectorbench_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: vectorbench missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (rand_bench_test_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: rand-bench-test missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (rand_bench_doc_tokens) |token| {
        if (std.mem.indexOf(u8, tooling, token) == null) {
            try stderr.print("toolingcheck: docs/tooling.md missing rand-bench-test token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (rand_bench_smoke_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: rand-bench-smoke missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (rand_bench_smoke_doc_tokens) |token| {
        if (std.mem.indexOf(u8, tooling, token) == null) {
            try stderr.print("toolingcheck: docs/tooling.md missing rand-bench-smoke token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (rand_bench_smoke_dry_run_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: rand-bench-smoke-dry-run missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (rand_bench_smoke_self_test_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: rand-bench-smoke-self-test missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    const rand_bench_smoke_source = try std.Io.Dir.cwd().readFileAlloc(io, "tools/rand_bench_smoke.sh", allocator, .limited(64 * 1024));
    defer allocator.free(rand_bench_smoke_source);
    inline for (rand_bench_smoke_script_tokens) |token| {
        if (std.mem.indexOf(u8, rand_bench_smoke_source, token) == null) {
            try stderr.print("toolingcheck: tools/rand_bench_smoke.sh missing token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (stream_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: stream missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (repro_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: repro missing dependency token `{s}`\n", .{token});
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
    inline for (profilecheck_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: profilecheck missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (profiletailcheck_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: profiletailcheck missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (profilestresscheck_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: profilestresscheck missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (profilelongcheck_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: profilelongcheck missing dependency token `{s}`\n", .{token});
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
    inline for (rand_status_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: rand-status missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (rand_status_json_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: rand-status-json missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (rand_status_schema_version_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: rand-status-schema-version missing dependency token `{s}`\n", .{token});
            missing += 1;
        }
    }
    inline for (rand_status_self_test_dependencies) |token| {
        if (std.mem.indexOf(u8, build, token) == null) {
            try stderr.print("toolingcheck: rand-status-self-test missing dependency token `{s}`\n", .{token});
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

fn isShellTool(path: []const u8) bool {
    return std.mem.endsWith(u8, path, ".sh");
}

fn isExecutable(io: std.Io, path: []const u8) bool {
    std.Io.Dir.cwd().access(io, path, .{ .execute = true }) catch return false;
    return true;
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

test "shell tool detection is extension based" {
    try std.testing.expect(isShellTool("tools/practrand.sh"));
    try std.testing.expect(!isShellTool("tools/toolingcheck.zig"));
    try std.testing.expect(!isShellTool("tools/run_wasi_test.js"));
}
