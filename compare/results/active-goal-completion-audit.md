# Active Goal Completion Audit

Date: 2026-07-05

Active objective: keep working toward Alea's project mission until the goal is
actually achieved. In concrete terms for the current thread, this means driving
Alea's core RNG functionality and local Linux performance/validation roadmap to
no known core gaps against the locally available Rust `rand` / `rand_distr`
evidence, then raising the bar instead of declaring the product permanently
finished.

This audit is intentionally not a completion claim. It records the current
prompt-to-artifact checklist and the evidence that prevents calling the goal
complete.

## Prompt-to-Artifact Checklist

| Requirement | Evidence artifact / command | Current finding |
| --- | --- | --- |
| Core RNG functionality breadth must match or exceed local Rust evidence | `compare/results/distribution-parity-matrix.md`, `compare/results/linux-no-known-gaps-audit.md`, `docs/api-reference.md`, `zig build apicheck` | Functionality gaps are closed for the current Linux/local Rust surface. |
| Statistical validation must cover primary engines | PractRand reports under `compare/results/`, `compare/results/2026-06-28-practrand-128gib-summary.md`, `zig build statcheck` | Current 128GiB Linux stage is closed; portable fill smoke is recorded for `Xoshiro256PlusPlus`. |
| Reproducibility must be documented and checked beyond x86_64 Linux where possible | `compare/results/reproducibility-matrix.md`, `compare/results/2026-07-03-repro-wasm32-wasi-node.md`, `zig build crosscheck`, `zig build validate-all` | Current second-target WASI bar is closed; broader non-WASI runner gaps are tracked separately. |
| Benchmark parity must cover local Rust comparable rows | `compare/rand_bench/src/main.rs`, `bench/throughput.zig`, `bench/vector.zig`, `compare/results/rust-benchmark-coverage-audit.md` | Current local Rust benchmark surface is mapped to Alea evidence. |
| S4-M1 broader platform reproducibility | `core-rand-coverage.md`, WASI report, `cross-platform-repro-blocker.md` | Closed for current bar. |
| S4-M2 longer statistical validation | 128GiB PractRand summary and engine reports | Closed for current bar. |
| S4-M3 SIMD/vector API design | `bench/vector.zig`, `simd-distribution-kernel-notes.md`, source audit in `core-rand-coverage.md` | Closed for API/prototype bar; performance blocker moved to S4-M4. |
| S4-M4 targeted performance follow-up | `compare/results/performance-triage.md`, `compare/results/s4-m4-remaining-gaps.md`, `lognormal-codegen-audit.md`, `simd-distribution-kernel-notes.md` | Closed for the current local Linux bar; LogNormal and vector normal/exponential throughput gaps now have documented opt-in coverage. |
| S4-M5 default/general dense SIMD kernels | `compare/results/s4-m5-approximation-policy.md`, `compare/results/s4-m4-remaining-gaps.md`, `compare/results/simd-distribution-kernel-notes.md`, `compare/results/performance-triage.md` | Closed for the current local Linux policy bar: named table and approx-log vector profiles are accepted as the explicit throughput-first dense vector surface, while exact/default APIs remain scalar ziggurat lane-fill. |
| S4-M6 accepted profile hardening | `compare/results/2026-07-04-s4-m6-profilecheck.md`, `tools/profilecheck.zig`, `compare/results/reproducibility-matrix.md`, `zig build validate`, `zig build crosscheck`, `zig build -Doptimize=ReleaseFast wasi-profilecheck` | Closed for the current bar: accepted profiles now have 1Mi-lane mean/variance/CDF gates, native validation integration, WASI execution, and cross-target compile coverage. |
| S4-M7 longer tail/profile validation | `compare/results/2026-07-04-s4-m7-profiletailcheck.md`, `tools/profiletailcheck.zig`, `zig build -Doptimize=ReleaseFast profilecheck-tail`, `zig build -Doptimize=ReleaseFast wasi-profiletailcheck` | Closed for the current bar: accepted profiles now have 8Mi-lane tail-focused gates on native Linux and WASI. |
| S4-M8 multi-seed/profile stress | `compare/results/2026-07-04-s4-m8-profilestresscheck.md`, `tools/profilestresscheck.zig`, `zig build -Doptimize=ReleaseFast profilecheck-stress`, `zig build -Doptimize=ReleaseFast wasi-profilestresscheck` | Closed for the current bar: accepted profiles now have deterministic 8-seed stress gates on native Linux and WASI. |
| S4-M9 longer stress sweep | `compare/results/2026-07-04-s4-m9-profilelongcheck.md`, `tools/profilelongcheck.zig`, `zig build -Doptimize=ReleaseFast profilecheck-long`, `zig build -Doptimize=ReleaseFast wasi-profilelongcheck` | Closed for the current long-sweep bar: accepted profiles now have 8Mi-lane/profile long stress gates on native Linux and WASI. |
| S4-M10 additional non-WASI runtime | `compare/results/2026-07-04-s4-m10-profilelong-musl.md`, `zig build -Dtarget=x86_64-linux-musl -Doptimize=ReleaseFast profilecheck-long` | Closed for the current bar: accepted profiles execute the long sweep on x86_64-linux-musl in addition to native glibc and WASI. |
| S4-M11 exact/default dense-kernel breakthrough or new external gap | `compare/results/s4-m11-blocker-audit.md`, `core-rand-coverage.md`, future dense SIMD evidence, future architecture/runtime reports, future local Rust audits | Blocked in this session; no exact/default-compatible dense SIMD winner is known, no additional runtime runner is installed, and no new local Rust core gap has been identified. |
| S4-M12 accepted vector profile adoption example | `examples/vector_profiles.zig`, `zig build run-vector-profiles`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m12-vector-profile-example.md` | Closed for the current bar: a runnable example demonstrates exact/default vectors versus explicit `Table`/`ApproxLog` opt-ins. |
| S4-M13 LogNormal opt-in adoption example | `examples/lognormal_profiles.zig`, `zig build run-lognormal-profiles`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m13-lognormal-profile-example.md` | Closed for the current bar: a runnable example demonstrates exact/default, buffered, native/exp2, and platform libc-backed LogNormal profiles. |
| S4-M14 NativeF32 profile adoption example | `examples/native_f32_profiles.zig`, `zig build run-native-f32-profiles`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m14-native-f32-profile-example.md` | Closed for the current bar: a runnable example demonstrates exact/default f32 outputs versus `NativeF32` scalar/vector profiles. |
| S4-M15 examples validation gate | `zig build examples`, `zig build validate`, `build.zig`, `compare/results/s4-m15-examples-validation.md` | Closed for the current bar: all user-facing examples run through a single build step and local validation depends on it. |
| S4-M16 weighted sampling adoption example | `examples/weighted_sampling.zig`, `zig build run-weighted-sampling`, `zig build examples`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m16-weighted-sampling-example.md` | Closed for the current bar: a runnable example demonstrates one-shot, alias-table, weighted-tree, weighted-choice, and weighted no-replacement workflows. |
| S4-M17 multivariate sampling adoption example | `examples/multivariate_sampling.zig`, `zig build run-multivariate-sampling`, `zig build examples`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m17-multivariate-sampling-example.md` | Closed for the current bar: a runnable example demonstrates Multinomial and Dirichlet owned/caller-buffer/batch workflows. |
| S4-M18 sequence sampling adoption example | `examples/sequence_sampling.zig`, `zig build run-sequence-sampling`, `zig build examples`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m18-sequence-sampling-example.md` | Closed for the current bar: a runnable example demonstrates index sampling, item subsets, partial shuffle, reservoir, reusable choice, and streaming iterator workflows. |
| S4-M19 string generation adoption example | `examples/string_generation.zig`, `zig build run-string-generation`, `zig build examples`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m19-string-generation-example.md` | Closed for the current bar: a runnable example demonstrates predefined/custom ASCII charsets, allocated strings, Unicode scalar generation, and caller-owned UTF-8 buffers. |
| S4-M20 unit geometry adoption example | `examples/unit_geometry.zig`, `zig build run-unit-geometry`, `zig build examples`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m20-unit-geometry-example.md` | Closed for the current bar: a runnable example demonstrates scalar, fill, reusable diagnostic, and vector-lane unit geometry workflows. |
| S4-M21 distribution diagnostics adoption example | `examples/distribution_diagnostics.zig`, `zig build run-distribution-diagnostics`, `zig build examples`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m21-distribution-diagnostics-example.md` | Closed for the current bar: a runnable example demonstrates moments, support, derived constructors, z-score conversion, and PERT builder diagnostics. |
| S4-M22 reproducible streams adoption example | `examples/reproducible_streams.zig`, `zig build run-reproducible-streams`, `zig build examples`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m22-reproducible-streams-example.md` | Closed for the current bar: a runnable example demonstrates seed mixing/substreams, engine aliases, split/jump, and PCG stream selection. |
| S4-M23 range and uniform sampling adoption example | `examples/range_sampling.zig`, `zig build run-range-sampling`, `zig build examples`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m23-range-sampling-example.md` | Closed for the current bar: a runnable example demonstrates integer/float/duration ranges, endpoint semantics, reusable Uniform, vector ranges, collapsed point masses, and checked errors. |
| S4-M24 discrete distributions adoption example | `examples/discrete_distributions.zig`, `zig build run-discrete-distributions`, `zig build examples`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m24-discrete-distributions-example.md` | Closed for the current bar: a runnable example demonstrates Bernoulli, Binomial, NegativeBinomial, Poisson, Geometric, Hypergeometric, vector discrete samplers, and checked errors. |
| S4-M25 continuous distributions adoption example | `examples/continuous_distributions.zig`, `zig build run-continuous-distributions`, `zig build examples`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m25-continuous-distributions-example.md` | Closed for the current bar: a runnable example demonstrates core continuous shape/tail distributions, diagnostics, fills, vector batches, and checked errors. |
| S4-M26 advanced continuous distributions adoption example | `examples/advanced_continuous_distributions.zig`, `zig build run-advanced-continuous-distributions`, `zig build examples`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m26-advanced-continuous-distributions-example.md` | Closed for the current bar: a runnable example demonstrates remaining advanced continuous shape/tail families, fills, vector batches, and checked errors. |
| S4-M27 rank distributions adoption example | `examples/rank_distributions.zig`, `zig build run-rank-distributions`, `zig build examples`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m27-rank-distributions-example.md` | Closed for the current bar: a runnable example demonstrates finite Zipf, unbounded Zeta, vector rank samplers, degenerate infinite-exponent behavior, and checked errors. |
| S4-M28 examples catalog | `docs/examples.md`, `zig build examples`, `zig build apicheck`, `compare/results/s4-m28-examples-catalog.md` | Closed for the current bar: all focused runnable examples are discoverable from a central catalog and remain under local validation. |
| S4-M29 example catalog drift check | `tools/examplecheck.zig`, `zig build examplecheck`, `zig build validate`, `docs/examples.md`, `compare/results/s4-m29-examplecheck.md` | Closed for the current bar: example source and focused run-step coverage in `docs/examples.md` is verified and included in local validation. |
| S4-M30 build/tooling catalog drift check | `docs/tooling.md`, `tools/toolingcheck.zig`, `zig build toolingcheck`, `zig build validate`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m30-toolingcheck.md` | Closed for the current bar: project build steps and checked-in tool files have a central catalog and validator included in local validation. |
| S4-M31 README discovery and doccheck aggregate | `README.md`, `tools/readmecheck.zig`, `zig build readmecheck`, `zig build doccheck`, `zig build test`, `zig build validate`, `compare/results/s4-m31-readme-doccheck.md` | Closed for the current bar: README discovery is verified and API/example/tooling/README/roadmap checks run through one documentation gate. |
| S4-M32 roadmap and active-audit drift check | `tools/roadmapcheck.zig`, `zig build roadmapcheck`, `zig build doccheck`, `zig build test`, `zig build validate`, `compare/results/core-rand-coverage.md`, `compare/results/active-goal-completion-audit.md`, `compare/results/linux-no-known-gaps-audit.md`, `compare/results/s4-m32-roadmapcheck.md` | Closed for the current bar: closed S4 evidence files, next-gap continuity, S4-M11 blocker visibility, and non-completion audit language are verified. |
| S4-M33 fixed-size item array sequence sampling | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/distribution-parity-matrix.md`, `compare/results/s4-m33-choose-array.md` | Closed for the current bar: fixed-size item array sampling is available without heap allocation and documented against local Rust sequence ergonomics. |
| S4-M34 one-shot weighted item and pointer choice | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/distribution-parity-matrix.md`, `compare/results/s4-m34-choose-weighted.md` | Closed for the current bar: one-shot weighted values and mutable pointers are available and documented alongside weighted indexes and reusable weighted samplers. |
| S4-M35 caller-owned reservoir sampling | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m35-reservoir-into.md` | Closed for the current bar: reservoir samples can now fill caller-owned buffers with checked no-consume behavior. |
| S4-M36 caller-owned iterator reservoir sampling | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m36-iterator-into.md` | Closed for the current bar: streaming iterator samples can now fill caller-owned buffers with optional partial-fill and checked exact-fill forms. |
| S4-M37 fixed-size weighted array sampling | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m37-weighted-array.md` | Closed for the current bar: fixed-size weighted no-replacement item arrays are available without heap allocation. |
| S4-M38 fixed-size weighted index array sampling | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m38-weighted-index-array.md` | Closed for the current bar: fixed-size weighted no-replacement index arrays are available without heap allocation. |
| S4-M39 fixed-size weighted iterator array sampling | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m39-weighted-iterator-array.md` | Closed for the current bar: fixed-size weighted iterator arrays are available without heap allocation. |
| S4-M40 fixed-size iterator array sampling | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m40-iterator-array.md` | Closed for the current bar: fixed-size iterator arrays are available without heap allocation. |
| S4-M41 caller-owned weighted index sampling | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m41-weighted-indices-into.md` | Closed for the current bar: runtime-length weighted no-replacement index samples can now fill caller-owned buffers with caller-provided scratch keys. |
| S4-M42 caller-owned weighted item sampling | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m42-weighted-into.md` | Closed for the current bar: runtime-length weighted no-replacement item samples can now fill caller-owned buffers with caller-provided index/key scratch. |
| S4-M43 caller-owned weighted iterator sampling | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m43-weighted-iterator-into.md` | Closed for the current bar: runtime-length weighted iterator samples can now fill caller-owned buffers with caller-provided key scratch. |
| S4-M44 caller-owned index sampling | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m44-indices-into.md` | Closed for the current bar: runtime-length index samples can now fill caller-owned buffers. |
| S4-M45 caller-owned slice item sampling | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m45-choose-multiple-into.md` | Closed for the current bar: runtime-length item subsets can now fill caller-owned buffers with caller-provided index scratch. |
| S4-M46 partial shuffle split result | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m46-partial-shuffle-split.md` | Closed for the current bar: partial shuffle can now return selected and rest slices together. |
| S4-M47 caller-owned U32 index sampling | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m47-u32-indices-into.md` | Closed for the current bar: runtime-length `u32` index samples can now fill caller-owned buffers. |
| S4-M48 caller-owned sampling adoption example | `examples/caller_owned_sampling.zig`, `zig build run-caller-owned-sampling`, `zig build examples`, `zig build validate`, `docs/examples.md`, `compare/results/s4-m48-caller-owned-example.md` | Closed for the current bar: caller-owned and scratch-buffer sequence workflows now have a dedicated runnable example and catalog/checker coverage. |
| S4-M49 IndexVec item iterators | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m49-indexvec-item-iterators.md` | Closed for the current bar: sampled index vectors can lazily map to slice values or pointers without allocating mapped results. |
| S4-M50 IndexVec caller-owned item mapping | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m50-indexvec-into.md` | Closed for the current bar: sampled index vectors can fill caller-owned value/pointer buffers without allocating mapped results. |
| S4-M51 IndexVec mutable pointer mapping | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m51-indexvec-mutptrs.md` | Closed for the current bar: sampled index vectors can lazily iterate or fill caller-owned mutable pointer buffers after checked bounds/distinctness validation. |
| S4-M52 caller-owned pointer subset sampling | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m52-choose-multiple-ptrs-into.md` | Closed for the current bar: runtime-length item subsets can now fill caller-owned const/mutable pointer buffers with caller-provided index scratch. |
| S4-M53 fixed-size pointer array sampling | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m53-choose-ptr-array.md` | Closed for the current bar: fixed-size item subsets can now return const/mutable pointer arrays without heap allocation or value copies. |
| S4-M54 fixed-size weighted pointer array sampling | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m54-weighted-ptr-array.md` | Closed for the current bar: fixed-size weighted no-replacement item subsets can now return const/mutable pointer arrays without heap allocation or value copies. |
| S4-M55 caller-owned weighted pointer subset sampling | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m55-weighted-ptrs-into.md` | Closed for the current bar: runtime-length weighted no-replacement item subsets can now fill caller-owned const/mutable pointer buffers with caller-provided index/key scratch. |
| S4-M56 const-pointer single choice | `src/rng.zig`, `examples/basic.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m56-choose-const-ptr.md` | Closed for the current bar: one-shot choice can now return `*const T` from immutable slices without value copies or mutable slice requirements. |
| S4-M57 weighted const-pointer single choice | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m57-choose-weighted-const-ptr.md` | Closed for the current bar: one-shot weighted choice can now return `*const T` from immutable item slices without value copies or mutable slice requirements. |
| S4-M58 allocation-returning pointer subset sampling | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m58-choose-multiple-ptrs.md` | Closed for the current bar: allocation-returning item subsets can now return const/mutable pointer slices without value copies. |
| S4-M59 allocation-returning weighted pointer subset sampling | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m59-weighted-ptrs.md` | Closed for the current bar: allocation-returning weighted no-replacement item subsets can now return const/mutable pointer slices without value copies. |
| S4-M60 allocation-returning reservoir pointer sampling | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m60-reservoir-ptrs.md` | Closed for the current bar: allocation-returning reservoir samples can now return const/mutable pointer slices without value copies. |
| S4-M61 caller-owned reservoir pointer sampling | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m61-reservoir-ptrs-into.md` | Closed for the current bar: caller-owned reservoir samples can now fill const/mutable pointer buffers without value copies. |
| S4-M62 caller-owned pointer adoption example refresh | `examples/caller_owned_sampling.zig`, `zig build run-caller-owned-sampling`, `docs/examples.md`, `compare/results/s4-m62-caller-owned-pointer-example.md` | Closed for the current bar: the caller-owned example now demonstrates pointer buffers for item subsets, reservoir samples, and weighted samples. |
| S4-M63 one-shot index choice | `src/rng.zig`, `examples/basic.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m63-choose-index.md` | Closed for the current bar: callers can now sample a single index from `0..length` without spelling a raw integer range helper. |
| S4-M64 generic one-shot weighted index | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m64-generic-weighted-index.md` | Closed for the current bar: one-shot weighted indexes now accept generic integer or float weights through the sequence namespace. |
| S4-M65 example content drift check | `tools/examplecheck.zig`, `docs/examples.md`, `docs/tooling.md`, `compare/results/s4-m65-example-output-check.md` | Closed for the current bar: examplecheck now guards key adoption-output tokens in the focused examples. |
| S4-M66 S4-M11 blocker audit drift check | `tools/roadmapcheck.zig`, `compare/results/s4-m11-blocker-audit.md`, `compare/results/s4-m66-s4-m11-blockercheck.md` | Closed for the current bar: roadmapcheck now validates the concrete S4-M11 blocker tokens and non-completion warning. |
| S4-M67 README quick-start index/pointer discovery | `README.md`, `tools/readmecheck.zig`, `docs/tooling.md`, `compare/results/s4-m67-readme-choice-discovery.md` | Closed for the current bar: README and readmecheck now keep one-shot index and const-pointer choice visible in the quick start. |
| S4-M68 doccheck dependency hardening | `tools/toolingcheck.zig`, `docs/tooling.md`, `compare/results/s4-m68-doccheck-dependency-check.md` | Closed for the current bar: toolingcheck now verifies doccheck still runs all documentation/catalog checkers. |
| S4-M69 weighted IndexVec sampling | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m69-weighted-indexvec.md` | Closed for the current bar: weighted no-replacement index samples can now return compact `IndexVec` results. |
| S4-M70 caller-owned weighted u32 index sampling | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m70-weighted-u32-indices-into.md` | Closed for the current bar: weighted no-replacement index samples can now fill compact caller-owned `u32` buffers. |
| S4-M71 fixed-size weighted u32 index arrays | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m71-weighted-u32-index-array.md` | Closed for the current bar: weighted no-replacement index samples can now return compact fixed-size `[N]u32` arrays. |
| S4-M72 allocation-returning weighted u32 index slices | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m72-weighted-u32-indices.md` | Closed for the current bar: weighted no-replacement index samples can now return compact allocation-owned `[]u32` slices. |
| S4-M73 fixed-size u32 index arrays | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m73-u32-index-array.md` | Closed for the current bar: unweighted index samples can now return compact fixed-size `[N]u32` arrays. |
| S4-M74 IndexVec u32 export mapping | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m74-indexvec-u32-export.md` | Closed for the current bar: sampled IndexVec results can now fill or allocate compact `u32` copies. |
| S4-M75 IndexVec owned item mapping | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m75-indexvec-owned-mapping.md` | Closed for the current bar: sampled IndexVec results can now allocate mapped values or const/mutable pointer slices. |
| S4-M76 one-shot u32 index choice | `src/rng.zig`, `examples/basic.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m76-choose-index-u32.md` | Closed for the current bar: callers can now sample one compact `u32` index from `0..length`. |
| S4-M77 generic weighted u32 index choice | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m77-generic-weighted-index-u32.md` | Closed for the current bar: generic weighted one-shot index choice can now return compact `u32` indexes. |
| S4-M78 f64 weighted u32 index choice | `src/rng.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m78-rng-weighted-index-u32.md` | Closed for the current bar: f64 weighted one-shot index choice can now return compact `u32` indexes. |
| S4-M79 WeightedChoice index fills | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m79-weighted-choice-index-fills.md` | Closed for the current bar: reusable weighted choices can now fill caller-owned usize/u32 index buffers. |
| S4-M80 Choice index fills | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m80-choice-index-fills.md` | Closed for the current bar: reusable unweighted choices can now fill caller-owned usize/u32 index buffers. |
| S4-M81 Choice sampler index samples | `src/seq.zig`, `examples/sequence_sampling.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m81-choice-sample-index.md` | Closed for the current bar: reusable unweighted and weighted choices can now sample usize/u32 indexes directly. |
| S4-M82 Choice owned index batches | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m82-choice-owned-indices.md` | Closed for the current bar: reusable unweighted choices can now allocate usize/u32 index batches. |
| S4-M83 WeightedChoice owned index batches | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m83-weighted-choice-owned-indices.md` | Closed for the current bar: reusable weighted choices can now allocate usize/u32 index batches. |
| S4-M84 reusable choice owned values and pointers | `src/seq.zig`, `examples/sequence_sampling.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m84-choice-owned-values-ptrs.md` | Closed for the current bar: reusable unweighted and weighted choices can now allocate repeated values and const pointers. |
| S4-M85 Rng owned repeated samples | `src/rng.zig`, `examples/basic.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m85-rng-owned-batches.md` | Closed for the current bar: `Rng` can now allocate owned repeated values and sampler draws. |
| S4-M86 Rng owned byte buffers | `src/rng.zig`, `examples/basic.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m86-rng-owned-bytes.md` | Closed for the current bar: `Rng` can now allocate owned random byte slices. |
| S4-M87 Rng owned range batches | `src/rng.zig`, `examples/range_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m87-rng-owned-ranges.md` | Closed for the current bar: `Rng` can now allocate owned scalar integer/float range batches. |
| S4-M88 Rng owned strict-interval batches | `src/rng.zig`, `examples/range_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m88-rng-owned-strict-intervals.md` | Closed for the current bar: `Rng` can now allocate owned strict-open and open-closed float batches. |
| S4-M89 Rng owned probability batches | `src/rng.zig`, `examples/basic.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m89-rng-owned-probabilities.md` | Closed for the current bar: `Rng` can now allocate owned chance/ratio bool batches. |
| S4-M90 Rng owned normal/exponential batches | `src/rng.zig`, `examples/basic.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m90-rng-owned-normal-exponential.md` | Closed for the current bar: `Rng` can now allocate owned normal/exponential sample batches. |
| S4-M91 Rng owned duration range batches | `src/rng.zig`, `examples/range_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m91-rng-owned-durations.md` | Closed for the current bar: `Rng` can now allocate owned `std.Io.Duration` range batches. |
| S4-M92 Rng owned vector range batches | `src/rng.zig`, `examples/range_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m92-rng-owned-vector-ranges.md` | Closed for the current bar: `Rng` can now allocate owned vector range batches. |
| S4-M93 Rng owned vector strict-interval batches | `src/rng.zig`, `examples/range_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m93-rng-owned-vector-strict-intervals.md` | Closed for the current bar: `Rng` can now allocate owned vector strict-open and open-closed float batches. |
| S4-M94 Rng owned vector probability batches | `src/rng.zig`, `examples/basic.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m94-rng-owned-vector-probabilities.md` | Closed for the current bar: `Rng` can now allocate owned vector chance/ratio bool batches. |
| S4-M95 Rng owned vector normal/exponential batches | `src/rng.zig`, `examples/basic.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m95-rng-owned-vector-normal-exponential.md` | Closed for the current bar: `Rng` can now allocate owned vector normal/exponential sample batches. |
| S4-M96 Rng owned standard normal/exponential batches | `src/rng.zig`, `examples/basic.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m96-rng-owned-standard-normal-exponential.md` | Closed for the current bar: `Rng` can now sample, fill, and allocate scalar/vector standard normal/exponential batches directly. |
| S4-M97 Rng owned Unicode scalar batches | `src/rng.zig`, `examples/string_generation.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m97-rng-owned-unicode-scalars.md` | Closed for the current bar: `Rng` can now fill caller-owned Unicode scalar buffers and allocate owned scalar batches. |
| S4-M98 Unicode scalar range helpers | `src/rng.zig`, `examples/string_generation.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m98-unicode-scalar-ranges.md` | Closed for the current bar: `Rng` can now sample, fill, and allocate bounded Unicode scalar ranges while skipping surrogate code points. |
| S4-M99 Rng owned bounded uint batches | `src/rng.zig`, `examples/basic.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m99-rng-owned-bounded-uint.md` | Closed for the current bar: `Rng` can now fill and allocate bounded unsigned integer batches directly. |
| S4-M100 Rng owned inclusive integer range batches | `src/rng.zig`, `examples/range_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m100-rng-owned-inclusive-ranges.md` | Closed for the current bar: `Rng` can now fill and allocate inclusive integer ranges directly. |
| S4-M101 Rng owned vector inclusive integer range batches | `src/rng.zig`, `examples/range_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m101-rng-owned-vector-inclusive-ranges.md` | Closed for the current bar: `Rng` can now sample, fill, and allocate inclusive integer vector ranges directly. |
| S4-M102 Rng repeated index choice batches | `src/rng.zig`, `examples/basic.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m102-rng-owned-index-choice-batches.md` | Closed for the current bar: `Rng` can now fill and allocate repeated usize/u32 with-replacement index choices. |
| S4-M103 Rng repeated value choice batches | `src/rng.zig`, `examples/basic.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m103-rng-owned-value-choice-batches.md` | Closed for the current bar: `Rng` can now fill and allocate repeated with-replacement value choices. |
| S4-M104 Rng repeated const-pointer choice batches | `src/rng.zig`, `examples/basic.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m104-rng-owned-const-ptr-choice-batches.md` | Closed for the current bar: `Rng` can now fill and allocate repeated with-replacement const-pointer choices. |
| S4-M105 Rng repeated mutable-pointer choice batches | `src/rng.zig`, `examples/basic.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m105-rng-owned-mut-ptr-choice-batches.md` | Closed for the current bar: `Rng` can now fill and allocate repeated with-replacement mutable-pointer choices. |
| S4-M106 Rng repeated weighted index batches | `src/rng.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m106-rng-owned-weighted-index-batches.md` | Closed for the current bar: `Rng` can now fill and allocate repeated f64 weighted indexes. |
| S4-M107 Rng repeated weighted u32 index batches | `src/rng.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m107-rng-owned-weighted-u32-index-batches.md` | Closed for the current bar: `Rng` can now fill and allocate repeated compact f64 weighted indexes. |
| S4-M108 Rng repeated weighted value batches | `src/rng.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m108-rng-owned-weighted-value-batches.md` | Closed for the current bar: `Rng` can now fill and allocate repeated f64 weighted values. |
| S4-M109 Rng repeated weighted const-pointer batches | `src/rng.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m109-rng-owned-weighted-const-ptr-batches.md` | Closed for the current bar: `Rng` can now fill and allocate repeated f64 weighted const pointers. |
| S4-M110 Rng repeated weighted mutable-pointer batches | `src/rng.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m110-rng-owned-weighted-mut-ptr-batches.md` | Closed for the current bar: `Rng` can now fill and allocate repeated f64 weighted mutable pointers. |
| S4-M111 generic repeated weighted index batches | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m111-generic-weighted-index-batches.md` | Closed for the current bar: `seq` can now fill and allocate repeated generic-weight usize/u32 weighted indexes. |
| S4-M112 generic repeated weighted value batches | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m112-generic-weighted-value-batches.md` | Closed for the current bar: `seq` can now fill and allocate repeated generic-weight weighted values. |
| S4-M113 generic repeated weighted const-pointer batches | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m113-generic-weighted-const-ptr-batches.md` | Closed for the current bar: `seq` can now fill and allocate repeated generic-weight weighted const pointers. |
| S4-M114 generic repeated weighted mutable-pointer batches | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m114-generic-weighted-mut-ptr-batches.md` | Closed for the current bar: `seq` can now fill and allocate repeated generic-weight weighted mutable pointers. |
| S4-M115 accessor-based weighted item choices | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m115-accessor-weighted-choices.md` | Closed for the current bar: `seq` can now select weighted values/const pointers/mutable pointers through comptime item accessors. |
| S4-M116 accessor-based weighted no-replacement samples | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m116-accessor-weighted-samples.md` | Closed for the current bar: `seq` can now allocate weighted no-replacement value/const-pointer/mutable-pointer subsets through comptime item accessors. |
| S4-M117 accessor-based weighted caller-owned buffers | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m117-accessor-weighted-into.md` | Closed for the current bar: `seq` can now fill caller-owned weighted no-replacement index/value/const-pointer/mutable-pointer buffers through comptime item accessors. |
| S4-M118 accessor-based weighted index samples | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m118-accessor-weighted-index-samples.md` | Closed for the current bar: `seq` can now allocate accessor-weighted usize/u32/IndexVec no-replacement index samples. |
| S4-M119 accessor-based weighted index arrays | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m119-accessor-weighted-index-arrays.md` | Closed for the current bar: `seq` can now return fixed-size accessor-weighted usize/u32 index arrays without heap allocation. |
| S4-M120 accessor-based weighted item arrays | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m120-accessor-weighted-item-arrays.md` | Closed for the current bar: `seq` can now return fixed-size accessor-weighted value/const-pointer/mutable-pointer arrays without heap allocation. |
| S4-M121 WeightedChoice accessor construction/update | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m121-weightedchoice-accessor-init.md` | Closed for the current bar: reusable `WeightedChoice` can now be built and updated from comptime item weight accessors. |
| S4-M122 stable iterator choice aliases | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m122-stable-iterator-choice.md` | Closed for the current bar: iterator choice now has explicit stable aliases matching local Rust `choose_stable` terminology. |
| S4-M123 iterator sample-fill aliases | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m123-iterator-sample-fill.md` | Closed for the current bar: iterator caller-owned reservoir sampling now has explicit `sampleIteratorFill*` aliases matching local Rust `sample_fill` terminology. |
| S4-M124 slice sample aliases | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m124-slice-sample-aliases.md` | Closed for the current bar: allocation-returning and caller-owned slice item/const-pointer/mutable-pointer subsets now have explicit `sampleItems*` / `samplePtrs*` / `sampleMutPtrs*` aliases matching local Rust `IndexedRandom::sample` terminology. |
| S4-M125 index-weighted no-replacement samples | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m125-index-weighted-samples.md` | Closed for the current bar: length-based index weight accessors now produce usize/u32/IndexVec no-replacement weighted index samples matching local Rust `index::sample_weighted(..., |index| ...)` workflows. |
| S4-M126 caller-owned index-weighted buffers | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m126-index-weighted-into.md` | Closed for the current bar: length-based index weight accessors now fill caller-owned usize/u32 no-replacement weighted index buffers. |
| S4-M127 fixed-size index-weighted arrays | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m127-index-weighted-arrays.md` | Closed for the current bar: length-based index weight accessors now return fixed-size usize/u32 no-replacement weighted index arrays. |
| S4-M128 fixed-size slice sample aliases | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m128-slice-sample-array-aliases.md` | Closed for the current bar: fixed-size value/const-pointer/mutable-pointer slice array samples now have explicit `sampleItemsArray*` / `samplePtrArray*` / `sampleMutPtrArray*` aliases matching local Rust `sample_array` terminology. |
| S4-M129 seq shuffle aliases | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m129-seq-shuffle-aliases.md` | Closed for the current bar: full in-place slice shuffling is now discoverable as `seq.shuffle` / `seq.shuffleFrom` alongside partial-shuffle sequence helpers. |
| S4-M130 Rust-style tail partial shuffle | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m130-tail-partial-shuffle.md` | Closed for the current bar: `seq.partialShuffleTail*` selects into the slice tail and returns selected/rest views matching local Rust `partial_shuffle` semantics. |
| S4-M131 seq one-shot choice aliases | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m131-seq-choice-aliases.md` | Closed for the current bar: one-shot value/const-pointer/mutable-pointer slice choices are now discoverable as `seq.choose*` aliases matching local Rust `choose` / `choose_mut` terminology. |
| S4-M132 seq repeated choice fill aliases | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m132-seq-choice-fills.md` | Closed for the current bar: repeated value/const-pointer/mutable-pointer with-replacement choices can now fill caller-owned buffers through `seq.fillChoose*` aliases. |
| S4-M133 seq owned repeated choice batches | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m133-seq-owned-choice-batches.md` | Closed for the current bar: repeated value/const-pointer/mutable-pointer with-replacement choices can now allocate owned batches through `seq.choose*Batch` aliases. |
| S4-M134 seq index choice aliases | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m134-seq-index-choice-aliases.md` | Closed for the current bar: one-shot, caller-owned, and allocation-returning repeated usize/u32 index choices are now discoverable through `seq.chooseIndex*` aliases beside value/pointer `seq.choose*` workflows. |
| S4-M135 accessor-weighted choice fills | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m135-accessor-weighted-choice-fills.md` | Closed for the current bar: caller-owned repeated accessor-weighted value/const-pointer/mutable-pointer choices can now be filled through `seq.fillChooseWeighted*By` helpers. |
| S4-M136 accessor-weighted choice batches | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m136-accessor-weighted-choice-batches.md` | Closed for the current bar: allocation-returning repeated accessor-weighted value/const-pointer/mutable-pointer choices can now be created through `seq.chooseWeighted*BatchBy` helpers. |
| S4-M137 accessor-weighted one-shot indexes | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m137-accessor-weighted-index-choice.md` | Closed for the current bar: one-shot usize/u32 weighted indexes can now be selected directly from item-derived weights through `seq.weightedIndex*By` helpers. |
| S4-M138 accessor-weighted index fills | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m138-accessor-weighted-index-fills.md` | Closed for the current bar: caller-owned repeated usize/u32 weighted index buffers can now be filled from item-derived weights through `seq.fillWeightedIndex*By` helpers. |
| S4-M139 accessor-weighted index batches | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m139-accessor-weighted-index-batches.md` | Closed for the current bar: allocation-returning repeated usize/u32 weighted index batches can now be allocated from item-derived weights through `seq.weightedIndex*BatchBy` helpers. |
| S4-M140 index-weighted one-shot indexes | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m140-index-weighted-index-choice.md` | Closed for the current bar: one-shot usize/u32 weighted indexes can now be selected directly from a length and index-weight accessor through `seq.weightedIndex*ByIndex` helpers. |
| S4-M141 index-weighted index fills | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m141-index-weighted-index-fills.md` | Closed for the current bar: caller-owned repeated usize/u32 weighted index buffers can now be filled from a length and index-weight accessor through `seq.fillWeightedIndex*ByIndex` helpers. |
| S4-M142 index-weighted index batches | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m142-index-weighted-index-batches.md` | Closed for the current bar: allocation-returning repeated usize/u32 weighted index batches can now be allocated from a length and index-weight accessor through `seq.weightedIndex*BatchByIndex` helpers. |
| S4-M143 index-weighted item choices | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m143-index-weighted-item-choices.md` | Closed for the current bar: one-shot value/const-pointer/mutable-pointer weighted choices can now be selected from slices through length/index-weight accessors via `seq.chooseWeighted*ByIndex` helpers. |
| S4-M144 index-weighted item choice fills | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m144-index-weighted-item-choice-fills.md` | Closed for the current bar: caller-owned repeated value/const-pointer/mutable-pointer weighted choices can now be filled from slices through length/index-weight accessors via `seq.fillChooseWeighted*ByIndex` helpers. |
| S4-M145 index-weighted item choice batches | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m145-index-weighted-item-choice-batches.md` | Closed for the current bar: allocation-returning repeated value/const-pointer/mutable-pointer weighted choices can now be allocated from slices through length/index-weight accessors via `seq.chooseWeighted*BatchByIndex` helpers. |
| S4-M146 WeightedChoice index accessor construction/update | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m146-weightedchoice-index-accessor-init.md` | Closed for the current bar: reusable `WeightedChoice` can now be built and updated from comptime index-weight accessors through `initByIndex` and `updateByIndex`. |
| S4-M147 weighted tree index accessor construction/update | `src/distributions.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m147-weighted-tree-index-accessors.md` | Closed for the current bar: dynamic `WeightedTree` and `WeightedIntTree` can now be built and fully refreshed from comptime index-weight accessors. |
| S4-M148 weighted tree item accessor construction/update | `src/distributions.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m148-weighted-tree-item-accessors.md` | Closed for the current bar: dynamic `WeightedTree` and `WeightedIntTree` can now be built and fully refreshed from item-derived weight accessors. |
| S4-M149 weighted tree compact u32 index output | `src/distributions.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m149-weighted-tree-u32-output.md` | Closed for the current bar: dynamic `WeightedTree` and `WeightedIntTree` now expose compact `u32` sample/fill helpers for populations that fit `u32`. |
| S4-M150 weighted tree owned index batches | `src/distributions.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m150-weighted-tree-owned-indices.md` | Closed for the current bar: dynamic `WeightedTree` and `WeightedIntTree` now allocate repeated `usize` and compact `u32` index batches. |
| S4-M151 weighted tree index naming aliases | `src/distributions.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m151-weighted-tree-index-aliases.md` | Closed for the current bar: dynamic `WeightedTree` and `WeightedIntTree` now expose `sampleIndex*` and `fillIndices*` aliases matching reusable `WeightedChoice` index naming. |
| S4-M152 weighted tree index iterators | `src/distributions.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m152-weighted-tree-index-iterators.md` | Closed for the current bar: dynamic `WeightedTree` and `WeightedIntTree` now expose repeated `usize` and compact `u32` index iterators. |
| S4-M153 AliasTable compact u32 index output | `src/distributions.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m153-aliastable-u32-output.md` | Closed for the current bar: static `AliasTable` now exposes compact `u32` sample/fill helpers for populations that fit `u32`. |
| S4-M154 AliasTable owned index batches | `src/distributions.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m154-aliastable-owned-indices.md` | Closed for the current bar: static `AliasTable` now allocates repeated `usize` and compact `u32` index batches. |
| S4-M155 AliasTable index naming aliases | `src/distributions.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m155-aliastable-index-aliases.md` | Closed for the current bar: static `AliasTable` now exposes `sampleIndex*` and `fillIndices*` aliases matching reusable `WeightedChoice` and dynamic tree index naming. |
| S4-M156 AliasTable index iterators | `src/distributions.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m156-aliastable-index-iterators.md` | Closed for the current bar: static `AliasTable` now exposes repeated `usize` and compact `u32` index iterators. |
| S4-M157 AliasTable index accessor construction/update | `src/distributions.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m157-aliastable-index-accessors.md` | Closed for the current bar: static `AliasTable` can now be built and updated from comptime index-weight accessors. |
| S4-M158 AliasTable item accessor construction/update | `src/distributions.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m158-aliastable-item-accessors.md` | Closed for the current bar: static `AliasTable` can now be built and updated from item-derived weight accessors. |
| S4-M159 AliasTable fixed index arrays | `src/distributions.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m159-aliastable-index-arrays.md` | Closed for the current bar: static `AliasTable` now returns fixed-size repeated `usize` and compact `u32` index arrays. |
| S4-M160 weighted tree fixed index arrays | `src/distributions.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m160-weighted-tree-index-arrays.md` | Closed for the current bar: dynamic `WeightedTree` and `WeightedIntTree` now return fixed-size repeated `usize` and compact `u32` index arrays. |
| S4-M161 WeightedChoice fixed index arrays | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m161-weightedchoice-index-arrays.md` | Closed for the current bar: reusable `WeightedChoice` now returns fixed-size repeated `usize` and compact `u32` index arrays. |
| S4-M162 Choice fixed index arrays | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m162-choice-index-arrays.md` | Closed for the current bar: reusable `Choice` now returns fixed-size repeated `usize` and compact `u32` index arrays. |
| S4-M163 Choice fixed value and pointer arrays | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m163-choice-value-ptr-arrays.md` | Closed for the current bar: reusable `Choice` now returns fixed-size repeated value and const-pointer arrays. |
| S4-M164 WeightedChoice fixed value and pointer arrays | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m164-weightedchoice-value-ptr-arrays.md` | Closed for the current bar: reusable `WeightedChoice` now returns fixed-size repeated value and const-pointer arrays. |
| S4-M165 fixed repeated index-choice arrays | `src/rng.zig`, `src/seq.zig`, `examples/basic.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m165-index-choice-arrays.md` | Closed for the current bar: `Rng` and `seq` now return fixed-size repeated with-replacement `usize` and compact `u32` index choice arrays. |
| S4-M166 Rng fixed value and pointer choice arrays | `src/rng.zig`, `examples/basic.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m166-rng-choice-arrays.md` | Closed for the current bar: `Rng` now returns fixed-size repeated with-replacement value, const-pointer, and mutable-pointer choice arrays. |
| S4-M167 Rng fixed weighted choice arrays | `src/rng.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m167-rng-weighted-choice-arrays.md` | Closed for the current bar: `Rng` now returns fixed-size repeated f64 weighted index/u32-index/value/const-pointer/mutable-pointer arrays. |
| S4-M168 seq generic weighted choice arrays | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m168-seq-generic-weighted-choice-arrays.md` | Closed for the current bar: `seq` now returns fixed-size repeated generic-weight index/u32-index/value/const-pointer/mutable-pointer arrays. |
| S4-M169 accessor-weighted choice arrays | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m169-accessor-weighted-choice-arrays.md` | Closed for the current bar: `seq` now returns fixed-size repeated item-accessor weighted index/u32-index/value/const-pointer/mutable-pointer arrays. |
| S4-M170 index-weighted choice arrays | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m170-index-weighted-choice-arrays.md` | Closed for the current bar: `seq` now returns fixed-size repeated length/index-weight accessor weighted index/u32-index/value/const-pointer/mutable-pointer arrays while keeping no-replacement `sampleWeighted*ArrayByIndex` semantics distinct. |
| S4-M171 seq fixed repeated choice arrays | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m171-seq-repeated-choice-arrays.md` | Closed for the current bar: `seq` now returns explicit fixed-size repeated with-replacement value/const-pointer/mutable-pointer choice arrays while keeping `chooseArray` / `choosePtrArray` no-replacement semantics distinct. |
| S4-M172 choice index iterators | `src/seq.zig`, `examples/sequence_sampling.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m172-choice-index-iterators.md` | Closed for the current bar: reusable `Choice` and `WeightedChoice` now expose repeated `usize` and compact `u32` index iterators with fill helpers. |
| S4-M173 IndexVec consuming owned conversions | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m173-indexvec-consuming-owned.md` | Closed for the current bar: `IndexVec` now has consuming owned-slice conversions matching Rust `IndexVec::into_vec` ergonomics. |
| S4-M174 IndexVec content equality | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m174-indexvec-equality.md` | Closed for the current bar: `IndexVec.eql` now compares sampled index-vector contents across compact and native backings, matching Rust `IndexVec` `PartialEq` behavior in Zig form. |
| S4-M175 IndexVec owned backing constructors | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m175-indexvec-owned-constructors.md` | Closed for the current bar: `IndexVec.fromOwnedSlice` and `IndexVec.fromOwnedU32Slice` now adopt caller-owned native or compact backing slices without copying. |
| S4-M176 IndexVec representation-preserving clone | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m176-indexvec-clone.md` | Closed for the current bar: `IndexVec.clone` now deep-copies compact or native backing slices while preserving representation. |
| S4-M177 IndexVec consuming iterator | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m177-indexvec-consuming-iterator.md` | Closed for the current bar: `IndexVec.intoIter` now consumes owned compact/native index vectors into exact-size usize index streams with explicit allocator cleanup. |
| S4-M178 weighted choice pointer iterators | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m178-weighted-choice-iterators.md` | Closed for the current bar: `WeightedChoice` and `seq.chooseWeightedIter*` now expose repeated weighted const-pointer streams matching Rust `choose_weighted_iter` workflows. |
| S4-M179 accessor-weighted choice pointer iterators | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m179-accessor-weighted-choice-iterators.md` | Closed for the current bar: `seq.chooseWeightedIterBy*` now streams repeated weighted const pointers from item-derived weights, matching Rust closure-weighted `choose_weighted_iter` workflows. |
| S4-M180 index-weighted choice pointer iterators | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m180-index-weighted-choice-iterators.md` | Closed for the current bar: `seq.chooseWeightedIterByIndex*` now streams repeated weighted const pointers from index-derived weights. |
| S4-M181 sampled pointer iterators | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m181-sampled-ptr-iterators.md` | Closed for the current bar: `seq.samplePtrsIter*` now owns sampled no-replacement indexes and streams const pointers like Rust `IndexedSamples`. |
| S4-M182 sampled value iterators | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m182-sampled-value-iterators.md` | Closed for the current bar: `seq.sampleItemsIter*` now owns sampled no-replacement indexes and streams copied values, complementing Rust `IndexedSamples(...).cloned()` workflows. |
| S4-M183 sampled mutable-pointer iterators | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m183-sampled-mut-ptr-iterators.md` | Closed for the current bar: `seq.sampleMutPtrsIter*` now owns sampled no-replacement indexes and streams distinct mutable pointers. |
| S4-M184 choice count diagnostics | `src/seq.zig`, `examples/sequence_sampling.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m184-choice-numchoices.md` | Closed for the current bar: reusable `Choice` and `WeightedChoice` expose `numChoices` diagnostics matching Rust `Choose::num_choices` discoverability. |
| S4-M185 sampled iterator fill helpers | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/api-reference.md`, `compare/results/s4-m185-sampled-iterator-fill.md` | Closed for the current bar: sampled value/const-pointer/mutable-pointer iterators can now fill caller-owned buffers. |
| S4-M186 exact-size iterator length aliases | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/api-reference.md`, `compare/results/s4-m186-iterator-len-aliases.md` | Closed for the current bar: bounded `IndexVec` and sampled iterators now expose `len()` aliases matching exact-size iterator discoverability. |
| S4-M187 exact-size iterator size hints | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/api-reference.md`, `compare/results/s4-m187-iterator-size-hints.md` | Closed for the current bar: bounded `IndexVec` and sampled iterators now expose exact lower/upper `sizeHint` diagnostics matching Rust `Iterator::size_hint` discoverability. |
| S4-M188 IndexVec iterator fill helpers | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m188-indexvec-iterator-fill.md` | Closed for the current bar: bounded `IndexVec` and mapped iterators now fill caller-owned buffers while preserving exact remaining counts. |
| S4-M189 IndexVec index alias | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m189-indexvec-index-alias.md` | Closed for the current bar: `IndexVec.index` now mirrors `IndexVec.at` for Rust-discoverable positional index lookup. |
| S4-M190 IndexVec checked positional lookup | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m190-indexvec-get.md` | Closed for the current bar: `IndexVec.get` now returns optional positional lookups for checked access beyond Rust's panicking `IndexVec::index`. |
| S4-M191 optional weighted sampler weight lookup | `src/distributions.zig`, `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m191-weighted-sampler-weight.md` | Closed for the current bar: `AliasTable.weight` and `WeightedChoice.weight` now expose optional single-weight lookup matching Rust `WeightedIndex::weight` discoverability. |
| S4-M192 weighted sampler weight iterators | `src/distributions.zig`, `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m192-weight-iterators.md` | Closed for the current bar: `AliasTable.weightIter` and `WeightedChoice.weightIter` now stream reconstructed weights like Rust `WeightedIndex::weights`. |
| S4-M193 optional weighted sampler probability lookup | `src/distributions.zig`, `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m193-weighted-sampler-probability.md` | Closed for the current bar: `AliasTable.probability` and `WeightedChoice.probability` now expose optional single-probability lookup alongside `probabilityAt`. |
| S4-M194 weighted sampler probability iterators | `src/distributions.zig`, `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m194-probability-iterators.md` | Closed for the current bar: `AliasTable.probabilityIter` and `WeightedChoice.probabilityIter` now stream normalized probabilities for allocation-free diagnostics. |
| S4-M195 Choice optional probability lookup | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m195-choice-probability.md` | Closed for the current bar: `Choice.probability` now exposes null-on-missing probability lookup alongside `probabilityAt`. |
| S4-M196 Choice probability iterator | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m196-choice-probability-iterator.md` | Closed for the current bar: `Choice.probabilityIter` now streams uniform probabilities for allocation-free diagnostics. |
| S4-M197 Charset optional probability lookup | `src/ascii.zig`, `examples/string_generation.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m197-charset-probability.md` | Closed for the current bar: `Charset.probability` now exposes null-on-missing probability lookup alongside `probabilityAt`. |
| S4-M198 Charset probability iterator | `src/ascii.zig`, `examples/string_generation.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m198-charset-probability-iterator.md` | Closed for the current bar: `Charset.probabilityIter` now streams uniform probabilities for allocation-free diagnostics. |
| S4-M199 reusable choice item lookup | `src/seq.zig`, `examples/sequence_sampling.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m199-choice-get.md` | Closed for the current bar: `Choice.get` and `WeightedChoice.get` now expose null-on-missing item lookup alongside checked `itemAt`. |
| S4-M200 Charset optional item lookup | `src/ascii.zig`, `examples/string_generation.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m200-charset-get.md` | Closed for the current bar: `Charset.get` now exposes null-on-missing byte lookup alongside checked `byteAt`. |
| S4-M201 diagnostic iterator size hints | `src/distributions.zig`, `src/seq.zig`, `src/ascii.zig`, `examples/weighted_sampling.zig`, `examples/sequence_sampling.zig`, `examples/string_generation.zig`, `compare/results/s4-m201-diagnostic-iterator-sizehints.md` | Closed for the current bar: lazy weight/probability diagnostic iterators now expose exact `sizeHint` lower/upper counts. |
| S4-M202 Charset count diagnostics | `src/ascii.zig`, `examples/string_generation.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m202-charset-numchoices.md` | Closed for the current bar: `Charset.numChoices` now mirrors `len` for Rust-discoverable charset count diagnostics. |
| S4-M203 reusable choice checked item alias | `src/seq.zig`, `examples/sequence_sampling.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m203-choice-item-alias.md` | Closed for the current bar: `Choice.item` and `WeightedChoice.item` now mirror `itemAt` for Rust-discoverable checked item lookup. |
| S4-M204 Charset checked item alias | `src/ascii.zig`, `examples/string_generation.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m204-charset-item-alias.md` | Closed for the current bar: `Charset.item` now mirrors `byteAt` for checked byte lookup. |
| S4-M205 dynamic tree optional weight lookup | `src/distributions.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m205-tree-weight.md` | Closed for the current bar: `WeightedTree.weight` and `WeightedIntTree.weight` now expose null-on-missing dynamic weight lookup alongside checked `weightAt`. |
| S4-M206 dynamic tree optional probability lookup | `src/distributions.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m206-tree-probability.md` | Closed for the current bar: `WeightedTree.probability` and `WeightedIntTree.probability` now expose null-on-missing dynamic probability lookup alongside checked `probabilityAt`. |
| S4-M207 dynamic tree weight iterators | `src/distributions.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m207-tree-weight-iterators.md` | Closed for the current bar: `WeightedTree.weightIter` and `WeightedIntTree.weightIter` now stream dynamic weights with exact size hints. |
| S4-M208 dynamic tree probability iterators | `src/distributions.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m208-tree-probability-iterators.md` | Closed for the current bar: `WeightedTree.probabilityIter` and `WeightedIntTree.probabilityIter` now stream dynamic probabilities with exact size hints. |
| S4-M209 AliasTable count diagnostics | `src/distributions.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m209-aliastable-numchoices.md` | Closed for the current bar: `AliasTable.numChoices` now mirrors `len` for static alias-table count diagnostics. |
| S4-M210 dynamic tree count diagnostics | `src/distributions.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m210-tree-numchoices.md` | Closed for the current bar: `WeightedTree.numChoices` and `WeightedIntTree.numChoices` now mirror `len` for dynamic weighted-sampler count diagnostics. |
| S4-M211 dynamic tree constant-index diagnostics | `src/distributions.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m211-tree-constant-index.md` | Closed for the current bar: `WeightedTree.constantIndex` and `WeightedIntTree.constantIndex` now expose the single-positive deterministic index used by dynamic tree no-consume sampling paths. |
| S4-M212 WeightedChoice constant-index diagnostics | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m212-weightedchoice-constant-index.md` | Closed for the current bar: `WeightedChoice.constantIndex` now exposes the reusable weighted-choice single-positive deterministic index used by no-consume sampling paths. |
| S4-M213 Choice singleton constant-index diagnostics | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m213-choice-constant-index.md` | Closed for the current bar: `Choice.constantIndex` now exposes the singleton deterministic index used by reusable unweighted choice no-consume sampling paths. |
| S4-M214 Charset singleton constant-index diagnostics | `src/ascii.zig`, `examples/string_generation.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m214-charset-constant-index.md` | Closed for the current bar: `Charset.constantIndex` now exposes the singleton deterministic index used by single-byte charset no-consume sampling paths. |
| S4-M215 dynamic tree positive-count diagnostics | `src/distributions.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m215-tree-positive-count.md` | Closed for the current bar: `WeightedTree.positiveCount` and `WeightedIntTree.positiveCount` now expose the dynamic count of positive-weight choices. |
| S4-M216 AliasTable positive-count diagnostics | `src/distributions.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m216-aliastable-positive-count.md` | Closed for the current bar: `AliasTable.positiveCount` now exposes the static alias table positive-weight count. |
| S4-M217 WeightedChoice positive-count diagnostics | `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m217-weightedchoice-positive-count.md` | Closed for the current bar: `WeightedChoice.positiveCount` now exposes the reusable weighted-choice positive-weight count. |
| S4-M218 static weighted single-weight updates | `src/distributions.zig`, `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m218-weighted-update-at.md` | Closed for the current bar: `AliasTable.updateAt` and `WeightedChoice.updateAt` now refresh one static/reusable weighted-sampler weight while preserving failed-update table safety. |
| S4-M219 static weighted ordered partial updates | `src/distributions.zig`, `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m219-weighted-update-many.md` | Closed for the current bar: `AliasTable.updateMany` and `WeightedChoice.updateMany` now apply ordered partial updates while preserving failed-update table safety. |
| S4-M220 dynamic tree ordered partial updates | `src/distributions.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m220-tree-update-many.md` | Closed for the current bar: `WeightedTree.updateMany` and `WeightedIntTree.updateMany` now apply ordered dynamic partial updates while preserving failed-update tree safety. |
| S4-M221 weighted updateWeights aliases | `src/distributions.zig`, `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m221-weighted-updateweights-alias.md` | Closed for the current bar: `updateWeights` aliases now expose Rust-discoverable ordered partial-update naming across static, reusable, and dynamic weighted samplers. |
| S4-M222 IndexVec intoVec alias | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m222-indexvec-into-vec.md` | Closed for the current bar: `IndexVec.intoVec` now exposes Rust-discoverable consuming owned `[]usize` conversion naming. |
| S4-M223 Choice new aliases | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m223-choice-new-alias.md` | Closed for the current bar: `Choice.new` and `Choice.newChecked` now expose Rust-discoverable reusable-choice construction naming. |
| S4-M224 weighted new aliases | `src/distributions.zig`, `src/seq.zig`, `examples/weighted_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m224-weighted-new-alias.md` | Closed for the current bar: `AliasTable.new` and `WeightedChoice.new` now expose Rust-discoverable weighted-sampler construction naming. |
| S4-M225 Bernoulli new aliases | `src/distributions.zig`, `examples/discrete_distributions.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m225-bernoulli-new-alias.md` | Closed for the current bar: `Bernoulli.new` / `newRatio` and vector equivalents now expose Rust-discoverable Bernoulli construction naming. |
| S4-M226 Uniform new aliases | `src/distributions.zig`, `examples/range_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m226-uniform-new-alias.md` | Closed for the current bar: scalar and vector `Uniform.new` / `newInclusive` aliases now expose Rust-discoverable uniform-range construction naming. |
| S4-M227 Bernoulli fromRatio aliases | `src/distributions.zig`, `examples/discrete_distributions.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m227-bernoulli-fromratio-alias.md` | Closed for the current bar: scalar and vector `Bernoulli.fromRatio` aliases now expose Rust-discoverable ratio construction naming. |
| S4-M228 Bernoulli p alias | `src/distributions.zig`, `examples/discrete_distributions.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m228-bernoulli-p-alias.md` | Closed for the current bar: scalar and vector `Bernoulli.p` aliases now expose Rust-discoverable probability lookup naming. |
| S4-M229 Uniform sampleSingle aliases | `src/distributions.zig`, `examples/range_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m229-uniform-samplesingle-alias.md` | Closed for the current bar: distribution one-shot `sampleSingle` / `sampleSingleInclusive` aliases now expose Rust-discoverable checked uniform range naming. |
| S4-M230 Rng randomBool/randomRatio aliases | `src/rng.zig`, `examples/basic.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m230-rng-random-bool-ratio-alias.md` | Closed for the current bar: `Rng.randomBool` / `randomRatio` aliases and checked/direct variants now expose Rust-discoverable probability naming. |
| S4-M231 Rng randomRange aliases | `src/rng.zig`, `examples/range_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m231-rng-random-range-alias.md` | Closed for the current bar: `Rng.randomRange` aliases and checked/direct/inclusive variants now expose Rust-discoverable scalar range naming. |
| S4-M232 Rng sample alias | `src/rng.zig`, `examples/basic.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m232-rng-sample-alias.md` | Closed for the current bar: `Rng.sample` / `sampleFrom` aliases now expose Rust-discoverable one-shot sampler facade naming. |
| S4-M233 Rng randomValue aliases | `src/rng.zig`, `examples/basic.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m233-rng-random-value-alias.md` | Closed for the current bar: `Rng.randomValue` aliases and checked/direct variants now expose Rust-discoverable structured-value naming. |
| S4-M234 Rng raw aliases | `src/rng.zig`, `examples/basic.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m234-rng-raw-aliases.md` | Closed for the current bar: `Rng.nextU64` / `nextU32` / `fillBytes` aliases and direct variants now expose Rust-discoverable raw RNG naming. |
| S4-M235 engine raw aliases | `src/engines/*.zig`, `src/root.zig`, `examples/reproducible_streams.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m235-engine-raw-aliases.md` | Closed for the current bar: deterministic engines now expose Rust-discoverable `nextU64` / `nextU32` and byte-fill engines expose `fillBytes`. |
| S4-M236 engine seedFromU64 aliases | `src/engines/*.zig`, `src/root.zig`, `examples/reproducible_streams.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m236-engine-seedfromu64-aliases.md` | Closed for the current bar: deterministic engines now expose Rust-discoverable `seedFromU64` constructor aliases that mirror existing `u64` constructors. |
| S4-M237 engine fromSeed aliases | `src/engines/*.zig`, `src/root.zig`, `examples/reproducible_streams.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m237-engine-fromseed-aliases.md` | Closed for the current bar: deterministic engines now expose Rust-discoverable `fromSeed` aliases for Alea `Seed` values. |
| S4-M238 engine fromRng/fork aliases | `src/seed.zig`, `src/engines/*.zig`, `src/root.zig`, `examples/reproducible_streams.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m238-engine-fromrng-fork-aliases.md` | Closed for the current bar: `Seed.fromRng`, direct-engine `fromRng`, and direct-engine `fork` now expose Rust-discoverable seeded-from-RNG and fork naming. |
| S4-M239 full-state fromRng/fork seeding | `src/engines/*.zig`, `src/root.zig`, `docs/core-guide.md`, `compare/results/s4-m239-full-state-fromrng.md` | Closed for the current bar: multi-word engines now consume full state/key seed material for `fromRng` / `fork`, with focused consumption tests. |
| S4-M240 engine fromSeedBytes aliases | `src/engines/*.zig`, `src/root.zig`, `examples/reproducible_streams.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m240-engine-fromseedbytes-aliases.md` | Closed for the current bar: direct engines now expose Rust-discoverable fixed byte-array seed constructors. |
| S4-M241 engine tryFromRng aliases | `src/seed.zig`, `src/engines/*.zig`, `src/root.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m241-engine-tryfromrng-aliases.md` | Closed for the current bar: `Seed.tryFromRng` and direct-engine `tryFromRng` now expose Rust-discoverable fallible seeded-from-RNG naming. |
| S4-M242 engine tryNext/tryFork aliases | `src/engines/*.zig`, `src/rng.zig`, `src/root.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m242-engine-tryfork-aliases.md` | Closed for the current bar: direct engines and the `Rng` facade now expose Rust-discoverable try-shaped raw aliases, and engines expose `tryFork` mirroring `tryFromRng(self)`. |
| S4-M243 try raw RNG aliases | `src/rng.zig`, `src/engines/*.zig`, `src/root.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m243-try-raw-rng-aliases.md` | Closed for the current bar: facade and direct engines now expose Rust-discoverable try-shaped raw aliases. |
| S4-M244 Rng try raw From aliases | `src/rng.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m244-rng-try-raw-from-aliases.md` | Closed for the current bar: `Rng.tryNextU64From` / `tryNextU32From` / `tryFillBytesFrom` now expose direct-source try-shaped raw helpers with error propagation. |
| S4-M245 root makeRng helper | `src/root.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m245-root-makerng.md` | Closed for the current bar: root `makeRng(Engine, io)` now exposes Rust-discoverable generic system-entropy engine construction. |
| S4-M246 RngReader adapter | `src/rng.zig`, `examples/basic.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/reproducibility-matrix.md`, `compare/results/s4-m246-rng-reader.md` | Closed for the current bar: `Rng.reader` / `readerFrom` / `rngReader` now expose random byte streams through `std.Io.Reader`, with focused local-Rust-shaped byte, stream/discard, ownership, and fallible-source diagnostics tests. |
| S4-M247 SysRng system entropy source | `src/rng.zig`, `src/root.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/reproducibility-matrix.md`, `compare/results/s4-m247-sysrng.md` | Closed for the current bar: `Rng.SysRng` and root `sysRng(io)` now expose Rust-discoverable system-entropy source workflows over `std.Io.randomSecure`, with focused success and failure-propagation tests. |
| S4-M248 mapped sampler adapter | `src/distributions.zig`, `examples/range_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m248-mapped-sampler.md` | Closed for the current bar: `distributions.map` and `MappedSampler.map` now expose Rust-discoverable reusable-sampler output mapping with direct-source, fill, and iterator stream-shape tests. |
| S4-M249 unbounded iterator size hints | `src/rng.zig`, `examples/basic.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/reproducibility-matrix.md`, `compare/results/s4-m249-unbounded-iterator-sizehint.md` | Closed for the current bar: unbounded value/random/sample iterators now expose `sizeHint()` diagnostics matching local Rust iterator discoverability while preserving fill stream policy. |
| S4-M250 distribution sampleIter aliases | `src/distributions.zig`, `examples/range_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m250-distribution-sampleiter.md` | Closed for the current bar: distribution-namespace `sampleIter` / `sampleIterFrom` aliases now expose Rust-discoverable `Distribution::sample_iter` naming while delegating to existing Alea sample iterators. |
| S4-M251 SampleString aliases | `src/ascii.zig`, `examples/string_generation.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m251-samplestring-aliases.md` | Closed for the current bar: ASCII charsets now expose Rust-discoverable `sampleString` / `appendString` aliases with checked empty-charset and stream-shape coverage. |
| S4-M252 UnicodeCharset string alphabets | `src/ascii.zig`, `examples/string_generation.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/reproducibility-matrix.md`, `compare/results/s4-m252-unicode-charset.md` | Closed for the current bar: `UnicodeCharset` now exposes reusable Unicode scalar alphabets with diagnostics, checked empty/invalid validation, scalar fills, and SampleString-style UTF-8 sample/append APIs. |
| S4-M253 hinted iterator choice | `src/seq.zig`, `examples/sequence_sampling.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/reproducibility-matrix.md`, `compare/results/s4-m253-hinted-iterator-choice.md` | Closed for the current bar: `seq.chooseIteratorHinted*` now exposes local Rust `IteratorRandom::choose`-style exact-size-hint-sensitive iterator choice while existing `chooseIterator` / `chooseIteratorStable` remain stable reservoir helpers. |
| S4-M254 StdRng and SmallRng aliases | `src/root.zig`, `examples/reproducible_streams.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/reproducibility-matrix.md`, `compare/results/s4-m254-stdrng-smallrng-aliases.md` | Closed for the current bar: root `StdRng` and `SmallRng` aliases now expose local Rust `rand::rngs::StdRng` / `SmallRng` discovery names over Alea's secure-style and small fast engines. |
| S4-M255 StepRng deterministic mock source | `src/engines/step.zig`, `src/root.zig`, `examples/basic.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/reproducibility-matrix.md`, `compare/results/s4-m255-step-rng.md` | Closed for the current bar: `StepRng` now exposes local Rust-style deterministic arithmetic and constant mock streams, byte-fill shape, raw aliases, `std.Random` interop, and root `stepRng` / `constRng` helpers. |
| S4-M256 ChaCha12Rng alias | `src/root.zig`, `examples/reproducible_streams.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/reproducibility-matrix.md`, `compare/results/s4-m256-chacha12rng-alias.md` | Closed for the current bar: root `ChaCha12Rng` now exposes local Rust optional-`chacha` naming over Alea's existing `ChaCha` / `SecurePrng` engine. |
| S4-M257 ChaCha8Rng and ChaCha20Rng engines | `src/engines/chacha8.zig`, `src/engines/chacha20.zig`, `src/root.zig`, `examples/reproducible_streams.zig`, `tools/stream.zig`, `tools/statcheck.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/reproducibility-matrix.md`, `compare/results/s4-m257-chacha8-chacha20-rngs.md` | Closed for the current bar: root `ChaCha8Rng` and `ChaCha20Rng` now expose the remaining local Rust optional-`chacha` RNG names with deterministic seed/raw/fork/std.Random workflows while preserving the existing `ChaCha` / `ChaCha12Rng` / `StdRng` ChaCha12 contract. |
| S4-M258 Xoshiro128PlusPlus engine | `src/engines/xoshiro128plusplus.zig`, `src/rng.zig`, `src/root.zig`, `examples/reproducible_streams.zig`, `tools/stream.zig`, `tools/statcheck.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/reproducibility-matrix.md`, `compare/results/s4-m258-xoshiro128plusplus.md` | Closed for the current bar: root `Xoshiro128PlusPlus` now exposes local Rust's public 32-bit Xoshiro++ portable generator with reference vectors, seed/raw/fork/std.Random workflows, while preserving local 64-bit `SmallRng = Xoshiro256PlusPlus`. |
| S4-M259 root top-level random helpers | `src/root.zig`, `examples/basic.zig`, `tools/examplecheck.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m259-root-random-helpers.md` | Closed for the current bar: root explicit-I/O random/fill helpers now cover local Rust top-level `random`, `random_iter`, `random_range`, `random_bool`, `random_ratio`, and `fill` workflows without adding hidden thread-local RNG state. |
| S4-M260 SysError alias | `src/root.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m260-syserror-alias.md` | Closed for the current bar: root `SysError = SysRng.Error` now exposes local Rust `rand::rngs::SysError` discovery naming over Alea's explicit `std.Io.RandomSecureError` system-entropy error contract. |
| S4-M261 WeightError alias | `src/seq.zig`, `src/root.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m261-weighterror-alias.md` | Closed for the current bar: `seq.WeightError = seq.Error` and root `WeightError = seq.WeightError` now expose local Rust `rand::seq::WeightError` discovery naming over Alea's existing weighted-sampling error contract. |
| S4-M262 StandardUniform sampler | `src/distributions.zig`, `examples/range_sampling.zig`, `tools/examplecheck.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `docs/examples.md`, `README.md`, `compare/results/distribution-parity-matrix.md`, `compare/results/s4-m262-standard-uniform.md` | Closed for the current bar: `distributions.StandardUniform` now exposes local Rust `rand::distr::StandardUniform` discovery over Alea's existing default-value sampling semantics, with focused stream-shape tests and a range-example demonstration. |
| S4-M263 BernoulliError discovery | `src/distributions.zig`, `examples/discrete_distributions.zig`, `tools/examplecheck.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `docs/examples.md`, `README.md`, `compare/results/distribution-parity-matrix.md`, `compare/results/s4-m263-bernoulli-error.md` | Closed for the current bar: `distributions.BernoulliError` now exposes local Rust `rand::distr::BernoulliError` discovery naming, and scalar/vector Bernoulli constructors return the dedicated invalid-probability error set. |
| S4-M264 distribution ASCII aliases | `src/distributions.zig`, `examples/string_generation.zig`, `tools/examplecheck.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `docs/examples.md`, `README.md`, `compare/results/distribution-parity-matrix.md`, `compare/results/s4-m264-distribution-ascii-aliases.md` | Closed for the current bar: `distributions.Alphanumeric` and `distributions.Alphabetic` now expose local Rust `rand::distr::{Alphanumeric, Alphabetic}` discovery naming while aliasing Alea's canonical ASCII charset samplers. |
| S4-M265 WeightedIndex alias | `src/distributions.zig`, `examples/weighted_sampling.zig`, `tools/examplecheck.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `docs/examples.md`, `README.md`, `compare/results/distribution-parity-matrix.md`, `compare/results/s4-m265-weightedindex-alias.md` | Closed for the current bar: `distributions.WeightedIndex(Weight)` now exposes local Rust `rand::distr::weighted::WeightedIndex` discovery naming while aliasing Alea's existing `AliasTable(Weight)` static weighted sampler. |
| S4-M266 UniformDuration sampler | `src/distributions.zig`, `examples/range_sampling.zig`, `tools/examplecheck.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `docs/examples.md`, `README.md`, `compare/results/distribution-parity-matrix.md`, `compare/results/s4-m266-uniform-duration.md` | Closed for the current bar: `distributions.UniformDuration` now exposes local Rust `rand::distr::uniform::UniformDuration` discovery naming over Alea's existing `std.Io.Duration` range helper semantics. |
| S4-M267 Uniform Unicode scalar sampler | `src/distributions.zig`, `examples/string_generation.zig`, `tools/examplecheck.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `docs/examples.md`, `README.md`, `compare/results/distribution-parity-matrix.md`, `compare/results/s4-m267-uniform-unicode-scalar.md` | Closed for the current bar: `distributions.UniformUnicodeScalar` now exposes local Rust `rand::distr::uniform::UniformChar`-style reusable range sampling in Alea's Zig-native `u21` Unicode scalar form. |
| S4-M268 distribution Choose sampler | `src/distributions.zig`, `examples/sequence_sampling.zig`, `tools/examplecheck.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `docs/examples.md`, `README.md`, `compare/results/distribution-parity-matrix.md`, `compare/results/s4-m268-distribution-choose.md` | Closed for the current bar: `distributions.Choose(T)` now exposes local Rust `rand::distr::slice::Choose` discovery naming with Zig-native pointer/value sampling over `[]const T`. |
| S4-M269 UniformError alias | `src/distributions.zig`, `examples/range_sampling.zig`, `tools/examplecheck.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `README.md`, `compare/results/distribution-parity-matrix.md`, `compare/results/s4-m269-uniform-error.md` | Closed for the current bar: `distributions.UniformError` now exposes local Rust `rand::distr::uniform::Error` discovery naming over Alea's existing uniform-family error set. |
| S4-M270 distribution Map/Iter aliases | `src/distributions.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `README.md`, `compare/results/s4-m270-map-iter-aliases.md` | Closed for the current bar: `distributions.Map` and `distributions.Iter` now expose local Rust `rand::distr::{Map, Iter}` discovery names as aliases over Alea's existing mapped sampler and sample iterator types. |
| S4-M271 distribution weighted error aliases | `src/distributions.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `README.md`, `compare/results/distribution-parity-matrix.md`, `compare/results/s4-m271-weighted-error-aliases.md` | Closed for the current bar: `distributions.WeightError` and `distributions.WeightedError` now expose local Rust `rand::distr::weighted::Error` discovery naming over Alea's existing weighted-sampling error set. |
| S4-M272 Uniform backend discovery aliases | `src/distributions.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `README.md`, `compare/results/distribution-parity-matrix.md`, `compare/results/s4-m272-uniform-backend-aliases.md` | Closed for the current bar: `distributions.UniformInt(T)`, `UniformFloat(T)`, and `UniformUsize` now expose local Rust uniform backend discovery names while aliasing Alea's existing `Uniform(T)` sampler. |
| S4-M273 distribution slice namespace aliases | `src/distributions.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `README.md`, `compare/results/distribution-parity-matrix.md`, `compare/results/s4-m273-slice-namespace-aliases.md` | Closed for the current bar: `distributions.slice.Choose(T)` and `distributions.slice.Empty` now expose local Rust `rand::distr::slice::{Choose, Empty}` discovery naming while preserving Alea's existing `Choose(T)` sampler and error contract. |
| S4-M274 UniformChar discovery alias | `src/distributions.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `README.md`, `compare/results/distribution-parity-matrix.md`, `compare/results/s4-m274-uniform-char-alias.md` | Closed for the current bar: `distributions.UniformChar` now exposes local Rust `rand::distr::uniform::UniformChar` discovery naming while aliasing Alea's existing `UniformUnicodeScalar` reusable `u21` scalar sampler. |
| S4-M275 Uniform NonFinite error parity | `src/rng.zig`, `src/distributions.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `README.md`, `compare/results/distribution-parity-matrix.md`, `compare/results/s4-m275-uniform-nonfinite.md` | Closed for the current bar: checked scalar/vector float range and uniform paths now return `NonFinite` for non-finite endpoints or widths, matching local Rust `rand::distr::uniform::Error::NonFinite` while preserving no-consume validation. |
| S4-M276 Uniform range-constructor aliases | `src/distributions.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `README.md`, `compare/results/distribution-parity-matrix.md`, `compare/results/s4-m276-uniform-range-constructors.md` | Closed for the current bar: `Uniform(T)` and `VectorUniform(VectorType)` now expose `tryFromRange` / `tryFromRangeInclusive` aliases for local Rust `Uniform::try_from(Range)` / `RangeInclusive` discovery while preserving existing constructors. |
| S4-M277 rngs namespace aliases | `src/root.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `README.md`, `compare/results/s4-m277-rngs-namespace.md` | Closed for the current bar: root `rngs` now exposes local Rust `rand::rngs::*` discovery names over Alea's existing explicit engines and entropy source without adding hidden thread-local RNG semantics. |
| S4-M278 root RngReader aliases | `src/root.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `README.md`, `compare/results/s4-m278-root-rngreader.md` | Closed for the current bar: root `RngReader(Source)` and `rngReader(source, buffer)` now expose local Rust root `rand::RngReader` discovery while forwarding to Alea's existing explicit-buffer `Rng` adapter. |
| S4-M279 IndexedSamples aliases | `src/seq.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `README.md`, `compare/results/distribution-parity-matrix.md`, `compare/results/s4-m279-indexed-samples-aliases.md` | Closed for the current bar: `seq.IndexedSamples(T)` and `seq.SliceChooseIter(T)` now expose local Rust `rand::seq::{IndexedSamples, SliceChooseIter}` discovery naming over Alea's existing sampled pointer iterator implementation. |
| S4-M280 prelude namespace aliases | `src/root.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `README.md`, `compare/results/s4-m280-prelude-namespace.md` | Closed for the current bar: root `prelude` now exposes local Rust `rand::prelude::*` discovery naming over Alea's common modules and aliases without adding Rust trait machinery. |
| S4-M281 weighted error variant diagnostics | `src/distributions.zig`, `src/seq.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `README.md`, `compare/results/distribution-parity-matrix.md`, `compare/results/s4-m271-weighted-error-aliases.md`, `compare/results/s4-m281-weighted-error-variants.md` | Closed for the current bar: static `AliasTable` / `WeightedIndex` diagnostics now expose local Rust `rand::distr::weighted::Error` variant names for invalid input, invalid weight, insufficient non-zero weights, and overflow while preserving weighted error aliases and mapping sequence wrappers back to existing `seq.Error` outcomes. |
| S4-M282 root distr namespace alias | `src/root.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `README.md`, `compare/results/s4-m282-distr-alias.md` | Closed for the current bar: root `distr` now exposes local Rust `rand::distr::*` discovery naming while aliasing Alea's existing canonical `distributions` module. |
| S4-M283 Rust trait surface audit | `compare/results/s4-m283-rust-trait-surface-audit.md`, `compare/results/core-rand-coverage.md`, `compare/results/linux-no-known-gaps-audit.md` | Closed for the current bar: remaining local Rust public trait/marker/thread-local names are documented as covered by Zig-native APIs or intentionally not copied, with no new unblocked implementation gap identified. |
| S4-M284 distribution weighted namespace | `src/distributions.zig`, `examples/weighted_sampling.zig`, `tools/examplecheck.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `docs/examples.md`, `README.md`, `compare/results/distribution-parity-matrix.md`, `compare/results/s4-m284-weighted-namespace.md` | Closed for the current bar: `distributions.weighted` now exposes local Rust `rand::distr::weighted::*` discovery names over Alea's existing `WeightedIndex` / `AliasTable` sampler and weighted error aliases. |
| S4-M285 uniform namespace audit | `compare/results/s4-m285-uniform-namespace-audit.md`, `compare/results/core-rand-coverage.md`, `compare/results/linux-no-known-gaps-audit.md` | Closed for the current bar: local Rust `rand::distr::uniform::*` is documented as covered by top-level Alea concrete uniform APIs or intentionally not copied where the intermediate Rust namespace would collide with Alea's existing one-shot `uniform(...)` function. |
| S4-M286 `rand_core` re-export surface audit | `compare/results/s4-m286-rand-core-reexport-audit.md`, `compare/results/core-rand-coverage.md`, `compare/results/linux-no-known-gaps-audit.md` | Closed for the current bar: local Rust root `pub use rand_core` and resolved `rand_core` low-level traits/helpers are documented as covered by Alea concrete APIs or intentionally not copied as Rust implementation machinery. |
| S4-M287 sequence index namespace audit | `compare/results/s4-m287-seq-index-namespace-audit.md`, `compare/results/core-rand-coverage.md`, `compare/results/linux-no-known-gaps-audit.md` | Closed for the current bar: local Rust `rand::seq::index` is documented as covered by top-level Alea `seq.*` APIs or intentionally not copied where an intermediate `seq.index` namespace would duplicate workflows and collide with Zig identifiers. |
| S4-M288 local Rust public-surface manifest | `compare/results/s4-m288-local-rand-public-surface-manifest.md`, `compare/results/core-rand-coverage.md`, `compare/results/linux-no-known-gaps-audit.md` | Closed for the current bar: root, `rngs`, `distr`, `seq`, and resolved `rand_core` public names are mapped to Alea evidence or intentional Zig-native exclusions, with no new unblocked local Rust public-surface gap identified. |
| S4-M289 rand_distr error alias names | `src/distributions.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `README.md`, `compare/results/distribution-parity-matrix.md`, `compare/results/s4-m289-rand-distr-error-aliases.md` | Closed for the current bar: local `rand_distr::*Error` root discovery names now alias Alea's shared distribution error set while preserving Zig-native diagnostics. |
| S4-M290 rand_distr Exp aliases | `src/distributions.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `README.md`, `compare/results/distribution-parity-matrix.md`, `compare/results/s4-m290-exp-aliases.md` | Closed for the current bar: local `rand_distr::Exp` and `rand_distr::Exp1` root discovery names now alias Alea's existing `Exponential(T)` and `StandardExponential(T)` samplers. |
| S4-M291 multi Dirichlet alias | `src/distributions.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `README.md`, `compare/results/distribution-parity-matrix.md`, `compare/results/s4-m291-multi-dirichlet-alias.md` | Closed for the current bar: local `rand_distr::multi::Dirichlet` discovery now aliases Alea's existing concrete `Dirichlet(T)` sampler without copying Rust multivariate trait machinery. |
| S4-M292 rand_distr new constructor aliases | `src/distributions.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `README.md`, `compare/results/distribution-parity-matrix.md`, `compare/results/s4-m292-rand-distr-new-aliases.md` | Closed for the current bar: local `rand_distr` `new(...)` constructor discovery is available for matching scalar reusable sampler shapes, with the Geometric trial/failure semantic exception documented. |
| S4-M293 fromMeanCv constructor aliases | `src/distributions.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m293-from-mean-cv-aliases.md` | Closed for the current bar: local `rand_distr::from_mean_cv` discovery now maps to Alea `Normal(T).fromMeanCv` and `LogNormal(T).fromMeanCv` aliases over existing `initMeanCv` constructors. |
| S4-M294 local rand_distr public-surface manifest | `compare/results/s4-m294-rand-distr-public-surface-manifest.md`, `compare/results/core-rand-coverage.md`, `compare/results/linux-no-known-gaps-audit.md` | Closed for the current bar: cached local `rand_distr 0.6.0` root, `multi`, `weighted`, utility, and trait surfaces are mapped to Alea evidence or intentional Zig-native exclusions, with no new unblocked local `rand_distr` public-surface gap identified. |
| S4-M295 public-surface manifest guardrails | `tools/roadmapcheck.zig`, `compare/results/s4-m295-public-surface-manifest-guardrails.md`, `compare/results/core-rand-coverage.md`, `compare/results/linux-no-known-gaps-audit.md` | Closed for the current bar: `roadmapcheck` now verifies scanned-source, major-surface, representative exclusion, no-new-gap result, and non-completion tokens in the local Rust and `rand_distr` public-surface manifests instead of relying only on file existence. |
| S4-M296 optional local surface drift checker | `tools/surfacecheck.zig`, `build.zig`, `docs/tooling.md`, `compare/results/s4-m296-surfacecheck.md` | Closed for the current bar: `zig build surfacecheck` re-scans local Rust `rand`, resolved `rand_core`, and cached `rand_distr` public declarations/re-exports against the checked-in manifests, with explicit local path overrides and a documented `rand_distr` `#[cfg(test)]` helper exclusion. |
| S4-M297 surfacecheck multiline re-exports | `tools/surfacecheck.zig`, `compare/results/s4-m297-surfacecheck-multiline-reexports.md` | Closed for the current bar: `surfacecheck` now collects Rust multiline `pub use ... { ... };` blocks, checks aliases/names after the terminator, and detects unterminated or oversized re-export blocks while preserving test-helper exclusions. |
| S4-M298 SkewNormal parameter discovery aliases | `src/distributions.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/distribution-parity-matrix.md`, `compare/results/s4-m298-skewnormal-parameter-aliases.md` | Closed for the current bar: `SkewNormal(T)` and `VectorSkewNormal(VectorType)` now expose `locationParameter`, `scaleParameter`, and `shapeParameter` aliases over existing parameter accessors, with exact Rust method-name copying intentionally avoided because it would collide with public Zig fields. |
| S4-M299 WeightedTree is_valid manifest mapping | `compare/results/s4-m299-weighted-tree-is-valid.md`, `compare/results/s4-m294-rand-distr-public-surface-manifest.md`, `compare/results/distribution-parity-matrix.md`, `tools/surfacecheck.zig` | Closed for the current bar: local `rand_distr::WeightedTreeIndex::is_valid` is explicitly mapped to Alea `WeightedTree.isValid` / `WeightedIntTree.isValid`, and `surfacecheck` now requires the `is_valid` token in the manifest. |
| S4-M300 Normal parameter discovery aliases | `src/distributions.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/distribution-parity-matrix.md`, `compare/results/s4-m300-normal-parameter-aliases.md` | Closed for the current bar: `Normal(T)` now exposes `meanParameter`, `stddevParameter`, and `stdDevParameter` aliases over existing parameter accessors, with exact Rust method names intentionally avoided because they collide with public Zig fields. |
| S4-M301 surfacecheck impl-method scanning | `tools/surfacecheck.zig`, `compare/results/s4-m301-surfacecheck-impl-methods.md`, `compare/results/s4-m288-local-rand-public-surface-manifest.md`, `compare/results/s4-m294-rand-distr-public-surface-manifest.md` | Closed for the current bar: `surfacecheck` now scans non-test `impl`-body `pub fn` methods and the manifests explicitly map the newly exposed local helper/weighted-tree methods to existing Alea APIs or Rust-only scaffolding. |
| S4-M302 surfacecheck Bernoulli impl coverage | `tools/surfacecheck.zig`, `compare/results/s4-m302-surfacecheck-bernoulli-impl.md`, `compare/results/s4-m288-local-rand-public-surface-manifest.md` | Closed for the current bar: `surfacecheck` now scans the re-exported local `rand` Bernoulli implementation and the manifest explicitly maps `from_ratio` / `p` to Alea `fromRatio` / `p()`. |
| S4-M303 surfacecheck coverage summaries | `tools/surfacecheck.zig`, `docs/tooling.md`, `compare/results/s4-m303-surfacecheck-summary.md` | Closed for the current bar: `surfacecheck` now prints per-baseline file, expected-token, and source-token counts for local `rand`, resolved `rand_core`, and cached `rand_distr` checks. |
| S4-M304 surfacecheck token-boundary matching | `tools/surfacecheck.zig`, `compare/results/s4-m304-surfacecheck-token-boundaries.md`, `compare/results/s4-m288-local-rand-public-surface-manifest.md` | Closed for the current bar: manifest token checks now prefer exact backtick-wrapped tokens and identifier boundaries, eliminating ordinary substring false positives and forcing additional manifest mappings for previously hidden short names. |
| S4-M305 surfacecheck extra public files | `tools/surfacecheck.zig`, `compare/results/s4-m305-surfacecheck-extra-files.md`, `compare/results/s4-m294-rand-distr-public-surface-manifest.md` | Closed for the current bar: `surfacecheck` now scans local `rand/src/distr/other.rs` and cached `rand_distr/src/ziggurat_tables.rs`, covering ASCII distribution aliases and ziggurat table type names in source-driven drift checks. |
| S4-M306 surfacecheck public-file guard | `tools/surfacecheck.zig`, `docs/tooling.md`, `compare/results/s4-m306-surfacecheck-public-file-guard.md` | Closed for the current bar: `surfacecheck` now recursively reports unlisted `.rs` files with public declarations/methods under each local baseline root, with explicit ignores for private local `rand::seq` helper files. |
| S4-M307 S4-M11 blocker refresh | `compare/results/s4-m11-blocker-audit.md`, `compare/results/s4-m307-blocker-refresh.md`, `compare/results/core-rand-coverage.md` | Closed for the current bar: the blocker audit now records the current runtime command availability, green `surfacecheck` coverage, and continued lack of a new unblocked exact/default SIMD, extra runtime, or public-surface gap. |
| S4-M308 README surfacecheck guard | `tools/readmecheck.zig`, `README.md`, `compare/results/s4-m308-readme-surfacecheck-guard.md` | Closed for the current bar: README discovery checks now require `zig build surfacecheck`, keeping the local `rand` / `rand_distr` comparison guard visible in the command list. |
| S4-M309 surfacecheck token matcher tests | `tools/surfacecheck.zig`, `compare/results/s4-m309-surfacecheck-token-tests.md` | Closed for the current bar: helper tests now cover exact code-token matching, identifier-boundary matching, short-token false-positive rejection, and non-identifier fallback behavior. |
| S4-M310 surfacecheck build-step tests | `build.zig`, `docs/tooling.md`, `tools/surfacecheck.zig`, `compare/results/s4-m310-surfacecheck-build-tests.md` | Closed for the current bar: `zig build surfacecheck` now runs `tools/surfacecheck.zig` unit tests before the local public-surface checker executable. |
| S4-M311 toolingcheck surfacecheck dependency guard | `tools/toolingcheck.zig`, `docs/tooling.md`, `compare/results/s4-m311-toolingcheck-surfacecheck-deps.md` | Closed for the current bar: `toolingcheck` now enforces both `surfacecheck` dependencies, keeping helper tests wired before the drift scan. |
| S4-M312 surfacecheck public-file guard tests | `tools/surfacecheck.zig`, `compare/results/s4-m312-surfacecheck-public-file-tests.md` | Closed for the current bar: helper tests now cover listed files, ignored private helper files, public-looking declarations/methods, `pub(crate)` non-public helpers, and comment-only lines. |
| S4-M313 surfacecheck HOME-relative roots | `tools/surfacecheck.zig`, `docs/tooling.md`, `compare/results/s4-m313-surfacecheck-home-roots.md` | Closed for the current bar: `surfacecheck` now resolves default local baseline roots relative to `$HOME` while preserving explicit `ALEA_RAND_ROOT`, `ALEA_RAND_CORE_ROOT`, and `ALEA_RAND_DISTR_ROOT` overrides. |
| S4-M314 surfacecheck root resolution tests | `tools/surfacecheck.zig`, `compare/results/s4-m314-surfacecheck-root-tests.md` | Closed for the current bar: helper tests now cover `$HOME` suffix resolution, no-HOME fallback, and no-suffix fallback for surfacecheck default roots. |
| S4-M315 roadmapcheck surface blocker tokens | `tools/roadmapcheck.zig`, `compare/results/s4-m11-blocker-audit.md`, `compare/results/s4-m315-roadmapcheck-surface-blocker.md` | Closed for the current bar: `roadmapcheck` now requires the S4-M11 blocker audit to keep current surfacecheck/no-public-gap evidence alongside SIMD/runtime blocker evidence. |
| S4-M316 surfacecheck ignored-file guard | `tools/surfacecheck.zig`, `compare/results/s4-m316-surfacecheck-ignore-guard.md` | Closed for the current bar: `surfacecheck` now validates explicitly ignored public-looking helper files still exist and still look public, preventing stale ignores from masking source-list drift. |
| S4-M317 validate-local aggregate | `build.zig`, `docs/tooling.md`, `README.md`, `compare/results/s4-m317-validate-local.md` | Closed for the current bar: `zig build validate-local` now runs native validation plus the local public-surface drift checker, and discovery/dependency guards cover the new aggregate. |
| S4-M318 validate-local evidence normalization | `compare/results/s4-m317-validate-local.md`, `compare/results/s4-m318-validate-local-evidence.md` | Closed for the current bar: S4-M317 evidence now separates the generic `zig build validate-local` feature command from the actual `zig build -Doptimize=ReleaseFast validate-local` validation run. |
| S4-M319 roadmapcheck validate-local blocker token | `tools/roadmapcheck.zig`, `compare/results/s4-m11-blocker-audit.md`, `compare/results/s4-m319-roadmapcheck-validate-local-blocker.md` | Closed for the current bar: S4-M11 blocker evidence now keeps `zig build validate-local` visible, and `roadmapcheck` requires that token alongside surfacecheck/no-public-gap evidence. |
| S4-M320 current-rule validate-local guidance | `compare/results/core-rand-coverage.md`, `tools/roadmapcheck.zig`, `compare/results/s4-m320-current-rule-validate-local.md` | Closed for the current bar: the Current Rule now directs local `rand` / `rand_distr` comparison or public-surface evidence changes to use `zig build validate-local`, and `roadmapcheck` guards that token. |
| S4-M321 runtime runner availability checker | `tools/runtimecheck.zig`, `build.zig`, `docs/tooling.md`, `compare/results/s4-m321-runtimecheck.md` | Closed for the current bar: `zig build runtimecheck` automates the S4-M11 runner-availability branch, is wired into `validate-local`, and fails if a new QEMU/Wine/wasmtime/wasmer opportunity runner appears. |
| S4-M322 runtimecheck helper tests | `tools/runtimecheck.zig`, `build.zig`, `docs/tooling.md`, `compare/results/s4-m322-runtimecheck-tests.md` | Closed for the current bar: runtimecheck helper tests cover PATH discovery and missing/non-executable entries, and `zig build runtimecheck` runs those tests before the executable check. |
| S4-M323 roadmapcheck runtimecheck OK token | `tools/roadmapcheck.zig`, `compare/results/s4-m11-blocker-audit.md`, `compare/results/s4-m323-roadmapcheck-runtime-ok.md` | Closed for the current bar: `roadmapcheck` now requires the S4-M11 blocker audit to keep the current `runtimecheck ok: no additional runtime runner available` conclusion. |
| S4-M324 validate-local runtime evidence sync | `compare/results/s4-m317-validate-local.md`, `compare/results/s4-m324-validate-local-runtime-evidence.md` | Closed for the current bar: the original `validate-local` evidence now lists `runtimecheck` as part of the aggregate and notes that `toolingcheck` verifies all three dependencies. |
| S4-M325 runtimecheck decision tests | `tools/runtimecheck.zig`, `compare/results/s4-m325-runtimecheck-decision-tests.md` | Closed for the current bar: runtimecheck now tests final decision outcomes for pass, missing required tools, opportunity runners, and missing-required priority. |
| S4-M326 runtimecheck runner-set docs | `docs/tooling.md`, `tools/toolingcheck.zig`, `compare/results/s4-m326-runtimecheck-docs.md` | Closed for the current bar: tooling docs now list runtimecheck's required and opportunity runner sets, and toolingcheck guards those tokens. |
| S4-M327 runtimecheck summary counts | `tools/runtimecheck.zig`, `compare/results/s4-m11-blocker-audit.md`, `compare/results/s4-m327-runtimecheck-summary.md` | Closed for the current bar: runtimecheck now prints required/opportunity summary counts, and S4-M11 blocker evidence plus roadmapcheck require the current no-extra-runner summary. |
| S4-M328 runtimecheck documentation token guard | `tools/toolingcheck.zig`, `docs/tooling.md`, `compare/results/s4-m328-runtimecheck-doc-token-guard.md` | Closed for the current bar: toolingcheck now requires docs/tooling to keep the full runtimecheck required/opportunity runner set visible. |
| S4-M329 runtimecheck evidence sync | `compare/results/s4-m321-runtimecheck.md`, `compare/results/s4-m329-runtimecheck-evidence-sync.md` | Closed for the current bar: the original runtimecheck evidence now includes the summary-count output added in S4-M327. |
| S4-M330 core-guide runtimecheck runner list | `docs/core-guide.md`, `compare/results/s4-m330-core-guide-runtimecheck.md` | Closed for the current bar: the core guide now names runtimecheck's required tools and exact S4-M11 opportunity runner set. |
| S4-M331 runtimecheck empty PATH segment test | `tools/runtimecheck.zig`, `compare/results/s4-m331-runtimecheck-empty-path.md` | Closed for the current bar: runtimecheck now tests that empty PATH segments normalize to the current directory while non-empty segments are preserved. |
| S4-M332 README validate-local prose | `README.md`, `tools/readmecheck.zig`, `compare/results/s4-m332-readme-validate-local-prose.md` | Closed for the current bar: README now explains `validate-local` as the Linux-first local comparison aggregate and readmecheck guards that prose. |
| S4-M333 runtimecheck static QEMU names | `tools/runtimecheck.zig`, `docs/tooling.md`, `docs/core-guide.md`, `compare/results/s4-m333-runtimecheck-static-qemu.md` | Closed for the current bar: runtimecheck now treats `qemu-aarch64-static`, `qemu-riscv64-static`, and `qemu-x86_64-static` as opportunity runners, and docs/evidence reflect ten current opportunity names. |
| S4-M334 example aggregate validation guard | `tools/examplecheck.zig`, `docs/examples.md`, `docs/tooling.md`, `compare/results/s4-m334-example-aggregate-guard.md` | Closed for the current bar: `examplecheck` now verifies that every cataloged runnable example remains included in aggregate `zig build examples`, keeping adoption examples in the `validate` path. |
| S4-M335 validate aggregate dependency guard | `tools/toolingcheck.zig`, `docs/tooling.md`, `compare/results/s4-m335-validate-dependency-guard.md` | Closed for the current bar: `toolingcheck` now verifies the full current `zig build validate` dependency set, keeping tests, examples, docs, statcheck, distcheck, libc distcheck, and accepted-profile checks wired. |
| S4-M336 validate-all aggregate dependency guard | `tools/toolingcheck.zig`, `docs/tooling.md`, `compare/results/s4-m336-validate-all-dependency-guard.md` | Closed for the current bar: `toolingcheck` now verifies the full current `zig build validate-all` dependency set, keeping native validation, crosscheck, test-wasi, and wasi-report wired. |
| S4-M337 WASI report chain dependency guard | `tools/toolingcheck.zig`, `docs/tooling.md`, `compare/results/s4-m337-wasi-report-chain-guard.md` | Closed for the current bar: `toolingcheck` now verifies the current `zig build wasi-report` dependency chain from repro through statcheck, distcheck, profilecheck, tail, stress, and long-profile checks, plus the no-Node failure path. |
| S4-M338 README validate-all prose | `README.md`, `tools/readmecheck.zig`, `compare/results/s4-m338-readme-validate-all-prose.md` | Closed for the current bar: README now explains `validate-all` as the portability-sensitive aggregate for native validation plus cross-target compile checks, WASI unit tests, and the chained WASI report, and readmecheck guards that prose. |
| S4-M339 core-guide validation aggregate prose | `docs/core-guide.md`, `tools/toolingcheck.zig`, `compare/results/s4-m339-core-guide-validation-prose.md` | Closed for the current bar: the core guide now explains when to use `validate`, `validate-local`, and `validate-all`, and toolingcheck guards the guidance tokens. |
| S4-M340 API reference validation aggregate prose | `docs/api-reference.md`, `tools/toolingcheck.zig`, `compare/results/s4-m340-api-reference-validation-prose.md` | Closed for the current bar: the API reference now explains when API-related work should use `validate`, `validate-local`, or `validate-all`, and toolingcheck guards the guidance tokens. |
| S4-M341 active completion criteria guard | `tools/roadmapcheck.zig`, `compare/results/active-goal-completion-audit.md`, `compare/results/s4-m341-active-completion-criteria-guard.md` | Closed for the current bar: `roadmapcheck` now verifies that this active audit keeps the concrete required-next-work criteria for whole-goal completion visible. |
| S4-M342 roadmap current-rule guard | `tools/roadmapcheck.zig`, `compare/results/core-rand-coverage.md`, `compare/results/s4-m342-current-rule-guard.md` | Closed for the current bar: `roadmapcheck` now verifies the living Current Rule's validation and prioritization guidance, including unblocked work, blocker evidence, local comparison checks, statcheck, stream validation, and deferred micro-optimization. |
| S4-M343 long-term product track guard | `tools/roadmapcheck.zig`, `compare/results/core-rand-coverage.md`, `compare/results/s4-m343-long-term-track-guard.md` | Closed for the current bar: `roadmapcheck` now verifies that the roadmap keeps long-term product tracks and non-completion framing visible after stage milestones close. |
| S4-M344 roadmapcheck helper tests | `tools/roadmapcheck.zig`, `build.zig`, `tools/toolingcheck.zig`, `docs/tooling.md`, `compare/results/s4-m344-roadmapcheck-helper-tests.md` | Closed for the current bar: `roadmapcheck` now runs focused helper tests before its executable audit, and `toolingcheck` guards that dependency shape. |
| S4-M345 toolingcheck helper tests | `tools/toolingcheck.zig`, `build.zig`, `docs/tooling.md`, `compare/results/s4-m345-toolingcheck-helper-tests.md` | Closed for the current bar: `toolingcheck` now runs focused helper tests before its executable audit, and guards that dependency shape itself. |
| S4-M346 apicheck helper tests | `tools/apicheck.zig`, `build.zig`, `tools/toolingcheck.zig`, `docs/tooling.md`, `compare/results/s4-m346-apicheck-helper-tests.md` | Closed for the current bar: `apicheck` now runs focused helper tests before its executable audit, and `toolingcheck` guards that dependency shape. |
| S4-M347 examplecheck helper tests | `tools/examplecheck.zig`, `build.zig`, `tools/toolingcheck.zig`, `docs/tooling.md`, `compare/results/s4-m347-examplecheck-helper-tests.md` | Closed for the current bar: `examplecheck` now runs focused helper tests before its executable audit, and `toolingcheck` guards that dependency shape. |
| S4-M348 readmecheck helper tests | `tools/readmecheck.zig`, `build.zig`, `tools/toolingcheck.zig`, `docs/tooling.md`, `compare/results/s4-m348-readmecheck-helper-tests.md` | Closed for the current bar: `readmecheck` now runs focused helper tests before its executable audit, and `toolingcheck` guards that dependency shape. |
| S4-M349 statcheck helper tests | `tools/statcheck.zig`, `build.zig`, `tools/toolingcheck.zig`, `docs/tooling.md`, `compare/results/s4-m349-statcheck-helper-tests.md` | Closed for the current bar: `statcheck` now runs focused helper tests before its executable smoke checks, and `toolingcheck` guards that dependency shape. |
| S4-M350 distcheck helper tests | `tools/distcheck.zig`, `build.zig`, `tools/toolingcheck.zig`, `docs/tooling.md`, `compare/results/s4-m350-distcheck-helper-tests.md` | Closed for the current bar: `distcheck` and `distcheck-libc` now run focused helper tests before their executable distribution audits, and `toolingcheck` guards that dependency shape. |
| S4-M351 profilecheck helper tests | `tools/profilecheck.zig`, `build.zig`, `tools/toolingcheck.zig`, `docs/tooling.md`, `compare/results/s4-m351-profilecheck-helper-tests.md` | Closed for the current bar: `profilecheck` now runs focused helper tests before its executable vector-profile audit, and `toolingcheck` guards that dependency shape. |
| S4-M352 profiletailcheck helper tests | `tools/profiletailcheck.zig`, `build.zig`, `tools/toolingcheck.zig`, `docs/tooling.md`, `compare/results/s4-m352-profiletailcheck-helper-tests.md` | Closed for the current bar: `profilecheck-tail` now runs focused helper tests before its executable tail audit, and `toolingcheck` guards that dependency shape. |
| S4-M353 profilestresscheck helper tests | `tools/profilestresscheck.zig`, `build.zig`, `tools/toolingcheck.zig`, `docs/tooling.md`, `compare/results/s4-m353-profilestresscheck-helper-tests.md` | Closed for the current bar: `profilecheck-stress` now runs focused helper tests before its executable stress audit, duplicate exponential aggregate-count accumulation was removed, and `toolingcheck` guards the dependency shape. |
| S4-M354 profilelongcheck helper tests | `tools/profilelongcheck.zig`, `build.zig`, `tools/toolingcheck.zig`, `docs/tooling.md`, `compare/results/s4-m354-profilelongcheck-helper-tests.md` | Closed for the current bar: `profilecheck-long` now runs focused helper tests before its executable long-sweep audit, and `toolingcheck` guards that dependency shape. |
| S4-M355 stream helper tests | `tools/stream.zig`, `build.zig`, `tools/toolingcheck.zig`, `docs/tooling.md`, `compare/results/s4-m355-stream-helper-tests.md` | Closed for the current bar: `stream` now runs focused helper tests before writing raw RNG bytes, and `toolingcheck` guards that dependency shape. |
| S4-M356 repro helper tests | `tools/repro.zig`, `build.zig`, `tools/toolingcheck.zig`, `docs/tooling.md`, `compare/results/s4-m356-repro-helper-tests.md` | Closed for the current bar: `repro` now runs focused helper tests before printing deterministic snapshots, and `toolingcheck` guards that dependency shape. |
| S4-M357 PractRand wrapper dry-run | `tools/practrand.sh`, `tools/toolingcheck.zig`, `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, `docs/tooling.md`, `compare/results/s4-m357-practrand-dry-run.md` | Closed for the current bar: PractRand wrapper dry-run and custom binary support are documented and guarded, allowing pipeline validation even when PractRand is unavailable. |
| S4-M358 PractRand dry-run build step | `build.zig`, `tools/toolingcheck.zig`, `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, `docs/tooling.md`, `compare/results/s4-m358-practrand-dry-run-step.md` | Closed for the current bar: `zig build practrand-dry-run` now exposes PractRand pipeline validation through the build graph, and toolingcheck guards it. |
| S4-M359 README PractRand dry-run guard | `tools/readmecheck.zig`, `README.md`, `compare/results/s4-m359-readme-practrand-dry-run-guard.md` | Closed for the current bar: `readmecheck` now guards README PractRand dry-run, build-step, and custom-binary guidance. |
| S4-M360 guide/API PractRand dry-run guards | `tools/toolingcheck.zig`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m360-guide-api-practrand-guards.md` | Closed for the current bar: `toolingcheck` now guards PractRand dry-run discovery in the core guide and API reference. |
| S4-M361 shell tool executable-bit guard | `tools/toolingcheck.zig`, `docs/tooling.md`, `compare/results/s4-m361-shell-tool-executable-guard.md` | Closed for the current bar: `toolingcheck` now ensures checked-in `.sh` tools remain executable and covers shell-tool detection with focused tests. |
| S4-M362 WASI runner dry-run | `tools/run_wasi_test.js`, `tools/toolingcheck.zig`, `docs/tooling.md`, `docs/api-reference.md`, `compare/results/s4-m362-wasi-runner-dry-run.md` | Closed for the current bar: the Node WASI runner now has a dry-run mode for argument validation, and toolingcheck guards its support tokens. |
| S4-M363 WASI dry-run build step | `build.zig`, `tools/toolingcheck.zig`, `README.md`, `docs/api-reference.md`, `docs/tooling.md`, `compare/results/s4-m363-wasi-dry-run-step.md` | Closed for the current bar: `zig build wasi-dry-run` now exposes Node WASI argv validation through the build graph, and toolingcheck guards it. |
| S4-M364 README WASI dry-run guard | `tools/readmecheck.zig`, `README.md`, `compare/results/s4-m364-readme-wasi-dry-run-guard.md` | Closed for the current bar: `readmecheck` now guards README discovery of `zig build wasi-dry-run`. |
| S4-M365 core-guide WASI dry-run guidance | `docs/core-guide.md`, `tools/toolingcheck.zig`, `compare/results/s4-m365-core-guide-wasi-dry-run.md` | Closed for the current bar: the core guide now documents WASI dry-run command usage, and toolingcheck guards the tokens. |
| S4-M366 README WASI dry-run prose | `README.md`, `tools/readmecheck.zig`, `compare/results/s4-m366-readme-wasi-dry-run-prose.md` | Closed for the current bar: README now explains `wasi-dry-run` usage, and readmecheck guards the prose. |
| S4-M367 tooling WASI dry-run prose guard | `tools/toolingcheck.zig`, `docs/tooling.md`, `compare/results/s4-m367-tooling-wasi-dry-run-prose.md` | Closed for the current bar: `toolingcheck` now guards the tooling catalog's WASI dry-run prose. |
| S4-M368 API reference WASI dry-run prose | `docs/api-reference.md`, `tools/toolingcheck.zig`, `compare/results/s4-m368-api-wasi-dry-run-prose.md` | Closed for the current bar: the API reference now explains WASI dry-run usage, and toolingcheck guards the prose. |
| S4-M369 crosscheck target guard | `build.zig`, `docs/tooling.md`, `tools/toolingcheck.zig`, `compare/results/s4-m369-crosscheck-target-guard.md` | Closed for the current bar: exact crosscheck target names are documented and guarded in build/tooling checks. |
| S4-M370 README crosscheck target prose | `README.md`, `tools/readmecheck.zig`, `compare/results/s4-m370-readme-crosscheck-targets.md` | Closed for the current bar: README now documents the exact crosscheck target set and readmecheck guards it. |
| S4-M371 crosscheck wasm32 usize fix | `src/seq.zig`, `compare/results/s4-m371-crosscheck-wasm32-usize.md` | Closed for the current bar: width-sensitive `u32.max + 1` tests are gated to targets where `usize` can represent them, and `zig build crosscheck` passes. |
| S4-M372 validate-all after crosscheck fix | `compare/results/s4-m372-validate-all-after-crosscheck.md` | Closed for the current bar: after S4-M371, `zig build validate-all` passes across native validation, crosscheck, test-wasi, and wasi-report. |
| S4-M373 validate-local refresh | `compare/results/s4-m373-validate-local-refresh.md` | Closed for the current bar: `zig build validate-local` passes after recent tooling and portability changes, including native validation, surfacecheck, and runtimecheck. |
| S4-M374 API reference crosscheck target prose | `docs/api-reference.md`, `tools/toolingcheck.zig`, `compare/results/s4-m374-api-crosscheck-targets.md` | Closed for the current bar: API reference crosscheck target set and no-execute guidance are documented and guarded. |
| S4-M375 core-guide crosscheck target prose | `docs/core-guide.md`, `tools/toolingcheck.zig`, `compare/results/s4-m375-core-guide-crosscheck-targets.md` | Closed for the current bar: the core guide now documents the exact crosscheck target set, and toolingcheck guards it. |
| S4-M376 WASI runner file-input guard | `build.zig`, `tools/toolingcheck.zig`, `docs/tooling.md`, `compare/results/s4-m376-wasi-runner-file-input-guard.md` | Closed for the current bar: `toolingcheck` now guards `tools/run_wasi_test.js` file inputs for WASI build steps. |
| S4-M377 vectorbench filter-only arguments | `bench/vector.zig`, `build.zig`, `tools/toolingcheck.zig`, `docs/tooling.md`, `compare/results/s4-m377-vectorbench-filter-args.md` | Closed for the current bar: vectorbench now supports filter-only arguments, helper tests run before the executable, and toolingcheck guards that shape. |
| S4-M378 bench parser helper tests | `bench/throughput.zig`, `build.zig`, `tools/toolingcheck.zig`, `docs/tooling.md`, `compare/results/s4-m378-bench-parser-tests.md` | Closed for the current bar: main throughput bench argument parsing is helper-tested and `zig build bench` runs tests before the executable. |
| S4-M379 bench-libc parser helper tests | `build.zig`, `tools/toolingcheck.zig`, `docs/tooling.md`, `compare/results/s4-m379-bench-libc-parser-tests.md` | Closed for the current bar: `bench-libc` now runs libc-linked throughput parser helper tests before the executable, and toolingcheck guards it. |
| S4-M380 Rust comparison bench parser tests | `compare/rand_bench/src/main.rs`, `build.zig`, `tools/toolingcheck.zig`, `tools/readmecheck.zig`, `docs/tooling.md`, `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m380-rand-bench-parser-tests.md` | Closed for the current bar: local Rust comparison benchmark argument parsing is helper-tested and guarded through `zig build rand-bench-test` / `validate-local`. |
| S4-M381 Rust comparison bench smoke step | `tools/rand_bench_smoke.sh`, `build.zig`, `tools/toolingcheck.zig`, `tools/readmecheck.zig`, `docs/tooling.md`, `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m381-rand-bench-smoke.md` | Closed for the current bar: local Rust comparison benchmark filtering is smoke-tested through `zig build rand-bench-smoke` / `validate-local`. |
| S4-M382 Rust bench smoke dry-run | `tools/rand_bench_smoke.sh`, `build.zig`, `tools/toolingcheck.zig`, `tools/readmecheck.zig`, `docs/tooling.md`, `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m382-rand-bench-smoke-dry-run.md` | Closed for the current bar: Rust comparison smoke command shape can be previewed through `zig build rand-bench-smoke-dry-run` without running cargo. |
| S4-M383 Rust bench smoke self-tests | `tools/rand_bench_smoke.sh`, `build.zig`, `tools/toolingcheck.zig`, `tools/readmecheck.zig`, `docs/tooling.md`, `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m383-rand-bench-smoke-self-test.md` | Closed for the current bar: Rust comparison smoke wrapper dry-run argument parsing is self-tested through `zig build rand-bench-smoke-self-test` and included in `validate-local`. |
| S4-M384 Rust bench smoke env overrides | `tools/rand_bench_smoke.sh`, `tools/toolingcheck.zig`, `tools/readmecheck.zig`, `docs/tooling.md`, `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m384-rand-bench-smoke-env-overrides.md` | Closed for the current bar: smoke wrapper manifest/expected-row overrides are self-tested and documented. |
| S4-M385 S4-M11 benchmark-gate blocker evidence | `compare/results/s4-m11-blocker-audit.md`, `tools/roadmapcheck.zig`, `compare/results/s4-m385-blocker-benchmark-gates.md` | Closed for the current bar: S4-M11 blocker evidence and roadmapcheck now retain the Rust comparison benchmark gates that participate in `validate-local`. |
| S4-M386 PractRand wrapper self-tests | `tools/practrand.sh`, `build.zig`, `tools/toolingcheck.zig`, `tools/readmecheck.zig`, `docs/tooling.md`, `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m386-practrand-self-test.md` | Closed for the current bar: PractRand wrapper dry-run command construction is self-tested without `RNG_test`. |
| S4-M387 WASI runner self-tests | `tools/run_wasi_test.js`, `build.zig`, `tools/toolingcheck.zig`, `tools/readmecheck.zig`, `docs/tooling.md`, `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m387-wasi-runner-self-test.md` | Closed for the current bar: Node WASI runner dry-run/missing-argument paths are self-tested without wasm. |
| S4-M388 validate-all WASI dry/self-test aggregate | `build.zig`, `tools/toolingcheck.zig`, `docs/tooling.md`, `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m388-validate-all-wasi-self-test.md` | Closed for the current bar: `validate-all` now includes `wasi-dry-run` and `wasi-self-test`, and docs/checkers guard the expanded aggregate. |
| S4-M389 validate-all refresh after WASI aggregate expansion | `zig build validate-all`, `compare/results/s4-m389-validate-all-refresh.md` | Closed for the current bar: expanded `validate-all` passed after adding `wasi-dry-run` and `wasi-self-test`. |
| S4-M390 PractRand wrapper file-input guard | `build.zig`, `tools/toolingcheck.zig`, `docs/tooling.md`, `compare/results/s4-m390-practrand-file-input-guard.md` | Closed for the current bar: PractRand dry-run/self-test build steps now track `tools/practrand.sh` as an input and toolingcheck guards it. |
| S4-M391 validate PractRand wrapper self-test | `build.zig`, `tools/toolingcheck.zig`, `docs/tooling.md`, `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, `compare/results/s4-m391-validate-practrand-self-test.md` | Closed for the current bar: native `validate` now runs `practrand-self-test`, and docs/checkers guard it. |
| S4-M392 validate refresh after PractRand self-test | `zig build validate`, `compare/results/s4-m392-validate-practrand-refresh.md` | Closed for the current bar: native `validate` passes with `practrand-self-test` included. |
| S4-M393 validation build-step description guard | `build.zig`, `tools/toolingcheck.zig`, `compare/results/s4-m393-validation-description-guard.md` | Closed for the current bar: validation aggregate build descriptions match their current dependency scope and toolingcheck guards them. |
| S4-M394 test-step doccheck description guard | `docs/tooling.md`, `tools/toolingcheck.zig`, `compare/results/s4-m394-test-doccheck-description.md` | Closed for the current bar: tooling docs and toolingcheck now reflect that `zig build test` runs full doccheck. |
| S4-M395 validate-all tooling row precision | `docs/tooling.md`, `tools/toolingcheck.zig`, `compare/results/s4-m395-validate-all-tooling-row.md` | Closed for the current bar: validate-all tooling row now names WASI unit execution, dry/self tests, and report chain, and toolingcheck guards it. |
| S4-M396 README validate PractRand prose guard | `README.md`, `tools/readmecheck.zig`, `compare/results/s4-m396-readme-validate-practrand-guard.md` | Closed for the current bar: readmecheck guards README prose that `validate` includes the no-external PractRand wrapper self-test. |
| S4-M397 API validate PractRand prose guard | `docs/api-reference.md`, `tools/toolingcheck.zig`, `compare/results/s4-m397-api-validate-practrand-guard.md` | Closed for the current bar: toolingcheck guards API prose that `validate` includes no-external PractRand wrapper validation. |
| S4-M398 validate tooling row precision | `docs/tooling.md`, `tools/toolingcheck.zig`, `compare/results/s4-m398-validate-tooling-row.md` | Closed for the current bar: toolingcheck guards the precise `zig build validate` table-row scope. |
| S4-M399 README validate-local smoke guard | `README.md`, `tools/readmecheck.zig`, `compare/results/s4-m399-readme-validate-local-smoke-guard.md` | Closed for the current bar: readmecheck guards README validate-local prose for smoke/self-test plus surface/runtime checks. |
| S4-M400 wrapper self-test temp-file safety | `tools/practrand.sh`, `tools/rand_bench_smoke.sh`, `tools/toolingcheck.zig`, `compare/results/s4-m400-wrapper-self-test-tempfiles.md` | Closed for the current bar: wrapper self-tests use `mktemp` and trap cleanup, and toolingcheck guards it. |
| S4-M401 Rust bench smoke self-test usage | `tools/rand_bench_smoke.sh`, `tools/toolingcheck.zig`, `compare/results/s4-m401-rand-bench-smoke-self-test-usage.md` | Closed for the current bar: smoke wrapper help now documents `--self-test` and toolingcheck guards it. |
| S4-M402 PractRand self-test usage prose | `tools/practrand.sh`, `tools/toolingcheck.zig`, `compare/results/s4-m402-practrand-self-test-usage.md` | Closed for the current bar: PractRand wrapper help now explains no-`RNG_test` self-test semantics and toolingcheck guards it. |
| S4-M403 WASI self-test usage prose | `tools/run_wasi_test.js`, `tools/toolingcheck.zig`, `compare/results/s4-m403-wasi-self-test-usage.md` | Closed for the current bar: WASI runner help explains no-wasm `--self-test` semantics and toolingcheck guards it. |
| S4-M404 README WASI self-test prose guard | `README.md`, `tools/readmecheck.zig`, `compare/results/s4-m404-readme-wasi-self-test-guard.md` | Closed for the current bar: readmecheck guards README prose for no-wasm WASI runner self-test semantics. |
| S4-M405 guide/API WASI self-test prose guards | `docs/core-guide.md`, `docs/api-reference.md`, `tools/toolingcheck.zig`, `compare/results/s4-m405-guide-api-wasi-self-test-guards.md` | Closed for the current bar: toolingcheck guards core-guide/API prose for no-wasm WASI runner self-test semantics. |
| S4-M406 tooling WASI self-test prose guard | `docs/tooling.md`, `tools/toolingcheck.zig`, `compare/results/s4-m406-tooling-wasi-self-test-guard.md` | Closed for the current bar: toolingcheck guards tooling catalog prose for no-wasm WASI runner self-test semantics. |
| S4-M407 tooling WASI runner tool-row self-test semantics | `docs/tooling.md`, `tools/toolingcheck.zig`, `compare/results/s4-m407-tooling-wasi-runner-row.md` | Closed for the current bar: toolingcheck guards the checked-tool row for no-wasm WASI runner self-test semantics. |
| S4-M408 atomic tooling WASI runner row guard | `docs/tooling.md`, `tools/toolingcheck.zig`, `compare/results/s4-m408-tooling-wasi-runner-row-atomic.md` | Closed for the current bar: toolingcheck requires the full checked-tool row for no-wasm WASI runner self-test semantics. |
| S4-M409 README direct WASI self-test command | `README.md`, `tools/readmecheck.zig`, `compare/results/s4-m409-readme-direct-wasi-self-test.md` | Closed for the current bar: README lists and explains direct `node tools/run_wasi_test.js --self-test` runner validation. |
| S4-M410 README direct WASI dry-run command | `README.md`, `tools/readmecheck.zig`, `compare/results/s4-m410-readme-direct-wasi-dry-run.md` | Closed for the current bar: README lists and explains direct `node tools/run_wasi_test.js --dry-run <test.wasm>` runner argv validation. |
| S4-M411 WASI runner dry-run help prose | `tools/run_wasi_test.js`, `tools/toolingcheck.zig`, `compare/results/s4-m411-wasi-dry-run-help.md` | Closed for the current bar: WASI runner help explains no-wasm `--dry-run` semantics and toolingcheck guards it. |
| S4-M412 WASI runner help self-test coverage | `tools/run_wasi_test.js`, `tools/toolingcheck.zig`, `compare/results/s4-m412-wasi-help-self-test.md` | Closed for the current bar: WASI runner self-test validates help output keeps no-wasm dry-run/self-test semantics. |
| S4-M413 validate-all refresh after WASI runner help self-test | `compare/results/s4-m413-validate-all-after-wasi-help.md` | Closed for the current bar: full `zig build validate-all` passed after WASI runner help/self-test changes. |
| S4-M414 tooling row for WASI help self-test | `docs/tooling.md`, `tools/toolingcheck.zig`, `compare/results/s4-m414-tooling-wasi-help-self-test.md` | Closed for the current bar: tooling catalog now states and guards that `wasi-self-test` covers help output. |
| S4-M415 README WASI help-output self-test prose | `README.md`, `tools/readmecheck.zig`, `compare/results/s4-m415-readme-wasi-help-self-test.md` | Closed for the current bar: README now states and guards that `wasi-self-test` covers help output. |
| S4-M416 guide/API WASI help-output self-test prose | `docs/core-guide.md`, `docs/api-reference.md`, `tools/toolingcheck.zig`, `compare/results/s4-m416-guide-api-wasi-help-self-test.md` | Closed for the current bar: core guide/API now state and guard that `wasi-self-test` covers help output. |
| S4-M417 validate refresh after WASI help-output docs | `compare/results/s4-m417-validate-after-wasi-help-docs.md` | Closed for the current bar: broad native `zig build validate` passed after WASI help-output documentation/guard updates. |
| S4-M418 validate-local refresh after WASI help-output docs | `compare/results/s4-m418-validate-local-after-wasi-help-docs.md` | Closed for the current bar: `zig build validate-local` passed after WASI help-output docs/guard updates. |
| S4-M419 S4-M11 validate-local blocker sync | `compare/results/s4-m11-blocker-audit.md`, `tools/roadmapcheck.zig`, `compare/results/s4-m419-blocker-validate-local-sync.md` | Closed for the current bar: S4-M11 blocker evidence now cites fresh S4-M418 `validate-local` Rust comparison/surface/runtime output. |
| S4-M420 current local rand comparison status | `compare/results/s4-m420-current-rand-status.md` | Closed for the current bar: current local Rust comparison snapshot records validate-local/surface/runtime evidence and S4-M11 blocker state. |
| S4-M421 README current rand status discovery | `README.md`, `tools/readmecheck.zig`, `compare/results/s4-m421-readme-current-rand-status.md` | Closed for the current bar: README now links the current local rand comparison status snapshot. |
| S4-M422 guide/API current rand status discovery | `docs/core-guide.md`, `docs/api-reference.md`, `tools/toolingcheck.zig`, `compare/results/s4-m422-guide-api-current-rand-status.md` | Closed for the current bar: core guide/API now link the current local rand comparison status snapshot. |
| S4-M423 tooling current rand status discovery | `docs/tooling.md`, `tools/toolingcheck.zig`, `compare/results/s4-m423-tooling-current-rand-status.md` | Closed for the current bar: tooling catalog now links the current local rand comparison status snapshot. |
| S4-M424 current rand status token guard | `compare/results/s4-m420-current-rand-status.md`, `tools/roadmapcheck.zig`, `compare/results/s4-m424-current-rand-status-guard.md` | Closed for the current bar: roadmapcheck guards essential tokens in the current local rand comparison status snapshot. |
| S4-M425 `rand-status` status printer | `tools/rand_status.zig`, `build.zig`, `README.md`, `docs/tooling.md`, `tools/readmecheck.zig`, `tools/toolingcheck.zig`, `compare/results/s4-m425-rand-status-step.md` | Closed for the current bar: `zig build rand-status` prints current local rand/rand_distr comparison status. |
| S4-M426 guide/API `rand-status` discovery | `docs/core-guide.md`, `docs/api-reference.md`, `tools/toolingcheck.zig`, `compare/results/s4-m426-guide-api-rand-status.md` | Closed for the current bar: core guide/API now list `zig build rand-status`. |
| S4-M427 include `rand-status` in validate-local | `build.zig`, `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, `docs/tooling.md`, `tools/readmecheck.zig`, `tools/toolingcheck.zig`, `compare/results/s4-m427-validate-local-rand-status.md` | Closed for the current bar: `validate-local` now runs `rand-status` and docs/checkers guard the expanded aggregate. |
| S4-M428 validate-local refresh after rand-status aggregate | `compare/results/s4-m428-validate-local-after-rand-status.md`, `compare/results/s4-m420-current-rand-status.md` | Closed for the current bar: `zig build validate-local` passed with `rand-status` included and the current status snapshot was refreshed. |
| S4-M429 S4-M11 blocker sync after rand-status validate-local | `compare/results/s4-m11-blocker-audit.md`, `tools/roadmapcheck.zig`, `compare/results/s4-m429-blocker-rand-status-sync.md` | Closed for the current bar: S4-M11 blocker evidence now cites fresh S4-M428 `validate-local` output including `rand-status`. |
| S4-M430 `rand-status` output token guard | `tools/rand_status.zig`, `tools/toolingcheck.zig`, `compare/results/s4-m430-rand-status-output-guard.md` | Closed for the current bar: toolingcheck guards essential `rand-status` output tokens. |
| S4-M431 `rand-status` JSON/help output | `tools/rand_status.zig`, `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, `docs/tooling.md`, `tools/readmecheck.zig`, `tools/toolingcheck.zig`, `compare/results/s4-m431-rand-status-json.md` | Closed for the current bar: `rand-status` now has stable JSON and help output. |
| S4-M432 next unblocked product gap | `core-rand-coverage.md`, future audits | Not complete; S4-M11 remains blocked and the next independent product improvement has not yet been selected. |
| No proxy signal is accepted as whole-goal completion | `zig build validate-all` plus roadmap/audit files | Validation passes are necessary but not sufficient; blocker audits still show missing performance requirements. |

## Current Non-Completion Evidence

The active goal cannot be marked complete because the roadmap has deliberately
raised the bar beyond S4-M5. `s4-m5-approximation-policy.md` records S4-M5 as
closed for the current local Linux policy bar: named table and approx-log vector
profiles are accepted as the explicit throughput-first dense vector surface for
callers who choose approximation/output-mapping contracts, while exact/default
APIs remain scalar ziggurat lane-fill.

The next unresolved blocked milestone remains S4-M11:

1. Accepted approximation profiles have native glibc, x86_64-linux-musl, and WASI
   long-sweep evidence, but no exact/default-compatible dense SIMD
   normal/exponential kernel has beaten scalar ziggurat lane-fill in the real
   `vectorbench` slice-fill harness.
2. No additional architecture/runtime runner is installed here (`qemu-*`,
   `wine*`, `wasmtime`, and `wasmer` are absent), and no new local `rand` /
   `rand_distr` core gap has been identified.

S4-M12 through S4-M14 are closed as unblocked adoption/documentation
improvements, S4-M15 adds an examples validation gate, S4-M16 adds weighted
sampling adoption guidance, S4-M17 adds multivariate adoption guidance, S4-M18
adds sequence sampling adoption guidance, S4-M19 adds string-generation adoption
guidance, S4-M20 adds unit-geometry adoption guidance, S4-M21 adds distribution
diagnostics adoption guidance, S4-M22 adds reproducible-stream adoption
guidance, S4-M23 adds range/uniform adoption guidance, S4-M24 adds discrete
distribution adoption guidance, S4-M25 adds continuous-distribution adoption
guidance, S4-M26 adds advanced-continuous adoption guidance, S4-M27 adds
rank-distribution adoption guidance, S4-M28 adds a central examples catalog,
S4-M29 adds an example catalog drift checker, S4-M30 adds a build/tooling
catalog drift checker, S4-M31 adds README/doccheck discovery validation, and
S4-M32 adds roadmap/audit drift checking, S4-M33 adds fixed-size item array
sequence sampling, S4-M34 adds one-shot weighted item/pointer choice, and S4-M35 adds caller-owned reservoir sampling, S4-M36 adds caller-owned iterator
reservoir sampling, and S4-M37 adds fixed-size weighted item array sampling, S4-M38 adds fixed-size
weighted index array sampling, S4-M39 adds fixed-size weighted iterator array
sampling, and S4-M40 adds fixed-size iterator array sampling, S4-M41 adds caller-owned
weighted index sampling, S4-M42 adds caller-owned weighted item sampling, and
S4-M43 adds caller-owned weighted iterator sampling, S4-M44 adds caller-owned
index sampling, and S4-M45 adds caller-owned slice item sampling, S4-M46 adds selected/rest
partial-shuffle splits, and S4-M47 adds caller-owned `u32` index sampling, and S4-M48 adds a focused caller-owned sampling adoption example, and S4-M49 adds IndexVec item iterators, and S4-M50 adds caller-owned IndexVec item
mapping, and S4-M51 adds checked mutable-pointer IndexVec mapping, and S4-M52 adds caller-owned pointer subset sampling, and S4-M53 adds fixed-size pointer array sampling, and S4-M54 adds fixed-size weighted pointer array sampling, and S4-M55 adds caller-owned weighted pointer subset sampling, and S4-M56 adds const-pointer single choice, and S4-M57 adds weighted const-pointer single choice, and S4-M58 adds allocation-returning pointer subset sampling, and S4-M59 adds allocation-returning weighted pointer subset sampling, and S4-M60 adds allocation-returning reservoir pointer sampling, and S4-M61 adds caller-owned reservoir pointer sampling, and S4-M62 refreshes the caller-owned pointer adoption example, and S4-M63 adds one-shot index choice, and S4-M64 adds generic one-shot weighted index choice, and S4-M65 hardens example content drift checks, and S4-M66 hardens S4-M11 blocker audit drift checks, and S4-M67 refreshes README quick-start index/pointer choice discovery, and S4-M68 hardens doccheck dependency validation, and S4-M69 adds weighted IndexVec sampling, and S4-M70 adds caller-owned weighted u32 index buffers, and S4-M71 adds fixed-size weighted u32 index arrays, and S4-M72 adds allocation-returning weighted u32 index slices, and S4-M73 adds fixed-size u32 index arrays, and S4-M74 adds IndexVec u32 export mapping, and S4-M75 adds IndexVec owned item mapping, and S4-M76 adds one-shot u32 index choice, and S4-M77 adds generic weighted u32 index choice, and S4-M78 adds f64 weighted u32 index choice, and S4-M79 adds WeightedChoice index fills, and S4-M80 adds Choice index fills, and S4-M81 adds Choice sampler index samples, and S4-M82 adds Choice owned index batches, and S4-M83 adds WeightedChoice owned index batches, and S4-M84 adds reusable Choice/WeightedChoice owned value and pointer batches, and S4-M85 adds Rng owned repeated value/sample batches, and S4-M86 adds Rng owned byte buffers, and S4-M87 adds Rng owned scalar range batches, and S4-M88 adds Rng owned strict-interval float batches, and S4-M89 adds Rng owned probability bool batches, and S4-M90 adds Rng owned normal/exponential batches, and S4-M91 adds Rng owned duration range batches, and S4-M92 adds Rng owned vector range batches, and S4-M93 adds Rng owned vector strict-interval batches, and S4-M94 adds Rng owned vector probability bool batches, and S4-M95 adds Rng owned vector normal/exponential batches, and S4-M96 adds Rng owned standard normal/exponential batches, and S4-M97 adds Rng owned Unicode scalar batches, and S4-M98 adds Unicode scalar range helpers, and S4-M99 adds Rng owned bounded uint batches, and S4-M100 adds Rng owned inclusive integer range batches, and S4-M101 adds Rng owned vector inclusive integer range batches, and S4-M102 adds Rng repeated index choice batches, and S4-M103 adds Rng repeated value choice batches, and S4-M104 adds Rng repeated const-pointer choice batches, and S4-M105 adds Rng repeated mutable-pointer choice batches, and S4-M106 adds Rng repeated weighted index batches, and S4-M107 adds Rng repeated weighted u32 index batches, and S4-M108 adds Rng repeated weighted value batches, and S4-M109 adds Rng repeated weighted const-pointer batches, and S4-M110 adds Rng repeated weighted mutable-pointer batches, and S4-M111 adds generic repeated weighted index batches, and S4-M112 adds generic repeated weighted value batches, and S4-M113 adds generic repeated weighted const-pointer batches, and S4-M114 adds generic repeated weighted mutable-pointer batches, S4-M115 adds accessor-based weighted value/const-pointer/mutable-pointer choices, S4-M116 adds accessor-based weighted no-replacement value/const-pointer/mutable-pointer samples, S4-M117 adds caller-owned accessor-weighted no-replacement buffers, S4-M118 adds accessor-weighted usize/u32/IndexVec no-replacement index samples, S4-M119 adds accessor-weighted fixed-size index arrays, S4-M120 adds accessor-weighted fixed-size value/const-pointer/mutable-pointer arrays, S4-M121 adds reusable `WeightedChoice` accessor construction/update, S4-M122 adds stable iterator choice aliases, S4-M123 adds iterator sample-fill aliases, S4-M124 adds slice sample aliases, S4-M125 adds index-weighted no-replacement samples, S4-M126 adds caller-owned index-weighted buffers, S4-M127 adds fixed-size index-weighted arrays, S4-M128 adds fixed-size slice sample aliases, S4-M129 adds `seq.shuffle` aliases, S4-M130 adds Rust-style tail partial shuffles, S4-M131 adds `seq.choose` aliases, S4-M132 adds `seq.fillChoose` aliases, S4-M133 adds `seq.chooseBatch` aliases, S4-M134 adds `seq.chooseIndex` / `seq.fillChooseIndex` / `seq.chooseIndexBatch` aliases, S4-M135 adds accessor-weighted `seq.fillChooseWeighted*By` aliases, S4-M136 adds accessor-weighted `seq.chooseWeighted*BatchBy` aliases, S4-M137 adds accessor-weighted `seq.weightedIndex*By` aliases, S4-M138 adds accessor-weighted `seq.fillWeightedIndex*By` aliases, S4-M139 adds accessor-weighted `seq.weightedIndex*BatchBy` aliases, and S4-M140 adds index-weighted `seq.weightedIndex*ByIndex` aliases, and S4-M141 adds index-weighted `seq.fillWeightedIndex*ByIndex` aliases, and S4-M142 adds index-weighted `seq.weightedIndex*BatchByIndex` aliases, and S4-M143 adds index-weighted `seq.chooseWeighted*ByIndex` aliases, and S4-M144 adds index-weighted `seq.fillChooseWeighted*ByIndex` aliases, and S4-M145 adds index-weighted `seq.chooseWeighted*BatchByIndex` aliases, and S4-M146 adds index-weighted `WeightedChoice.initByIndex` / `updateByIndex`, and S4-M147 adds index-weighted `WeightedTree` / `WeightedIntTree` construction and full-refresh helpers, and S4-M148 adds item-accessor `WeightedTree` / `WeightedIntTree` construction and full-refresh helpers, and S4-M149 adds compact `u32` dynamic tree sample/fill output, and S4-M150 adds owned repeated index/u32-index dynamic tree batches, and S4-M151 adds `sampleIndex` / `fillIndices` dynamic tree aliases, and S4-M152 adds repeated dynamic tree index/u32-index iterators, and S4-M153 adds compact `u32` `AliasTable` sample/fill output, and S4-M154 adds owned repeated index/u32-index `AliasTable` batches, and S4-M155 adds `sampleIndex` / `fillIndices` `AliasTable` aliases, and S4-M156 adds repeated `AliasTable` index/u32-index iterators, and S4-M157 adds index-weighted `AliasTable.initByIndex` / `updateByIndex`, and S4-M158 adds item-accessor `AliasTable.initBy` / `updateBy`, and S4-M159 adds fixed-size `AliasTable` index/u32-index arrays, and S4-M160 adds fixed-size dynamic tree index/u32-index arrays, S4-M161 adds fixed-size reusable `WeightedChoice` index/u32-index arrays, S4-M162 adds fixed-size reusable `Choice` index/u32-index arrays, S4-M163 adds fixed-size reusable `Choice` value/pointer arrays, S4-M164 adds fixed-size reusable `WeightedChoice` value/pointer arrays, and S4-M165 adds fixed-size repeated index-choice arrays for `Rng` and `seq`, and S4-M166 adds fixed-size repeated value/pointer choice arrays for `Rng`, and S4-M167 adds fixed-size repeated f64 weighted index/value/pointer arrays for `Rng`, and S4-M168 adds fixed-size repeated generic-weight index/value/pointer arrays for `seq`, and S4-M169 adds fixed-size repeated item-accessor weighted index/value/pointer arrays for `seq`, and S4-M170 adds fixed-size repeated length/index-weight accessor weighted index/value/pointer arrays for `seq`, and S4-M171 adds explicit fixed-size repeated value/pointer choice arrays for `seq`, and S4-M172 adds reusable `Choice` / `WeightedChoice` index iterators, and S4-M173 adds `IndexVec` consuming owned-slice conversions, and S4-M174 adds representation-independent `IndexVec` content equality, and S4-M175 adds `IndexVec` owned backing constructors, and S4-M176 adds representation-preserving `IndexVec` deep clone, and S4-M177 adds a consuming `IndexVec` index iterator, and S4-M178 adds repeated weighted choice pointer iterators, and S4-M179 adds accessor-weighted repeated pointer iterators, and S4-M180 adds index-weighted repeated pointer iterators, and S4-M181 adds no-replacement sampled pointer iterators, and S4-M182 adds no-replacement sampled value iterators, and S4-M183 adds no-replacement sampled mutable-pointer iterators, and S4-M184 adds reusable choice count diagnostics, and S4-M185 adds sampled iterator fill helpers, and S4-M186 adds exact-size iterator len aliases, and S4-M187 adds exact-size iterator size hints, and S4-M188 adds IndexVec iterator fill helpers, and S4-M189 adds a Rust-discoverable IndexVec.index alias, and S4-M190 adds checked IndexVec positional lookup, and S4-M191 adds optional weighted sampler weight lookup, and S4-M192 adds weighted sampler weight iterators, and S4-M193 adds optional weighted sampler probability lookup, and S4-M194 adds weighted sampler probability iterators, and S4-M195 adds Choice optional probability lookup, and S4-M196 adds a Choice probability iterator, and S4-M197 adds Charset optional probability lookup, and S4-M198 adds a Charset probability iterator, and S4-M199 adds reusable choice item lookup, and S4-M200 adds Charset optional item lookup, and S4-M201 adds diagnostic iterator size hints, and S4-M202 adds Charset count diagnostics, and S4-M203 adds reusable choice checked item aliases, and S4-M204 adds Charset checked item alias, and S4-M205 adds dynamic tree optional weight lookup, and S4-M206 adds dynamic tree optional probability lookup, and S4-M207 adds dynamic tree weight iterators, and S4-M208 adds dynamic tree probability iterators, and S4-M209 adds AliasTable count diagnostics, and S4-M210 adds dynamic tree count diagnostics, and S4-M211 adds dynamic tree constant-index diagnostics, and S4-M212 adds `WeightedChoice` constant-index diagnostics, and S4-M213 adds reusable `Choice` singleton constant-index diagnostics, and S4-M214 adds Charset singleton constant-index diagnostics, and S4-M215 adds dynamic tree positive-count diagnostics, and S4-M216 adds AliasTable positive-count diagnostics, and S4-M217 adds `WeightedChoice` positive-count diagnostics, and S4-M218 adds static/reusable weighted single-weight update helpers, and S4-M219 adds ordered static/reusable weighted partial update helpers, and S4-M220 adds ordered dynamic weighted-tree partial update helpers, and S4-M221 adds Rust-discoverable weighted updateWeights aliases, and S4-M222 adds a Rust-discoverable `IndexVec.intoVec` alias, and S4-M223 adds Rust-discoverable `Choice.new` aliases, and S4-M224 adds Rust-discoverable weighted `new` aliases, and S4-M225 adds Rust-discoverable Bernoulli `new` aliases, and S4-M226 adds Rust-discoverable scalar/vector Uniform `new` aliases, and S4-M227 adds Rust-discoverable Bernoulli `fromRatio` aliases, and S4-M228 adds Rust-discoverable Bernoulli `p()` aliases, and S4-M229 adds Rust-discoverable uniform `sampleSingle` aliases, and S4-M230 adds Rust-discoverable `Rng.randomBool` / `randomRatio` aliases, and S4-M231 adds Rust-discoverable `Rng.randomRange` aliases, and S4-M232 adds Rust-discoverable `Rng.sample` aliases, and S4-M233 adds Rust-discoverable `Rng.randomValue` aliases, and S4-M234 adds Rust-discoverable `Rng.nextU64` / `nextU32` / `fillBytes` raw aliases, and S4-M235 adds matching Rust-discoverable direct-engine raw aliases, and S4-M236 adds Rust-discoverable direct-engine `seedFromU64` aliases, and S4-M237 adds Rust-discoverable direct-engine `fromSeed` aliases, and S4-M238 adds Rust-discoverable `Seed.fromRng` plus direct-engine `fromRng` / `fork` aliases, and S4-M239 strengthens direct-engine `fromRng` / `fork` to consume full target seed material, and S4-M240 adds Rust-discoverable direct-engine `fromSeedBytes` byte-array seed constructors, and S4-M241 adds Rust-discoverable fallible `tryFromRng` seed constructors, and S4-M242 adds Rust-discoverable engine `tryNext` / `tryFork` aliases, and S4-M243 adds Rust-discoverable facade/engine `tryNextU64` / `tryNextU32` / `tryFillBytes` raw aliases, and S4-M244 adds direct-source `Rng.try*From` raw aliases, and S4-M245 adds Rust-discoverable root `makeRng(Engine, io)`, and S4-M246 adds a Zig-native `RngReader` `std.Io.Reader` adapter, and S4-M247 adds a Rust-discoverable `SysRng` system-entropy source, and S4-M248 adds a mapped reusable-sampler adapter, and S4-M249 adds unbounded RNG iterator size hints, S4-M250 adds distribution-namespace sample iterator aliases, S4-M251 adds SampleString aliases, S4-M252 adds reusable Unicode scalar charset strings, S4-M253 adds hinted iterator choice aliases, S4-M254 adds StdRng/SmallRng aliases, S4-M255 adds StepRng deterministic mock streams, S4-M256 adds a ChaCha12Rng alias, S4-M257 adds ChaCha8Rng/ChaCha20Rng engines, S4-M258 adds Xoshiro128PlusPlus, and S4-M259 adds root top-level random helpers, and S4-M260 adds a SysError alias, and S4-M261 adds a WeightError alias, but they do not resolve S4-M11 or complete the long-term objective.

S4-M262 additionally adds the distribution-namespace `StandardUniform` sampler;
it is another closed side gap and does not resolve S4-M11 or complete the
long-term objective.
S4-M263 additionally adds `distributions.BernoulliError`; it is another closed
local Rust discovery-name side gap and does not resolve S4-M11 or complete the
long-term objective.
S4-M264 additionally adds distribution-namespace `Alphanumeric` / `Alphabetic`
aliases; it is another closed local Rust discovery-name side gap and does not
resolve S4-M11 or complete the long-term objective.
S4-M265 additionally adds `distributions.WeightedIndex`; it is another closed
local Rust discovery-name side gap and does not resolve S4-M11 or complete the
long-term objective.
S4-M266 additionally adds `distributions.UniformDuration`; it is another closed
local Rust discovery-name side gap and does not resolve S4-M11 or complete the
long-term objective.
S4-M267 additionally adds `distributions.UniformUnicodeScalar`; it is another
closed local Rust workflow side gap and does not resolve S4-M11 or complete the
long-term objective.
S4-M268 additionally adds `distributions.Choose`; it is another closed local
Rust discovery-name side gap and does not resolve S4-M11 or complete the
long-term objective.
S4-M269 additionally adds `distributions.UniformError`; it is another closed
local Rust discovery-name side gap and does not resolve S4-M11 or complete the
long-term objective.
S4-M270 additionally adds distribution-namespace `Map` / `Iter` aliases; it is
another closed local Rust discovery-name side gap and does not resolve S4-M11 or
complete the long-term objective.
S4-M271 additionally adds distribution-namespace weighted error aliases; it is
another closed local Rust discovery-name side gap and does not resolve S4-M11 or
complete the long-term objective.
S4-M272 additionally adds uniform backend discovery aliases; it is another
closed local Rust discovery-name side gap and does not resolve S4-M11 or
complete the long-term objective.
S4-M273 additionally adds distribution slice namespace aliases; it is another
closed local Rust discovery-name side gap and does not resolve S4-M11 or
complete the long-term objective.
S4-M274 additionally adds a UniformChar discovery alias; it is another closed
local Rust discovery-name side gap and does not resolve S4-M11 or complete the
long-term objective.
S4-M275 additionally adds Uniform `NonFinite` error parity; it is another closed
local Rust uniform diagnostics side gap and does not resolve S4-M11 or complete
the long-term objective.
S4-M276 additionally adds Uniform range-constructor aliases; it is another
closed local Rust discovery-name side gap and does not resolve S4-M11 or
complete the long-term objective.
S4-M277 additionally adds a root `rngs` namespace; it is another closed local
Rust discovery-name side gap and does not resolve S4-M11 or complete the
long-term objective.
S4-M278 additionally adds root RngReader aliases; it is another closed local
Rust discovery-name side gap and does not resolve S4-M11 or complete the
long-term objective.
S4-M279 additionally adds IndexedSamples aliases; it is another closed local
Rust discovery-name side gap and does not resolve S4-M11 or complete the
long-term objective.
S4-M280 additionally adds a root `prelude` namespace; it is another closed local
Rust discovery-name side gap and does not resolve S4-M11 or complete the
long-term objective.
S4-M281 additionally adds weighted error variant diagnostics; it is another
closed local Rust diagnostics side gap and does not resolve S4-M11 or complete
the long-term objective.
S4-M282 additionally adds a root `distr` namespace alias; it is another closed
local Rust discovery-name side gap and does not resolve S4-M11 or complete the
long-term objective.
S4-M283 additionally documents the remaining local Rust trait/marker/thread-local
surface; it is an audit closure and does not resolve S4-M11 or complete the
long-term objective.
S4-M284 additionally adds a `distributions.weighted` namespace; it is another
closed local Rust discovery-name side gap and does not resolve S4-M11 or
complete the long-term objective.
S4-M285 additionally audits the local Rust uniform namespace path; it is an
audit closure and does not resolve S4-M11 or complete the long-term objective.
S4-M286 additionally audits the local Rust `rand_core` re-export surface; it is
an audit closure and does not resolve S4-M11 or complete the long-term
objective.
S4-M287 additionally audits the local Rust `seq::index` namespace path; it is an
audit closure and does not resolve S4-M11 or complete the long-term objective.
S4-M288 additionally adds a local Rust public-surface manifest; it is an audit
closure and does not resolve S4-M11 or complete the long-term objective.
S4-M289 additionally adds local `rand_distr` error alias names; it is another
closed discovery-name side gap and does not resolve S4-M11 or complete the
long-term objective.
S4-M290 additionally adds local `rand_distr` `Exp` / `Exp1` aliases; it is
another closed discovery-name side gap and does not resolve S4-M11 or complete
the long-term objective.
S4-M291 additionally adds a local `rand_distr::multi::Dirichlet` namespace
alias; it is another closed discovery-name side gap and does not resolve S4-M11
or complete the long-term objective.
S4-M292 additionally adds local `rand_distr` `new(...)` constructor aliases; it
is another closed discovery-name side gap and does not resolve S4-M11 or
complete the long-term objective.
S4-M293 additionally adds local `rand_distr` `from_mean_cv` constructor aliases;
it is another closed discovery-name side gap and does not resolve S4-M11 or
complete the long-term objective.
S4-M294 additionally adds a local `rand_distr` public-surface manifest; it is an
audit closure and does not resolve S4-M11 or complete the long-term objective.
S4-M295 additionally adds manifest guardrails to `roadmapcheck`; it is an
evidence-quality improvement and does not resolve S4-M11 or complete the
long-term objective.
S4-M296 additionally adds an explicit local surface drift checker; it is an
evidence-quality/tooling improvement and does not resolve S4-M11 or complete the
long-term objective.
S4-M297 additionally strengthens that drift checker with multiline re-export
parsing; it is an evidence-quality/tooling improvement and does not resolve
S4-M11 or complete the long-term objective.
S4-M298 additionally adds SkewNormal parameter discovery aliases; it is another
closed local `rand_distr` accessor side gap and does not resolve S4-M11 or
complete the long-term objective.
S4-M299 additionally maps local `rand_distr::WeightedTreeIndex::is_valid` to
existing Alea dynamic-tree readiness diagnostics; it is an evidence/manifest
closure and does not resolve S4-M11 or complete the long-term objective.
S4-M300 additionally adds Normal parameter discovery aliases; it is another
closed local `rand_distr` accessor side gap and does not resolve S4-M11 or
complete the long-term objective.
S4-M301 additionally strengthens local public-surface drift checking for impl
methods; it is an evidence/tooling closure and does not resolve S4-M11 or
complete the long-term objective.
S4-M302 additionally extends that drift checking to local `rand` Bernoulli impl
methods; it is an evidence/tooling closure and does not resolve S4-M11 or
complete the long-term objective.
S4-M303 additionally adds surfacecheck coverage summaries; it is an
evidence/tooling improvement and does not resolve S4-M11 or complete the
long-term objective.
S4-M304 additionally hardens surfacecheck token matching; it is an
evidence/tooling improvement and does not resolve S4-M11 or complete the
long-term objective.
S4-M305 additionally broadens surfacecheck's source-file coverage; it is an
evidence/tooling improvement and does not resolve S4-M11 or complete the
long-term objective.
S4-M306 additionally guards against unlisted public Rust source files in
surfacecheck; it is an evidence/tooling improvement and does not resolve S4-M11
or complete the long-term objective.
S4-M307 additionally refreshes the S4-M11 blocker audit; it confirms the blocker
remains unresolved and therefore does not complete the long-term objective.
S4-M308 additionally guards README discovery of `zig build surfacecheck`; it is
an evidence/tooling improvement and does not resolve S4-M11 or complete the
long-term objective.
S4-M309 additionally adds focused tests for `surfacecheck` token matching; it is
an evidence/tooling improvement and does not resolve S4-M11 or complete the
long-term objective.
S4-M310 additionally wires those tests into `zig build surfacecheck`; it is an
evidence/tooling improvement and does not resolve S4-M11 or complete the
long-term objective.
S4-M311 additionally guards the `surfacecheck` build-step dependency shape in
`toolingcheck`; it is an evidence/tooling improvement and does not resolve
S4-M11 or complete the long-term objective.
S4-M312 additionally adds focused tests for `surfacecheck` public-file guard
helpers; it is an evidence/tooling improvement and does not resolve S4-M11 or
complete the long-term objective.
S4-M313 additionally makes `surfacecheck` default roots HOME-relative; it is an
evidence/tooling portability improvement and does not resolve S4-M11 or complete
the long-term objective.
S4-M314 additionally tests `surfacecheck` root-resolution helpers; it is an
evidence/tooling portability improvement and does not resolve S4-M11 or complete
the long-term objective.
S4-M315 additionally hardens `roadmapcheck` for S4-M11 surfacecheck blocker
tokens; it is an evidence/tooling improvement and does not resolve S4-M11 or
complete the long-term objective.
S4-M316 additionally guards against stale `surfacecheck` ignored-file entries;
it is an evidence/tooling improvement and does not resolve S4-M11 or complete
the long-term objective.
S4-M317 additionally adds a `validate-local` aggregate; it is an
evidence/tooling improvement and does not resolve S4-M11 or complete the
long-term objective.
S4-M318 additionally normalizes `validate-local` evidence wording; it is an
evidence-quality improvement and does not resolve S4-M11 or complete the
long-term objective.
S4-M319 additionally keeps `validate-local` visible in S4-M11 blocker checks; it
is an evidence/tooling improvement and does not resolve S4-M11 or complete the
long-term objective.
S4-M320 additionally updates the roadmap Current Rule to prefer `validate-local`
for local comparison/public-surface evidence changes; it is an evidence/tooling
improvement and does not resolve S4-M11 or complete the long-term objective.
S4-M321 additionally adds a runtime-runner availability checker; it is an
evidence/tooling improvement and does not resolve S4-M11 or complete the
long-term objective.
S4-M322 additionally adds runtimecheck helper tests and build-step wiring; it is
an evidence/tooling improvement and does not resolve S4-M11 or complete the
long-term objective.
S4-M323 additionally hardens `roadmapcheck` for the runtimecheck OK conclusion;
it is an evidence/tooling improvement and does not resolve S4-M11 or complete
the long-term objective.
S4-M324 additionally synchronizes earlier `validate-local` evidence with the
runtimecheck dependency added later; it is an evidence-quality improvement and
does not resolve S4-M11 or complete the long-term objective.
S4-M325 additionally adds runtimecheck decision tests; it is an evidence/tooling
improvement and does not resolve S4-M11 or complete the long-term objective.
S4-M326 additionally documents and guards runtimecheck's runner sets; it is an
evidence/tooling improvement and does not resolve S4-M11 or complete the
long-term objective.
S4-M327 additionally adds runtimecheck summary counts to output and blocker
evidence; it is an evidence/tooling improvement and does not resolve S4-M11 or
complete the long-term objective.
S4-M328 additionally strengthens runtimecheck documentation guards; it is an
evidence/tooling improvement and does not resolve S4-M11 or complete the
long-term objective.
S4-M329 additionally synchronizes earlier runtimecheck evidence with the current
summary output; it is an evidence-quality improvement and does not resolve S4-M11
or complete the long-term objective.
S4-M330 additionally syncs the core guide runtimecheck runner list; it is a
documentation improvement and does not resolve S4-M11 or complete the long-term
objective.
S4-M331 additionally adds runtimecheck empty-PATH-segment coverage; it is an
evidence/tooling improvement and does not resolve S4-M11 or complete the
long-term objective.
S4-M332 additionally documents `validate-local` usage in README prose; it is a
documentation/tooling improvement and does not resolve S4-M11 or complete the
long-term objective.
S4-M333 additionally broadens runtimecheck's QEMU opportunity names to include
static binaries; it does not resolve S4-M11 or complete the long-term objective.
S4-M334 additionally hardens example validation so cataloged runnable examples
remain in aggregate `zig build examples` / `zig build validate` coverage; it is
an adoption/tooling improvement and does not resolve S4-M11 or complete the
long-term objective.
S4-M335 additionally hardens `zig build validate` dependency checks so the native
validation aggregate keeps tests, examples, docs, statistical checks, distribution
checks, libc checks, and accepted-profile checks wired; it is a tooling
improvement and does not resolve S4-M11 or complete the long-term objective.
S4-M336 additionally hardens `zig build validate-all` dependency checks so the
broad validation aggregate keeps native validation, cross-target compile checks,
WASI unit execution, and the WASI report chain wired; it is a tooling improvement
and does not resolve S4-M11 or complete the long-term objective.
S4-M337 additionally hardens the WASI report dependency chain so repro,
statcheck, distcheck, profilecheck, tail, stress, long-profile, and no-Node
failure paths remain wired; it is a tooling improvement and does not resolve
S4-M11 or complete the long-term objective.
S4-M338 additionally documents `validate-all` usage in README prose and guards
the portability-sensitive aggregate explanation with `readmecheck`; it is a
documentation/tooling improvement and does not resolve S4-M11 or complete the
long-term objective.
S4-M339 additionally documents validation aggregate selection in the core guide
and guards the `validate` / `validate-local` / `validate-all` guidance with
`toolingcheck`; it is a documentation/tooling improvement and does not resolve
S4-M11 or complete the long-term objective.
S4-M340 additionally documents validation aggregate selection in the API
reference and guards the API validation guidance with `toolingcheck`; it is a
documentation/tooling improvement and does not resolve S4-M11 or complete the
long-term objective.
S4-M341 additionally hardens `roadmapcheck` so the active audit must retain the
concrete required-next-work completion criteria; it is an evidence/tooling
improvement and does not resolve S4-M11 or complete the long-term objective.
S4-M342 additionally hardens `roadmapcheck` so the roadmap Current Rule must
retain concrete validation and prioritization guidance; it is an evidence/tooling
improvement and does not resolve S4-M11 or complete the long-term objective.
S4-M343 additionally hardens `roadmapcheck` so the roadmap Long-Term Product
Tracks keep feature breadth, statistical confidence, performance, ergonomics,
and portability pressure visible; it is an evidence/tooling improvement and does
not resolve S4-M11 or complete the long-term objective.
S4-M344 additionally adds focused roadmapcheck helper tests and wires them into
`zig build roadmapcheck`; it is an evidence/tooling improvement and does not
resolve S4-M11 or complete the long-term objective.
S4-M345 additionally adds focused toolingcheck helper tests and wires them into
`zig build toolingcheck`; it is an evidence/tooling improvement and does not
resolve S4-M11 or complete the long-term objective.
S4-M346 additionally adds focused apicheck helper tests and wires them into
`zig build apicheck`; it is an evidence/tooling improvement and does not resolve
S4-M11 or complete the long-term objective.
S4-M347 additionally adds focused examplecheck helper tests and wires them into
`zig build examplecheck`; it is an evidence/tooling improvement and does not
resolve S4-M11 or complete the long-term objective.
S4-M348 additionally adds focused readmecheck helper tests and wires them into
`zig build readmecheck`; it is an evidence/tooling improvement and does not
resolve S4-M11 or complete the long-term objective.
S4-M349 additionally adds focused statcheck helper tests and wires them into
`zig build statcheck`; it is an evidence/tooling improvement and does not resolve
S4-M11 or complete the long-term objective.
S4-M350 additionally adds focused distcheck helper tests and wires them into
`zig build distcheck` / `zig build distcheck-libc`; it is an evidence/tooling
improvement and does not resolve S4-M11 or complete the long-term objective.
S4-M351 additionally adds focused profilecheck helper tests and wires them into
`zig build profilecheck`; it is an evidence/tooling improvement and does not
resolve S4-M11 or complete the long-term objective.
S4-M352 additionally adds focused profiletailcheck helper tests and wires them
into `zig build profilecheck-tail`; it is an evidence/tooling improvement and
does not resolve S4-M11 or complete the long-term objective.
S4-M353 additionally adds focused profilestresscheck helper tests, removes
duplicate exponential aggregate-count accumulation, and wires tests into
`zig build profilecheck-stress`; it is an evidence/tooling improvement and does
not resolve S4-M11 or complete the long-term objective.
S4-M354 additionally adds focused profilelongcheck helper tests and wires them
into `zig build profilecheck-long`; it is an evidence/tooling improvement and
does not resolve S4-M11 or complete the long-term objective.
S4-M355 additionally adds focused stream helper tests and wires them into
`zig build stream`; it is an evidence/tooling improvement and does not resolve
S4-M11 or complete the long-term objective.
S4-M356 additionally adds focused repro helper tests and wires them into
`zig build repro`; it is an evidence/tooling improvement and does not resolve
S4-M11 or complete the long-term objective.
S4-M357 additionally adds dry-run and custom-binary support to the PractRand
wrapper and guards the documentation; it is an evidence/tooling improvement and
does not resolve S4-M11 or complete the long-term objective.
S4-M358 additionally adds a discoverable `zig build practrand-dry-run` step for
PractRand pipeline validation; it is an evidence/tooling improvement and does
not resolve S4-M11 or complete the long-term objective.
S4-M359 additionally strengthens `readmecheck` so README keeps PractRand dry-run
and custom-binary guidance visible; it is an evidence/tooling improvement and
does not resolve S4-M11 or complete the long-term objective.
S4-M360 additionally strengthens `toolingcheck` so the core guide and API
reference keep PractRand dry-run guidance visible; it is an evidence/tooling
improvement and does not resolve S4-M11 or complete the long-term objective.
S4-M361 additionally strengthens `toolingcheck` so checked-in shell tools keep
executable permissions; it is an evidence/tooling improvement and does not
resolve S4-M11 or complete the long-term objective.
S4-M362 additionally adds dry-run support to the Node WASI runner and guards it
with `toolingcheck`; it is an evidence/tooling improvement and does not resolve
S4-M11 or complete the long-term objective.
S4-M363 additionally adds a discoverable `zig build wasi-dry-run` step for Node
WASI argv validation; it is an evidence/tooling improvement and does not resolve
S4-M11 or complete the long-term objective.
S4-M364 additionally strengthens `readmecheck` so README keeps WASI dry-run
discovery visible; it is an evidence/tooling improvement and does not resolve
S4-M11 or complete the long-term objective.
S4-M365 additionally documents WASI dry-run usage in the core guide and guards it
with `toolingcheck`; it is an evidence/tooling improvement and does not resolve
S4-M11 or complete the long-term objective.
S4-M366 additionally documents WASI dry-run usage in README prose and guards it
with `readmecheck`; it is an evidence/tooling improvement and does not resolve
S4-M11 or complete the long-term objective.
S4-M367 additionally strengthens `toolingcheck` so docs/tooling keeps WASI
dry-run prose visible; it is an evidence/tooling improvement and does not resolve
S4-M11 or complete the long-term objective.
S4-M368 additionally documents WASI dry-run usage in the API reference and guards
it with `toolingcheck`; it is an evidence/tooling improvement and does not
resolve S4-M11 or complete the long-term objective.
S4-M369 additionally documents and guards the exact crosscheck target set; it is
an evidence/tooling improvement and does not resolve S4-M11 or complete the
long-term objective.
S4-M370 additionally documents the exact crosscheck target set in README and
guards it with `readmecheck`; it is an evidence/tooling improvement and does not
resolve S4-M11 or complete the long-term objective.
S4-M371 additionally fixes width-sensitive tests discovered by `zig build
crosscheck`; it is a portability test/evidence improvement and does not resolve
S4-M11 or complete the long-term objective.
S4-M372 additionally reruns and records full `zig build validate-all` evidence
after the crosscheck fix; it is a portability evidence improvement and does not
resolve S4-M11 or complete the long-term objective.
S4-M373 additionally reruns and records `zig build validate-local` evidence for
the current local rand/rand_distr comparison workflow; it is local comparison
evidence and does not resolve S4-M11 or complete the long-term objective.
S4-M374 additionally documents the exact crosscheck target set in the API
reference and guards it with `toolingcheck`; it is an evidence/tooling
improvement and does not resolve S4-M11 or complete the long-term objective.
S4-M375 additionally documents the exact crosscheck target set in the core guide
and guards it with `toolingcheck`; it is an evidence/tooling improvement and does
not resolve S4-M11 or complete the long-term objective.
S4-M376 additionally guards WASI runner file inputs in build steps; it is an
evidence/tooling improvement and does not resolve S4-M11 or complete the
long-term objective.
S4-M377 additionally improves vectorbench filter-only argument ergonomics and
wires parser tests into `zig build vectorbench`; it is a performance-tooling
improvement and does not resolve S4-M11 or complete the long-term objective.
S4-M378 additionally adds helper-tested argument parsing to the main throughput
bench and wires tests into `zig build bench`; it is a performance-tooling
improvement and does not resolve S4-M11 or complete the long-term objective.
S4-M379 additionally wires those throughput parser helper tests into `zig build
bench-libc`; it is a performance-tooling improvement and does not resolve S4-M11
or complete the long-term objective.
S4-M380 additionally adds helper-tested argument parsing and a `zig build
rand-bench-test` step for the Rust comparison benchmark; it is local comparison
benchmark tooling and does not resolve S4-M11 or complete the long-term
objective.
S4-M381 additionally adds a tiny filtered `zig build rand-bench-smoke`
end-to-end run for the Rust comparison benchmark; it is local comparison
benchmark tooling and does not resolve S4-M11 or complete the long-term
objective.
S4-M382 additionally adds a `zig build rand-bench-smoke-dry-run` command preview
for the Rust comparison smoke wrapper; it is local comparison benchmark tooling
and does not resolve S4-M11 or complete the long-term objective.
S4-M383 additionally adds no-cargo self-tests for the Rust comparison smoke
wrapper; it is local comparison benchmark tooling and does not resolve S4-M11 or
complete the long-term objective.
S4-M384 additionally guards `ALEA_RAND_BENCH_MANIFEST` and
`ALEA_RAND_BENCH_EXPECTED_ROW` override paths for the Rust comparison smoke
wrapper; it is local comparison benchmark tooling and does not resolve S4-M11 or
complete the long-term objective.
S4-M385 additionally synchronizes S4-M11 blocker evidence with the Rust
comparison benchmark gates in `validate-local`; it is blocker-evidence tooling
and does not resolve S4-M11 or complete the long-term objective.
S4-M386 additionally adds no-`RNG_test` self-tests for the PractRand wrapper; it
is external-statistical-tooling reliability and does not resolve S4-M11 or
complete the long-term objective.
S4-M387 additionally adds no-wasm self-tests for the Node WASI runner; it is
portability tooling reliability and does not resolve S4-M11 or complete the
long-term objective.
S4-M388 additionally wires WASI dry-run and self-test steps into `validate-all`;
it is portability validation aggregate reliability and does not resolve S4-M11 or
complete the long-term objective.
S4-M389 additionally reruns and records the expanded `zig build validate-all`
aggregate; it is portability validation evidence and does not resolve S4-M11 or
complete the long-term objective.
S4-M390 additionally guards PractRand wrapper build-step file inputs; it is
external-statistical-tooling reliability and does not resolve S4-M11 or complete
the long-term objective.
S4-M391 additionally wires PractRand wrapper self-tests into native validation;
it is external-statistical-tooling reliability and does not resolve S4-M11 or
complete the long-term objective.
S4-M392 additionally reruns and records native `zig build validate` after the
PractRand wrapper self-test dependency; it is native validation evidence and does
not resolve S4-M11 or complete the long-term objective.
S4-M393 additionally updates and guards validation aggregate build descriptions;
it is validation tooling reliability and does not resolve S4-M11 or complete the
long-term objective.
S4-M394 additionally updates and guards `zig build test` tooling docs for the
full doccheck aggregate; it is validation documentation reliability and does not
resolve S4-M11 or complete the long-term objective.
S4-M395 additionally sharpens and guards the `validate-all` tooling table row; it
is validation documentation reliability and does not resolve S4-M11 or complete
the long-term objective.
S4-M396 additionally guards README prose for `validate` including PractRand
wrapper self-tests; it is validation documentation reliability and does not
resolve S4-M11 or complete the long-term objective.
S4-M397 additionally guards API reference prose for no-external PractRand wrapper
validation; it is validation documentation reliability and does not resolve
S4-M11 or complete the long-term objective.
S4-M398 additionally guards the `validate` tooling table row; it is validation
documentation reliability and does not resolve S4-M11 or complete the long-term
objective.
S4-M399 additionally guards README `validate-local` prose for Rust comparison
smoke/self-test coverage; it is validation documentation reliability and does
not resolve S4-M11 or complete the long-term objective.
S4-M400 additionally makes no-external wrapper self-test temporary files safe for
parallel runs; it is tooling reliability and does not resolve S4-M11 or complete
the long-term objective.
S4-M401 additionally documents and guards the Rust comparison smoke wrapper
`--self-test` usage; it is local comparison tooling reliability and does not
resolve S4-M11 or complete the long-term objective.
S4-M402 additionally documents and guards PractRand wrapper `--self-test` usage
semantics; it is external-statistical-tooling reliability and does not resolve
S4-M11 or complete the long-term objective.
S4-M403 additionally documents and guards WASI runner `--self-test` usage
semantics; it is portability tooling reliability and does not resolve S4-M11 or
complete the long-term objective.
S4-M404 additionally guards README prose for WASI runner self-test semantics; it
is portability documentation reliability and does not resolve S4-M11 or complete
the long-term objective.
S4-M405 additionally guards core-guide/API prose for WASI runner self-test
semantics; it is portability documentation reliability and does not resolve
S4-M11 or complete the long-term objective.
S4-M406 additionally guards tooling-catalog prose for WASI runner self-test
semantics; it is portability documentation reliability and does not resolve
S4-M11 or complete the long-term objective.
S4-M407 additionally guards the checked-tool row for WASI runner self-test
semantics; it is portability documentation reliability and does not resolve
S4-M11 or complete the long-term objective.
S4-M408 additionally tightens that checked-tool row guard so the full WASI runner
self-test semantics must stay together in the row; it is portability
documentation reliability and does not resolve S4-M11 or complete the long-term
objective.
S4-M409 additionally documents and guards direct Node WASI runner self-test
invocation in README; it is portability documentation reliability and does not
resolve S4-M11 or complete the long-term objective.
S4-M410 additionally documents and guards direct Node WASI runner dry-run
invocation in README; it is portability documentation reliability and does not
resolve S4-M11 or complete the long-term objective.
S4-M411 additionally documents WASI runner dry-run usage text; it is portability
tooling reliability and does not resolve S4-M11 or complete the long-term
objective.
S4-M412 additionally makes the WASI runner self-test validate its help prose; it
is portability tooling reliability and does not resolve S4-M11 or complete the
long-term objective.
S4-M413 additionally refreshes full `validate-all` evidence after WASI runner
help/self-test changes; it is validation evidence and does not resolve S4-M11 or
complete the long-term objective.
S4-M414 additionally documents and guards the tooling catalog row for WASI
help-output self-test coverage; it is portability tooling documentation
reliability and does not resolve S4-M11 or complete the long-term objective.
S4-M415 additionally documents and guards README prose for WASI help-output
self-test coverage; it is portability documentation reliability and does not
resolve S4-M11 or complete the long-term objective.
S4-M416 additionally documents and guards core-guide/API prose for WASI
help-output self-test coverage; it is portability documentation reliability and
does not resolve S4-M11 or complete the long-term objective.
S4-M417 additionally refreshes broad native `validate` evidence after the WASI
help-output documentation updates; it is validation evidence and does not
resolve S4-M11 or complete the long-term objective.
S4-M418 additionally refreshes local Rust comparison `validate-local` evidence
after the WASI help-output documentation updates; it is validation evidence and
does not resolve S4-M11 or complete the long-term objective.
S4-M419 additionally syncs S4-M11 blocker evidence with the fresh
`validate-local` output; it is blocker-evidence maintenance and does not resolve
S4-M11 or complete the long-term objective.
S4-M420 additionally records a concise current local `rand` / `rand_distr`
comparison status snapshot; it is status evidence and does not resolve S4-M11 or
complete the long-term objective.
S4-M421 additionally exposes that current local rand comparison snapshot from
README; it is documentation discoverability and does not resolve S4-M11 or
complete the long-term objective.
S4-M422 additionally exposes that current local rand comparison snapshot from
the core guide and API reference; it is documentation discoverability and does
not resolve S4-M11 or complete the long-term objective.
S4-M423 additionally exposes that current local rand comparison snapshot from
the tooling catalog; it is documentation discoverability and does not resolve
S4-M11 or complete the long-term objective.
S4-M424 additionally guards the current local rand comparison snapshot's
essential tokens; it is evidence-quality maintenance and does not resolve S4-M11
or complete the long-term objective.
S4-M425 additionally adds a `rand-status` status printer for current local
`rand` / `rand_distr` comparison evidence; it is tooling/discoverability and
does not resolve S4-M11 or complete the long-term objective.
S4-M426 additionally exposes `rand-status` from the core guide and API
reference; it is documentation discoverability and does not resolve S4-M11 or
complete the long-term objective.
S4-M427 additionally includes `rand-status` in `validate-local`; it is local
comparison validation ergonomics and does not resolve S4-M11 or complete the
long-term objective.
S4-M428 additionally refreshes `validate-local` evidence after adding
`rand-status` to the aggregate; it is validation evidence and does not resolve
S4-M11 or complete the long-term objective.
S4-M429 additionally syncs S4-M11 blocker evidence with the fresh rand-status
`validate-local` output; it is blocker-evidence maintenance and does not resolve
S4-M11 or complete the long-term objective.
S4-M430 additionally guards the `rand-status` output tokens; it is tooling
evidence-quality maintenance and does not resolve S4-M11 or complete the
long-term objective.
S4-M431 additionally adds scriptable JSON/help output to `rand-status`; it is
tooling ergonomics and does not resolve S4-M11 or complete the long-term
objective.

All other recently found S4-M4 side gaps have either been closed or narrowed by
checked-in evidence, including Hypergeometric H2PE coverage, static/dynamic
weighted samplers, f32 standard fills, OpenClosed f64 bulk, Cauchy, SkewNormal,
unit geometry direct rows, and many direct-source/bulk distribution workflows.
LogNormal exact defaults are now documented as a stable-output tradeoff with
multiple opt-in performance profiles (`BufferedLogNormal`, `LogNormalDlsymExp`,
`LogNormalLibmvec`, and f32 approximation/native variants) that cover the local
Rust performance gap without changing the exact default.
The SIMD performance gap has narrowed on the vector opt-in side: table-quantile
normal/exponential and f32 approximate-log exponential vector opt-ins now beat the
matching ziggurat lane-fill rows for users who accept explicit
approximation/output-mapping contracts, and distcheck now includes larger-sample
moment/CDF gates for those approximation profiles. S4-M5 is closed by policy,
S4-M6 is closed by native+WASI `profilecheck` hardening, S4-M7 is closed by
native+WASI `profiletailcheck` tail gates, and S4-M8 is closed by native+WASI
`profilestresscheck` multi-seed gates, and S4-M9 is closed by native+WASI
`profilelongcheck` long stress gates, and S4-M10 is closed by x86_64-linux-musl
`profilelongcheck` execution. S4-M11 remains unresolved because exact/default
normal/exponential kernels remain scalar ziggurat lane-fill, no further executed
architecture/runtime is available, and no new local Rust core gap is known.

## Required Next Work Before Completion

The goal remains active until at least one of these happens:

- a default/exact-compatible dense SIMD normal/exponential candidate beats
  scalar lane-fill in the real vector-slice harness while preserving or
  deliberately versioning rejected-lane stream shape;
- or a later roadmap audit raises/reshapes the bar again with explicit rationale.

Until then, do not call `update_goal(status=complete)`.
