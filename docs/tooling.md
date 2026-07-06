# Alea Tooling Catalog

This catalog lists project-defined `zig build` steps and checked-in tooling.
Run `zig build -l` for Zig's built-in `install` / `uninstall` steps and the
current generated list. `zig build toolingcheck` keeps this catalog synchronized
with `build.zig` and the checked-in `tools/` directory.

## Validation Gates

| Step | Purpose |
| --- | --- |
| `zig build test` | Run unit tests plus the full `doccheck` aggregate (API, examples, tooling, README, and roadmap checks). |
| `zig build apicheck` | Run apicheck helper tests, then verify public symbols are covered by `docs/api-reference.md`. |
| `zig build examplecheck` | Run examplecheck helper tests, then verify `docs/examples.md` covers every checked-in runnable example/focused `run-*` step, every cataloged example remains wired into aggregate `zig build examples`, and key examples still contain expected adoption-output tokens. |
| `zig build toolingcheck` | Run toolingcheck helper tests, then verify this tooling catalog covers every project-defined build step/checked-in tool file, executable bits on checked-in shell tools, WASI runner and PractRand wrapper file inputs, that doccheck, validate, validate-all, and wasi-report keep their aggregate dependencies, and that apicheck/examplecheck/readmecheck/statcheck/bench/bench-libc/vectorbench/stream/repro/distcheck/distcheck-libc/profilecheck/profilecheck-tail/profilecheck-stress/profilecheck-long/surfacecheck/runtimecheck/roadmapcheck/toolingcheck run helper tests before their executable checks. |
| `zig build readmecheck` | Run readmecheck helper tests, then verify README discovery links, quick-start API tokens, and core validation commands stay visible. |
| `zig build roadmapcheck` | Run roadmapcheck helper tests, then verify roadmap, active-audit milestone evidence, public-surface manifests, and concrete S4-M11 blocker tokens stay synchronized. |
| `zig build surfacecheck` | Run surfacecheck helper tests, compare the local Rust `rand` / resolved `rand_core` / cached `rand_distr` public surface against the checked-in manifests, guard against unlisted public source files, and print file/token coverage summaries; defaults are resolved relative to `$HOME`, and `ALEA_RAND_ROOT`, `ALEA_RAND_CORE_ROOT`, and `ALEA_RAND_DISTR_ROOT` override local paths. |
| `zig build runtimecheck` | Run runtimecheck helper tests, then check S4-M11 runtime-runner availability: required local tools (`node`, `cargo`, `rustc`) must exist, while extra runners such as QEMU/Wine/wasmtime/wasmer cause the check to fail so blocker evidence can be refreshed. |
| `zig build doccheck` | Run API, examples, tooling, README, and roadmap documentation checks together. |
| `zig build statcheck` | Run statcheck helper tests, then extended statistical smoke checks. |
| `zig build distcheck` | Run distcheck helper tests, then parameter-grid distribution checks. |
| `zig build distcheck-libc` | Run libc-linked distcheck helper tests, then distribution checks for platform-backed opt-ins. |
| `zig build profilecheck` | Run profilecheck helper tests, then accepted vector profile distribution checks. |
| `zig build profilecheck-tail` | Run profiletailcheck helper tests, then accepted vector profile tail checks. |
| `zig build profilecheck-stress` | Run profilestresscheck helper tests, then accepted vector profile multi-seed stress checks. |
| `zig build profilecheck-long` | Run profilelongcheck helper tests, then accepted vector profile long stress checks. |
| `zig build crosscheck` | Compile unit tests for secondary targets without executing them: `wasm32-wasi`, `aarch64-linux`, `riscv64-linux`, `x86_64-windows`, `x86_64-macos`, and `aarch64-macos`. |
| `zig build test-wasi` | Run wasm32-wasi unit tests through Node's WASI runtime. |
| `zig build wasi-dry-run` | Print Node WASI runner argv without executing wasm. |
| `zig build wasi-self-test` | Run Node WASI runner self-tests for dry-run output, help output, and missing-argument usage without reading or executing wasm. |
| `zig build wasi-report` | Run the chained wasm32-wasi repro/statcheck/distcheck/profile checks through Node's WASI runtime. |
| `zig build validate` | Run native unit, example, catalog, API, statistical, distribution, libc, accepted-profile, and no-external PractRand-wrapper self-test checks. |
| `zig build validate-local` | Run native validation plus the Rust comparison benchmark helper tests, a tiny Rust comparison smoke run, smoke-wrapper self-tests, local Rust `rand` / `rand_core` / `rand_distr` public-surface drift checker, and runtime-runner availability checker. |
| `zig build rand-status` | Run rand-status helper tests, then print the current local `rand` / `rand_distr` comparison status summary and status-file path. |
| `zig build validate-all` | Run native validation plus cross-target compile checks, WASI unit execution, WASI dry/self tests, and the chained WASI report. |

`zig build doccheck` depends on the full `zig build apicheck` step including its
helper tests, the full `zig build examplecheck` step including its helper tests, the full `zig build toolingcheck` step
including its helper tests,
the full `zig build readmecheck` step including its helper tests, and the full
`zig build roadmapcheck` step including
its helper tests. `zig build
validate` depends on `zig build examples`, `zig build doccheck`, the full
`zig build statcheck` step including its helper tests, `zig build distcheck`, `zig build distcheck-libc`, `zig build
profilecheck`, and `zig build practrand-self-test`. `zig build validate-local` adds `zig build rand-bench-test`, `zig build rand-bench-smoke`,
`zig build rand-bench-smoke-self-test`, `zig build surfacecheck`, and
`zig build runtimecheck` to native validation for
this Linux-first local comparison environment; see
`compare/results/s4-m420-current-rand-status.md` for the current local `rand` /
`rand_distr` comparison status. `zig build validate-all` adds `zig build crosscheck`,
`zig build test-wasi`, `zig build wasi-dry-run`, `zig build
wasi-self-test`, and `zig build wasi-report`.

`zig build runtimecheck` treats `node`, `cargo`, and `rustc` as required local
tools. It treats `qemu-aarch64`, `qemu-aarch64-static`, `qemu-riscv64`,
`qemu-riscv64-static`, `qemu-x86_64`, `qemu-x86_64-static`, `wine`, `wine64`,
`wasmtime`, and `wasmer` as S4-M11 opportunity runners: if any of those appear,
refresh the blocker audit and run the newly available validation path instead of
continuing to treat that branch as blocked.

## Runnable Examples

See `docs/examples.md` for adoption guidance and API coverage. The focused
example steps are:

| Step | Source |
| --- | --- |
| `zig build run-basic` | `examples/basic.zig` |
| `zig build run-reproducible-streams` | `examples/reproducible_streams.zig` |
| `zig build run-range-sampling` | `examples/range_sampling.zig` |
| `zig build run-discrete-distributions` | `examples/discrete_distributions.zig` |
| `zig build run-continuous-distributions` | `examples/continuous_distributions.zig` |
| `zig build run-advanced-continuous-distributions` | `examples/advanced_continuous_distributions.zig` |
| `zig build run-rank-distributions` | `examples/rank_distributions.zig` |
| `zig build run-distribution-diagnostics` | `examples/distribution_diagnostics.zig` |
| `zig build run-vector-profiles` | `examples/vector_profiles.zig` |
| `zig build run-native-f32-profiles` | `examples/native_f32_profiles.zig` |
| `zig build run-lognormal-profiles` | `examples/lognormal_profiles.zig` |
| `zig build run-weighted-sampling` | `examples/weighted_sampling.zig` |
| `zig build run-sequence-sampling` | `examples/sequence_sampling.zig` |
| `zig build run-caller-owned-sampling` | `examples/caller_owned_sampling.zig` |
| `zig build run-multivariate-sampling` | `examples/multivariate_sampling.zig` |
| `zig build run-string-generation` | `examples/string_generation.zig` |
| `zig build run-unit-geometry` | `examples/unit_geometry.zig` |
| `zig build examples` | Run all examples above. |

## WASI Runtime Steps

These steps execute wasm32-wasi tools through Node when Node's WASI runtime is
available. Use `node tools/run_wasi_test.js --dry-run <test.wasm> [args...]` to
verify WASI runner arguments without reading or executing a wasm file, or
`node tools/run_wasi_test.js --self-test` / `zig build wasi-self-test` to test
the dry-run and missing-argument paths without wasm:

| Step | Tool |
| --- | --- |
| `zig build wasi-repro` | `tools/repro.zig` |
| `zig build wasi-statcheck` | `tools/statcheck.zig` |
| `zig build wasi-distcheck` | `tools/distcheck.zig` |
| `zig build wasi-profilecheck` | `tools/profilecheck.zig` |
| `zig build wasi-profiletailcheck` | `tools/profiletailcheck.zig` |
| `zig build wasi-profilestresscheck` | `tools/profilestresscheck.zig` |
| `zig build wasi-profilelongcheck` | `tools/profilelongcheck.zig` |

## Benchmarks And Performance Probes

Use `-Doptimize=ReleaseFast` and usually `-Dcpu=native` for throughput evidence.
The plain step names below are what the catalog checker tracks.

| Step | Purpose |
| --- | --- |
| `zig build bench` | Run bench helper tests, then the main Alea throughput benchmark; accepts either `[bytes] [filter]` or filter-only arguments. |
| `zig build bench-libc` | Run libc-linked bench helper tests, then the throughput benchmark for platform-backed opt-ins; accepts either `[bytes] [filter]` or filter-only arguments. |
| `zig build vectorbench` | Run vectorbench helper tests, then vector/SIMD microbenchmarks; accepts either `[lanes] [filter]` or filter-only arguments. |
| `zig build rand-bench-test` | Run Rust comparison benchmark helper tests with `cargo test --manifest-path compare/rand_bench/Cargo.toml`, including the `[bytes] [filter]` / filter-only parser used by the local `rand` throughput harness. |
| `zig build rand-bench-smoke` | Run a tiny filtered Rust comparison benchmark smoke test via `tools/rand_bench_smoke.sh 1024 standard-normal`, checking that the filtered `rand_distr standard-normal` rows appear and unrelated byte-throughput rows stay filtered out. |
| `zig build rand-bench-smoke-dry-run` | Print the Rust comparison smoke cargo command via `tools/rand_bench_smoke.sh --dry-run 1024 standard-normal` without running cargo. |
| `zig build rand-bench-smoke-self-test` | Run no-cargo self-tests for the Rust comparison smoke wrapper dry-run argument parsing and invalid filter-only diagnostics. |
| `zig build ziggurat-stats` | Report ziggurat branch frequencies. |
| `zig build ziggurat-probe` | Run ziggurat expression-shape microbenchmarks. |
| `zig build cauchy-probe` | Run Cauchy expression-shape microbenchmarks. |
| `zig build open-closed-probe` | Run OpenClosed01 f64 bulk conversion microbenchmarks. |
| `zig build log-normal-probe` | Run LogNormal bulk expression-shape microbenchmarks. |
| `zig build nig-probe` | Run NormalInverseGaussian bulk expression-shape microbenchmarks. |
| `zig build inverse-gaussian-probe` | Run InverseGaussian bulk expression-shape microbenchmarks. |
| `zig build poisson-probe` | Run Poisson lambda=20 profile microbenchmarks. |
| `zig build skew-normal-probe` | Run SkewNormal bulk expression-shape microbenchmarks. |
| `zig build triangular-probe` | Run Triangular bulk expression-shape microbenchmarks. |
| `zig build rayleigh-probe` | Run Rayleigh bulk expression-shape microbenchmarks. |
| `zig build logistic-probe` | Run Logistic bulk expression-shape microbenchmarks. |
| `zig build laplace-probe` | Run Laplace bulk expression-shape microbenchmarks. |
| `zig build log-logistic-probe` | Run LogLogistic bulk expression-shape microbenchmarks. |
| `zig build power-function-probe` | Run PowerFunction bulk expression-shape microbenchmarks. |
| `zig build kumaraswamy-probe` | Run Kumaraswamy bulk expression-shape microbenchmarks. |
| `zig build gumbel-probe` | Run Gumbel bulk expression-shape microbenchmarks. |
| `zig build frechet-probe` | Run Frechet bulk expression-shape microbenchmarks. |
| `zig build pert-probe` | Run PERT special-case microbenchmarks. |
| `zig build arcsine-probe` | Run Arcsine bulk expression-shape microbenchmarks. |
| `zig build maxwell-probe` | Run Maxwell bulk expression-shape microbenchmarks. |
| `zig build chi-probe` | Run Chi bulk expression-shape microbenchmarks. |
| `zig build erlang-probe` | Run Erlang bulk expression-shape microbenchmarks. |
| `zig build pareto-probe` | Run Pareto bulk expression-shape microbenchmarks. |
| `zig build weibull-probe` | Run Weibull bulk expression-shape microbenchmarks. |
| `zig build half-normal-probe` | Run HalfNormal bulk expression-shape microbenchmarks. |
| `zig build unit-geometry-probe` | Run unit geometry bulk expression-shape microbenchmarks. |
| `zig build weighted-tree-probe` | Run WeightedTree expression-shape microbenchmarks. |
| `zig build standard-fill-probe` | Run standard distribution fill microbenchmarks. |
| `zig build exponential-rate-probe` | Run exponential rate bulk microbenchmarks. |
| `zig build normal-affine-probe` | Run normal affine bulk microbenchmarks. |
| `zig build gamma-shape-probe` | Run gamma shape-specialization microbenchmarks. |
| `zig build student-t-probe` | Run StudentT special-case microbenchmarks. |
| `zig build fisher-f-probe` | Run Fisher-F special-case microbenchmarks. |
| `zig build beta-special-probe` | Run Beta special-case microbenchmarks. |
| `zig build hypergeo-h2pe-probe` | Run isolated Hypergeometric H2PE experiments. |

## External Statistical And Snapshot Tools

| Step | Purpose |
| --- | --- |
| `zig build stream` | Run stream helper tests, then write raw RNG bytes to stdout for external statistical tools, for example `zig build stream -- --engine fast --bytes 1048576`. |
| `zig build practrand-dry-run` | Print the default PractRand stream pipeline without requiring `RNG_test`. |
| `zig build practrand-self-test` | Run PractRand wrapper self-tests for dry-run defaults, `PRACTRAND_BIN`, and invalid argument counts without requiring `RNG_test`. |
| `zig build repro` | Run repro helper tests, then print deterministic reproducibility snapshots. |

`tools/practrand.sh` wraps `zig build stream` for PractRand runs and writes
checked-in evidence under `compare/results/` when a report is accepted. Use
`tools/practrand.sh --dry-run` to verify the exact stream and `RNG_test stdin64`
command without requiring PractRand, run `tools/practrand.sh --self-test` or
`zig build practrand-self-test` to self-test wrapper command construction without
`RNG_test`, and set `PRACTRAND_BIN` when the executable name differs.

## Checked-In Tool Files

Every checked-in tool file is listed here so `zig build toolingcheck` can catch
new helpers that need documentation.

| Tool | Primary use |
| --- | --- |
| `tools/apicheck.zig` | API reference coverage checker with focused helper tests. |
| `tools/arcsine_probe.zig` | Arcsine performance probe. |
| `tools/beta_special_probe.zig` | Beta special-case performance probe. |
| `tools/cauchy_probe.zig` | Cauchy expression-shape performance probe. |
| `tools/chi_probe.zig` | Chi performance probe. |
| `tools/distcheck.zig` | Distribution parameter-grid checker with focused helper tests. |
| `tools/erlang_probe.zig` | Erlang performance probe. |
| `tools/examplecheck.zig` | Examples catalog and key-output-token checker with focused helper tests. |
| `tools/exponential_rate_probe.zig` | Exponential-rate performance probe. |
| `tools/fisher_f_probe.zig` | Fisher-F special-case performance probe. |
| `tools/frechet_probe.zig` | Frechet performance probe. |
| `tools/gamma_shape_probe.zig` | Gamma shape-specialization performance probe. |
| `tools/gumbel_probe.zig` | Gumbel performance probe. |
| `tools/half_normal_probe.zig` | HalfNormal performance probe. |
| `tools/hypergeo_h2pe_probe.zig` | Hypergeometric H2PE experiment runner. |
| `tools/inverse_gaussian_probe.zig` | InverseGaussian performance probe. |
| `tools/kumaraswamy_probe.zig` | Kumaraswamy performance probe. |
| `tools/laplace_probe.zig` | Laplace performance probe. |
| `tools/log_logistic_probe.zig` | LogLogistic performance probe. |
| `tools/log_normal_probe.zig` | LogNormal performance probe. |
| `tools/logistic_probe.zig` | Logistic performance probe. |
| `tools/maxwell_probe.zig` | Maxwell performance probe. |
| `tools/nig_probe.zig` | NormalInverseGaussian performance probe. |
| `tools/normal_affine_probe.zig` | Normal affine performance probe. |
| `tools/open_closed_probe.zig` | OpenClosed01 f64 conversion performance probe. |
| `tools/pareto_probe.zig` | Pareto performance probe. |
| `tools/pert_probe.zig` | PERT special-case performance probe. |
| `tools/poisson_probe.zig` | Poisson performance probe. |
| `tools/power_function_probe.zig` | PowerFunction performance probe. |
| `tools/practrand.sh` | PractRand wrapper for accepted external statistical reports, with `--dry-run`, `--self-test`, `PRACTRAND_BIN` support, and build-step file-input guards. |
| `tools/profilecheck.zig` | Accepted vector profile checker with focused helper tests. |
| `tools/profilelongcheck.zig` | Accepted vector profile long-sweep checker with focused helper tests. |
| `tools/profilestresscheck.zig` | Accepted vector profile multi-seed stress checker with focused helper tests. |
| `tools/profiletailcheck.zig` | Accepted vector profile tail checker with focused helper tests. |
| `tools/rayleigh_probe.zig` | Rayleigh performance probe. |
| `tools/repro.zig` | Reproducibility snapshot printer with focused helper tests. |
| `tools/readmecheck.zig` | README discovery and quick-start token checker. |
| `tools/rand_bench_smoke.sh` | Tiny filtered Rust comparison benchmark smoke-test wrapper with `--dry-run` command preview, `--self-test` parser/env coverage, and `ALEA_RAND_BENCH_MANIFEST` / `ALEA_RAND_BENCH_EXPECTED_ROW` overrides. |
| `tools/rand_status.zig` | Current local `rand` / `rand_distr` comparison status printer with helper tests. |
| `tools/roadmapcheck.zig` | Roadmap, active-audit evidence, public-surface manifest, and S4-M11 blocker-token checker with focused helper tests. |
| `tools/runtimecheck.zig` | S4-M11 runtime-runner availability checker. |
| `tools/run_wasi_test.js` | Node WASI runner used by WASI build steps, with `--dry-run` argument reporting and `--self-test` coverage for dry-run and missing-argument paths without wasm. |
| `tools/skew_normal_probe.zig` | SkewNormal performance probe. |
| `tools/standard_fill_probe.zig` | Standard distribution fill performance probe. |
| `tools/statcheck.zig` | Statistical smoke checker with focused helper tests. |
| `tools/stream.zig` | Raw RNG byte stream exporter with focused helper tests. |
| `tools/student_t_probe.zig` | StudentT special-case performance probe. |
| `tools/surfacecheck.zig` | Local Rust `rand` / `rand_core` / `rand_distr` public-surface manifest drift checker with coverage summaries. |
| `tools/toolingcheck.zig` | Build/tooling catalog and doccheck dependency checker. |
| `tools/triangular_probe.zig` | Triangular performance probe. |
| `tools/unit_geometry_probe.zig` | Unit geometry performance probe. |
| `tools/weibull_probe.zig` | Weibull performance probe. |
| `tools/weighted_tree_probe.zig` | WeightedTree performance probe. |
| `tools/ziggurat_probe.zig` | Ziggurat expression-shape performance probe. |
| `tools/ziggurat_stats.zig` | Ziggurat branch-frequency reporter. |
