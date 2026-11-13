const std = @import("std");

const Evidence = struct {
    milestone: []const u8,
    path: []const u8,
};

fn parseRoadmapEvidence(allocator: std.mem.Allocator, roadmap: []const u8) ![]Evidence {
    var list: std.ArrayList(Evidence) = .empty;
    var lines = std.mem.splitScalar(u8, roadmap, '\n');
    while (lines.next()) |line| {
        const trimmed = std.mem.trimStart(u8, line, " \t");
        if (!std.mem.startsWith(u8, trimmed, "| S4-M")) continue;
        const first_pipe = std.mem.indexOfScalar(u8, trimmed, '|') orelse continue;
        const second_pipe = std.mem.indexOfScalarPos(u8, trimmed, first_pipe + 1, '|') orelse continue;
        const milestone = std.mem.trim(u8, trimmed[first_pipe + 1 .. second_pipe], " \t");
        if (!std.mem.startsWith(u8, milestone, "S4-M")) continue;
        const number = std.fmt.parseInt(usize, milestone[4..], 10) catch continue;
        if (number < 11) continue;

        var lower_buf: [32]u8 = undefined;
        if (milestone.len > lower_buf.len) continue;
        const lowered = lower_buf[0..milestone.len];
        for (milestone, 0..) |byte, index| lowered[index] = std.ascii.toLower(byte);

        var path: ?[]const u8 = null;
        var offset: usize = 0;
        while (std.mem.indexOfPos(u8, line, offset, "compare/results/")) |start| {
            const end = std.mem.indexOfPos(u8, line, start, ".md") orelse break;
            const candidate = line[start .. end + 3];
            if (std.mem.indexOf(u8, candidate, lowered) != null or path == null) {
                path = candidate;
            }
            offset = end + 3;
        }
        if (path) |evidence_path| {
            try list.append(allocator, .{
                .milestone = try allocator.dupe(u8, milestone),
                .path = try allocator.dupe(u8, evidence_path),
            });
        }
    }
    return list.toOwnedSlice(allocator);
}

const required_tokens = [_][]const u8{
    "Active Goal Completion Audit",
    "S4-M11",
    "blocked",
    "do not call `update_goal(status=complete)`",
    "S4-M1246",
    "S4-M1247",
    "S4-M1248",
    "S4-M1249",
    "S4-M1250",
    "S4-M1251",
    "S4-M1252",
    "S4-M1253",
    "S4-M1254",
    "S4-M1255",
    "S4-M1256",
    "S4-M1257",
    "S4-M1258",
    "S4-M1259",
    "S4-M1260",
    "S4-M1261",
    "S4-M1262",
    "S4-M1263",
    "S4-M1245",
    "S4-M1244",
    "S4-M1243",
    "S4-M1242",
    "S4-M1241",
    "S4-M1240",
    "S4-M1239",
    "S4-M1238",
    "S4-M1237",
    "S4-M1236",
    "S4-M1235",
    "S4-M1234",
    "S4-M1233",
    "S4-M1232",
    "S4-M1231",
    "S4-M1230",
    "S4-M1229",
    "S4-M1228",
    "S4-M1227",
    "S4-M1226",
    "S4-M1225",
    "S4-M1224",
    "S4-M1223",
    "S4-M1222",
    "S4-M1221",
    "S4-M1220",
    "S4-M1219",
    "S4-M1218",
    "S4-M1217",
    "S4-M1216",
    "S4-M1215",
    "S4-M1214",
    "S4-M1213",
    "S4-M1213",
    "S4-M1214",
    "S4-M1213",
    "S4-M1215",
    "S4-M1214",
    "S4-M1213",
    "S4-M1212",
    "S4-M1211",
    "S4-M1210",
    "S4-M1209",
    "S4-M1209",
    "S4-M1210",
    "S4-M1209",
    "S4-M1208",
    "S4-M1207",
    "S4-M1206",
    "S4-M1205",
    "S4-M1204",
    "S4-M1203",
    "S4-M1202",
    "S4-M1201",
    "S4-M1200",
    "S4-M1199",
    "S4-M1198",
    "S4-M1197",
    "zig build validate-local",
    "No proxy signal is accepted as whole-goal completion",
};

const blocker_tokens = [_][]const u8{
    "exact/default-compatible dense SIMD",
    "qemu-aarch64",
    "qemu-aarch64-static",
    "qemu-riscv64",
    "qemu-riscv64-static",
    "qemu-x86_64-static",
    "wine",
    "wasmtime",
    "wasmer",
    "no SIMD non-uniform implementation",
    "surfacecheck local rand",
    "zig build validate-local",
    "zig build rand-bench-test",
    "zig build rand-bench-smoke",
    "zig build rand-bench-smoke-self-test",
    "zig build rand-status",
    "zig build rand-status-json",
    "zig build rand-status-self-test",
    "zig build rand-status-schema-version",
    "compare/results/s4-m1222-static-multivariate-normal.md",
    "compare/results/s4-m1218-post-s4-m1217-validate-local.md",
    "compare/results/s4-m1217-minimum-vectorbench-gate.md",
    "compare/results/s4-m1216-post-s4-m1215-validate-all.md",
    "compare/results/s4-m1216-post-s4-m1215-validate-all.md",
    "compare/results/s4-m1215-post-s4-m1214-validate-local.md",
    "compare/results/s4-m1214-exponential-vectorbench-probe.md",
    "compare/results/s4-m1213-post-s4-m1212-validate-all.md",
    "compare/results/s4-m1212-post-s4-m1211-validate-all.md",
    "compare/results/s4-m1213-post-s4-m1212-validate-all.md",
    "compare/results/s4-m1212-post-s4-m1211-validate-all.md",
    "compare/results/s4-m1213-post-s4-m1212-validate-all.md",
    "compare/results/s4-m1212-post-s4-m1211-validate-all.md",
    "compare/results/s4-m1220-multivariate-normal.md",
    "compare/results/s4-m1218-post-s4-m1217-validate-local.md",
    "compare/results/s4-m1217-minimum-vectorbench-gate.md",
    "compare/results/s4-m1216-post-s4-m1215-validate-all.md",
    "compare/results/s4-m1216-post-s4-m1215-validate-all.md",
    "compare/results/s4-m1215-post-s4-m1214-validate-local.md",
    "compare/results/s4-m1214-exponential-vectorbench-probe.md",
    "compare/results/s4-m1211-post-s4-m1210-validate-local.md",
    "compare/results/s4-m1210-inverse-cdf-tail-probe.md",
    "compare/results/s4-m1209-post-s4-m1208-validate-all.md",
    "compare/results/s4-m1208-post-s4-m1207-validate-local.md",
    "compare/results/s4-m1207-post-s4-m1206-validate-all.md",
    "compare/results/s4-m1206-roadmap-evidence-path-guard.md",
    "compare/results/s4-m1205-post-s4-m1204-validate-local.md",
    "compare/results/s4-m1204-vectorbench-status-drift.md",
    "compare/results/s4-m1203-parameterized-vectorbench-refresh.md",
    "compare/results/s4-m1202-f64x4-vectorbench-refresh.md",
    "compare/results/s4-m1201-f32x8-vectorbench-refresh.md",
    "compare/results/s4-m1200-post-s4-m1199-validate-all.md",
    "compare/results/s4-m1192-rand-status-post-bar-drift.md",
    "compare/results/s4-m1191-rand-status-post-bar-drift.md",
    "compare/results/s4-m1190-post-s4-m1189-validate-all.md",
    "compare/results/s4-m1189-dynamic-tree-typed-total.md",
    "compare/results/s4-m1188-post-s4-m1187-validate-all.md",
    "compare/results/s4-m1187-dynamic-tree-typed-diagnostics.md",
    "compare/results/s4-m1162-beta-dirichlet-tiny-shape.md",
    "compare/results/s4-m1161-dirichlet-subnormal-alpha.md",
    "compare/results/s4-m1160-hypergeometric-large-population.md",
    "compare/results/s4-m1159-nig-alpha-infinity.md",
    "`1`",
    "Alea local rand/rand_distr status (2026-07-18)",
    "\"schema_version\"",
    "\"baseline\"",
    "\"validate_local_passes\"",
    "\"opportunity_runners_available\"",
    "\"current_conclusion\"",
    "\"no_known_unblocked_gap\"",
    "\"s4_m11_blocked\"",
    "\"local_rand_status\"",
    "\"blocker_audit\"",
    "\"latest_validate_local_evidence\"",
    "\"compare/results/s4-m1241-next-u32-only-source-fallback.md\"",
    "\"compare/results/s4-m1240-rng-init-raw-alias-source.md\"",
    "\"compare/results/s4-m1239-fromrng-native-u64-fallback.md\"",
    "\"compare/results/s4-m1238-nextfrom-native-u64-fallback.md\"",
    "\"compare/results/s4-m1237-fillbytes-direct-source-fallback.md\"",
    "\"compare/results/s4-m1236-next-u64-native-fallback.md\"",
    "\"compare/results/s4-m1234-root-string-preallocation.md\"",
    "\"compare/results/s4-m1233-fromrandom-nextu32-byte-shape.md\"",
    "\"compare/results/s4-m1232-owned-byte-allocation-fallback.md\"",
    "\"compare/results/s4-m1231-rng-reader-tryfill-hardening.md\"",
    "\"compare/results/s4-m1230-rng-normal-affine-lane-store.md\"",
    "\"compare/results/s4-m1229-vector-sampler-lane-count-sweep.md\"",
    "\"compare/results/s4-m1228-distribution-transform-lane-store-sweep.md\"",
    "\"compare/results/s4-m1227-distribution-lane-store-refactor.md\"",
    "\"compare/results/s4-m1226-float-fill-lane-store-refactor.md\"",
    "\"compare/results/s4-m1225-f64-uniform-lowbit-vector8.md\"",
    "\"compare/results/s4-m1224-f64-standard-uniform-throughput.md\"",
    "\"compare/results/s4-m1223-f64-standard-uniform-grid.md\"",
    "\"compare/results/s4-m1218-post-s4-m1217-validate-local.md\"",
    "\"compare/results/s4-m1217-minimum-vectorbench-gate.md\"",
    "\"compare/results/s4-m1216-post-s4-m1215-validate-all.md\"",
    "\"compare/results/s4-m1215-post-s4-m1214-validate-local.md\"",
    "\"compare/results/s4-m1214-exponential-vectorbench-probe.md\"",
    "\"compare/results/s4-m1213-post-s4-m1212-validate-all.md\"",
    "\"compare/results/s4-m1212-post-s4-m1211-validate-all.md\"",
    "\"compare/results/s4-m1211-post-s4-m1210-validate-local.md\"",
    "\"compare/results/s4-m1210-inverse-cdf-tail-probe.md\"",
    "\"compare/results/s4-m1209-post-s4-m1208-validate-all.md\"",
    "\"compare/results/s4-m1208-post-s4-m1207-validate-local.md\"",
    "\"compare/results/s4-m1207-post-s4-m1206-validate-all.md\"",
    "\"compare/results/s4-m1206-roadmap-evidence-path-guard.md\"",
    "\"compare/results/s4-m1205-post-s4-m1204-validate-local.md\"",
    "\"compare/results/s4-m1204-vectorbench-status-drift.md\"",
    "\"compare/results/s4-m1203-parameterized-vectorbench-refresh.md\"",
    "\"compare/results/s4-m1202-f64x4-vectorbench-refresh.md\"",
    "\"compare/results/s4-m1201-f32x8-vectorbench-refresh.md\"",
    "\"compare/results/s4-m1200-post-s4-m1199-validate-all.md\"",
    "\"compare/results/s4-m1192-rand-status-post-bar-drift.md\"",
    "\"compare/results/s4-m1191-rand-status-post-bar-drift.md\"",
    "\"compare/results/s4-m1190-post-s4-m1189-validate-all.md\"",
    "\"compare/results/s4-m1189-dynamic-tree-typed-total.md\"",
    "\"compare/results/s4-m1188-post-s4-m1187-validate-all.md\"",
    "\"compare/results/s4-m1187-dynamic-tree-typed-diagnostics.md\"",
    "rand-status self-test ok",
    "rand_distr standard-normal",
    "five passing Rust parser tests",
    "rand_bench_smoke self-test ok",
    "ALEA_RAND_BENCH_MANIFEST",
    "ALEA_RAND_BENCH_EXPECTED_ROW",
    "zig build runtimecheck",
    "wasmtime 31.0.0 (7a9be587f 2025-03-20)",
    "profilelongcheck ok",
    "compare/results/s4-m1123-wasmtime-profilelongcheck.md",
    "No new unblocked public-surface or local comparison-benchmark gap",
    "Do not call `update_goal(status=complete)`",
    "S4-M1212",
    "S4-M1211",
    "S4-M1210",
    "S4-M1209",
    "S4-M1208",
    "S4-M1207",
    "S4-M1206",
    "S4-M1205",
    "S4-M1204",
    "S4-M1203",
    "S4-M1202",
    "S4-M1201",
    "S4-M1200",
    "S4-M1199",
    "S4-M1198",
    "S4-M1197",
};

const active_completion_tokens = [_][]const u8{
    "## Current Completion Audit Refresh",
    "Objective restated as concrete deliverables",
    "Linux comparison, validation, and status evidence must be current",
    "Current evidence is still not sufficient",
    "S4-M420 records the current",
    "S4-M450/S4-M455 record the",
    "S4-M437/S4-M448 record recent",
    "S4-M1123 records direct Wasmtime",
    "S4-M11 is closed for the current bar",
    "exact/default-compatible dense SIMD normal/exponential",
    "S4-M1225",
    "S4-M1224",
    "S4-M1223",
    "S4-M1222",
    "S4-M1221",
    "S4-M1220",
    "S4-M1219",
    "S4-M1218",
    "S4-M1217",
    "S4-M1216",
    "S4-M1215",
    "S4-M1214",
    "S4-M1213",
    "S4-M1212",
    "S4-M1211",
    "S4-M1210",
    "S4-M1209",
    "S4-M1208",
    "S4-M1207",
    "compare/results/s4-m1220-multivariate-normal.md",
    "compare/results/s4-m1218-post-s4-m1217-validate-local.md",
    "compare/results/s4-m1217-minimum-vectorbench-gate.md",
    "compare/results/s4-m1216-post-s4-m1215-validate-all.md",
    "compare/results/s4-m1216-post-s4-m1215-validate-all.md",
    "compare/results/s4-m1215-post-s4-m1214-validate-local.md",
    "compare/results/s4-m1214-exponential-vectorbench-probe.md",
    "compare/results/s4-m1211-post-s4-m1210-validate-local.md",
    "compare/results/s4-m1210-inverse-cdf-tail-probe.md",
    "compare/results/s4-m1209-post-s4-m1208-validate-all.md",
    "compare/results/s4-m1208-post-s4-m1207-validate-local.md",
    "compare/results/s4-m1207-post-s4-m1206-validate-all.md",
    "compare/results/s4-m1206-roadmap-evidence-path-guard.md",
    "S4-M1202",
    "compare/results/s4-m1201-f32x8-vectorbench-refresh.md",
    "compare/results/s4-m1202-f64x4-vectorbench-refresh.md",
    "compare/results/s4-m1203-parameterized-vectorbench-refresh.md",
    "S4-M1219 refreshes validate-all evidence",
    "S4-M1218 refreshes validate-local evidence",
    "S4-M1217 refreshes minimum vectorbench evidence",
    "S4-M1216 refreshes validate-all evidence",
    "S4-M1215 refreshes validate-local evidence",
    "S4-M1214 refreshes exponential vectorbench evidence",
    "S4-M1213 refreshes validate-all evidence",
    "S4-M1212 refreshes validate-all evidence",
    "S4-M1211 refreshes validate-local evidence",
    "S4-M1210 refreshes inverse-CDF tail vectorbench evidence",
    "S4-M1209 refreshes validate-all evidence",
    "S4-M1208 refreshes validate-local evidence",
    "S4-M1207 refreshes validate-all evidence",
    "S4-M1206 adds the roadmap evidence-path guard",
    "S4-M1205 refreshes validate-local evidence",
    "S4-M1204 repairs vectorbench status drift",
    "S4-M1202 refreshes f64x4 vectorbench evidence",
    "S4-M1201 refreshes f32x8 vectorbench evidence",
    "S4-M1200 refreshes validate-all evidence",
    "S4-M1199 expands ziggurat-table surface guards",
    "S4-M1198 refreshes validate-all evidence",
    "S4-M1197 exposes Poisson max-lambda public constants",
    "S4-M1196 refreshes weighted manifest root-alias evidence",
    "S4-M1195 adds root weighted sampler aliases",
    "S4-M1194 adds weighted namespace aliases",
    "S4-M1193 refreshes validate-local evidence",
    "S4-M1192 repairs follow-up rand-status post-bar drift",
    "S4-M1191 repairs rand-status post-bar drift",
    "S4-M1190 refreshes validate-all evidence",
    "S4-M1189 adds dynamic weighted-tree typed total diagnostics",
    "S4-M1188 refreshes validate-all evidence",
    "S4-M1187 adds dynamic weighted-tree typed diagnostics",
    "S4-M1186 refreshes validate-local evidence",
    "S4-M1185 refreshes dense SIMD vectorbench evidence",
    "S4-M1184 refreshes validate-all evidence",
    "S4-M1183 extends typed diagnostics through WeightedChoice",
    "S4-M1182 refreshes weighted public-surface manifests",
    "S4-M1181 refreshes validate-all evidence",
    "Therefore do not call",
    "## Required Next Work Before Completion",
    "a default/exact-compatible dense SIMD normal/exponential candidate beats",
    "scalar lane-fill in the real vector-slice harness",
    "another non-WASI OS/architecture runtime executes",
    "a local `rand` / `rand_distr` audit finds",
    "a later roadmap audit raises/reshapes the bar again",
    "Until then, do not call `update_goal(status=complete)`",
};

const current_rule_tokens = [_][]const u8{
    "## Current Rule",
    "Continue feature-first or performance work on the earliest unblocked stage milestone",
    "When an earlier milestone is locally blocked",
    "keep its blocker evidence current and proceed to the next unblocked milestone",
    "`zig build validate` for broad native validation",
    "`zig build validate-local`",
    "local `rand` / `rand_distr` comparison workflow",
    "public-surface evidence",
    "`zig build statcheck` after changes that affect engines, distributions, ranges",
    "sampling internals",
    "`zig build stream -- ...` to feed raw engine output",
    "Defer pure",
    "micro-optimization until feature, correctness, and validation milestones are in",
    "place",
};

const long_term_track_tokens = [_][]const u8{
    "## Long-Term Product Tracks",
    "Closing a stage means the",
    "current evidence bar was met, not that Alea has finished surpassing Rust",
    "`rand` / `rand_distr` as a product",
    "| Feature breadth |",
    "Core random workflows should be available in one Zig-native library",
    "without forcing users into companion packages",
    "| Statistical confidence |",
    "Engine and distribution evidence should keep getting longer, broader, and easier to reproduce",
    "compare/results/practrand-observation-followup.md",
    "compare/results/reproducibility-matrix.md",
    "| Performance |",
    "Fast paths should be competitive with or faster than local Rust evidence",
    "compare/results/performance-triage.md",
    "| Ergonomics |",
    "APIs should feel natural in Zig",
    "allocation-free and comptime-friendly workflows",
    "| Portability |",
    "Stable-output expectations should be clear across targets",
    "Keep the Linux and wasm32-wasi stable-output suites green",
    "QEMU/Wine/native second-OS runners",
};

const local_rand_manifest_tokens = [_][]const u8{
    "# S4-M288 Local Rust Public Surface Manifest",
    "~/Work/rand/src/lib.rs",
    "rand_core 0.10.1",
    "## Root `rand` Surface",
    "## RNG Namespace Surface",
    "## Distribution Surface",
    "## Sequence Surface",
    "## `rand_core` Surface",
    "`ThreadRng`, `rng()`",
    "`Distribution`, `Iter`, `Map`",
    "`SampleUniform`, `UniformSampler`, `SampleBorrow`, `SampleRange`",
    "`seq::index::{IndexVec",
    "`block::{Generator, BlockRng, reconstruct",
    "No new unblocked local Rust public-surface gap",
    "typed `typedWeight*` / `weightValue*`",
    "S4-M1182",
    "not whole-goal completion evidence",
};

const local_rand_distr_manifest_tokens = [_][]const u8{
    "# S4-M294 Local `rand_distr` Public Surface Manifest",
    "rand_distr-0.6.0/src",
    "## Root Distribution Re-Exports",
    "## `multi` Module",
    "## `weighted` Module",
    "## Utility/Internal Surface",
    "`Normal`, `StandardNormal`, `LogNormal`",
    "`Exp`, `Exp1`",
    "`multi::Dirichlet`",
    "`WeightedAliasIndex`",
    "`WeightedTreeIndex`",
    "`AliasableWeight` trait",
    "typed `weightsValue*` / `typedWeights*`",
    "S4-M1199",
    "S4-M1197",
    "`Poisson::MAX_LAMBDA`",
    "`ZIG_NORM_X`",
    "`ZIG_EXP_F`",
    "`Distribution<T>` trait implementations",
    "No new unblocked local `rand_distr 0.6.0` public-surface gap",
    "not whole-goal completion evidence",
};

const current_rand_status_tokens = [_][]const u8{
    "# S4-M420 Current Local Rand Comparison Status",
    "~/Work/rand",
    "cached `rand_distr 0.6.0`",
    "`zig build validate-local` currently passes",
    "no new unblocked local Rust public-surface or comparison-benchmark gap is known",
    "rand_distr standard-normal",
    "\"schema_version\": 1",
    "\"validate_local_passes\": true",
    "\"opportunity_runners_available\": false",
    "\"no_known_unblocked_gap\": true",
    "\"s4_m11_blocked\": false",
    "\"local_rand_status\": \"compare/results/s4-m420-current-rand-status.md\"",
    "\"blocker_audit\": \"compare/results/s4-m11-blocker-audit.md\"",
    "\"latest_validate_local_evidence\": \"compare/results/s4-m1266-dynamic-wishart-inverse-wishart.md\"",
    "surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137",
    "surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30",
    "surfacecheck local rand_distr: files=34 expected-tokens=72 source-tokens=185",
    "rand_bench_smoke self-test ok",
    "wasmtime 31.0.0 (7a9be587f 2025-03-20)",
    "profilelongcheck ok",
    "compare/results/s4-m1123-wasmtime-profilelongcheck.md",
    "S4-M11 is closed for the current bar",
    "no known unblocked core RNG gap versus locally available `rand` / `rand_distr`",
};

const rand_status_matrix_tokens = [_][]const u8{
    "# S4-M450 `rand-status` Command Matrix Refresh",
    "$ zig build rand-status",
    "Alea local rand/rand_distr status (2026-07-18)",
    "$ zig build rand-status-json",
    "\"schema_version\": 1",
    "\"validate_local_passes\": true",
    "\"opportunity_runners_available\": false",
    "\"no_known_unblocked_gap\": true",
    "\"s4_m11_blocked\": false",
    "$ zig build rand-status-schema-version",
    "$ zig build rand-status-self-test",
    "rand-status self-test ok",
    "$ zig build rand-status -- --help",
    "--schema-version prints the stable JSON schema version",
    "--self-test validates text, JSON, help, and bad-argument paths without Rust tools",
    "S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1241 follow-ups closed for current bar",
};

const rand_status_direct_matrix_tokens = [_][]const u8{
    "# S4-M455 Direct `rand-status` Command Matrix",
    "$ zig build rand-status -- --json",
    "\"schema_version\": 1",
    "\"validate_local_passes\": true",
    "\"opportunity_runners_available\": false",
    "\"no_known_unblocked_gap\": true",
    "\"s4_m11_blocked\": false",
    "$ zig build rand-status -- --schema-version",
    "$ zig build rand-status -- --self-test",
    "rand-status self-test ok",
    "S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1241 follow-ups closed for current bar",
};

pub fn main(init: std.process.Init) !void {
    @setEvalBranchQuota(10_000);
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var stderr_buffer: [2048]u8 = undefined;
    var stderr_file = std.Io.File.stderr().writer(io, &stderr_buffer);
    const stderr = &stderr_file.interface;

    const allocator = std.heap.smp_allocator;
    var evidence_arena = std.heap.ArenaAllocator.init(allocator);
    defer evidence_arena.deinit();
    const roadmap = try readFile(io, allocator, "compare/results/core-rand-coverage.md");
    defer allocator.free(roadmap);
    const evidence = try parseRoadmapEvidence(evidence_arena.allocator(), roadmap);
    const audit = try readFile(io, allocator, "compare/results/active-goal-completion-audit.md");
    defer allocator.free(audit);
    const linux_audit = try readFile(io, allocator, "compare/results/linux-no-known-gaps-audit.md");
    defer allocator.free(linux_audit);
    const tooling = try readFile(io, allocator, "docs/tooling.md");
    defer allocator.free(tooling);
    const readme = try readFile(io, allocator, "README.md");
    defer allocator.free(readme);
    const build = try readFile(io, allocator, "build.zig");
    defer allocator.free(build);
    const blocker = try readFile(io, allocator, "compare/results/s4-m11-blocker-audit.md");
    defer allocator.free(blocker);
    const local_rand_manifest = try readFile(io, allocator, "compare/results/s4-m288-local-rand-public-surface-manifest.md");
    defer allocator.free(local_rand_manifest);
    const local_rand_distr_manifest = try readFile(io, allocator, "compare/results/s4-m294-rand-distr-public-surface-manifest.md");
    defer allocator.free(local_rand_distr_manifest);
    const current_rand_status = try readFile(io, allocator, "compare/results/s4-m420-current-rand-status.md");
    defer allocator.free(current_rand_status);
    const rand_status_matrix = try readFile(io, allocator, "compare/results/s4-m450-rand-status-command-matrix.md");
    defer allocator.free(rand_status_matrix);
    const rand_status_direct_matrix = try readFile(io, allocator, "compare/results/s4-m455-rand-status-direct-matrix.md");
    defer allocator.free(rand_status_direct_matrix);

    var missing: usize = 0;

    for (evidence) |item| {
        std.Io.Dir.cwd().access(io, item.path, .{}) catch |err| {
            try stderr.print("roadmapcheck: missing evidence file {s}: {s}\n", .{ item.path, @errorName(err) });
            missing += 1;
        };
        try checkEvidencePathMilestone(stderr, item.milestone, item.path, &missing);
        if (std.mem.indexOf(u8, roadmap, item.milestone) == null or
            std.mem.indexOf(u8, roadmap, item.path) == null)
        {
            try stderr.print("roadmapcheck: core-rand-coverage.md missing `{s}` / `{s}`\n", .{ item.milestone, item.path });
            missing += 1;
        }
        if (std.mem.indexOf(u8, audit, item.milestone) == null) {
            try stderr.print("roadmapcheck: active-goal-completion-audit.md missing `{s}`\n", .{item.milestone});
            missing += 1;
        }
        if (!std.mem.eql(u8, item.milestone, "S4-M11") and
            std.mem.indexOf(u8, linux_audit, item.path) == null)
        {
            try stderr.print("roadmapcheck: linux-no-known-gaps-audit.md missing `{s}`\n", .{item.path});
            missing += 1;
        }
    }

    inline for (required_tokens) |token| {
        if (std.mem.indexOf(u8, audit, token) == null and std.mem.indexOf(u8, roadmap, token) == null) {
            try stderr.print("roadmapcheck: roadmap/audit missing required token `{s}`\n", .{token});
            missing += 1;
        }
    }

    inline for (blocker_tokens) |token| {
        if (std.mem.indexOf(u8, blocker, token) == null) {
            try stderr.print("roadmapcheck: s4-m11-blocker-audit.md missing blocker token `{s}`\n", .{token});
            missing += 1;
        }
    }

    inline for (active_completion_tokens) |token| {
        if (std.mem.indexOf(u8, audit, token) == null) {
            try stderr.print("roadmapcheck: active audit missing completion-criteria token `{s}`\n", .{token});
            missing += 1;
        }
    }

    inline for (current_rule_tokens) |token| {
        if (std.mem.indexOf(u8, roadmap, token) == null) {
            try stderr.print("roadmapcheck: core-rand-coverage.md missing current-rule token `{s}`\n", .{token});
            missing += 1;
        }
    }

    inline for (long_term_track_tokens) |token| {
        if (std.mem.indexOf(u8, roadmap, token) == null) {
            try stderr.print("roadmapcheck: core-rand-coverage.md missing long-term-track token `{s}`\n", .{token});
            missing += 1;
        }
    }

    try checkManifestTokens(stderr, "local Rust public-surface manifest", local_rand_manifest, local_rand_manifest_tokens[0..], &missing);
    try checkManifestTokens(stderr, "local rand_distr public-surface manifest", local_rand_distr_manifest, local_rand_distr_manifest_tokens[0..], &missing);
    try checkManifestTokens(stderr, "current local rand status", current_rand_status, current_rand_status_tokens[0..], &missing);
    try checkManifestTokens(stderr, "rand-status command matrix", rand_status_matrix, rand_status_matrix_tokens[0..], &missing);
    try checkManifestTokens(stderr, "direct rand-status command matrix", rand_status_direct_matrix, rand_status_direct_matrix_tokens[0..], &missing);

    if (std.mem.indexOf(u8, roadmap, "| S4-M1164 | WeightedTree zero-total sampling errors") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1164 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1165 | WeightedIntTree integer overflow diagnostics") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1165 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1166 | Post-S4-M1165 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1166 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1167 | Weighted sampler clone/equality helpers") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1167 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1168 | Weighted sampler format helpers") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1168 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1169 | Weighted tree default constructors") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1169 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1170 | Weighted tree trySample aliases") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1170 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1171 | Post-S4-M1170 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1171 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1172 | Weighted iterator clone/format helpers") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1172 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1173 | Post-S4-M1172 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1173 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1174 | Weighted error message helpers") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1174 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1175 | Post-S4-M1174 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1175 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1176 | Root weighted error aliases") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1176 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1177 | Post-S4-M1176 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1177 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1178 | Weighted manifest refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1178 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1179 | Post-S4-M1178 validate-local refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1179 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1180 | Typed static weighted diagnostics") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1180 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1181 | Post-S4-M1180 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1181 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1182 | Weighted manifest typed-diagnostics refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1182 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1183 | WeightedChoice typed diagnostics") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1183 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1184 | Post-S4-M1183 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1184 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1185 | Dense SIMD probe refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1185 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1186 | Post-S4-M1185 validate-local refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1186 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1187 | Dynamic weighted-tree typed diagnostics") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1187 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1188 | Post-S4-M1187 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1188 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1189 | Dynamic weighted-tree typed totals") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1189 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1190 | Post-S4-M1189 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1190 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1191 | Rand-status post-bar drift repair") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1191 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1192 | Rand-status post-bar drift repair follow-up") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1192 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1193 | Post-S4-M1192 validate-local refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1193 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1194 | Weighted namespace alias refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1194 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1195 | Root weighted sampler aliases") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1195 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1196 | Weighted manifest root-alias refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1196 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1197 | Poisson max-lambda public constants") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1197 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1198 | Post-S4-M1197 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1198 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1199 | Ziggurat table surface guard") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1199 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1200 | Post-S4-M1199 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1200 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1201 | f32x8 vectorbench refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1201 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1202 | f64x4 vectorbench refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1202 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1203 | Parameterized vectorbench refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1203 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1204 | Vectorbench status drift repair") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1204 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1205 | Post-S4-M1204 validate-local refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1205 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1206 | Roadmap evidence path guard") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1206 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1207 | Post-S4-M1206 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1207 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1208 | Post-S4-M1207 validate-local refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1208 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1209 | Post-S4-M1208 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1209 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1210 | Inverse-CDF tail probe") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1210 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1211 | Post-S4-M1210 validate-local refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1211 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1212 | Post-S4-M1211 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1212 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1213 | Post-S4-M1212 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1213 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1214 | Exponential vectorbench probe") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1214 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1215 | Post-S4-M1214 validate-local refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1215 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1216 | Post-S4-M1215 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1216 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1217 | Minimum vectorbench gate refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1217 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1218 | Post-S4-M1217 validate-local refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1218 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1219 | Post-S4-M1218 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1219 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1220 | Full-covariance multivariate normal") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1220 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1221 | Multivariate-normal small-dimension throughput") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1221 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1222 | Static allocation-free multivariate normal") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1222 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1223 | f64 StandardUniform 53-bit grid consistency") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1223 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1224 | f64 StandardUniform throughput recovery") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1224 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1225 | f64 uniform low-bit/vector8 recovery") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1225 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1226 | Float fill lane-store refactor") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1226 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1227 | Distribution lane-store refactor") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1227 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1228 | Distribution transform lane-store sweep") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1228 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1229 | Vector sampler lane-count sweep") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1229 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1230 | Rng normal affine lane-store refactor") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1230 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1231 | Rng fallible byte-fill and reader refill hardening") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1231 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1232 | Rng owned byte allocation fallback hardening") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1232 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1233 | `std.Random` adapter nextU32 byte-shape hardening") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1233 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1234 | Root string preallocation hardening") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1234 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1235 | TryNextU32 direct-source native fallback") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1235 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1236 | NextU64 direct-source native fallback") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1236 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1237 | FillBytes direct-source fallback") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1237 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1238 | Generic nextFrom native-u64 fallback") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1238 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1239 | FromRng native-u64 fallback") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1239 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1240 | Rng.init raw-alias source fallback") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1240 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1241 | NextU32-only source fallback") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1241 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1242 | Next post-S4-M1241 product bar") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1242 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1243 | Stable iterator choice semantics") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1243 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1244 | Polymorphic standard normal/exponential unit samplers") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1244 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1245 | Rust API parity, N-dimensional unit sphere/ball, StandardCauchy/Logistic") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1245 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1246 | Von Mises circular/directional distribution") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1246 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1247 | Wrapped Cauchy circular distribution") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1247 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1248 | Dense true-SIMD f64x4 ziggurat for normal/exponential") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1248 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1249 | Extend true SIMD ziggurat to f32x8 native precision profiles") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1249 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1250 | Truncated Normal distribution") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1250 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1251 | Von Mises-Fisher spherical directional distribution") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1251 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1252 | Watson axial spherical directional distribution") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1252 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1253 | Rice (Rician) fading distribution") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1253 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1254 | Nakagami-m fading distribution") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1254 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1255 | Inverse Gamma distribution") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1255 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1256 | Exponentially Modified Gaussian") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1256 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1257 | Generalized Pareto") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1257 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1258 | Scaled Inverse Chi-Squared") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1258 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1259 | Hoyt (Nakagami-q)") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1259 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1260 | Noncentral Chi-Squared") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1260 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1261 | Noncentral t") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1261 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1262 | Noncentral F") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1262 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, roadmap, "| S4-M1263 | Noncentral Chi") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M1263 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1164 weighted-tree zero-total compatibility") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1164 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1165 weighted-int-tree overflow compatibility") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1165 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1166 post-S4-M1165 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1166 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1167 weighted-sampler clone/equality helpers") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1167 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1168 weighted-sampler format helpers") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1168 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1169 weighted-tree default constructors") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1169 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1170 weighted-tree trySample aliases") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1170 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1171 post-S4-M1170 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1171 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1172 weighted-iterator clone/format helpers") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1172 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1173 post-S4-M1172 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1173 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1174 weighted-error message helpers") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1174 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1175 post-S4-M1174 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1175 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1176 root weighted-error aliases") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1176 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1177 post-S4-M1176 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1177 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1178 weighted-manifest refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1178 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1179 post-S4-M1178 validate-local refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1179 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1180 typed static weighted diagnostics") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1180 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1181 post-S4-M1180 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1181 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1182 weighted-manifest typed-diagnostics refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1182 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1183 weighted-choice typed diagnostics") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1183 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1184 post-S4-M1183 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1184 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1185 dense SIMD probe refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1185 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1186 post-S4-M1185 validate-local refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1186 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1187 dynamic weighted-tree typed diagnostics") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1187 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1188 post-S4-M1187 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1188 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1189 dynamic weighted-tree typed totals") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1189 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1190 post-S4-M1189 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1190 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1191 rand-status post-bar drift repair") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1191 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1192 rand-status post-bar drift repair follow-up") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1192 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1193 post-S4-M1192 validate-local refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1193 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1194 weighted namespace alias refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1194 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1195 root weighted sampler aliases") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1195 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1196 weighted manifest root-alias refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1196 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1197 Poisson max-lambda public constants") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1197 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1198 post-S4-M1197 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1198 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1199 ziggurat table surface guard") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1199 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1200 post-S4-M1199 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1200 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1201 f32x8 vectorbench refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1201 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1202 f64x4 vectorbench refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1202 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1203 parameterized vectorbench refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1203 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1204 vectorbench status drift repair") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1204 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1205 post-S4-M1204 validate-local refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1205 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1206 roadmap evidence path guard") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1206 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1207 post-S4-M1206 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1207 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1208 post-S4-M1207 validate-local refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1208 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1209 post-S4-M1208 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1209 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1210 inverse-CDF tail probe") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1210 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1211 post-S4-M1210 validate-local refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1211 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1212 post-S4-M1211 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1212 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1213 post-S4-M1212 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1213 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1214 exponential vectorbench probe") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1214 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1215 post-S4-M1214 validate-local refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1215 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1216 post-S4-M1215 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1216 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1217 minimum vectorbench gate refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1217 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1218 post-S4-M1217 validate-local refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1218 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1219 post-S4-M1218 validate-all refresh") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1219 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1220 full-covariance multivariate normal") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1220 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1221 multivariate-normal small-dimension throughput") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1221 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1222 static allocation-free multivariate normal") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1222 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1223 f64 StandardUniform 53-bit grid consistency") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1223 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1224 f64 StandardUniform throughput recovery") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1224 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1225 f64 uniform low-bit/vector8 recovery") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1225 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1226 float fill lane-store refactor") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1226 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1227 distribution lane-store refactor") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1227 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1228 distribution transform lane-store sweep") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1228 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1229 vector sampler lane-count sweep") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1229 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1230 rng normal affine lane-store refactor") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1230 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1231 rng reader try-fill/refill hardening") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1231 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1232 owned byte allocation fallback hardening") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1232 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1233 std.Random adapter nextU32 byte-shape hardening") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1233 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1234 root string preallocation hardening") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1234 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1235 tryNextU32 direct-source native fallback") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1235 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1236 nextU64 direct-source native fallback") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1236 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1237 fillBytes direct-source fallback") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1237 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1238 generic nextFrom native-u64 fallback") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1238 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1239 fromRng native-u64 fallback") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1239 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1240 Rng.init raw-alias source fallback") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1240 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M1241 nextU32-only source fallback") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1241 closure row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "S4-M1242 is closed after") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1242 closure\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "S4-M1243 is closed after fixing") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1243 closure\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "S4-M1244 is closed after converting") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1244 closure\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "S4-M1245 is closed after adding") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1245 closure\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "S4-M1246 is closed after adding") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1246 closure\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "S4-M1247 adds Wrapped Cauchy") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1247 closure\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "S4-M1248 lands true mask-rejection SIMD") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1248 closure\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "S4-M1249 extends true mask-rejection SIMD") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1249 closure\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "S4-M1250 adds a Truncated Normal distribution") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1250 closure\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "S4-M1251 adds a Von Mises-Fisher") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1251 closure\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "S4-M1252 adds a Watson axial") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1252 closure\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "S4-M1253 adds a Rice") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1253 closure\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "S4-M1254 adds a Nakagami-m") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1254 closure\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "S4-M1255 adds an Inverse Gamma") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1255 closure\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "S4-M1256 adds an Exponentially Modified Gaussian") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1256 closure\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "S4-M1257 adds a Generalized Pareto") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1257 closure\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "S4-M1258 adds a Scaled Inverse Chi-Squared") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1258 closure\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "S4-M1259 adds a Hoyt (Nakagami-q)") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1259 closure\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "S4-M1260 adds a Noncentral Chi-Squared") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1260 closure\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "S4-M1261 adds a Noncentral t") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1261 closure\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "S4-M1262 adds a Noncentral F") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1262 closure\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "S4-M1263 adds a Noncentral Chi") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M1263 closure\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "S4-M11 is closed for the current bar") == null) {
        try stderr.print("roadmapcheck: active audit must keep S4-M11 current-bar closure statement\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, build, "doccheck_step.dependOn(roadmapcheck_step)") == null) {
        try stderr.print("roadmapcheck: doccheck must depend on roadmapcheck\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, tooling, "zig build roadmapcheck") == null or
        std.mem.indexOf(u8, readme, "zig build roadmapcheck") == null)
    {
        try stderr.print("roadmapcheck: README.md and docs/tooling.md must mention `zig build roadmapcheck`\n", .{});
        missing += 1;
    }

    if (missing != 0) {
        try stderr.flush();
        return error.RoadmapAuditIncomplete;
    }

    try stdout.print("roadmapcheck ok\n", .{});
    try stdout.flush();
}

fn checkEvidencePathMilestone(
    stderr: *std.Io.Writer,
    milestone: []const u8,
    path: []const u8,
    missing: *usize,
) !void {
    var lower_buf: [64]u8 = undefined;
    if (milestone.len > lower_buf.len) {
        try stderr.print("roadmapcheck: milestone token too long `{s}\n", .{milestone});
        missing.* += 1;
        return;
    }
    const lowered = lower_buf[0..milestone.len];
    for (milestone, 0..) |byte, index| {
        lowered[index] = std.ascii.toLower(byte);
    }
    if (std.mem.indexOf(u8, path, lowered) == null) {
        try stderr.print("roadmapcheck: evidence path `{s}` does not contain milestone `{s}\n", .{ path, lowered });
        missing.* += 1;
    }
}

fn readFile(io: std.Io, allocator: std.mem.Allocator, path: []const u8) ![]u8 {
    return std.Io.Dir.cwd().readFileAlloc(io, path, allocator, .limited(8 * 1024 * 1024));
}

fn checkManifestTokens(
    stderr: *std.Io.Writer,
    label: []const u8,
    contents: []const u8,
    tokens: []const []const u8,
    missing: *usize,
) !void {
    for (tokens) |token| {
        if (std.mem.indexOf(u8, contents, token) == null) {
            try stderr.print("roadmapcheck: {s} missing manifest token `{s}`\n", .{ label, token });
            missing.* += 1;
        }
    }
}

test "evidence path guard requires lowercase milestone token" {
    var out_buf: [256]u8 = undefined;
    var stderr = std.Io.Writer.fixed(&out_buf);
    var missing: usize = 0;

    try checkEvidencePathMilestone(&stderr, "S4-M1206", "compare/results/s4-m1206-example.md", &missing);
    try std.testing.expectEqual(@as(usize, 0), missing);

    try checkEvidencePathMilestone(&stderr, "S4-M1206", "compare/results/s4-m1207-wrong.md", &missing);
    try std.testing.expectEqual(@as(usize, 1), missing);
    try std.testing.expect(std.mem.indexOf(u8, std.Io.Writer.buffered(&stderr), "s4-m1206") != null);
}

test "manifest token checker counts missing tokens" {
    var out_buf: [256]u8 = undefined;
    var stderr = std.Io.Writer.fixed(&out_buf);
    var missing: usize = 0;

    try checkManifestTokens(
        &stderr,
        "sample manifest",
        "alpha beta",
        &.{ "alpha", "gamma" },
        &missing,
    );

    try std.testing.expectEqual(@as(usize, 1), missing);
    try std.testing.expect(std.mem.indexOf(u8, std.Io.Writer.buffered(&stderr), "gamma") != null);
}

test "manifest token checker accepts all present tokens" {
    var out_buf: [128]u8 = undefined;
    var stderr = std.Io.Writer.fixed(&out_buf);
    var missing: usize = 0;

    try checkManifestTokens(
        &stderr,
        "sample manifest",
        "alpha beta gamma",
        &.{ "alpha", "gamma" },
        &missing,
    );

    try std.testing.expectEqual(@as(usize, 0), missing);
    try std.testing.expectEqual(@as(usize, 0), std.Io.Writer.buffered(&stderr).len);
}
