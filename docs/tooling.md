# Alea Tooling Catalog

This catalog lists project-defined `zig build` steps and checked-in tooling.
Run `zig build -l` for Zig's built-in `install` / `uninstall` steps and the
current generated list. `zig build toolingcheck` keeps this catalog synchronized
with `build.zig` and the checked-in `tools/` directory.

## Validation Gates

| Step | Purpose |
| --- | --- |
| `zig build test` | Run unit tests and API reference coverage checks. |
| `zig build apicheck` | Verify public symbols are covered by `docs/api-reference.md`. |
| `zig build examplecheck` | Verify `docs/examples.md` covers every checked-in runnable example/focused `run-*` step and that key examples still contain expected adoption-output tokens. |
| `zig build toolingcheck` | Verify this tooling catalog covers every project-defined build step and checked-in tool file. |
| `zig build readmecheck` | Verify README discovery links and core validation commands stay visible. |
| `zig build roadmapcheck` | Verify roadmap and active-audit milestone evidence stays synchronized. |
| `zig build doccheck` | Run API, examples, tooling, README, and roadmap documentation checks together. |
| `zig build statcheck` | Run extended statistical smoke checks. |
| `zig build distcheck` | Run parameter-grid distribution checks. |
| `zig build distcheck-libc` | Run libc-linked distribution checks for platform-backed opt-ins. |
| `zig build profilecheck` | Run accepted vector profile distribution checks. |
| `zig build profilecheck-tail` | Run accepted vector profile tail checks. |
| `zig build profilecheck-stress` | Run accepted vector profile multi-seed stress checks. |
| `zig build profilecheck-long` | Run accepted vector profile long stress checks. |
| `zig build crosscheck` | Compile unit tests for secondary targets without executing them. |
| `zig build test-wasi` | Run wasm32-wasi unit tests through Node's WASI runtime. |
| `zig build wasi-report` | Run the chained wasm32-wasi repro/statcheck/distcheck/profile checks through Node's WASI runtime. |
| `zig build validate` | Run native unit, example, catalog, API, statistical, distribution, libc, and accepted-profile checks. |
| `zig build validate-all` | Run native validation plus cross-target compile checks and WASI runtime checks. |

`zig build doccheck` depends on `zig build apicheck`, `zig build
examplecheck`, `zig build toolingcheck`, `zig build readmecheck`, and `zig build
roadmapcheck`. `zig build
validate` depends on `zig build examples`, `zig build doccheck`, `zig build
statcheck`, `zig build distcheck`, `zig build distcheck-libc`, and `zig build
profilecheck`. `zig build validate-all` adds `zig build crosscheck`, `zig build
test-wasi`, and `zig build wasi-report`.

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
available:

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
| `zig build bench` | Run the main Alea throughput benchmark. |
| `zig build bench-libc` | Run the libc-linked throughput benchmark for platform-backed opt-ins. |
| `zig build vectorbench` | Run vector/SIMD microbenchmarks. |
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
| `zig build stream` | Write raw RNG bytes to stdout for external statistical tools, for example `zig build stream -- --engine fast --bytes 1048576`. |
| `zig build repro` | Print deterministic reproducibility snapshots. |

`tools/practrand.sh` wraps `zig build stream` for PractRand runs and writes
checked-in evidence under `compare/results/` when a report is accepted.

## Checked-In Tool Files

Every checked-in tool file is listed here so `zig build toolingcheck` can catch
new helpers that need documentation.

| Tool | Primary use |
| --- | --- |
| `tools/apicheck.zig` | API reference coverage checker. |
| `tools/arcsine_probe.zig` | Arcsine performance probe. |
| `tools/beta_special_probe.zig` | Beta special-case performance probe. |
| `tools/cauchy_probe.zig` | Cauchy expression-shape performance probe. |
| `tools/chi_probe.zig` | Chi performance probe. |
| `tools/distcheck.zig` | Distribution parameter-grid checker. |
| `tools/erlang_probe.zig` | Erlang performance probe. |
| `tools/examplecheck.zig` | Examples catalog and key-output-token checker. |
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
| `tools/practrand.sh` | PractRand wrapper for accepted external statistical reports. |
| `tools/profilecheck.zig` | Accepted vector profile checker. |
| `tools/profilelongcheck.zig` | Accepted vector profile long-sweep checker. |
| `tools/profilestresscheck.zig` | Accepted vector profile multi-seed stress checker. |
| `tools/profiletailcheck.zig` | Accepted vector profile tail checker. |
| `tools/rayleigh_probe.zig` | Rayleigh performance probe. |
| `tools/repro.zig` | Reproducibility snapshot printer. |
| `tools/readmecheck.zig` | README discovery checker. |
| `tools/roadmapcheck.zig` | Roadmap and active-audit evidence checker. |
| `tools/run_wasi_test.js` | Node WASI runner used by WASI build steps. |
| `tools/skew_normal_probe.zig` | SkewNormal performance probe. |
| `tools/standard_fill_probe.zig` | Standard distribution fill performance probe. |
| `tools/statcheck.zig` | Statistical smoke checker. |
| `tools/stream.zig` | Raw RNG byte stream exporter. |
| `tools/student_t_probe.zig` | StudentT special-case performance probe. |
| `tools/toolingcheck.zig` | Build/tooling catalog checker. |
| `tools/triangular_probe.zig` | Triangular performance probe. |
| `tools/unit_geometry_probe.zig` | Unit geometry performance probe. |
| `tools/weibull_probe.zig` | Weibull performance probe. |
| `tools/weighted_tree_probe.zig` | WeightedTree performance probe. |
| `tools/ziggurat_probe.zig` | Ziggurat expression-shape performance probe. |
| `tools/ziggurat_stats.zig` | Ziggurat branch-frequency reporter. |
