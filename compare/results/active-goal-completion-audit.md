# Active Goal Completion Audit

Date: 2026-07-06

Active objective: keep working toward Alea's project mission until the goal is
actually achieved. In concrete terms for the current thread, this means driving
Alea's core RNG functionality and local Linux performance/validation roadmap to
no known core gaps against the locally available Rust `rand` / `rand_distr`
evidence, then raising the bar instead of declaring the product permanently
finished.

This audit is intentionally not a completion claim. It records the current
prompt-to-artifact checklist and the evidence that prevents calling the goal
complete.

## Current Completion Audit Refresh

Objective restated as concrete deliverables: Alea must have no known core RNG
functionality, ergonomics, reproducibility, statistical-quality, or performance
gaps versus the locally available Rust `rand` / `rand_distr` evidence; local
Linux comparison, validation, and status evidence must be current; and any next
raised roadmap bar must be closed before the active goal can be marked complete.

Current evidence is not sufficient for completion. S4-M420 records the current
local `rand` / `rand_distr` status snapshot, S4-M450/S4-M455 record the
`rand-status` command matrices, S4-M437/S4-M448 record recent
`zig build validate-local` passes, and S4-M438/S4-M449 keep the S4-M11 blocker
audit synchronized with those status signals. However, S4-M11 remains
unresolved: no exact/default-compatible dense SIMD normal/exponential winner is
known, no new genuine runtime/architecture runner is available, and no new local
Rust core gap is currently identified. Therefore do not call
`update_goal(status=complete)`.

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
| S4-M432 `rand-status-json` build step and aggregate | `build.zig`, `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, `docs/tooling.md`, `tools/readmecheck.zig`, `tools/toolingcheck.zig`, `compare/results/s4-m432-rand-status-json-step.md` | Closed for the current bar: `rand-status-json` prints stable JSON and is included in `validate-local`. |
| S4-M433 validate-local refresh after rand-status-json aggregate | `compare/results/s4-m433-validate-local-after-rand-status-json.md`, `compare/results/s4-m420-current-rand-status.md` | Closed for the current bar: `zig build validate-local` passed with text and JSON `rand-status` output included. |
| S4-M434 S4-M11 blocker sync after rand-status-json validate-local | `compare/results/s4-m11-blocker-audit.md`, `tools/roadmapcheck.zig`, `compare/results/s4-m434-blocker-rand-status-json-sync.md` | Closed for the current bar: S4-M11 blocker evidence now cites fresh S4-M433 `validate-local` output including JSON status. |
| S4-M435 `rand-status-json` schema documentation | `docs/tooling.md`, `tools/toolingcheck.zig`, `compare/results/s4-m435-rand-status-json-schema.md` | Closed for the current bar: tooling docs list and guard the stable `rand-status-json` fields. |
| S4-M436 `rand-status` self-test step | `tools/rand_status.zig`, `build.zig`, `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, `docs/tooling.md`, `tools/readmecheck.zig`, `tools/toolingcheck.zig`, `compare/results/s4-m436-rand-status-self-test.md` | Closed for the current bar: `rand-status` can self-test text/JSON/help output and `validate-local` runs that step. |
| S4-M437 validate-local refresh after rand-status self-test aggregate | `compare/results/s4-m437-validate-local-after-rand-status-self-test.md`, `compare/results/s4-m420-current-rand-status.md` | Closed for the current bar: `zig build validate-local` passed with `rand-status-self-test` included. |
| S4-M438 S4-M11 blocker sync after rand-status self-test validate-local | `compare/results/s4-m11-blocker-audit.md`, `tools/roadmapcheck.zig`, `compare/results/s4-m438-blocker-rand-status-self-test-sync.md` | Closed for the current bar: S4-M11 blocker evidence now cites fresh S4-M437 `validate-local` output including `rand-status-self-test`. |
| S4-M439 validate-local description includes status checks | `build.zig`, `tools/toolingcheck.zig`, `compare/results/s4-m439-validate-local-status-description.md` | Closed for the current bar: `validate-local` build-step description now includes status checks. |
| S4-M440 boolean fields in `rand-status-json` | `tools/rand_status.zig`, `docs/tooling.md`, `tools/toolingcheck.zig`, `compare/results/s4-m440-rand-status-json-booleans.md` | Closed for the current bar: `rand-status-json` now exposes stable boolean fields for pass/no-gap/blocker/runtime state. |
| S4-M441 S4-M11 blocker sync for rand-status JSON booleans | `compare/results/s4-m11-blocker-audit.md`, `tools/roadmapcheck.zig`, `compare/results/s4-m441-blocker-rand-status-boolean-sync.md` | Closed for the current bar: S4-M11 blocker evidence now cites the stable boolean JSON status fields. |
| S4-M442 current rand status snapshot JSON booleans | `compare/results/s4-m420-current-rand-status.md`, `tools/roadmapcheck.zig`, `compare/results/s4-m442-current-status-json-booleans.md` | Closed for the current bar: the current status snapshot includes and guards the JSON boolean fields. |
| S4-M443 `rand-status-json` schema version | `tools/rand_status.zig`, `docs/tooling.md`, `tools/toolingcheck.zig`, `compare/results/s4-m443-rand-status-schema-version.md` | Closed for the current bar: `rand-status-json` now exposes a stable schema version field. |
| S4-M444 current status snapshot schema version | `compare/results/s4-m420-current-rand-status.md`, `tools/roadmapcheck.zig`, `compare/results/s4-m444-current-status-schema-version.md` | Closed for the current bar: current status snapshot now includes and guards `schema_version: 1`. |
| S4-M445 S4-M11 blocker sync for rand-status schema version | `compare/results/s4-m11-blocker-audit.md`, `tools/roadmapcheck.zig`, `compare/results/s4-m445-blocker-rand-status-schema-sync.md` | Closed for the current bar: S4-M11 blocker evidence now cites the JSON `schema_version` token. |
| S4-M446 `rand-status` bad-argument self-test | `tools/rand_status.zig`, `docs/tooling.md`, `tools/toolingcheck.zig`, `compare/results/s4-m446-rand-status-bad-arg-self-test.md` | Closed for the current bar: `rand-status --self-test` validates the bad-argument path. |
| S4-M447 `rand-status` schema-version command | `tools/rand_status.zig`, `build.zig`, `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, `docs/tooling.md`, `tools/readmecheck.zig`, `tools/toolingcheck.zig`, `compare/results/s4-m447-rand-status-schema-version-step.md` | Closed for the current bar: `rand-status` exposes a schema-version command and build step. |
| S4-M448 validate-local refresh after rand-status-schema-version aggregate | `compare/results/s4-m448-validate-local-after-rand-status-schema-version.md`, `compare/results/s4-m420-current-rand-status.md` | Closed for the current bar: `zig build validate-local` passed with `rand-status-schema-version` included. |
| S4-M449 S4-M11 blocker sync after schema-version validate-local | `compare/results/s4-m11-blocker-audit.md`, `tools/roadmapcheck.zig`, `compare/results/s4-m449-blocker-rand-status-schema-version-sync.md` | Closed for the current bar: S4-M11 blocker evidence now cites fresh S4-M448 `validate-local` output including schema-version status. |
| S4-M450 `rand-status` command matrix refresh | `compare/results/s4-m450-rand-status-command-matrix.md` | Closed for the current bar: all `rand-status` text/JSON/schema/self-test/help commands pass. |
| S4-M451 `rand-status` command matrix guard | `compare/results/s4-m450-rand-status-command-matrix.md`, `tools/roadmapcheck.zig`, `compare/results/s4-m451-rand-status-matrix-guard.md` | Closed for the current bar: roadmapcheck guards essential command-matrix evidence tokens. |
| S4-M452 README rand-status command matrix discovery | `README.md`, `tools/readmecheck.zig`, `compare/results/s4-m452-readme-rand-status-matrix.md` | Closed for the current bar: README now links the latest `rand-status` command matrix evidence. |
| S4-M453 guide/API rand-status matrix discovery | `docs/core-guide.md`, `docs/api-reference.md`, `tools/toolingcheck.zig`, `compare/results/s4-m453-guide-api-rand-status-matrix.md` | Closed for the current bar: core guide/API now link the latest `rand-status` command matrix evidence. |
| S4-M454 tooling rand-status matrix discovery | `docs/tooling.md`, `tools/toolingcheck.zig`, `compare/results/s4-m454-tooling-rand-status-matrix.md` | Closed for the current bar: tooling catalog now links the latest `rand-status` command matrix evidence. |
| S4-M455 direct `rand-status` command matrix | `compare/results/s4-m455-rand-status-direct-matrix.md`, `tools/roadmapcheck.zig` | Closed for the current bar: direct documented JSON/schema/self-test `rand-status` forms pass and are guarded. |
| S4-M456 active completion audit refresh | `compare/results/active-goal-completion-audit.md`, `compare/results/s4-m456-active-completion-audit-refresh.md` | Closed for the current bar: active audit restates concrete deliverables, cites current rand-status / validate-local / blocker evidence, and explicitly remains not complete due to S4-M11. |
| S4-M457 active completion audit refresh guard | `tools/roadmapcheck.zig`, `compare/results/s4-m457-active-audit-refresh-guard.md` | Closed for the current bar: roadmapcheck guards the active audit refresh section and non-completion reasons. |
| S4-M458 latest validate-local evidence in `rand-status-json` | `tools/rand_status.zig`, `docs/tooling.md`, `tools/toolingcheck.zig`, `compare/results/s4-m458-rand-status-latest-evidence-field.md` | Closed for the current bar: `rand-status-json` now links directly to the latest validate-local evidence file. |
| S4-M459 current status latest-evidence field | `compare/results/s4-m420-current-rand-status.md`, `tools/roadmapcheck.zig`, `compare/results/s4-m459-current-status-latest-evidence.md` | Closed for the current bar: current status snapshot now includes and guards `latest_validate_local_evidence`. |
| S4-M460 S4-M11 blocker sync for latest-evidence field | `compare/results/s4-m11-blocker-audit.md`, `tools/roadmapcheck.zig`, `compare/results/s4-m460-blocker-latest-evidence-sync.md` | Closed for the current bar: S4-M11 blocker evidence now cites the JSON `latest_validate_local_evidence` token. |
| S4-M461 blocker audit link in `rand-status-json` | `tools/rand_status.zig`, `docs/tooling.md`, `tools/toolingcheck.zig`, `compare/results/s4-m461-rand-status-blocker-audit-field.md` | Closed for the current bar: `rand-status-json` now links directly to the S4-M11 blocker audit. |
| S4-M462 current status blocker-audit field | `compare/results/s4-m420-current-rand-status.md`, `tools/roadmapcheck.zig`, `compare/results/s4-m462-current-status-blocker-audit.md` | Closed for the current bar: current status snapshot now includes and guards `blocker_audit`. |
| S4-M463 validate-local refresh after blocker-audit status field | `compare/results/s4-m463-validate-local-after-blocker-audit-field.md`, `compare/results/s4-m420-current-rand-status.md` | Closed for the current bar: `zig build validate-local` passed with `blocker_audit` in JSON status output. |
| S4-M464 S4-M11 blocker sync after blocker-audit validate-local | `compare/results/s4-m11-blocker-audit.md`, `tools/roadmapcheck.zig`, `compare/results/s4-m464-blocker-blocker-audit-field-sync.md` | Closed for the current bar: S4-M11 blocker evidence now cites fresh S4-M463 `validate-local` output including `blocker_audit`. |
| S4-M465 explicit local-status link in `rand-status-json` | `tools/rand_status.zig`, `docs/tooling.md`, `tools/toolingcheck.zig`, `compare/results/s4-m465-rand-status-local-status-field.md` | Closed for the current bar: `rand-status-json` now exposes `local_rand_status`. |
| S4-M466 current status local-status field | `compare/results/s4-m420-current-rand-status.md`, `tools/roadmapcheck.zig`, `compare/results/s4-m466-current-status-local-status.md` | Closed for the current bar: current status snapshot now includes and guards `local_rand_status`. |
| S4-M467 S4-M11 blocker sync for local-status field | `compare/results/s4-m11-blocker-audit.md`, `tools/roadmapcheck.zig`, `compare/results/s4-m467-blocker-local-status-sync.md` | Closed for the current bar: S4-M11 blocker evidence now cites the JSON `local_rand_status` token. |
| S4-M468 validate-local refresh after local-status field | `compare/results/s4-m468-validate-local-after-local-status-field.md`, `compare/results/s4-m420-current-rand-status.md` | Closed for the current bar: `zig build validate-local` passed with `local_rand_status` in JSON status output. |
| S4-M469 latest validate-local evidence pointer refresh | `tools/rand_status.zig`, `tools/toolingcheck.zig`, `tools/roadmapcheck.zig`, `compare/results/s4-m469-latest-validate-local-evidence-pointer.md` | Closed for the current bar: `rand-status-json` now points `latest_validate_local_evidence` at the newest checked-in validate-local artifact. |
| S4-M470 S4-M11 blocker sync after latest-evidence pointer refresh | `compare/results/s4-m11-blocker-audit.md`, `tools/roadmapcheck.zig`, `compare/results/s4-m470-blocker-latest-evidence-pointer-sync.md` | Closed for the current bar: S4-M11 blocker evidence now cites the fresh S4-M469 `validate-local` output and current latest-evidence path. |
| S4-M471 root one-shot caller-owned fill helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m471-root-one-shot-fill-helpers.md` | Closed for the current bar: root system-entropy helpers can now fill caller-owned range/probability buffers without constructing a secure engine. |
| S4-M472 root one-shot allocation batch helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m472-root-one-shot-batch-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate random value/range/probability batches directly. |
| S4-M473 root one-shot string helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m473-root-one-shot-string-helpers.md` | Closed for the current bar: root system-entropy helpers can now generate alphanumeric strings and Unicode UTF-8/scalars directly. |
| S4-M474 root one-shot endpoint-float helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m474-root-one-shot-endpoint-float-helpers.md` | Closed for the current bar: root system-entropy helpers can now fill or allocate strict `(0,1)` and `(0,1]` float samples directly. |
| S4-M475 root one-shot duration helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m475-root-one-shot-duration-helpers.md` | Closed for the current bar: root system-entropy helpers can now sample and allocate `std.Io.Duration` ranges directly. |
| S4-M476 root one-shot Unicode scalar range helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m476-root-one-shot-unicode-scalar-helpers.md` | Closed for the current bar: root system-entropy helpers can now fill and allocate Unicode scalar ranges directly. |
| S4-M477 root one-shot sampler helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m477-root-one-shot-sampler-helpers.md` | Closed for the current bar: root system-entropy helpers can now sample, fill, and allocate from arbitrary reusable samplers directly. |
| S4-M478 root one-shot choice helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m478-root-one-shot-choice-helpers.md` | Closed for the current bar: root system-entropy helpers can now choose indices and values directly. |
| S4-M479 root one-shot shuffle helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m479-root-one-shot-shuffle-helpers.md` | Closed for the current bar: root system-entropy helpers can now run full and partial in-place shuffles directly. |
| S4-M480 root one-shot weighted index helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m480-root-one-shot-weighted-index-helpers.md` | Closed for the current bar: root system-entropy helpers can now sample weighted indices directly. |
| S4-M481 root one-shot compact index choice helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m481-root-one-shot-compact-index-helpers.md` | Closed for the current bar: root system-entropy helpers can now choose compact `u32` indices directly. |
| S4-M482 root one-shot fixed-size choice arrays | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m482-root-one-shot-choice-array-helpers.md` | Closed for the current bar: root system-entropy helpers can now produce fixed-size index/value choice arrays directly. |
| S4-M483 root one-shot const-pointer choice helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m483-root-one-shot-const-ptr-choice-helpers.md` | Closed for the current bar: root system-entropy helpers can now choose const pointers directly. |
| S4-M484 root one-shot mutable-pointer choice helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m484-root-one-shot-mut-ptr-choice-helpers.md` | Closed for the current bar: root system-entropy helpers can now choose mutable pointers directly. |
| S4-M485 root one-shot compact weighted index helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m485-root-one-shot-weighted-u32-index-helpers.md` | Closed for the current bar: root system-entropy helpers can now sample compact `u32` weighted indices directly. |
| S4-M486 root one-shot weighted index arrays | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m486-root-one-shot-weighted-index-array-helpers.md` | Closed for the current bar: root system-entropy helpers can now produce fixed-size weighted index arrays directly. |
| S4-M487 root one-shot weighted value helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m487-root-one-shot-weighted-value-helpers.md` | Closed for the current bar: root system-entropy helpers can now sample weighted values directly. |
| S4-M488 root one-shot weighted const-pointer helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m488-root-one-shot-weighted-const-ptr-helpers.md` | Closed for the current bar: root system-entropy helpers can now sample weighted const pointers directly. |
| S4-M489 root one-shot weighted mutable-pointer helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m489-root-one-shot-weighted-mut-ptr-helpers.md` | Closed for the current bar: root system-entropy helpers can now sample weighted mutable pointers directly. |
| S4-M490 root one-shot no-replacement value sampling | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m490-root-one-shot-no-replacement-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate no-replacement value samples directly. |
| S4-M491 root one-shot no-replacement index sampling | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m491-root-one-shot-no-replacement-index-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate/fill no-replacement index samples directly. |
| S4-M492 root one-shot iterator choice helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m492-root-one-shot-iterator-choice-helpers.md` | Closed for the current bar: root system-entropy helpers can now choose one item from iterators directly. |
| S4-M493 root one-shot weighted iterator choice helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m493-root-one-shot-weighted-iterator-choice-helpers.md` | Closed for the current bar: root system-entropy helpers can now choose one item from weighted iterators directly. |
| S4-M494 root one-shot iterator sampling helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m494-root-one-shot-iterator-sampling-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate iterator samples directly. |
| S4-M495 root one-shot caller-owned iterator sampling | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m495-root-one-shot-iterator-into-helpers.md` | Closed for the current bar: root system-entropy helpers can now fill caller-owned iterator sample buffers directly. |
| S4-M496 root one-shot fixed-size iterator sample arrays | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m496-root-one-shot-iterator-array-helpers.md` | Closed for the current bar: root system-entropy helpers can now produce fixed-size iterator sample arrays directly. |
| S4-M497 root one-shot weighted iterator sampling | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m497-root-one-shot-weighted-iterator-sampling-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate weighted iterator samples directly. |
| S4-M498 root one-shot caller-owned weighted iterator sampling | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m498-root-one-shot-weighted-iterator-into-helpers.md` | Closed for the current bar: root system-entropy helpers can now fill caller-owned weighted iterator sample buffers directly. |
| S4-M499 root one-shot fixed-size weighted iterator arrays | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m499-root-one-shot-weighted-iterator-array-helpers.md` | Closed for the current bar: root system-entropy helpers can now produce fixed-size weighted iterator sample arrays directly. |
| S4-M500 root one-shot weighted no-replacement index sampling | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m500-root-one-shot-weighted-no-replacement-index-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate weighted no-replacement index samples directly. |
| S4-M501 root one-shot weighted no-replacement value sampling | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m501-root-one-shot-weighted-no-replacement-value-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate weighted no-replacement value samples directly. |
| S4-M502 root one-shot weighted no-replacement value arrays | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m502-root-one-shot-weighted-no-replacement-array-helpers.md` | Closed for the current bar: root system-entropy helpers can now produce fixed-size weighted no-replacement value arrays directly. |
| S4-M503 root one-shot weighted no-replacement const-pointer sampling | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m503-root-one-shot-weighted-no-replacement-const-ptr-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate weighted no-replacement const-pointer samples directly. |
| S4-M504 root one-shot weighted no-replacement mutable-pointer sampling | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m504-root-one-shot-weighted-no-replacement-mut-ptr-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate weighted no-replacement mutable-pointer samples directly. |
| S4-M505 root one-shot weighted no-replacement caller-owned index buffers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m505-root-one-shot-weighted-no-replacement-index-into-helpers.md` | Closed for the current bar: root system-entropy helpers can now fill caller-owned weighted no-replacement index buffers directly. |
| S4-M506 root one-shot weighted no-replacement caller-owned value buffers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m506-root-one-shot-weighted-no-replacement-value-into-helpers.md` | Closed for the current bar: root system-entropy helpers can now fill caller-owned weighted no-replacement value buffers directly. |
| S4-M507 root one-shot weighted no-replacement caller-owned const-pointer buffers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m507-root-one-shot-weighted-no-replacement-const-ptr-into-helpers.md` | Closed for the current bar: root system-entropy helpers can now fill caller-owned weighted no-replacement const-pointer buffers directly. |
| S4-M508 root one-shot weighted no-replacement caller-owned mutable-pointer buffers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m508-root-one-shot-weighted-no-replacement-mut-ptr-into-helpers.md` | Closed for the current bar: root system-entropy helpers can now fill caller-owned weighted no-replacement mutable-pointer buffers directly. |
| S4-M509 root one-shot weighted no-replacement index arrays | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m509-root-one-shot-weighted-no-replacement-index-array-helpers.md` | Closed for the current bar: root system-entropy helpers can now produce fixed-size weighted no-replacement index arrays directly. |
| S4-M510 root one-shot compact index-vector sampling | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m510-root-one-shot-indexvec-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate compact `IndexVec` no-replacement samples directly. |
| S4-M511 root one-shot weighted no-replacement compact index-vector sampling | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m511-root-one-shot-weighted-no-replacement-indexvec-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate compact weighted no-replacement `IndexVec` samples directly. |
| S4-M512 root one-shot no-replacement fixed-size index arrays | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m512-root-one-shot-index-array-helpers.md` | Closed for the current bar: root system-entropy helpers can now produce fixed-size no-replacement index arrays directly. |
| S4-M513 root one-shot no-replacement fixed-size value arrays | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m513-root-one-shot-value-array-helpers.md` | Closed for the current bar: root system-entropy helpers can now produce fixed-size no-replacement value arrays directly. |
| S4-M514 root one-shot no-replacement fixed-size const-pointer arrays | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m514-root-one-shot-const-ptr-array-helpers.md` | Closed for the current bar: root system-entropy helpers can now produce fixed-size no-replacement const-pointer arrays directly. |
| S4-M515 root one-shot no-replacement fixed-size mutable-pointer arrays | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m515-root-one-shot-mut-ptr-array-helpers.md` | Closed for the current bar: root system-entropy helpers can now produce fixed-size no-replacement mutable-pointer arrays directly. |
| S4-M516 root one-shot no-replacement const-pointer sampling | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m516-root-one-shot-const-ptr-sampling-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate no-replacement const-pointer samples directly. |
| S4-M517 root one-shot no-replacement mutable-pointer sampling | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m517-root-one-shot-mut-ptr-sampling-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate no-replacement mutable-pointer samples directly. |
| S4-M518 root one-shot no-replacement caller-owned value and pointer buffers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m518-root-one-shot-no-replacement-into-helpers.md` | Closed for the current bar: root system-entropy helpers can now fill caller-owned no-replacement value, const-pointer, and mutable-pointer buffers directly. |
| S4-M519 root chooseMultiple no-replacement aliases | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m519-root-choose-multiple-aliases.md` | Closed for the current bar: root system-entropy helpers now include Rust-discoverable `chooseMultiple*` aliases for no-replacement value, const-pointer, mutable-pointer, and caller-owned buffers. |
| S4-M520 root sampled no-replacement value and pointer iterators | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m520-root-sampled-iterator-helpers.md` | Closed for the current bar: root system-entropy helpers can now create owned sampled no-replacement value, const-pointer, and mutable-pointer iterators directly. |
| S4-M521 root one-shot reservoir value and pointer helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m521-root-reservoir-helpers.md` | Closed for the current bar: root system-entropy helpers can now create allocation-returning and caller-owned value, const-pointer, and mutable-pointer reservoir samples directly. |
| S4-M522 root repeated with-replacement fixed-size choice arrays | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m522-root-repeated-choice-array-helpers.md` | Closed for the current bar: root system-entropy helpers now include explicit repeated with-replacement fixed-size value, const-pointer, and mutable-pointer choice array aliases. |
| S4-M523 root iterator sample-fill aliases | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m523-root-iterator-sample-fill-aliases.md` | Closed for the current bar: root system-entropy helpers now include Rust-discoverable `sampleIteratorFill*` aliases for caller-owned iterator reservoir sampling. |
| S4-M524 root no-replacement value array choose aliases | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m524-root-choose-array-aliases.md` | Closed for the current bar: root system-entropy helpers now include Rust-discoverable `chooseArray*` aliases for fixed-size no-replacement value arrays. |
| S4-M525 root one-shot index-weighted index helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m525-root-weighted-by-index-helpers.md` | Closed for the current bar: root system-entropy helpers can now sample one `usize` or `u32` weighted index from a length and comptime index-weight function directly. |
| S4-M526 root one-shot index-weighted fill helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m526-root-weighted-by-index-fill-helpers.md` | Closed for the current bar: root system-entropy helpers can now fill caller-owned `usize` or `u32` weighted indexes from a length and comptime index-weight function directly. |
| S4-M527 root one-shot index-weighted batch helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m527-root-weighted-by-index-batch-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate owned `usize` or `u32` weighted index batches from a length and comptime index-weight function directly. |
| S4-M528 root one-shot index-weighted array helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m528-root-weighted-by-index-array-helpers.md` | Closed for the current bar: root system-entropy helpers can now produce fixed-size `usize` or `u32` weighted index arrays from a length and comptime index-weight function directly. |
| S4-M529 root one-shot index-weighted value choice helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m529-root-weighted-value-by-index-helpers.md` | Closed for the current bar: root system-entropy helpers can now choose values from an item slice and comptime index-weight function directly. |
| S4-M530 root one-shot index-weighted const-pointer choice helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m530-root-weighted-const-ptr-by-index-helpers.md` | Closed for the current bar: root system-entropy helpers can now choose const pointers from an item slice and comptime index-weight function directly. |
| S4-M531 root one-shot index-weighted mutable-pointer choice helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m531-root-weighted-mut-ptr-by-index-helpers.md` | Closed for the current bar: root system-entropy helpers can now choose mutable pointers from a mutable item slice and comptime index-weight function directly. |
| S4-M532 root one-shot index-weighted value fill helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m532-root-weighted-value-by-index-fill-helpers.md` | Closed for the current bar: root system-entropy helpers can now fill caller-owned value buffers from an item slice and comptime index-weight function directly. |
| S4-M533 root one-shot index-weighted const-pointer fill helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m533-root-weighted-const-ptr-by-index-fill-helpers.md` | Closed for the current bar: root system-entropy helpers can now fill caller-owned const-pointer buffers from an item slice and comptime index-weight function directly. |
| S4-M534 root one-shot index-weighted mutable-pointer fill helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m534-root-weighted-mut-ptr-by-index-fill-helpers.md` | Closed for the current bar: root system-entropy helpers can now fill caller-owned mutable-pointer buffers from a mutable item slice and comptime index-weight function directly. |
| S4-M535 root one-shot index-weighted value batch helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m535-root-weighted-value-by-index-batch-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate value batches from an item slice and comptime index-weight function directly. |
| S4-M536 root one-shot index-weighted const-pointer batch helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m536-root-weighted-const-ptr-by-index-batch-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate const-pointer batches from an item slice and comptime index-weight function directly. |
| S4-M537 root one-shot index-weighted mutable-pointer batch helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m537-root-weighted-mut-ptr-by-index-batch-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate mutable-pointer batches from a mutable item slice and comptime index-weight function directly. |
| S4-M538 root one-shot index-weighted value array helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m538-root-weighted-value-by-index-array-helpers.md` | Closed for the current bar: root system-entropy helpers can now produce fixed-size value arrays from an item slice and comptime index-weight function directly. |
| S4-M539 root one-shot index-weighted const-pointer array helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m539-root-weighted-const-ptr-by-index-array-helpers.md` | Closed for the current bar: root system-entropy helpers can now produce fixed-size const-pointer arrays from an item slice and comptime index-weight function directly. |
| S4-M540 root one-shot index-weighted mutable-pointer array helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m540-root-weighted-mut-ptr-by-index-array-helpers.md` | Closed for the current bar: root system-entropy helpers can now produce fixed-size mutable-pointer arrays from a mutable item slice and comptime index-weight function directly. |
| S4-M541 root item-accessor weighted index helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m541-root-weighted-by-helpers.md` | Closed for the current bar: root system-entropy helpers can now sample weighted indices directly from an item slice and comptime item-weight accessor. |
| S4-M542 root item-accessor weighted u32 index helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m542-root-weighted-u32-by-helpers.md` | Closed for the current bar: root system-entropy helpers can now sample compact `u32` weighted indices directly from an item slice and comptime item-weight accessor. |
| S4-M543 root item-accessor weighted index fill helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m543-root-weighted-by-fill-helpers.md` | Closed for the current bar: root system-entropy helpers can now fill caller-owned weighted index buffers directly from an item slice and comptime item-weight accessor. |
| S4-M544 root item-accessor weighted u32 index fill helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m544-root-weighted-u32-by-fill-helpers.md` | Closed for the current bar: root system-entropy helpers can now fill caller-owned compact `u32` weighted index buffers directly from an item slice and comptime item-weight accessor. |
| S4-M545 root item-accessor weighted index batch helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m545-root-weighted-by-batch-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate repeated weighted index batches directly from an item slice and comptime item-weight accessor. |
| S4-M546 root item-accessor weighted u32 index batch helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m546-root-weighted-u32-by-batch-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate repeated compact `u32` weighted index batches directly from an item slice and comptime item-weight accessor. |
| S4-M547 root item-accessor weighted index array helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m547-root-weighted-by-array-helpers.md` | Closed for the current bar: root system-entropy helpers can now produce fixed-size weighted index arrays directly from an item slice and comptime item-weight accessor. |
| S4-M548 root item-accessor weighted u32 index array helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m548-root-weighted-u32-by-array-helpers.md` | Closed for the current bar: root system-entropy helpers can now produce fixed-size compact `u32` weighted index arrays directly from an item slice and comptime item-weight accessor. |
| S4-M549 root item-accessor weighted value choice helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m549-root-weighted-by-value-helpers.md` | Closed for the current bar: root system-entropy helpers can now choose weighted values directly from an item slice and comptime item-weight accessor. |
| S4-M550 root item-accessor weighted const-pointer choice helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m550-root-weighted-by-const-ptr-helpers.md` | Closed for the current bar: root system-entropy helpers can now choose weighted const pointers directly from an item slice and comptime item-weight accessor. |
| S4-M551 root item-accessor weighted mutable-pointer choice helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m551-root-weighted-by-mut-ptr-helpers.md` | Closed for the current bar: root system-entropy helpers can now choose weighted mutable pointers directly from a mutable item slice and comptime item-weight accessor. |
| S4-M552 root item-accessor weighted value fill helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m552-root-weighted-by-value-fill-helpers.md` | Closed for the current bar: root system-entropy helpers can now fill caller-owned weighted value buffers directly from an item slice and comptime item-weight accessor. |
| S4-M553 root item-accessor weighted const-pointer fill helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m553-root-weighted-by-const-ptr-fill-helpers.md` | Closed for the current bar: root system-entropy helpers can now fill caller-owned weighted const-pointer buffers directly from an item slice and comptime item-weight accessor. |
| S4-M554 root item-accessor weighted mutable-pointer fill helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m554-root-weighted-by-mut-ptr-fill-helpers.md` | Closed for the current bar: root system-entropy helpers can now fill caller-owned weighted mutable-pointer buffers directly from a mutable item slice and comptime item-weight accessor. |
| S4-M555 root item-accessor weighted value batch helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m555-root-weighted-by-value-batch-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate repeated weighted value batches directly from an item slice and comptime item-weight accessor. |
| S4-M556 root item-accessor weighted const-pointer batch helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m556-root-weighted-by-const-ptr-batch-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate repeated weighted const-pointer batches directly from an item slice and comptime item-weight accessor. |
| S4-M557 root item-accessor weighted mutable-pointer batch helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m557-root-weighted-by-mut-ptr-batch-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate repeated weighted mutable-pointer batches directly from a mutable item slice and comptime item-weight accessor. |
| S4-M558 root item-accessor weighted value array helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m558-root-weighted-by-value-array-helpers.md` | Closed for the current bar: root system-entropy helpers can now produce fixed-size weighted value arrays directly from an item slice and comptime item-weight accessor. |
| S4-M559 root item-accessor weighted const-pointer array helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m559-root-weighted-by-const-ptr-array-helpers.md` | Closed for the current bar: root system-entropy helpers can now produce fixed-size weighted const-pointer arrays directly from an item slice and comptime item-weight accessor. |
| S4-M560 root item-accessor weighted mutable-pointer array helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m560-root-weighted-by-mut-ptr-array-helpers.md` | Closed for the current bar: root system-entropy helpers can now produce fixed-size weighted mutable-pointer arrays directly from a mutable item slice and comptime item-weight accessor. |
| S4-M561 root item-accessor weighted value sample helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m561-root-weighted-by-sample-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate no-replacement weighted value samples directly from an item slice and comptime item-weight accessor. |
| S4-M562 root item-accessor weighted const-pointer sample helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m562-root-weighted-by-const-ptr-sample-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate no-replacement weighted const-pointer samples directly from an item slice and comptime item-weight accessor. |
| S4-M563 root item-accessor weighted mutable-pointer sample helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m563-root-weighted-by-mut-ptr-sample-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate no-replacement weighted mutable-pointer samples directly from a mutable item slice and comptime item-weight accessor. |
| S4-M564 root item-accessor weighted value into helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m564-root-weighted-by-value-into-helpers.md` | Closed for the current bar: root system-entropy helpers can now fill caller-owned no-replacement weighted value buffers directly from an item slice and comptime item-weight accessor. |
| S4-M565 root item-accessor weighted const-pointer into helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m565-root-weighted-by-const-ptr-into-helpers.md` | Closed for the current bar: root system-entropy helpers can now fill caller-owned no-replacement weighted const-pointer buffers directly from an item slice and comptime item-weight accessor. |
| S4-M566 root item-accessor weighted mutable-pointer into helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m566-root-weighted-by-mut-ptr-into-helpers.md` | Closed for the current bar: root system-entropy helpers can now fill caller-owned no-replacement weighted mutable-pointer buffers directly from a mutable item slice and comptime item-weight accessor. |
| S4-M567 root item-accessor weighted index sample helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m567-root-weighted-by-index-sample-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate no-replacement weighted `usize` index samples directly from an item slice and comptime item-weight accessor. |
| S4-M568 root item-accessor weighted compact u32 index sample helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m568-root-weighted-by-u32-index-sample-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate no-replacement weighted compact `u32` index samples directly from an item slice and comptime item-weight accessor. |
| S4-M569 root item-accessor weighted IndexVec sample helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m569-root-weighted-by-index-vec-sample-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate no-replacement weighted `IndexVec` samples directly from an item slice and comptime item-weight accessor. |
| S4-M570 root item-accessor weighted index into helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m570-root-weighted-by-index-into-helpers.md` | Closed for the current bar: root system-entropy helpers can now fill caller-owned no-replacement weighted `usize` index buffers directly from an item slice and comptime item-weight accessor. |
| S4-M571 root item-accessor weighted index array helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m571-root-weighted-by-index-array-helpers.md` | Closed for the current bar: root system-entropy helpers can now produce fixed-size no-replacement weighted `usize` index arrays directly from an item slice and comptime item-weight accessor. |
| S4-M572 root item-accessor weighted compact u32 index array helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m572-root-weighted-by-u32-index-array-helpers.md` | Closed for the current bar: root system-entropy helpers can now produce fixed-size no-replacement weighted compact `u32` index arrays directly from an item slice and comptime item-weight accessor. |
| S4-M573 root length-weighted index sample helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m573-root-weighted-by-index-index-sample-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate no-replacement weighted `usize` index samples directly from a length and comptime index-weight accessor. |
| S4-M574 root length-weighted compact u32 index sample helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m574-root-weighted-by-index-u32-sample-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate no-replacement weighted compact `u32` index samples directly from a length and comptime index-weight accessor. |
| S4-M575 root length-weighted IndexVec sample helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m575-root-weighted-by-index-vec-index-sample-helpers.md` | Closed for the current bar: root system-entropy helpers can now allocate no-replacement weighted `IndexVec` samples directly from a length and comptime index-weight accessor. |
| S4-M576 root length-weighted index into helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m576-root-weighted-by-index-index-into-helpers.md` | Closed for the current bar: root system-entropy helpers can now fill caller-owned no-replacement weighted `usize` index buffers directly from a length and comptime index-weight accessor. |
| S4-M577 root length-weighted compact u32 index into helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m577-root-weighted-by-index-u32-into-helpers.md` | Closed for the current bar: root system-entropy helpers can now fill caller-owned no-replacement weighted compact `u32` index buffers directly from a length and comptime index-weight accessor. |
| S4-M578 root length-weighted index array helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m578-root-weighted-by-index-index-array-helpers.md` | Closed for the current bar: root system-entropy helpers can now produce fixed-size no-replacement weighted `usize` index arrays directly from a length and comptime index-weight accessor. |
| S4-M579 root length-weighted compact u32 index array helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m579-root-weighted-by-index-u32-array-helpers.md` | Closed for the current bar: root system-entropy helpers can now produce fixed-size no-replacement weighted compact `u32` index arrays directly from a length and comptime index-weight accessor. |
| S4-M580 root item-accessor weighted value array sample helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m580-root-weighted-by-value-array-sample-helpers.md` | Closed for the current bar: root system-entropy helpers can now produce fixed-size no-replacement weighted value arrays directly from an item slice and comptime item-weight accessor. |
| S4-M581 root item-accessor weighted const-pointer array sample helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m581-root-weighted-by-const-ptr-array-sample-helpers.md` | Closed for the current bar: root system-entropy helpers can now produce fixed-size no-replacement weighted const-pointer arrays directly from an item slice and comptime item-weight accessor. |
| S4-M582 root item-accessor weighted mutable-pointer array sample helpers | `src/root.zig`, `examples/basic.zig`, `docs/api-reference.md`, `tools/examplecheck.zig`, `compare/results/s4-m582-root-weighted-by-mut-ptr-array-sample-helpers.md` | Closed for the current bar: root system-entropy helpers can now produce fixed-size no-replacement weighted mutable-pointer arrays directly from a mutable item slice and comptime item-weight accessor. |
| S4-M583 root parallel-weighted value sample prevalidation | `src/root.zig`, `compare/results/s4-m583-root-weighted-value-sample-prevalidation.md` | Closed for the current bar: root parallel-weighted value sample helpers now validate deterministic no-entropy paths before secure-engine construction. |
| S4-M584 root parallel-weighted const-pointer sample prevalidation | `src/root.zig`, `compare/results/s4-m584-root-weighted-const-ptr-sample-prevalidation.md` | Closed for the current bar: root parallel-weighted const-pointer sample helpers now validate deterministic no-entropy paths before secure-engine construction. |
| S4-M585 root parallel-weighted mutable-pointer sample prevalidation | `src/root.zig`, `compare/results/s4-m585-root-weighted-mut-ptr-sample-prevalidation.md` | Closed for the current bar: root parallel-weighted mutable-pointer sample helpers now validate deterministic no-entropy paths before secure-engine construction. |
| S4-M586 root parallel-weighted value array prevalidation | `src/root.zig`, `compare/results/s4-m586-root-weighted-value-array-prevalidation.md` | Closed for the current bar: root parallel-weighted value array helpers now validate deterministic no-entropy paths before secure-engine construction. |
| S4-M587 root parallel-weighted const-pointer array prevalidation | `src/root.zig`, `compare/results/s4-m587-root-weighted-const-ptr-array-prevalidation.md` | Closed for the current bar: root parallel-weighted const-pointer array helpers now validate deterministic no-entropy paths before secure-engine construction. |
| S4-M588 root parallel-weighted mutable-pointer array prevalidation | `src/root.zig`, `compare/results/s4-m588-root-weighted-mut-ptr-array-prevalidation.md` | Closed for the current bar: root parallel-weighted mutable-pointer array helpers now validate deterministic no-entropy paths before secure-engine construction. |
| S4-M589 root weighted-iterator fixed-array lazy entropy | `src/root.zig`, `compare/results/s4-m589-root-weighted-iterator-array-lazy-entropy.md` | Closed for the current bar: root weighted iterator fixed-size array helpers now defer secure-engine construction until random competition is required. |
| S4-M590 root weighted-iterator allocated sample lazy entropy | `src/root.zig`, `compare/results/s4-m590-root-weighted-iterator-allocated-lazy-entropy.md` | Closed for the current bar: root allocated weighted iterator sample helpers now defer secure-engine construction until random competition is required. |
| S4-M591 root weighted-iterator into lazy entropy | `src/root.zig`, `compare/results/s4-m591-root-weighted-iterator-into-lazy-entropy.md` | Closed for the current bar: root weighted iterator into helpers now defer secure-engine construction until random competition is required. |
| S4-M592 root index fill/batch empty-range prevalidation | `src/root.zig`, `compare/results/s4-m592-root-index-fill-batch-empty-range-prevalidation.md` | Closed for the current bar: root index fill and batch helpers now reject non-empty zero-length ranges before secure-engine construction. |
| S4-M593 root value choose fill/batch empty-input prevalidation | `src/root.zig`, `compare/results/s4-m593-root-value-choose-fill-batch-empty-input-prevalidation.md` | Closed for the current bar: root value choose fill and batch helpers now reject non-empty empty-input requests before secure-engine construction. |
| S4-M594 root const-pointer choose fill/batch empty-input prevalidation | `src/root.zig`, `compare/results/s4-m594-root-const-ptr-choose-fill-batch-empty-input-prevalidation.md` | Closed for the current bar: root const-pointer choose fill and batch helpers now reject non-empty empty-input requests before secure-engine construction. |
| S4-M595 root mutable-pointer choose fill/batch empty-input prevalidation | `src/root.zig`, `compare/results/s4-m595-root-mut-ptr-choose-fill-batch-empty-input-prevalidation.md` | Closed for the current bar: root mutable-pointer choose fill and batch helpers now reject non-empty empty-input requests before secure-engine construction. |
| S4-M596 root weighted-index invalid-weight prevalidation | `src/root.zig`, `compare/results/s4-m596-root-weighted-index-invalid-weight-prevalidation.md` | Closed for the current bar: root weighted-index helpers now validate invalid-weight paths before secure-engine construction and before random-output allocation. |
| S4-M597 root weighted value batch prevalidation | `src/root.zig`, `compare/results/s4-m597-root-weighted-value-batch-prevalidation.md` | Closed for the current bar: root weighted value batch helpers now prevalidate deterministic and invalid paths before random-output allocation and secure-engine construction. |
| S4-M598 root weighted const-pointer batch prevalidation | `src/root.zig`, `compare/results/s4-m598-root-weighted-const-ptr-batch-prevalidation.md` | Closed for the current bar: root weighted const-pointer batch helpers now prevalidate deterministic and invalid paths before random-output allocation and secure-engine construction. |
| S4-M599 root weighted mutable-pointer batch prevalidation | `src/root.zig`, `compare/results/s4-m599-root-weighted-mut-ptr-batch-prevalidation.md` | Closed for the current bar: root weighted mutable-pointer batch helpers now prevalidate deterministic and invalid paths before random-output allocation and secure-engine construction. |
| S4-M600 root item-accessor weighted value batch prevalidation | `src/root.zig`, `compare/results/s4-m600-root-weighted-by-value-batch-prevalidation.md` | Closed for the current bar: root item-accessor weighted value batch helpers now prevalidate deterministic and invalid paths before random-output allocation and secure-engine construction. |
| S4-M601 root item-accessor weighted const-pointer batch prevalidation | `src/root.zig`, `compare/results/s4-m601-root-weighted-by-const-ptr-batch-prevalidation.md` | Closed for the current bar: root item-accessor weighted const-pointer batch helpers now prevalidate deterministic and invalid paths before random-output allocation and secure-engine construction. |
| S4-M602 root item-accessor weighted mutable-pointer batch prevalidation | `src/root.zig`, `compare/results/s4-m602-root-weighted-by-mut-ptr-batch-prevalidation.md` | Closed for the current bar: root item-accessor weighted mutable-pointer batch helpers now prevalidate deterministic and invalid paths before random-output allocation and secure-engine construction. |
| S4-M603 root by-index weighted value batch prevalidation | `src/root.zig`, `compare/results/s4-m603-root-weighted-by-index-value-batch-prevalidation.md` | Closed for the current bar: root by-index weighted value batch helpers now prevalidate deterministic and invalid paths before random-output allocation and secure-engine construction. |
| S4-M604 root by-index weighted const-pointer batch prevalidation | `src/root.zig`, `compare/results/s4-m604-root-weighted-by-index-const-ptr-batch-prevalidation.md` | Closed for the current bar: root by-index weighted const-pointer batch helpers now prevalidate deterministic and invalid paths before random-output allocation and secure-engine construction. |
| S4-M605 root by-index weighted mutable-pointer batch prevalidation | `src/root.zig`, `compare/results/s4-m605-root-weighted-by-index-mut-ptr-batch-prevalidation.md` | Closed for the current bar: root by-index weighted mutable-pointer batch helpers now prevalidate deterministic and invalid paths before random-output allocation and secure-engine construction. |
| S4-M606 root item-accessor weighted index batch prevalidation | `src/root.zig`, `compare/results/s4-m606-root-weighted-by-index-batch-prevalidation.md` | Closed for the current bar: root item-accessor weighted index batch helpers now prevalidate deterministic and invalid paths before random-output allocation and secure-engine construction. |
| S4-M607 root item-accessor weighted compact u32 index batch prevalidation | `src/root.zig`, `compare/results/s4-m607-root-weighted-by-u32-index-batch-prevalidation.md` | Closed for the current bar: root item-accessor weighted compact u32 index batch helpers now prevalidate deterministic and invalid paths before random-output allocation and secure-engine construction. |
| S4-M608 root by-index weighted index batch prevalidation | `src/root.zig`, `compare/results/s4-m608-root-weighted-by-index-index-batch-prevalidation.md` | Closed for the current bar: root length/by-index weighted index batch helpers now prevalidate deterministic and invalid paths before random-output allocation and secure-engine construction. |
| S4-M609 root by-index weighted compact u32 index batch prevalidation | `src/root.zig`, `compare/results/s4-m609-root-weighted-by-index-u32-index-batch-prevalidation.md` | Closed for the current bar: root length/by-index weighted compact u32 index batch helpers now prevalidate deterministic and invalid paths before random-output allocation and secure-engine construction. |
| S4-M610 root checked scalar batch parameter prevalidation | `src/root.zig`, `compare/results/s4-m610-root-checked-scalar-batch-prevalidation.md` | Closed for the current bar: root checked scalar batch helpers now prevalidate invalid parameters before random-output allocation and secure-engine construction. |
| S4-M611 root checked inclusive integer batch parameter prevalidation | `src/root.zig`, `compare/results/s4-m611-root-checked-inclusive-batch-prevalidation.md` | Closed for the current bar: root checked inclusive integer range batch helpers now prevalidate invalid parameters before random-output allocation and secure-engine construction. |
| S4-M612 root checked Unicode scalar batch parameter prevalidation | `src/root.zig`, `compare/results/s4-m612-root-checked-unicode-batch-prevalidation.md` | Closed for the current bar: root checked Unicode scalar range batch helpers now prevalidate invalid ranges/code points before random-output allocation and secure-engine construction. |
| S4-M613 root duration range batch parameter prevalidation | `src/root.zig`, `compare/results/s4-m613-root-duration-batch-prevalidation.md` | Closed for the current bar: root duration range batch helpers now prevalidate invalid parameters before random-output allocation and secure-engine construction. |
| S4-M614 root Unicode scalar batch parameter prevalidation | `src/root.zig`, `compare/results/s4-m614-root-unicode-batch-prevalidation.md` | Closed for the current bar: root unchecked Unicode scalar range batch helpers now prevalidate invalid ranges/code points before random-output allocation and secure-engine construction. |
| S4-M615 root checked value choose batch empty-input prevalidation | `src/root.zig`, `compare/results/s4-m615-root-checked-value-choose-batch-prevalidation.md` | Closed for the current bar: root checked value choose batch helper now prevalidates non-zero empty-input requests before output allocation and secure-engine construction. |
| S4-M616 root checked const-pointer choose batch empty-input prevalidation | `src/root.zig`, `compare/results/s4-m616-root-checked-const-ptr-choose-batch-prevalidation.md` | Closed for the current bar: root checked const-pointer choose batch helper now prevalidates non-zero empty-input requests before output allocation and secure-engine construction. |
| S4-M617 root checked mutable-pointer choose batch empty-input prevalidation | `src/root.zig`, `compare/results/s4-m617-root-checked-mut-ptr-choose-batch-prevalidation.md` | Closed for the current bar: root checked mutable-pointer choose batch helper now prevalidates non-zero empty-input requests before output allocation and secure-engine construction. |
| S4-M618 root scalar range batch parameter prevalidation | `src/root.zig`, `compare/results/s4-m618-root-scalar-range-batch-prevalidation.md` | Closed for the current bar: root scalar range batch helpers now prevalidate invalid ranges before random-output allocation and secure-engine construction. |
| S4-M619 root probability batch parameter prevalidation | `src/root.zig`, `compare/results/s4-m619-root-probability-batch-prevalidation.md` | Closed for the current bar: root boolean probability and ratio batch helpers now prevalidate invalid parameters before random-output allocation and secure-engine construction. |
| S4-M620 root value batch empty-type prevalidation | `src/root.zig`, `compare/results/s4-m620-root-value-batch-empty-type-prevalidation.md` | Closed for the current bar: root value batch helper now prevalidates non-zero uninhabited value types before output allocation and secure-engine construction. |
| S4-M621 root no-replacement value sample empty-type prevalidation | `src/root.zig`, `compare/results/s4-m621-root-no-replacement-empty-type-prevalidation.md` | Closed for the current bar: root checked no-replacement value sampling now prevalidates non-zero uninhabited value types before output allocation and secure-engine construction. |
| S4-M622 root Unicode scalar range prevalidation | `src/root.zig`, `compare/results/s4-m622-root-unicode-range-prevalidation.md` | Closed for the current bar: root unchecked Unicode scalar range scalar/fill helpers now prevalidate invalid ranges/code points before secure-engine construction. |
| S4-M623 root sampler batch empty-type prevalidation | `src/root.zig`, `compare/results/s4-m623-root-sampler-batch-empty-type-prevalidation.md` | Closed for the current bar: root generic sampler batch helper now prevalidates non-zero uninhabited output types before output allocation and secure-engine construction. |
| S4-M624 root generic value empty-type prevalidation | `src/root.zig`, `compare/results/s4-m624-root-generic-value-empty-type-prevalidation.md` | Closed for the current bar: root generic value scalar/fill/sample helpers now prevalidate uninhabited output types before secure-engine construction. |
| S4-M625 root scalar range prevalidation | `src/root.zig`, `compare/results/s4-m625-root-scalar-range-prevalidation.md` | Closed for the current bar: root scalar range scalar/fill helpers now prevalidate invalid ranges before secure-engine construction. |
| S4-M626 root random iterator empty-type prevalidation | `src/root.zig`, `compare/results/s4-m626-root-random-iter-empty-type-prevalidation.md` | Closed for the current bar: root random value iterator helper now prevalidates uninhabited element types before secure-engine construction. |
| S4-M627 root probability scalar/fill prevalidation | `src/root.zig`, `compare/results/s4-m627-root-probability-scalar-fill-prevalidation.md` | Closed for the current bar: root unchecked boolean probability and ratio scalar/fill helpers now prevalidate invalid parameters before secure-engine construction. |
| S4-M628 root secure bytes empty-output prevalidation | `src/root.zig`, `compare/results/s4-m628-root-secure-bytes-empty-prevalidation.md` | Closed for the current bar: root secure byte helper now returns for empty buffers before requesting system entropy. |
| S4-M629 root duration scalar range prevalidation | `src/root.zig`, `compare/results/s4-m629-root-duration-scalar-prevalidation.md` | Closed for the current bar: root duration range scalar helpers now prevalidate invalid ranges before secure-engine construction. |
| S4-M630 root weighted value sample empty-type prevalidation | `src/root.zig`, `compare/results/s4-m630-root-weighted-value-sample-empty-type-prevalidation.md` | Closed for the current bar: root weighted value sample helpers now prevalidate non-zero uninhabited value types before random-output allocation and secure-engine construction. |
| S4-M631 root item-accessor weighted value sample empty-type prevalidation | `src/root.zig`, `compare/results/s4-m631-root-weighted-by-value-sample-empty-type-prevalidation.md` | Closed for the current bar: root item-accessor weighted value sample helpers now prevalidate non-zero uninhabited value types before random-output allocation and secure-engine construction. |
| S4-M632 root weighted value array empty-type prevalidation | `src/root.zig`, `compare/results/s4-m632-root-weighted-value-array-empty-type-prevalidation.md` | Closed for the current bar: root weighted fixed-size value array helpers now prevalidate non-zero uninhabited value types before secure-engine construction. |
| S4-M633 root item-accessor weighted value array empty-type prevalidation | `src/root.zig`, `compare/results/s4-m633-root-weighted-by-value-array-empty-type-prevalidation.md` | Closed for the current bar: root item-accessor weighted fixed-size value array helpers now prevalidate non-zero uninhabited value types before secure-engine construction. |
| S4-M634 root item-accessor weighted value choose array empty-type prevalidation | `src/root.zig`, `compare/results/s4-m634-root-weighted-by-value-choice-array-empty-type-prevalidation.md` | Closed for the current bar: root item-accessor weighted repeated-choice fixed-size value array helpers now prevalidate non-zero uninhabited value types before secure-engine construction. |
| S4-M635 root weighted value choice array empty-type prevalidation | `src/root.zig`, `compare/results/s4-m635-root-weighted-value-choice-array-empty-type-prevalidation.md` | Closed for the current bar: root weighted repeated-choice fixed-size value array helpers now prevalidate non-zero uninhabited value types before secure-engine construction. |
| S4-M636 root by-index weighted value choice array empty-type prevalidation | `src/root.zig`, `compare/results/s4-m636-root-weighted-by-index-value-choice-array-empty-type-prevalidation.md` | Closed for the current bar: root by-index weighted repeated-choice fixed-size value array helpers now prevalidate non-zero uninhabited value types before secure-engine construction. |
| S4-M637 root unweighted value choose empty-type prevalidation | `src/root.zig`, `compare/results/s4-m637-root-value-choose-empty-type-prevalidation.md` | Closed for the current bar: root unweighted value choose helpers now prevalidate non-empty uninhabited value type requests before output allocation and secure-engine construction. |
| S4-M638 root unweighted index-into invalid-count prevalidation | `src/root.zig`, `compare/results/s4-m638-root-index-into-invalid-count-prevalidation.md` | Closed for the current bar: root unweighted index output-buffer helpers now reject oversized output buffers before secure-engine construction in unchecked variants. |
| S4-M639 root unweighted index allocation invalid-count prevalidation | `src/root.zig`, `compare/results/s4-m639-root-index-alloc-invalid-count-prevalidation.md` | Closed for the current bar: root unweighted index allocation helpers now reject oversized sample amounts before allocation and secure-engine construction in unchecked variants. |
| S4-M640 root unweighted no-replacement allocation/iterator invalid-count prevalidation | `src/root.zig`, `compare/results/s4-m640-root-no-replacement-alloc-iter-invalid-count-prevalidation.md` | Closed for the current bar: root unweighted no-replacement value/pointer allocation and iterator helpers now reject oversized sample amounts before allocation and secure-engine construction in unchecked variants. |
| S4-M641 root checked iterator exact-short prevalidation | `src/root.zig`, `compare/results/s4-m641-root-iterator-exact-short-prevalidation.md` | Closed for the current bar: root checked iterator sample helpers now reject exact-known short iterators before allocation, entropy, and iterator consumption. |
| S4-M642 root unchecked iterator exact-short prevalidation | `src/root.zig`, `compare/results/s4-m642-root-unchecked-iterator-exact-short-prevalidation.md` | Closed for the current bar: root unchecked iterator allocation/array helpers now avoid oversized allocation and pre-return exact-short array cases before entropy or iterator consumption where possible. |
| S4-M643 root weighted index allocation prevalidation | `src/root.zig`, `compare/results/s4-m643-root-weighted-index-alloc-prevalidation.md` | Closed for the current bar: root parallel-weighted index allocation helpers now resolve empty, all-zero, single-positive, and checked oversized requests before secure-engine construction. |
| S4-M644 direct sequence index allocation invalid-count prevalidation | `src/seq.zig`, `compare/results/s4-m644-seq-index-alloc-invalid-count-prevalidation.md` | Closed for the current bar: direct `seq` unchecked index allocation helpers now reject oversized sample amounts before allocation and random-stream use. |
| S4-M645 Rng no-replacement invalid-count prevalidation | `src/rng.zig`, `compare/results/s4-m645-rng-no-replacement-invalid-count-prevalidation.md` | Closed for the current bar: `Rng` unchecked no-replacement value sampling now rejects oversized sample counts before allocation and random-stream use. |
| S4-M646 ASCII charset unchecked empty prevalidation | `src/ascii.zig`, `compare/results/s4-m646-ascii-charset-unchecked-empty-prevalidation.md` | Closed for the current bar: ASCII `Charset` unchecked allocation/string helpers now reject non-zero empty charsets before allocation, random-stream use, or buffer mutation. |
| S4-M647 Unicode charset unchecked invalid prevalidation | `src/ascii.zig`, `compare/results/s4-m647-unicode-charset-unchecked-invalid-prevalidation.md` | Closed for the current bar: `UnicodeCharset` unchecked UTF-8 string helpers now reject non-zero empty/invalid scalar sets before allocation, random-stream use, or buffer mutation. |
| S4-M648 Rng unchecked repeated choice empty prevalidation | `src/rng.zig`, `compare/results/s4-m648-rng-repeated-choice-empty-prevalidation.md` | Closed for the current bar: `Rng` unchecked repeated choice/index batch helpers now reject non-zero empty inputs before allocation and random-stream use. |
| S4-M649 seq unchecked repeated choice empty prevalidation | `src/seq.zig`, `compare/results/s4-m649-seq-repeated-choice-empty-prevalidation.md` | Closed for the current bar: `seq` unchecked repeated choice/index batch aliases now reject non-zero empty inputs before allocation and random-stream use with seq-style `error.EmptyInput`. |
| S4-M650 Rng repeated choice fill empty-output prevalidation | `src/rng.zig`, `compare/results/s4-m650-rng-choice-fill-empty-output-prevalidation.md` | Closed for the current bar: `Rng` unchecked repeated choice/index fill helpers now treat empty output buffers as no-op before empty-choice validation or assertions. |
| S4-M651 Rng weighted nullable batch prevalidation | `src/rng.zig`, `compare/results/s4-m651-rng-weighted-nullable-batch-prevalidation.md` | Closed for the current bar: `Rng` unchecked weighted nullable fill/batch helpers now resolve invalid/all-zero/single-positive/empty-output cases before repeated one-shot sampling and unnecessary stream use. |
| S4-M652 Rng scalar fill empty-output prevalidation | `src/rng.zig`, `compare/results/s4-m652-rng-scalar-fill-empty-output-prevalidation.md` | Closed for the current bar: `Rng` unchecked scalar range/probability fill helpers now treat empty output buffers as no-op before invalid parameter assertions. |
| S4-M653 Rng vector fill empty-output prevalidation | `src/rng.zig`, `compare/results/s4-m653-rng-vector-fill-empty-output-prevalidation.md` | Closed for the current bar: `Rng` unchecked vector range/probability fill helpers now treat empty output buffers as no-op before invalid parameter assertions. |
| S4-M654 Rng scalar normal/exponential fill empty-output prevalidation | `src/rng.zig`, `compare/results/s4-m654-rng-normal-exponential-fill-empty-output-prevalidation.md` | Closed for the current bar: `Rng` unchecked scalar normal/exponential fill helpers now treat empty output buffers as no-op before invalid parameter assertions. |
| S4-M655 Rng vector normal/exponential fill empty-output prevalidation | `src/rng.zig`, `compare/results/s4-m655-rng-vector-normal-exponential-fill-empty-output-prevalidation.md` | Closed for the current bar: `Rng` unchecked vector normal/exponential fill helpers now treat empty output buffers as no-op before invalid parameter assertions. |
| S4-M656 Rng scalar normal/exponential batch invalid-parameter prevalidation | `src/rng.zig`, `compare/results/s4-m656-rng-normal-exponential-batch-invalid-prevalidation.md` | Closed for the current bar: `Rng` unchecked scalar normal/exponential batch helpers now reject invalid parameters before allocation and random-stream use. |
| S4-M657 Rng vector normal/exponential batch invalid-parameter prevalidation | `src/rng.zig`, `compare/results/s4-m657-rng-vector-normal-exponential-batch-invalid-prevalidation.md` | Closed for the current bar: `Rng` unchecked vector normal/exponential batch helpers now reject invalid parameters before allocation and random-stream use. |
| S4-M658 Rng scalar range/probability batch invalid-parameter prevalidation | `src/rng.zig`, `compare/results/s4-m658-rng-scalar-batch-invalid-prevalidation.md` | Closed for the current bar: `Rng` unchecked scalar range/probability batch helpers now reject invalid parameters before allocation and random-stream use. |
| S4-M659 Rng vector range/probability batch invalid-parameter prevalidation | `src/rng.zig`, `compare/results/s4-m659-rng-vector-batch-invalid-prevalidation.md` | Closed for the current bar: `Rng` unchecked vector range/probability batch helpers now reject invalid parameters before allocation and random-stream use. |
| S4-M660 Rng duration batch invalid-range prevalidation | `src/rng.zig`, `compare/results/s4-m660-rng-duration-batch-invalid-prevalidation.md` | Closed for the current bar: `Rng` unchecked duration range batch helpers now reject invalid ranges before allocation and random-stream use. |
| S4-M661 Rng Unicode scalar range batch invalid-parameter prevalidation | `src/rng.zig`, `compare/results/s4-m661-rng-unicode-batch-invalid-prevalidation.md` | Closed for the current bar: `Rng` unchecked Unicode scalar range batch helpers now reject invalid scalar/range parameters before allocation and random-stream use. |
| S4-M662 Rng Unicode scalar fill empty-output prevalidation | `src/rng.zig`, `compare/results/s4-m662-rng-unicode-fill-empty-output-prevalidation.md` | Closed for the current bar: `Rng` unchecked Unicode scalar range fill helpers now treat empty output buffers as no-op before invalid parameter assertions. |
| S4-M663 Rng value batch empty-type prevalidation | `src/rng.zig`, `compare/results/s4-m663-rng-value-batch-empty-type-prevalidation.md` | Closed for the current bar: `Rng` unchecked value batch helpers now reject non-zero uninhabited value types before allocation and random-stream use. |
| S4-M664 Rng sample batch empty-type prevalidation | `src/rng.zig`, `compare/results/s4-m664-rng-sample-batch-empty-type-prevalidation.md` | Closed for the current bar: `Rng` unchecked sampler batch helpers now reject non-zero uninhabited output types before allocation and random-stream use. |
| S4-M665 Rng sampler fill empty-output prevalidation | `src/rng.zig`, `compare/results/s4-m665-rng-sampler-fill-empty-output-prevalidation.md` | Closed for the current bar: `Rng` generic sampler fill helpers now treat empty output buffers as no-op before invoking sampler fill hooks. |
| S4-M666 root checked index batch empty-range prevalidation | `src/root.zig`, `compare/results/s4-m666-root-checked-index-batch-empty-range-prevalidation.md` | Closed for the current bar: root checked usize/u32 index batch helpers now reject non-zero zero-length ranges before allocation and secure-engine construction. |
| S4-M667 Rng no-replacement empty-type prevalidation | `src/rng.zig`, `compare/results/s4-m667-rng-no-replacement-empty-type-prevalidation.md` | Closed for the current bar: `Rng` no-replacement value sampling now rejects non-zero uninhabited value types before allocation and random-stream use. |
| S4-M668 root chooseMultiple empty-type prevalidation | `src/root.zig`, `compare/results/s4-m668-root-choose-multiple-empty-type-prevalidation.md` | Closed for the current bar: root `chooseMultiple` value alias now rejects non-zero uninhabited value types before allocation and secure-engine construction. |
| S4-M669 root fixed value array empty-type prevalidation | `src/root.zig`, `compare/results/s4-m669-root-value-array-empty-type-prevalidation.md` | Closed for the current bar: root fixed-size no-replacement value array helpers now reject non-zero uninhabited value types before secure-engine construction or deterministic value copying. |
| S4-M670 root caller-owned value sample empty-type prevalidation | `src/root.zig`, `compare/results/s4-m670-root-value-into-empty-type-prevalidation.md` | Closed for the current bar: root caller-owned no-replacement value buffer helpers now reject non-zero uninhabited value types before secure-engine construction or deterministic value copying. |
| S4-M671 seq fixed value array empty-type prevalidation | `src/seq.zig`, `compare/results/s4-m671-seq-value-array-empty-type-prevalidation.md` | Closed for the current bar: `seq` fixed-size no-replacement value array helpers now reject non-zero uninhabited value types before index sampling or value copying. |
| S4-M672 seq caller-owned value sample empty-type prevalidation | `src/seq.zig`, `compare/results/s4-m672-seq-value-into-empty-type-prevalidation.md` | Closed for the current bar: `seq` caller-owned no-replacement value buffer helpers now reject non-zero uninhabited value types before index sampling or value copying. |
| S4-M673 seq owned value sample empty-type prevalidation | `src/seq.zig`, `compare/results/s4-m673-seq-owned-value-empty-type-prevalidation.md` | Closed for the current bar: `seq` allocation-returning no-replacement value sample helpers now reject non-zero uninhabited value types before output/index allocation and random-stream use. |
| S4-M674 seq sampled value iterator empty-type prevalidation | `src/seq.zig`, `compare/results/s4-m674-seq-value-iter-empty-type-prevalidation.md` | Closed for the current bar: `seq` sampled value iterator helpers now reject non-zero uninhabited value types before index allocation and random-stream use. |
| S4-M675 IndexVec value mapping empty-type prevalidation | `src/seq.zig`, `compare/results/s4-m675-indexvec-value-empty-type-prevalidation.md` | Closed for the current bar: `IndexVec` value mapping helpers now reject non-empty uninhabited value types before owned allocation or value copying. |
| S4-M676 reservoir value sample empty-type prevalidation | `src/seq.zig`, `src/root.zig`, `compare/results/s4-m676-reservoir-value-empty-type-prevalidation.md` | Closed for the current bar: `seq` and root reservoir value sampling now reject non-zero uninhabited value types before allocation, entropy, or value copying. |
| S4-M677 seq iterator reservoir empty-type prevalidation | `src/seq.zig`, `compare/results/s4-m677-seq-iterator-value-empty-type-prevalidation.md` | Closed for the current bar: `seq` iterator reservoir value helpers now reject non-zero uninhabited value types before allocation, iterator consumption, or random-stream use. |
| S4-M678 root iterator reservoir empty-type prevalidation | `src/root.zig`, `compare/results/s4-m678-root-iterator-value-empty-type-prevalidation.md` | Closed for the current bar: root iterator reservoir value helpers now reject non-zero uninhabited value types before allocation, entropy, iterator consumption, or secure-engine construction. |
| S4-M679 seq weighted iterator reservoir empty-type prevalidation | `src/seq.zig`, `compare/results/s4-m679-seq-weighted-iterator-empty-type-prevalidation.md` | Closed for the current bar: `seq` weighted iterator reservoir value helpers now reject non-zero uninhabited value types before heap allocation, iterator consumption, or random-stream use. |
| S4-M680 root weighted iterator reservoir empty-type prevalidation | `src/root.zig`, `compare/results/s4-m680-root-weighted-iterator-empty-type-prevalidation.md` | Closed for the current bar: root weighted iterator reservoir value helpers now reject non-zero uninhabited value types before allocation, entropy, iterator consumption, heap allocation, or secure-engine construction. |
| S4-M681 seq weighted value choice empty-type prevalidation | `src/seq.zig`, `compare/results/s4-m681-seq-weighted-value-empty-type-prevalidation.md` | Closed for the current bar: `seq` weighted value choice helpers now reject non-zero uninhabited value types before weighted-index sampling, allocation, or value copying. |
| S4-M682 seq accessor-weighted value choice empty-type prevalidation | `src/seq.zig`, `compare/results/s4-m682-seq-weighted-by-value-empty-type-prevalidation.md` | Closed for the current bar: `seq` item-accessor weighted value choice helpers now reject non-zero uninhabited value types before accessor weight evaluation, weighted-index sampling, allocation, or value copying. |
| S4-M683 seq index-weighted value choice empty-type prevalidation | `src/seq.zig`, `compare/results/s4-m683-seq-weighted-by-index-value-empty-type-prevalidation.md` | Closed for the current bar: `seq` index-weighted value choice helpers now reject non-zero uninhabited value types before index-weight validation, weighted-index sampling, allocation, or value copying. |
| S4-M684 root accessor-weighted value choice empty-type prevalidation | `src/root.zig`, `compare/results/s4-m684-root-weighted-by-value-empty-type-prevalidation.md` | Closed for the current bar: root item-accessor weighted value choice helpers now reject non-zero uninhabited value types before accessor weight evaluation, allocation, entropy, or value copying. |
| S4-M685 root index-weighted value choice empty-type prevalidation | `src/root.zig`, `compare/results/s4-m685-root-weighted-by-index-value-empty-type-prevalidation.md` | Closed for the current bar: root index-weighted value choice helpers now reject non-zero uninhabited value types before index-weight validation, allocation, entropy, or value copying. |
| S4-M686 root weighted value choice empty-type prevalidation | `src/root.zig`, `compare/results/s4-m686-root-weighted-value-empty-type-prevalidation.md` | Closed for the current bar: root parallel-weight value choice helpers now reject non-zero uninhabited value types before weighted-index sampling, allocation, entropy, or value copying. |
| S4-M687 Rng regular-struct empty-type prevalidation | `src/rng.zig`, `compare/results/s4-m687-rng-regular-struct-empty-type-prevalidation.md` | Closed for the current bar: `Rng` empty-type detection now rejects regular structs containing empty enum fields before allocation or random-stream use. |
| S4-M688 seq weighted sample empty-type prevalidation | `src/seq.zig`, `compare/results/s4-m688-seq-weighted-sample-empty-type-prevalidation.md` | Closed for the current bar: `seq` parallel-weighted no-replacement value sample helpers now reject non-zero uninhabited value types before allocation, weighted-key sampling, random-stream use, or value copying. |
| S4-M689 seq accessor-weighted sample empty-type prevalidation | `src/seq.zig`, `compare/results/s4-m689-seq-weighted-by-sample-empty-type-prevalidation.md` | Closed for the current bar: `seq` item-accessor weighted no-replacement value sample helpers now reject non-zero uninhabited value types before accessor weight evaluation, allocation, weighted-key sampling, random-stream use, or value copying. |
| S4-M690 root weighted into empty-type prevalidation | `src/root.zig`, `compare/results/s4-m690-root-weighted-into-empty-type-prevalidation.md` | Closed for the current bar: root weighted no-replacement caller-owned value helpers now reject non-zero uninhabited output types before accessor weight evaluation, entropy, secure-engine construction, weighted-key sampling, random-stream use, or value copying. |
| S4-M691 rng weighted value empty-type prevalidation | `src/rng.zig`, `compare/results/s4-m691-rng-weighted-value-empty-type-prevalidation.md` | Closed for the current bar: `Rng` weighted value-choice helpers now reject non-zero uninhabited output types before allocation, weighted-index sampling, random-stream use, or value copying. |
| S4-M692 rng value choice empty-type prevalidation | `src/rng.zig`, `compare/results/s4-m692-rng-value-choice-empty-type-prevalidation.md` | Closed for the current bar: `Rng` unweighted value-choice helpers now reject non-zero uninhabited output types before allocation, index sampling, random-stream use, or value copying. |
| S4-M693 seq repeated value array empty-type prevalidation | `src/seq.zig`, `compare/results/s4-m693-seq-repeated-value-array-empty-type-prevalidation.md` | Closed for the current bar: `seq` repeated with-replacement fixed value arrays now reject non-zero uninhabited output types before random-stream use or value copying. |
| S4-M694 seq repeated value fill/batch empty-type prevalidation | `src/seq.zig`, `compare/results/s4-m694-seq-repeated-value-fill-batch-empty-type-prevalidation.md` | Closed for the current bar: `seq` repeated with-replacement value fill/batch aliases now reject non-empty uninhabited output types before allocation, random-stream use, or value copying. |
| S4-M695 seq one-shot choice empty-type prevalidation | `src/seq.zig`, `compare/results/s4-m695-seq-one-shot-choice-empty-type-prevalidation.md` | Closed for the current bar: `seq` one-shot value choice aliases now reject non-empty uninhabited output types before random-stream use or value copying. |
| S4-M696 seq iterator choice empty-type prevalidation | `src/seq.zig`, `compare/results/s4-m696-seq-iterator-choice-empty-type-prevalidation.md` | Closed for the current bar: `seq` one-shot iterator value choice helpers now reject uninhabited output types before iterator consumption, random-stream use, or value copying. |
| S4-M697 root iterator choice empty-type prevalidation | `src/root.zig`, `compare/results/s4-m697-root-iterator-choice-empty-type-prevalidation.md` | Closed for the current bar: root one-shot iterator value choice helpers now reject uninhabited output types before iterator consumption, entropy, secure-engine construction, random-stream use, or value copying. |
| S4-M698 root weighted iterator choice empty-type prevalidation | `src/root.zig`, `compare/results/s4-m698-root-weighted-iterator-choice-empty-type-prevalidation.md` | Closed for the current bar: root weighted iterator one-shot value choice helpers now reject uninhabited output types before iterator consumption, weight evaluation, entropy, secure-engine construction, random-stream use, or value copying. |
| S4-M699 root sampled value iterator empty-type prevalidation | `src/root.zig`, `compare/results/s4-m699-root-sampled-value-iter-empty-type-prevalidation.md` | Closed for the current bar: root sampled value iterator aliases now reject non-zero uninhabited output types before index allocation, entropy, secure-engine construction, random-stream use, iterator construction, or value copying. |
| S4-M700 seq weighted iterator choice empty-type prevalidation | `src/seq.zig`, `compare/results/s4-m700-seq-weighted-iterator-choice-empty-type-prevalidation.md` | Closed for the current bar: `seq` weighted iterator one-shot value choice helpers now reject uninhabited output types before iterator consumption, weight evaluation, random-stream use, or value copying. |
| S4-M701 seq unchecked iterator into empty-type prevalidation | `src/seq.zig`, `compare/results/s4-m701-seq-unchecked-iterator-into-empty-type-prevalidation.md` | Closed for the current bar: `seq` unchecked caller-owned iterator value fills now treat non-empty uninhabited output buffers as zero-fill no-ops before iterator consumption, random-stream use, or value copying. |
| S4-M702 seq weighted choice iterator empty-type prevalidation | `src/seq.zig`, `compare/results/s4-m702-seq-weighted-choice-iter-empty-type-prevalidation.md` | Closed for the current bar: `seq` reusable weighted choice iterator constructors now reject non-empty uninhabited value types before weight validation/evaluation, allocation, random-stream use, iterator construction, or value access. |
| S4-M703 weightedchoice value-copy empty-type prevalidation | `src/seq.zig`, `compare/results/s4-m703-weightedchoice-value-copy-empty-type-prevalidation.md` | Closed for the current bar: reusable `WeightedChoice` value-copy helpers now handle non-empty uninhabited output types before allocation, random-stream use, or value copying. |
| S4-M704 choice value-copy empty-type prevalidation | `src/seq.zig`, `compare/results/s4-m704-choice-value-copy-empty-type-prevalidation.md` | Closed for the current bar: reusable `Choice` value-copy helpers now handle non-empty uninhabited output types before allocation, random-stream use, or value copying. |
| S4-M705 choice checked value array | `src/seq.zig`, `compare/results/s4-m705-choice-checked-value-array.md` | Closed for the current bar: reusable `Choice` now has checked fixed-size value array helpers that reject non-zero uninhabited output types before random-stream use or value copying. |
| S4-M706 weightedchoice checked value array | `src/seq.zig`, `docs/api-reference.md`, `compare/results/s4-m706-weightedchoice-checked-value-array.md` | Closed for the current bar: reusable `WeightedChoice` now has checked fixed-size value array helpers that reject non-zero uninhabited output types before random-stream use or value copying. |
| S4-M707 distribution choose value-copy empty-type prevalidation | `src/distributions.zig`, `compare/results/s4-m707-distribution-choose-value-copy-empty-type-prevalidation.md` | Closed for the current bar: distribution-layer `Choose` value-copy fills now handle non-empty uninhabited output types before random-stream use or value copying. |
| S4-M708 distribution choose value array | `src/distributions.zig`, `docs/api-reference.md`, `compare/results/s4-m708-distribution-choose-value-array.md` | Closed for the current bar: distribution-layer `Choose` now has fixed-size value array helpers, including checked empty-type failures before random-stream use or value copying. |
| S4-M709 distribution choose owned values | `src/distributions.zig`, `docs/api-reference.md`, `compare/results/s4-m709-distribution-choose-owned-values.md` | Closed for the current bar: distribution-layer `Choose` now has owned repeated value helpers with empty-type failures before allocation, random-stream use, or value copying. |
| S4-M710 distribution choose pointer outputs | `src/distributions.zig`, `docs/api-reference.md`, `compare/results/s4-m710-distribution-choose-pointer-outputs.md` | Closed for the current bar: distribution-layer `Choose` now has fixed-size and owned pointer output helpers. |
| S4-M711 distribution choose index outputs | `src/distributions.zig`, `docs/api-reference.md`, `compare/results/s4-m711-distribution-choose-index-outputs.md` | Closed for the current bar: distribution-layer `Choose` now has scalar, caller-owned, owned, and fixed-size usize index output helpers. |
| S4-M712 distribution choose u32 index outputs | `src/distributions.zig`, `docs/api-reference.md`, `compare/results/s4-m712-distribution-choose-u32-index-outputs.md` | Closed for the current bar: distribution-layer `Choose` now has scalar, caller-owned, owned, and fixed-size u32 index output helpers. |
| S4-M713 distribution choose index iterators | `src/distributions.zig`, `docs/api-reference.md`, `compare/results/s4-m713-distribution-choose-index-iterators.md` | Closed for the current bar: distribution-layer `Choose` now has reusable usize and u32 index iterators. |
| S4-M714 distribution choose introspection | `src/distributions.zig`, `docs/api-reference.md`, `compare/results/s4-m714-distribution-choose-introspection.md` | Closed for the current bar: distribution-layer `Choose` now exposes item metadata and lookup helpers on the sampler. |
| S4-M715 distribution choose probability introspection | `src/distributions.zig`, `docs/api-reference.md`, `compare/results/s4-m715-distribution-choose-probability-introspection.md` | Closed for the current bar: distribution-layer `Choose` now exposes probability lookup/output/iteration helpers and exact iterator size hints. |
| S4-M716 distribution choose checked index aliases | `src/distributions.zig`, `docs/api-reference.md`, `compare/results/s4-m716-distribution-choose-checked-index-aliases.md` | Closed for the current bar: distribution-layer `Choose` now has checked aliases for scalar, caller-owned, owned, and fixed-size usize index outputs. |
| S4-M717 distribution choose checked u32 index aliases | `src/distributions.zig`, `docs/api-reference.md`, `compare/results/s4-m717-distribution-choose-checked-u32-index-aliases.md` | Closed for the current bar: distribution-layer `Choose` now has checked aliases for scalar, caller-owned, owned, and fixed-size u32 index outputs. |
| S4-M718 distribution choose checked values | `src/distributions.zig`, `docs/api-reference.md`, `compare/results/s4-m718-distribution-choose-checked-values.md` | Closed for the current bar: distribution-layer `Choose` now has checked scalar value-copy helpers with empty-type failures before random-stream use or value copying. |
| S4-M719 distribution choose pointer iterators | `src/distributions.zig`, `docs/api-reference.md`, `compare/results/s4-m719-distribution-choose-pointer-iterators.md` | Closed for the current bar: distribution-layer `Choose` now has reusable pointer iterators. |
| S4-M720 distribution choose checked pointer aliases | `src/distributions.zig`, `docs/api-reference.md`, `compare/results/s4-m720-distribution-choose-checked-pointer-aliases.md` | Closed for the current bar: distribution-layer `Choose` now has checked aliases for caller-owned, owned, and fixed-size pointer outputs. |
| S4-M721 distribution choose value iterators | `src/distributions.zig`, `docs/api-reference.md`, `compare/results/s4-m721-distribution-choose-value-iterators.md` | Closed for the current bar: distribution-layer `Choose` now has reusable value iterators. |
| S4-M722 distribution choose checked iterator aliases | `src/distributions.zig`, `docs/api-reference.md`, `compare/results/s4-m722-distribution-choose-checked-iterator-aliases.md` | Closed for the current bar: distribution-layer `Choose` now has checked aliases for value, pointer, and usize index iterators. |
| S4-M723 choice checked values | `src/seq.zig`, `docs/api-reference.md`, `compare/results/s4-m723-choice-checked-values.md` | Closed for the current bar: reusable `Choice` now has checked scalar value-copy helpers with empty-type failures before random-stream use or value copying. |
| S4-M724 weightedchoice checked values | `src/seq.zig`, `docs/api-reference.md`, `compare/results/s4-m724-weightedchoice-checked-values.md` | Closed for the current bar: reusable `WeightedChoice` now has checked scalar value-copy helpers with empty-type failures before random-stream use or value copying. |
| S4-M725 choice value iterators | `src/seq.zig`, `docs/api-reference.md`, `compare/results/s4-m725-choice-value-iterators.md` | Closed for the current bar: reusable `Choice` now has value iterator helpers with checked empty-type construction. |
| S4-M726 weightedchoice value iterators | `src/seq.zig`, `docs/api-reference.md`, `compare/results/s4-m726-weightedchoice-value-iterators.md` | Closed for the current bar: reusable `WeightedChoice` now has value iterator helpers with checked empty-type construction. |
| S4-M727 choice pointer iterator aliases | `src/seq.zig`, `docs/api-reference.md`, `compare/results/s4-m727-choice-pointer-iterator-aliases.md` | Closed for the current bar: reusable `Choice` now has explicit pointer iterator aliases and checked aliases. |
| S4-M728 weightedchoice pointer iterator aliases | `src/seq.zig`, `docs/api-reference.md`, `compare/results/s4-m728-weightedchoice-pointer-iterator-aliases.md` | Closed for the current bar: reusable `WeightedChoice` now has explicit pointer iterator aliases and checked aliases. |
| S4-M729 choice checked pointer aliases | `src/seq.zig`, `docs/api-reference.md`, `compare/results/s4-m729-choice-checked-pointer-aliases.md` | Closed for the current bar: reusable `Choice` now has checked aliases for caller-owned, owned, and fixed-size pointer outputs. |
| S4-M730 weightedchoice checked pointer aliases | `src/seq.zig`, `docs/api-reference.md`, `compare/results/s4-m730-weightedchoice-checked-pointer-aliases.md` | Closed for the current bar: reusable `WeightedChoice` now has checked aliases for caller-owned, owned, and fixed-size weighted pointer outputs. |
| S4-M731 choice checked index aliases | `src/seq.zig`, `docs/api-reference.md`, `compare/results/s4-m731-choice-checked-index-aliases.md` | Closed for the current bar: reusable `Choice` now has checked aliases for scalar, caller-owned, owned, fixed-size, and iterator `usize` index outputs. |
| S4-M732 weightedchoice checked index aliases | `src/seq.zig`, `docs/api-reference.md`, `compare/results/s4-m732-weightedchoice-checked-index-aliases.md` | Closed for the current bar: reusable `WeightedChoice` now has checked aliases for scalar, caller-owned, owned, fixed-size, and iterator weighted `usize` index outputs. |
| S4-M733 choice checked u32 index aliases | `src/seq.zig`, `docs/api-reference.md`, `compare/results/s4-m733-choice-checked-u32-index-aliases.md` | Closed for the current bar: reusable `Choice` now has checked aliases for scalar, caller-owned, owned, fixed-size, and iterator compact `u32` index outputs. |
| S4-M734 weightedchoice checked u32 index aliases | `src/seq.zig`, `docs/api-reference.md`, `compare/results/s4-m734-weightedchoice-checked-u32-index-aliases.md` | Closed for the current bar: reusable `WeightedChoice` now has checked aliases for scalar, caller-owned, owned, fixed-size, and iterator compact weighted `u32` index outputs. |
| S4-M735 choice checked value batches | `src/seq.zig`, `docs/api-reference.md`, `compare/results/s4-m735-choice-checked-value-batches.md` | Closed for the current bar: reusable `Choice` now has checked aliases for caller-owned and allocation-returning value-copy batches. |
| S4-M736 weightedchoice checked value batches | `src/seq.zig`, `docs/api-reference.md`, `compare/results/s4-m736-weightedchoice-checked-value-batches.md` | Closed for the current bar: reusable `WeightedChoice` now has checked aliases for caller-owned and allocation-returning weighted value-copy batches. |
| S4-M737 distribution choose checked value batches | `src/distributions.zig`, `docs/api-reference.md`, `compare/results/s4-m737-distribution-choose-checked-value-batches.md` | Closed for the current bar: distribution-layer `Choose` now has checked aliases for caller-owned and allocation-returning value-copy batches. |
| S4-M738 distribution choose checked u32 iterators | `src/distributions.zig`, `docs/api-reference.md`, `compare/results/s4-m738-distribution-choose-checked-u32-iterators.md` | Closed for the current bar: distribution-layer `Choose` now has checked aliases for compact `u32` index iterators. |
| S4-M739 aliastable checked iterators | `src/distributions.zig`, `docs/api-reference.md`, `compare/results/s4-m739-aliastable-checked-iterators.md` | Closed for the current bar: static `AliasTable` now has checked iterator aliases for `usize` and compact `u32` index iterators. |
| S4-M740 weighted tree checked iterators | `src/distributions.zig`, `docs/api-reference.md`, `compare/results/s4-m740-weighted-tree-checked-iterators.md` | Closed for the current bar: dynamic `WeightedTree` and `WeightedIntTree` now have checked iterator aliases for `usize` and compact `u32` index iterators. |
| S4-M741 aliastable checked index docs | `docs/api-reference.md`, `compare/results/s4-m741-aliastable-checked-index-docs.md` | Closed for the current bar: static `AliasTable` checked `usize` index APIs are now documented alongside the rest of the checked weighted-index surface. |
| S4-M742 weighted tree invalid checked iterators | `src/distributions.zig`, `compare/results/s4-m742-weighted-tree-invalid-checked-iterators.md` | Closed for the current bar: dynamic weighted-tree checked iterator constructors now have explicit invalid-state no-consumption evidence. |
| S4-M743 aliastable checked u32 iterator width | `src/distributions.zig`, `compare/results/s4-m743-aliastable-checked-u32-iterator-width.md` | Closed for the current bar: static `AliasTable` checked compact `u32` iterator construction now has explicit oversized-population no-consumption evidence. |
| S4-M744 weighted tree checked u32 iterator width | `src/distributions.zig`, `compare/results/s4-m744-weighted-tree-checked-u32-iterator-width.md` | Closed for the current bar: dynamic weighted-tree checked compact `u32` iterator construction now has explicit oversized-population no-consumption evidence. |
| S4-M745 choice checked pointer iter aliases | `src/distributions.zig`, `src/seq.zig`, `docs/api-reference.md`, `compare/results/s4-m745-choice-checked-pointer-iter-aliases.md` | Closed for the current bar: distribution-layer `Choose`, reusable `Choice`, and reusable `WeightedChoice` now have checked aliases for canonical repeated pointer iterators. |
| S4-M746 choice owned u32 index prevalidation | `src/distributions.zig`, `src/seq.zig`, `compare/results/s4-m746-choice-owned-u32-index-prevalidation.md` | Closed for the current bar: distribution-layer `Choose` and reusable `Choice` allocation-returning compact `u32` index helpers now reject oversized populations before allocation or random-stream use. |
| S4-M747 aliastable owned u32 index prevalidation | `src/distributions.zig`, `compare/results/s4-m747-aliastable-owned-u32-index-prevalidation.md` | Closed for the current bar: static `AliasTable` allocation-returning compact `u32` index helper now rejects oversized populations before allocation or random-stream use. |
| S4-M748 weighted tree owned u32 index prevalidation | `src/distributions.zig`, `compare/results/s4-m748-weighted-tree-owned-u32-index-prevalidation.md` | Closed for the current bar: dynamic `WeightedTree` and `WeightedIntTree` allocation-returning compact `u32` index helpers now reject oversized populations before allocation or random-stream use. |
| S4-M749 weighted tree invalid owned indices prevalidation | `src/distributions.zig`, `compare/results/s4-m749-weighted-tree-invalid-owned-indices-prevalidation.md` | Closed for the current bar: dynamic `WeightedTree` and `WeightedIntTree` checked allocation-returning index helpers now reject invalid all-zero trees before allocation or random-stream use. |
| S4-M750 aliastable checked owned u32 indices | `src/distributions.zig`, `docs/api-reference.md`, `compare/results/s4-m750-aliastable-checked-owned-u32-indices.md` | Closed for the current bar: static `AliasTable` now has checked allocation-returning compact `u32` index aliases. |
| S4-M751 aliastable checked fixed index arrays | `src/distributions.zig`, `compare/results/s4-m751-aliastable-checked-fixed-index-arrays.md` | Closed for the current bar: static `AliasTable` now implements the documented checked fixed-size `usize` index array aliases. |
| S4-M752 aliastable checked usize index aliases | `src/distributions.zig`, `compare/results/s4-m752-aliastable-checked-usize-index-aliases.md` | Closed for the current bar: static `AliasTable` now implements the documented checked scalar, fill, and owned `usize` index aliases. |
| S4-M753 rng fast helper namespace docs | `docs/api-reference.md`, `docs/core-guide.md`, `compare/results/s4-m753-rng-fast-helper-namespace-docs.md` | Closed for the current bar: scalar normal/exponential fast helper docs now use the correct `Rng.*FastFrom` namespace. |
| S4-M754 weighted checked iterator facades | `src/distributions.zig`, `compare/results/s4-m754-weighted-checked-iterator-facades.md` | Closed for the current bar: static `AliasTable` and dynamic weighted-tree checked facade iterator constructors now return facade iterator types and have stream-shape tests. |
| S4-M755 choice checked iterator facades | `src/distributions.zig`, `src/seq.zig`, `compare/results/s4-m755-choice-checked-iterator-facades.md` | Closed for the current bar: checked value/index iterator facade constructors for `Choose`, `Choice`, and `WeightedChoice` now have direct-source stream-shape coverage. |
| S4-M756 accessor weighted iterator checked-from coverage | `src/seq.zig`, `compare/results/s4-m756-accessor-weighted-iterator-checked-from.md` | Closed for the current bar: accessor- and index-weighted checked direct-source convenience iterators now have stream-shape coverage against reusable `WeightedChoice`. |
| S4-M757 parallel weighted iterator checked-from coverage | `src/seq.zig`, `compare/results/s4-m757-parallel-weighted-iterator-checked-from.md` | Closed for the current bar: parallel-weight checked direct-source convenience iterator now has stream-shape coverage against reusable `WeightedChoice`. |
| S4-M758 weighted checked u32 iterator facades | `src/distributions.zig`, `compare/results/s4-m758-weighted-checked-u32-iterator-facades.md` | Closed for the current bar: checked compact `u32` iterator facade constructors for `AliasTable`, `WeightedTree`, and `WeightedIntTree` now have direct-source stream-shape coverage. |
| S4-M759 choice convenience checked iterator coverage | `src/seq.zig`, `compare/results/s4-m759-choice-convenience-checked-iterator.md` | Closed for the current bar: `chooseIterChecked` and `chooseIterCheckedFrom` now have reusable `Choice` stream-shape coverage. |
| S4-M760 seq checked iterator exact-remaining prevalidation | `src/seq.zig`, `compare/results/s4-m760-seq-checked-iterator-exact-remaining-prevalidation.md` | Closed for the current bar: checked iterator sampling helpers now reject exact-size short iterators before allocation, iterator consumption, or random-stream use. |
| S4-M761 seq optional iterator array exact-remaining prevalidation | `src/seq.zig`, `compare/results/s4-m761-seq-optional-iterator-array-exact-remaining.md` | Closed for the current bar: optional fixed-size iterator array helpers now return null for exact-size short iterators before consuming the iterator or random stream. |
| S4-M762 iterator exact-empty allocation prevalidation | `src/seq.zig`, `src/root.zig`, `compare/results/s4-m762-iterator-exact-empty-allocation-prevalidation.md` | Closed for the current bar: iterator allocation-returning helpers now return empty outputs for exact-empty sources before allocation, consumption, entropy, or random-stream use. |
| S4-M763 iterator exact-empty caller-owned prevalidation | `src/seq.zig`, `src/root.zig`, `compare/results/s4-m763-iterator-exact-empty-caller-owned-prevalidation.md` | Closed for the current bar: caller-owned iterator helpers now return zero for exact-empty sources before iterator consumption, entropy, or random-stream use. |
| S4-M764 weighted iterator choice exact-empty prevalidation | `src/seq.zig`, `src/root.zig`, `compare/results/s4-m764-weighted-iterator-choice-exact-empty-prevalidation.md` | Closed for the current bar: weighted iterator one-shot choice helpers now handle exact-empty sources before iterator consumption, entropy, or random-stream use. |
| S4-M765 iterator choice exact-empty prevalidation | `src/seq.zig`, `src/root.zig`, `compare/results/s4-m765-iterator-choice-exact-empty-prevalidation.md` | Closed for the current bar: unweighted iterator one-shot choice helpers now handle exact-empty sources before iterator consumption, entropy, or random-stream use. |
| S4-M766 root iterator sample exact-empty allocation prevalidation | `src/root.zig`, `compare/results/s4-m766-root-iterator-sample-exact-empty-prevalidation.md` | Closed for the current bar: root allocation-returning unweighted iterator samples now return empty outputs for exact-empty sources before allocation, consumption, entropy, or random-stream use. |
| S4-M767 iterator exact-short allocation capacity | `src/seq.zig`, `src/root.zig`, `compare/results/s4-m767-iterator-exact-short-allocation-capacity.md` | Closed for the current bar: exact-short iterator sampling helpers now cap reservoir/heap capacity by known remaining counts before returning partial results. |
| S4-M768 iterator exact-short end-probe avoidance | `src/seq.zig`, `src/root.zig`, `compare/results/s4-m768-iterator-exact-short-end-probe.md` | Closed for the current bar: allocation-returning unweighted iterator samples now avoid extra null probes for exact-short sources. |
| S4-M769 iterator exact-short caller-owned end-probe avoidance | `src/seq.zig`, `src/root.zig`, `compare/results/s4-m769-iterator-exact-short-caller-owned-end-probe.md` | Closed for the current bar: caller-owned unweighted iterator fills now avoid extra null probes for exact-short sources. |
| S4-M770 checked iterator exact-count end-probe avoidance | `src/seq.zig`, `src/root.zig`, `compare/results/s4-m770-checked-iterator-exact-count-end-probe.md` | Closed for the current bar: checked unweighted iterator samples now avoid extra null probes when exact remaining equals the requested count. |
| S4-M771 weighted iterator choice exact-single end-probe avoidance | `src/seq.zig`, `src/root.zig`, `compare/results/s4-m771-weighted-iterator-choice-exact-single.md` | Closed for the current bar: weighted iterator one-shot choice helpers now avoid extra null probes for exact-single sources while preserving weight validation. |
| S4-M772 weighted iterator sample exact-single allocation avoidance | `src/seq.zig`, `src/root.zig`, `compare/results/s4-m772-weighted-iterator-sample-exact-single.md` | Closed for the current bar: allocation-returning weighted iterator samples now resolve exact-single sources without heap setup, extra probes, entropy, or random-stream use. |
| S4-M773 weighted iterator fill exact-single key avoidance | `src/seq.zig`, `src/root.zig`, `compare/results/s4-m773-weighted-iterator-fill-exact-single.md` | Closed for the current bar: caller-owned weighted iterator fills now resolve exact-single sources without key sampling, extra probes, entropy, or random-stream use. |
| S4-M774 weighted iterator array exact-single probe avoidance | `src/seq.zig`, `src/root.zig`, `compare/results/s4-m774-weighted-iterator-array-exact-single.md` | Closed for the current bar: fixed-size weighted iterator arrays now resolve exact-single sources without extra probes, key sampling, entropy, or random-stream use. |
| S4-M775 weighted iterator array exact-count key avoidance | `src/seq.zig`, `src/root.zig`, `compare/results/s4-m775-weighted-iterator-array-exact-count.md` | Closed for the current bar: fixed-size weighted iterator arrays now resolve all-positive exact-count sources without extra probes, key sampling, entropy, or random-stream use. |
| S4-M776 weighted iterator sample exact-cover heap avoidance | `src/seq.zig`, `src/root.zig`, `compare/results/s4-m776-weighted-iterator-sample-exact-cover.md` | Closed for the current bar: allocation-returning weighted iterator samples now resolve exact-cover sources without heap/key setup, extra probes, entropy, or random-stream use. |
| S4-M777 weighted iterator fill exact-cover key avoidance | `src/seq.zig`, `src/root.zig`, `compare/results/s4-m777-weighted-iterator-fill-exact-cover.md` | Closed for the current bar: caller-owned weighted iterator fills now resolve exact-cover sources without key sampling, extra probes, entropy, or random-stream use. |
| S4-M778 weighted iterator choice exact-count end-probe avoidance | `src/seq.zig`, `src/root.zig`, `compare/results/s4-m778-weighted-iterator-choice-exact-count.md` | Closed for the current bar: weighted iterator one-shot choices now read exact-count sources exactly without extra trailing probes while preserving stream shape. |
| S4-M779 stable iterator choice exact-count end-probe avoidance | `src/seq.zig`, `src/root.zig`, `compare/results/s4-m779-stable-iterator-choice-exact-count.md` | Closed for the current bar: stable unweighted iterator one-shot choices now read exact-count sources exactly without extra trailing probes while preserving reservoir stream shape. |
| S4-M780 weighted iterator array exact metadata reuse | `src/seq.zig`, `src/root.zig`, `compare/results/s4-m780-weighted-iterator-array-exact-metadata.md` | Closed for the current bar: fixed-size weighted iterator arrays now reuse exact remaining metadata instead of probing size hints/remaining twice. |
| S4-M781 weighted iterator sample exact metadata reuse | `src/seq.zig`, `src/root.zig`, `compare/results/s4-m781-weighted-iterator-sample-exact-metadata.md` | Closed for the current bar: allocation-returning weighted iterator samples now reuse exact remaining metadata instead of probing size hints/remaining twice. |
| S4-M782 weighted iterator fill exact metadata reuse | `src/root.zig`, `compare/results/s4-m782-weighted-iterator-fill-exact-metadata.md` | Closed for the current bar: root caller-owned weighted iterator fills now reuse exact remaining metadata instead of probing size hints/remaining twice. |
| S4-M783 iterator array exact-long end-probe avoidance | `src/seq.zig`, `src/root.zig`, `compare/results/s4-m783-iterator-array-exact-long-end-probe.md` | Closed for the current bar: fixed-size unweighted iterator arrays now avoid extra trailing probes for exact-long sources while preserving stream shape. |
| S4-M784 iterator fill exact-long end-probe avoidance | `src/seq.zig`, `src/root.zig`, `compare/results/s4-m784-iterator-fill-exact-long-end-probe.md` | Closed for the current bar: caller-owned unweighted iterator fills now avoid extra trailing probes for exact-long sources while preserving stream shape. |
| S4-M785 iterator sample exact-long end-probe avoidance | `src/seq.zig`, `src/root.zig`, `compare/results/s4-m785-iterator-sample-exact-long-end-probe.md` | Closed for the current bar: allocation-returning unweighted iterator samples now avoid extra trailing probes for exact-long sources while preserving stream shape. |
| S4-M786 root iterator choice exact metadata reuse | `src/root.zig`, `compare/results/s4-m786-root-iterator-choice-exact-metadata.md` | Closed for the current bar: root unweighted iterator choices now reuse exact remaining metadata instead of probing size hints/remaining multiple times. |
| S4-M787 weighted iterator array exact-long end-probe avoidance | `src/seq.zig`, `src/root.zig`, `compare/results/s4-m787-weighted-iterator-array-exact-long-end-probe.md` | Closed for the current bar: fixed-size weighted iterator arrays now avoid extra trailing probes for exact-long sources while preserving weighted-key stream shape. |
| S4-M788 weighted iterator fill exact-long end-probe avoidance | `src/seq.zig`, `src/root.zig`, `compare/results/s4-m788-weighted-iterator-fill-exact-long-end-probe.md` | Closed for the current bar: caller-owned weighted iterator fills now avoid extra trailing probes for exact-long sources while preserving weighted-key stream shape. |
| S4-M789 weighted iterator sample exact-long end-probe avoidance | `src/seq.zig`, `src/root.zig`, `compare/results/s4-m789-weighted-iterator-sample-exact-long-end-probe.md` | Closed for the current bar: allocation-returning weighted iterator samples now avoid extra trailing probes for exact-long sources while preserving weighted-key stream shape. |
| S4-M790 hinted iterator choice inexact metadata reuse | `src/seq.zig`, `compare/results/s4-m790-hinted-iterator-choice-inexact-metadata.md` | Closed for the current bar: hinted iterator choices now avoid duplicate inexact size-hint/remaining probes on fallback paths while preserving reservoir stream shape. |
| S4-M791 sampled iterator fill index-buffer reuse | `src/seq.zig`, `compare/results/s4-m791-sampled-iterator-fill-index-buffer.md` | Closed for the current bar: sampled value/pointer iterator fills now reuse the owned index iterator bulk fill path instead of per-slot next calls. |
| S4-M792 IndexVec mapped iterator fill index-buffer reuse | `src/seq.zig`, `compare/results/s4-m792-indexvec-mapped-iterator-fill-index-buffer.md` | Closed for the current bar: non-owned IndexVec value/pointer iterator fills now reuse index-buffer fills instead of per-slot next calls. |
| S4-M793 IndexVec mapped into switch-once loops | `src/seq.zig`, `compare/results/s4-m793-indexvec-mapped-into-switch-once.md` | Closed for the current bar: IndexVec caller-owned value/pointer mappings now switch once on backing representation instead of calling `at()` per output slot. |
| S4-M794 IndexVec owned u32 narrowing prevalidation | `src/seq.zig`, `compare/results/s4-m794-indexvec-owned-u32-prevalidation.md` | Closed for the current bar: IndexVec native-to-u32 owned narrowing now rejects oversized indexes before allocating output. |
| S4-M795 uniform choice probability fill constant path | `src/seq.zig`, `src/distributions.zig`, `compare/results/s4-m795-choice-probability-fill-constant.md` | Closed for the current bar: uniform choice probability iterators now fill constant probabilities directly instead of per-slot `next()` calls. |
| S4-M796 AliasTable iterator fill direct storage paths | `src/distributions.zig`, `compare/results/s4-m796-aliastable-iterator-fill-direct-storage.md` | Closed for the current bar: AliasTable weight/probability iterators now fill directly from stored weights instead of per-slot lookup calls. |
| S4-M797 weighted tree iterator fill direct storage paths | `src/distributions.zig`, `compare/results/s4-m797-weighted-tree-iterator-fill-direct-storage.md` | Closed for the current bar: dynamic weighted tree weight/probability iterators now fill directly from tree storage and cache totals instead of per-slot lookup calls. |
| S4-M798 IndexVec copied u32 narrowing prevalidation | `src/seq.zig`, `compare/results/s4-m798-indexvec-copied-u32-prevalidation.md` | Closed for the current bar: IndexVec native-to-u32 copied narrowing now rejects oversized indexes before allocating output. |
| S4-M799 IndexVec fill direct backing paths | `src/seq.zig`, `compare/results/s4-m799-indexvec-fill-direct-backing.md` | Closed for the current bar: IndexVec borrowed and consuming iterator fills now switch once per fill and copy/map directly from backing storage. |
| S4-M800 IndexVec search and validation direct scans | `src/seq.zig`, `compare/results/s4-m800-indexvec-search-validation-direct-scans.md` | Closed for the current bar: IndexVec search and validation helpers now switch once per call and scan the active backing storage directly. |
| S4-M801 IndexVec copyIntoU32 no-partial-write prevalidation | `src/seq.zig`, `compare/results/s4-m801-indexvec-copyintou32-prevalidation.md` | Closed for the current bar: IndexVec native-to-u32 caller-owned copying now rejects oversized indexes before modifying output. |
| S4-M802 IndexVec next direct backing paths | `src/seq.zig`, `compare/results/s4-m802-indexvec-next-direct-backing.md` | Closed for the current bar: IndexVec borrowed and consuming iterator `next()` calls now read directly from backing storage. |
| S4-M803 Choice fill direct index mapping | `src/seq.zig`, `src/distributions.zig`, `compare/results/s4-m803-choice-fill-direct-index-mapping.md` | Closed for the current bar: reusable and distribution-layer unweighted choice pointer/value fills now map generated indexes directly into item storage. |
| S4-M804 WeightedChoice fill direct index mapping | `src/seq.zig`, `compare/results/s4-m804-weightedchoice-fill-direct-index-mapping.md` | Closed for the current bar: reusable weighted choice pointer/value fills now map sampled alias indexes directly into item storage. |
| S4-M805 AliasTable fill direct sampling paths | `src/distributions.zig`, `compare/results/s4-m805-aliastable-fill-direct-sampling.md` | Closed for the current bar: static AliasTable usize/u32 index fills now inline alias sampling loops instead of calling sampleFrom per slot. |
| S4-M806 WeightedChoice index fills reuse AliasTable direct paths | `src/seq.zig`, `compare/results/s4-m806-weightedchoice-index-fill-table-direct.md` | Closed for the current bar: WeightedChoice usize/u32 index fills now reuse the optimized AliasTable direct fill loops. |
| S4-M807 Weighted tree fill direct sampling paths | `src/distributions.zig`, `compare/results/s4-m807-weighted-tree-fill-direct-sampling.md` | Closed for the current bar: dynamic weighted tree usize/u32 index fills now use direct tree-walk loops. |
| S4-M808 Distribution Choose index fill direct uniform loop | `src/distributions.zig`, `compare/results/s4-m808-distribution-choose-index-fill-direct.md` | Closed for the current bar: distribution-layer Choose usize index fills now generate uniform indexes directly. |
| S4-M809 Choice index fill cached length direct loop | `src/seq.zig`, `compare/results/s4-m809-choice-index-fill-cached-length.md` | Closed for the current bar: reusable Choice usize index fills now cache item length and use a direct uniform loop. |
| S4-M810 Distribution Choose u32 index fill cached length loop | `src/distributions.zig`, `compare/results/s4-m810-distribution-choose-u32-index-fill-cached-length.md` | Closed for the current bar: distribution-layer Choose compact u32 index fills now cache item length and use a direct uniform loop. |
| S4-M811 Choice u32 index fill cached length loop | `src/seq.zig`, `compare/results/s4-m811-choice-u32-index-fill-cached-length.md` | Closed for the current bar: reusable Choice compact u32 index fills now cache item length and use a direct uniform loop. |
| S4-M812 Choice index iterators direct scalar sampling | `src/seq.zig`, `compare/results/s4-m812-choice-index-iterator-direct-sampling.md` | Closed for the current bar: reusable Choice usize/u32 index iterators now generate scalar indexes directly. |
| S4-M813 Distribution Choose index iterators direct scalar sampling | `src/distributions.zig`, `compare/results/s4-m813-distribution-choose-index-iterator-direct.md` | Closed for the current bar: distribution-layer Choose usize/u32 index iterators now generate scalar indexes directly. |
| S4-M814 WeightedChoice index iterators direct table sampling | `src/seq.zig`, `compare/results/s4-m814-weightedchoice-index-iterator-direct-table.md` | Closed for the current bar: reusable WeightedChoice usize/u32 index iterators now sample the underlying AliasTable directly. |
| S4-M815 AliasTable u32 iterator direct checked sampling | `src/distributions.zig`, `compare/results/s4-m815-aliastable-u32-iterator-direct.md` | Closed for the current bar: static AliasTable compact u32 iterator scalar next now calls the checked table sampler directly. |
| S4-M816 Weighted tree u32 iterators direct checked sampling | `src/distributions.zig`, `compare/results/s4-m816-weighted-tree-u32-iterator-direct.md` | Closed for the current bar: dynamic WeightedTree and WeightedIntTree compact u32 index iterators now call the checked sampler directly. |
| S4-M817 Choice value iterator direct index mapping | `src/seq.zig`, `compare/results/s4-m817-choice-value-iterator-direct-index.md` | Closed for the current bar: reusable Choice value iterators now map generated indexes directly into item storage. |
| S4-M818 Distribution Choose value iterator direct index mapping | `src/distributions.zig`, `compare/results/s4-m818-distribution-choose-value-iterator-direct.md` | Closed for the current bar: distribution-layer Choose value iterators now map generated indexes directly into item storage. |
| S4-M819 WeightedChoice value iterator direct table mapping | `src/seq.zig`, `compare/results/s4-m819-weightedchoice-value-iterator-direct-table.md` | Closed for the current bar: reusable WeightedChoice value iterators now map alias-table indexes directly into item storage. |
| S4-M820 Distribution Choose pointer iterator direct index mapping | `src/distributions.zig`, `compare/results/s4-m820-distribution-choose-ptr-iterator-direct.md` | Closed for the current bar: distribution-layer Choose pointer iterators now map generated indexes directly into item storage. |
| S4-M821 MappedSampler fill direct mapper application | `src/distributions.zig`, `compare/results/s4-m821-mappedsampler-fill-direct-mapper.md` | Closed for the current bar: mapped sampler fills now apply mappers directly to base sampler outputs. |
| S4-M822 Binomial fill direct sampler loop | `src/distributions.zig`, `compare/results/s4-m822-binomial-fill-direct-sampler.md` | Closed for the current bar: Binomial fills now call binomialFrom directly for non-degenerate outputs. |
| S4-M823 NegativeBinomial fill direct sampler loop | `src/distributions.zig`, `compare/results/s4-m823-negative-binomial-fill-direct-sampler.md` | Closed for the current bar: NegativeBinomial fills now call negativeBinomialFrom directly for non-degenerate outputs. |
| S4-M824 Hypergeometric fill direct method dispatch | `src/distributions.zig`, `compare/results/s4-m824-hypergeometric-fill-direct-method.md` | Closed for the current bar: Hypergeometric fills now switch once and call selected method samplers directly. |
| S4-M825 Geometric fill direct sampler loop | `src/distributions.zig`, `compare/results/s4-m825-geometric-fill-direct-sampler.md` | Closed for the current bar: Geometric fills now call geometricFrom directly for non-degenerate outputs. |
| S4-M826 GeometricFailures fill direct sampler loop | `src/distributions.zig`, `compare/results/s4-m826-geometric-failures-fill-direct-sampler.md` | Closed for the current bar: GeometricFailures fills now call geometricFailuresFrom directly for non-degenerate outputs. |
| S4-M827 VectorGeometric fill direct sampler loop | `src/distributions.zig`, `compare/results/s4-m827-vector-geometric-fill-direct-sampler.md` | Closed for the current bar: VectorGeometric fills now draw lanes with geometricFrom directly for non-degenerate outputs. |
| S4-M828 VectorGeometricFailures fill direct sampler loop | `src/distributions.zig`, `compare/results/s4-m828-vector-geometric-failures-fill-direct-sampler.md` | Closed for the current bar: VectorGeometricFailures fills now draw lanes with geometricFailuresFrom directly for non-degenerate outputs. |
| S4-M829 VectorNegativeBinomial fill direct sampler loop | `src/distributions.zig`, `compare/results/s4-m829-vector-negative-binomial-fill-direct-sampler.md` | Closed for the current bar: VectorNegativeBinomial fills now draw lanes with negativeBinomialFrom directly for non-degenerate outputs. |
| S4-M830 VectorBinomial fill direct sampler loop | `src/distributions.zig`, `compare/results/s4-m830-vector-binomial-fill-direct-sampler.md` | Closed for the current bar: VectorBinomial fills now draw lanes with binomialFrom directly for non-degenerate outputs. |
| S4-M831 VectorBinomialPoissonApprox fill direct sampler loop | `src/distributions.zig`, `compare/results/s4-m831-vector-binomial-poisson-approx-fill-direct.md` | Closed for the current bar: VectorBinomialPoissonApprox fills now draw lanes with binomialPoissonApproxFrom directly for non-degenerate outputs. |
| S4-M832 VectorHypergeometric fill direct method dispatch | `src/distributions.zig`, `compare/results/s4-m832-vector-hypergeometric-fill-direct-method.md` | Closed for the current bar: VectorHypergeometric fills now switch once and call selected method samplers directly. |
| S4-M833 VectorPoisson fill direct method dispatch | `src/distributions.zig`, `compare/results/s4-m833-vector-poisson-fill-direct-method.md` | Closed for the current bar: VectorPoisson fills now switch once and call selected method samplers directly. |
| S4-M834 HalfNormal reusable fill delegates to optimized helper | `src/distributions.zig`, `compare/results/s4-m834-halfnormal-fill-helper-delegate.md` | Closed for the current bar: reusable HalfNormal fills now delegate to the optimized top-level fill helper. |
| S4-M835 Exponential reusable fill standard staging | `src/distributions.zig`, `compare/results/s4-m835-exponential-fill-standard-stage.md` | Closed for the current bar: reusable Exponential fills now stage standard exponential samples through the shared fill helper and scale once in place. |
| S4-M836 VectorExponential reusable fill standard staging | `src/distributions.zig`, `compare/results/s4-m836-vector-exponential-fill-standard-stage.md` | Closed for the current bar: reusable VectorExponential fills now stage standard vector exponential samples through the shared fill helper and scale backing lanes in place. |
| S4-M837 Gamma shape-one reusable fill standard staging | `src/distributions.zig`, `compare/results/s4-m837-gamma-shape-one-fill-standard-stage.md` | Closed for the current bar: reusable Gamma fills with shape one now stage standard exponential samples through the shared fill helper and scale once in place. |
| S4-M838 VectorGamma shape-one reusable fill standard staging | `src/distributions.zig`, `compare/results/s4-m838-vector-gamma-shape-one-fill-standard-stage.md` | Closed for the current bar: reusable VectorGamma fills with shape one now stage standard vector exponential samples through the shared fill helper and scale backing lanes in place. |
| S4-M839 ChiSquared reusable fill delegates to Gamma fill | `src/distributions.zig`, `compare/results/s4-m839-chi-squared-fill-gamma-delegate.md` | Closed for the current bar: reusable ChiSquared fills now delegate to the cached Gamma sampler fill and reuse its shape-specific bulk paths. |
| S4-M840 VectorChiSquared reusable fill delegates to VectorGamma fill | `src/distributions.zig`, `compare/results/s4-m840-vector-chi-squared-fill-gamma-delegate.md` | Closed for the current bar: reusable VectorChiSquared fills now delegate to the cached Gamma sampler via VectorGamma fill and reuse shape-specific vector bulk paths. |
| S4-M841 Chi reusable fill delegates to ChiSquared fill | `src/distributions.zig`, `compare/results/s4-m841-chi-fill-chi-squared-delegate.md` | Closed for the current bar: reusable Chi fills now delegate to cached ChiSquared fills and apply square root in place. |
| S4-M842 VectorChi reusable fill delegates to VectorChiSquared fill | `src/distributions.zig`, `compare/results/s4-m842-vector-chi-fill-chi-squared-delegate.md` | Closed for the current bar: reusable VectorChi fills now delegate to cached VectorChiSquared fills and apply vector square root in place. |
| S4-M843 Erlang reusable fill delegates to Gamma fill | `src/distributions.zig`, `compare/results/s4-m843-erlang-fill-gamma-delegate.md` | Closed for the current bar: reusable Erlang fills now delegate to the cached Gamma sampler fill and reuse shape-specific Gamma bulk paths. |
| S4-M844 VectorErlang reusable fill delegates to VectorGamma fill | `src/distributions.zig`, `compare/results/s4-m844-vector-erlang-fill-gamma-delegate.md` | Closed for the current bar: reusable VectorErlang fills now delegate to the cached Gamma sampler via VectorGamma fill and reuse shape-specific vector bulk paths. |
| S4-M845 FisherF reusable fill direct cached Gamma ratio loop | `src/distributions.zig`, `compare/results/s4-m845-fisher-f-fill-direct-gamma-ratio.md` | Closed for the current bar: reusable FisherF fills now draw from cached numerator/denominator Gamma samplers directly and divide. |
| S4-M846 VectorFisherF reusable fill direct cached Gamma ratio lanes | `src/distributions.zig`, `compare/results/s4-m846-vector-fisher-f-fill-direct-gamma-ratio.md` | Closed for the current bar: reusable VectorFisherF fills now draw cached numerator/denominator Gamma values directly per lane and divide. |
| S4-M847 StudentT reusable fill direct composition | `src/distributions.zig`, `compare/results/s4-m847-student-t-fill-direct-composition.md` | Closed for the current bar: reusable StudentT fills now draw standard normal and cached chi-squared samples directly and combine them for finite degrees of freedom. |
| S4-M848 VectorStudentT reusable fill direct composition | `src/distributions.zig`, `compare/results/s4-m848-vector-student-t-fill-direct-composition.md` | Closed for the current bar: reusable VectorStudentT fills now draw standard normal and cached chi-squared samples directly per lane and combine them for finite degrees of freedom. |
| S4-M849 VectorTriangular reusable fill direct uniform transform | `src/distributions.zig`, `compare/results/s4-m849-vector-triangular-fill-direct-transform.md` | Closed for the current bar: reusable VectorTriangular fills now draw vector uniform values and apply the triangular transform directly. |
| S4-M850 VectorArcsine reusable fill direct open-uniform transform | `src/distributions.zig`, `compare/results/s4-m850-vector-arcsine-fill-direct-transform.md` | Closed for the current bar: reusable VectorArcsine fills now draw vector open-uniform values and apply the arcsine transform directly. |
| S4-M851 VectorCauchy reusable fill direct open-uniform transform | `src/distributions.zig`, `compare/results/s4-m851-vector-cauchy-fill-direct-transform.md` | Closed for the current bar: reusable VectorCauchy fills now draw vector open-uniform values and apply the Cauchy transform directly. |
| S4-M852 VectorLaplace reusable fill direct open-uniform transform | `src/distributions.zig`, `compare/results/s4-m852-vector-laplace-fill-direct-transform.md` | Closed for the current bar: reusable VectorLaplace fills now draw vector open-uniform values and apply the Laplace transform directly. |
| S4-M853 VectorLogistic reusable fill direct open-uniform transform | `src/distributions.zig`, `compare/results/s4-m853-vector-logistic-fill-direct-transform.md` | Closed for the current bar: reusable VectorLogistic fills now draw vector open-uniform values and apply the Logistic transform directly. |
| S4-M854 VectorLogLogistic reusable fill direct open-uniform transform | `src/distributions.zig`, `compare/results/s4-m854-vector-log-logistic-fill-direct-transform.md` | Closed for the current bar: reusable VectorLogLogistic fills now draw vector open-uniform values and apply the LogLogistic transform directly, including shape-one ratio handling. |
| S4-M855 VectorKumaraswamy reusable fill direct open-uniform transform | `src/distributions.zig`, `compare/results/s4-m855-vector-kumaraswamy-fill-direct-transform.md` | Closed for the current bar: reusable VectorKumaraswamy fills now draw vector open-uniform values and apply the Kumaraswamy transform directly, including beta-one/alpha-one paths. |
| S4-M856 VectorPowerFunction reusable fill direct transform | `src/distributions.zig`, `compare/results/s4-m856-vector-power-function-fill-direct-transform.md` | Closed for the current bar: reusable VectorPowerFunction fills now dispatch directly to point-max, uniform, sqrt, or generic power-function transforms. |
| S4-M857 VectorRayleigh reusable fill direct open-uniform transform | `src/distributions.zig`, `compare/results/s4-m857-vector-rayleigh-fill-direct-transform.md` | Closed for the current bar: reusable VectorRayleigh fills now draw vector open-uniform values and apply the Rayleigh transform directly. |
| S4-M858 VectorMaxwell reusable fill direct normal triple transform | `src/distributions.zig`, `compare/results/s4-m858-vector-maxwell-fill-direct-transform.md` | Closed for the current bar: reusable VectorMaxwell fills now draw three vector normal values and apply the Maxwell norm transform directly. |
| S4-M859 VectorPareto reusable fill direct open-uniform transform | `src/distributions.zig`, `compare/results/s4-m859-vector-pareto-fill-direct-transform.md` | Closed for the current bar: reusable VectorPareto fills now draw vector open-uniform values and apply the Pareto transform directly, including shape-one reciprocal handling. |
| S4-M860 VectorWeibull reusable fill direct open-uniform transform | `src/distributions.zig`, `compare/results/s4-m860-vector-weibull-fill-direct-transform.md` | Closed for the current bar: reusable VectorWeibull fills now draw vector open-uniform values and apply the Weibull transform directly, including shape-one standard-exponential handling. |
| S4-M861 VectorGumbel reusable fill direct open-closed-uniform transform | `src/distributions.zig`, `compare/results/s4-m861-vector-gumbel-fill-direct-transform.md` | Closed for the current bar: reusable VectorGumbel fills now draw vector open-closed-uniform values and apply the Gumbel transform directly. |
| S4-M862 VectorFrechet reusable fill direct open-closed-uniform transform | `src/distributions.zig`, `compare/results/s4-m862-vector-frechet-fill-direct-transform.md` | Closed for the current bar: reusable VectorFrechet fills now draw vector open-closed-uniform values and apply the Frechet transform directly, including shape-one handling. |
| S4-M863 VectorSkewNormal reusable fill direct normal composition | `src/distributions.zig`, `compare/results/s4-m863-vector-skew-normal-fill-direct-composition.md` | Closed for the current bar: reusable VectorSkewNormal fills now draw standard-normal vectors and apply skew-normal composition directly. |
| S4-M864 VectorPert reusable fill cached Beta delegate | `src/distributions.zig`, `compare/results/s4-m864-vector-pert-fill-beta-delegate.md` | Closed for the current bar: reusable VectorPert fills now reuse a cached VectorBeta sampler and affine-map beta vectors into the configured range. |
| S4-M865 VectorInverseGaussian reusable fill direct normal/uniform composition | `src/distributions.zig`, `compare/results/s4-m865-vector-inverse-gaussian-fill-direct-composition.md` | Closed for the current bar: reusable VectorInverseGaussian fills now draw vector standard-normal/uniform pairs and apply inverse-Gaussian composition directly. |
| S4-M866 VectorNormalInverseGaussian reusable fill direct composition | `src/distributions.zig`, `compare/results/s4-m866-vector-nig-fill-direct-composition.md` | Closed for the current bar: reusable VectorNormalInverseGaussian fills now draw embedded inverse-Gaussian and final standard-normal vectors directly. |
| S4-M867 VectorZipf reusable fill direct lane sampling | `src/distributions.zig`, `compare/results/s4-m867-vector-zipf-fill-direct-lanes.md` | Closed for the current bar: reusable VectorZipf fills now sample lanes directly from the cached scalar Zipf sampler. |
| S4-M868 VectorZeta reusable fill direct lane sampling | `src/distributions.zig`, `compare/results/s4-m868-vector-zeta-fill-direct-lanes.md` | Closed for the current bar: reusable VectorZeta fills now sample lanes directly from the cached scalar Zeta sampler. |
| S4-M869 VectorBeta reusable fill direct lane sampling | `src/distributions.zig`, `compare/results/s4-m869-vector-beta-fill-direct-lanes.md` | Closed for the current bar: reusable VectorBeta fills now sample lanes directly from the cached scalar Beta sampler. |
| S4-M870 VectorPoissonAhrensDieter reusable fill direct lane sampling | `src/distributions.zig`, `compare/results/s4-m870-vector-poisson-ad-fill-direct-lanes.md` | Closed for the current bar: reusable VectorPoissonAhrensDieter fills now sample lanes directly from the cached Ahrens-Dieter method. |
| S4-M871 VectorBernoulli reusable fill direct lane sampling | `src/distributions.zig`, `compare/results/s4-m871-vector-bernoulli-fill-direct-lanes.md` | Closed for the current bar: reusable VectorBernoulli generic-probability fills now draw lane raw words and compare directly against the cached threshold. |
| S4-M872 VectorGamma reusable fill direct lane sampling | `src/distributions.zig`, `compare/results/s4-m872-vector-gamma-fill-direct-lanes.md` | Closed for the current bar: reusable VectorGamma generic-shape fills now sample lanes directly from the cached scalar Gamma sampler. |
| S4-M873 Gamma reusable fill direct method dispatch | `src/distributions.zig`, `compare/results/s4-m873-gamma-fill-direct-method.md` | Closed for the current bar: reusable Gamma generic-shape fills now dispatch once to boosted-small-shape or regular Marsaglia sampling. |
| S4-M874 Beta reusable fill direct gamma ratio | `src/distributions.zig`, `compare/results/s4-m874-beta-fill-direct-gamma-ratio.md` | Closed for the current bar: reusable Beta generic fills now draw cached Gamma samplers and normalize directly. |
| S4-M875 Pert reusable fill beta delegate | `src/distributions.zig`, `compare/results/s4-m875-pert-fill-beta-delegate.md` | Closed for the current bar: reusable Pert fills now delegate through cached beta parameters and affine-map in place. |
| S4-M876 Kumaraswamy reusable fill direct inverse-CDF transform | `src/distributions.zig`, `compare/results/s4-m876-kumaraswamy-fill-direct-transform.md` | Closed for the current bar: reusable Kumaraswamy generic fills now draw open-uniform values and apply the inverse-CDF transform directly. |
| S4-M877 Zipf reusable fill direct rejection loop | `src/distributions.zig`, `compare/results/s4-m877-zipf-fill-direct-rejection.md` | Closed for the current bar: reusable Zipf fills now run the cached inverse-CDF proposal and rejection check directly. |
| S4-M878 Zeta reusable fill direct rejection loop | `src/distributions.zig`, `compare/results/s4-m878-zeta-fill-direct-rejection.md` | Closed for the current bar: reusable Zeta fills now run the cached proposal and rejection check directly. |
| S4-M879 UniformDuration reusable fill direct range dispatch | `src/distributions.zig`, `compare/results/s4-m879-uniform-duration-fill-direct-range.md` | Closed for the current bar: reusable UniformDuration fills now dispatch directly to half-open or inclusive duration range helpers. |
| S4-M880 ASCII Charset reusable fill direct index sampling | `src/ascii.zig`, `compare/results/s4-m880-charset-fill-direct-index.md` | Closed for the current bar: reusable ASCII Charset fills now draw uniform indexes and map into the byte slice directly. |
| S4-M881 UnicodeCharset reusable fill direct index sampling | `src/ascii.zig`, `compare/results/s4-m881-unicode-charset-fill-direct-index.md` | Closed for the current bar: reusable UnicodeCharset fills now draw uniform indexes and map into the scalar slice directly. |
| S4-M882 UnicodeCharset append UTF-8 direct index sampling | `src/ascii.zig`, `compare/results/s4-m882-unicode-charset-append-direct-index.md` | Closed for the current bar: UnicodeCharset UTF-8 append now draws uniform indexes and encodes selected scalars directly. |
| S4-M883 WeightedChoice pointer iterator direct table mapping | `src/seq.zig`, `compare/results/s4-m883-weightedchoice-pointer-iterator-direct-table.md` | Closed for the current bar: reusable WeightedChoice pointer iterator scalar outputs now sample the alias table directly and map into item storage. |
| S4-M884 WeightedChoice sample direct table mapping | `src/seq.zig`, `compare/results/s4-m884-weightedchoice-sample-direct-table.md` | Closed for the current bar: reusable WeightedChoice scalar pointer samples now sample the alias table directly and map into item storage. |
| S4-M885 WeightedChoice value sample direct table mapping | `src/seq.zig`, `compare/results/s4-m885-weightedchoice-value-sample-direct-table.md` | Closed for the current bar: reusable WeightedChoice scalar value samples now sample the alias table directly and copy item storage. |
| S4-M886 Choice value sample direct index mapping | `src/seq.zig`, `compare/results/s4-m886-choice-value-sample-direct-index.md` | Closed for the current bar: reusable Choice scalar value samples now generate a uniform index and copy item storage directly. |
| S4-M887 Distribution Choose value sample direct index mapping | `src/distributions.zig`, `compare/results/s4-m887-distribution-choose-value-sample-direct-index.md` | Closed for the current bar: distribution-layer Choose scalar value samples now generate a uniform index and copy item storage directly. |
| S4-M888 Choice sample direct index mapping | `src/seq.zig`, `compare/results/s4-m888-choice-sample-direct-index.md` | Closed for the current bar: reusable Choice scalar pointer samples now generate a uniform index and map into item storage directly. |
| S4-M889 Charset probability iterator direct fill | `src/ascii.zig`, `compare/results/s4-m889-charset-probability-fill-direct.md` | Closed for the current bar: ASCII and Unicode charset probability iterator fills now write uniform probabilities directly. |
| S4-M890 WeightedChoice compact index sample direct table path | `src/seq.zig`, `compare/results/s4-m890-weightedchoice-u32-sample-table-direct.md` | Closed for the current bar: reusable WeightedChoice compact index samples now call the underlying AliasTable compact sampler directly. |
| S4-M891 AliasTable u32 index alias direct checked path | `src/distributions.zig`, `compare/results/s4-m891-aliastable-u32-index-alias-direct.md` | Closed for the current bar: AliasTable compact index alias now calls the checked u32 sampler directly. |
| S4-M892 AliasTable index alias direct checked path | `src/distributions.zig`, `compare/results/s4-m892-aliastable-index-alias-direct.md` | Closed for the current bar: AliasTable index alias now calls the checked sampler path directly. |
| S4-M893 Weighted tree index aliases direct checked paths | `src/distributions.zig`, `compare/results/s4-m893-weighted-tree-index-alias-direct.md` | Closed for the current bar: dynamic weighted tree index aliases now call checked sampling paths directly. |
| S4-M894 AliasTable checked sample direct path | `src/distributions.zig`, `compare/results/s4-m894-aliastable-checked-sample-direct.md` | Closed for the current bar: AliasTable checked sampling now executes alias-table sampling paths directly. |
| S4-M895 AliasTable u32 checked sample direct path | `src/distributions.zig`, `compare/results/s4-m895-aliastable-u32-checked-direct.md` | Closed for the current bar: AliasTable compact checked sampling now executes u32 alias-table branches directly. |
| S4-M896 AliasTable checked index alias direct path | `src/distributions.zig`, `compare/results/s4-m896-aliastable-index-checked-direct.md` | Closed for the current bar: AliasTable checked index alias now executes alias-table sampling paths directly. |
| S4-M897 Charset checked sample direct index paths | `src/ascii.zig`, `compare/results/s4-m897-charset-checked-sample-direct.md` | Closed for the current bar: ASCII and Unicode charset checked samples now draw uniform indexes and map into storage directly after prevalidation. |
| S4-M898 Distribution Choose checked sample direct index paths | `src/distributions.zig`, `compare/results/s4-m898-distribution-choose-checked-sample-direct.md` | Closed for the current bar: distribution-layer Choose checked scalar value/index/u32 samples now draw indexes directly after prevalidation. |
| S4-M899 Choice checked sample direct index paths | `src/seq.zig`, `compare/results/s4-m899-choice-checked-sample-direct.md` | Closed for the current bar: reusable Choice checked scalar value/index/u32 samples now draw indexes directly after prevalidation. |
| S4-M900 WeightedChoice checked sample direct table paths | `src/seq.zig`, `compare/results/s4-m900-weightedchoice-checked-sample-direct.md` | Closed for the current bar: reusable WeightedChoice checked scalar value/index/u32 samples now sample the underlying AliasTable directly after prevalidation. |
| S4-M901 ValueChecked aliases direct sampling paths | `src/distributions.zig`, `src/seq.zig`, `compare/results/s4-m901-valuechecked-direct.md` | Closed for the current bar: Choose/Choice/WeightedChoice valueChecked aliases now sample directly after prevalidation. |
| S4-M902 AliasTable u32 checked index alias direct path | `src/distributions.zig`, `compare/results/s4-m902-aliastable-u32-index-checked-direct.md` | Closed for the current bar: AliasTable checked compact index aliases now execute u32 alias-table sampling branches directly. |
| S4-M903 Weighted tree checked aliases direct sampler paths | `src/distributions.zig`, `compare/results/s4-m903-weighted-tree-checked-alias-direct.md` | Closed for the current bar: dynamic WeightedTree and WeightedIntTree checked scalar/index/u32 aliases now validate once and sample directly. |
| S4-M904 SampleValueChecked facade aliases direct paths | `src/distributions.zig`, `src/seq.zig`, `compare/results/s4-m904-samplevaluechecked-facade-direct.md` | Closed for the current bar: Choose/Choice/WeightedChoice facade sampleValueChecked helpers now sample directly after prevalidation. |
| S4-M905 Checked index facade aliases direct paths | `src/distributions.zig`, `src/seq.zig`, `compare/results/s4-m905-checked-index-facade-direct.md` | Closed for the current bar: Choose/Choice/WeightedChoice facade checked index helpers now sample directly after prevalidation. |
| S4-M906 AliasTable checked index facade aliases direct paths | `src/distributions.zig`, `compare/results/s4-m906-aliastable-checked-index-facade-direct.md` | Closed for the current bar: AliasTable checked facade index aliases now execute alias-table sampling branches directly. |
| S4-M907 AliasTable index facade aliases direct paths | `src/distributions.zig`, `compare/results/s4-m907-aliastable-index-facade-direct.md` | Closed for the current bar: AliasTable facade index aliases now execute alias-table sampling branches directly. |
| S4-M908 AliasTable u32 facade sample direct paths | `src/distributions.zig`, `compare/results/s4-m908-aliastable-u32-facade-direct.md` | Closed for the current bar: AliasTable compact facade sample helpers now execute u32 alias-table sampling branches directly. |
| S4-M909 Weighted tree facade sample aliases direct paths | `src/distributions.zig`, `compare/results/s4-m909-weighted-tree-facade-direct.md` | Closed for the current bar: dynamic WeightedTree and WeightedIntTree facade sample/index/u32 aliases now validate once and sample directly. |
| S4-M910 U32 index facade fills direct paths | `src/distributions.zig`, `src/seq.zig`, `compare/results/s4-m910-u32-index-facade-fill-direct.md` | Closed for the current bar: Choose/Choice/WeightedChoice facade compact index fills now write directly. |
| S4-M911 Checked facade fills direct paths | `src/distributions.zig`, `src/seq.zig`, `compare/results/s4-m911-checked-facade-fill-direct.md` | Closed for the current bar: Choose/Choice/WeightedChoice checked facade pointer/value/index fills now write directly. |
| S4-M912 Checked u32 index facade fills direct paths | `src/distributions.zig`, `src/seq.zig`, `compare/results/s4-m912-checked-u32-index-facade-fill-direct.md` | Closed for the current bar: Choose/Choice/WeightedChoice checked facade compact index fills now write directly. |
| S4-M913 Distribution Choose checked array facade direct paths | `src/distributions.zig`, `compare/results/s4-m913-distribution-choose-checked-array-facade-direct.md` | Closed for the current bar: distribution Choose checked fixed-array facade helpers now fill directly. |
| S4-M914 Choice checked array facade direct paths | `src/seq.zig`, `compare/results/s4-m914-choice-checked-array-facade-direct.md` | Closed for the current bar: reusable Choice checked fixed-array facade helpers now fill directly. |
| S4-M915 WeightedChoice checked array facade direct paths | `src/seq.zig`, `compare/results/s4-m915-weightedchoice-checked-array-facade-direct.md` | Closed for the current bar: reusable WeightedChoice checked fixed-array facade helpers now fill directly. |
| S4-M916 Distribution Choose checked owned facade direct paths | `src/distributions.zig`, `compare/results/s4-m916-distribution-choose-checked-owned-facade-direct.md` | Closed for the current bar: distribution Choose checked allocation-returning facade helpers now allocate and fill directly. |
| S4-M917 Choice checked owned facade direct paths | `src/seq.zig`, `compare/results/s4-m917-choice-checked-owned-facade-direct.md` | Closed for the current bar: reusable Choice checked allocation-returning facade helpers now allocate and fill directly. |
| S4-M918 WeightedChoice checked owned facade direct paths | `src/seq.zig`, `compare/results/s4-m918-weightedchoice-checked-owned-facade-direct.md` | Closed for the current bar: reusable WeightedChoice checked allocation-returning facade helpers now allocate and fill directly. |
| S4-M919 Distribution Choose owned facade direct paths | `src/distributions.zig`, `compare/results/s4-m919-distribution-choose-owned-facade-direct.md` | Closed for the current bar: distribution Choose allocation-returning facade helpers now allocate and fill directly. |
| S4-M920 Choice owned facade direct paths | `src/seq.zig`, `compare/results/s4-m920-choice-owned-facade-direct.md` | Closed for the current bar: reusable Choice allocation-returning facade helpers now allocate and fill directly. |
| S4-M921 WeightedChoice owned facade direct paths | `src/seq.zig`, `compare/results/s4-m921-weightedchoice-owned-facade-direct.md` | Closed for the current bar: reusable WeightedChoice allocation-returning facade helpers now allocate and fill directly. |
| S4-M922 Distribution Choose checked iterator facade direct constructors | `src/distributions.zig`, `compare/results/s4-m922-distribution-choose-checked-iterator-facade-direct.md` | Closed for the current bar: distribution Choose checked iterator facade constructors now build iterators directly. |
| S4-M923 Choice checked iterator facade direct constructors | `src/seq.zig`, `compare/results/s4-m923-choice-checked-iterator-facade-direct.md` | Closed for the current bar: reusable Choice checked iterator facade constructors now build iterators directly. |
| S4-M924 WeightedChoice checked iterator facade direct constructors | `src/seq.zig`, `compare/results/s4-m924-weightedchoice-checked-iterator-facade-direct.md` | Closed for the current bar: reusable WeightedChoice checked iterator facade constructors now build iterators directly. |
| S4-M925 Distribution Choose iterator facade direct constructors | `src/distributions.zig`, `compare/results/s4-m925-distribution-choose-iterator-facade-direct.md` | Closed for the current bar: distribution Choose iterator facade constructors now build iterators directly. |
| S4-M926 Choice iterator facade direct constructors | `src/seq.zig`, `compare/results/s4-m926-choice-iterator-facade-direct.md` | Closed for the current bar: reusable Choice iterator facade constructors now build iterators directly. |
| S4-M927 WeightedChoice iterator facade direct constructors | `src/seq.zig`, `compare/results/s4-m927-weightedchoice-iterator-facade-direct.md` | Closed for the current bar: reusable WeightedChoice iterator facade constructors now build iterators directly. |
| S4-M928 Distribution Choose checked iterator From direct constructors | `src/distributions.zig`, `compare/results/s4-m928-distribution-choose-checked-iterator-from-direct.md` | Closed for the current bar: distribution Choose checked direct-source iterator constructors now build iterators directly. |
| S4-M929 Choice checked iterator From direct constructors | `src/seq.zig`, `compare/results/s4-m929-choice-checked-iterator-from-direct.md` | Closed for the current bar: reusable Choice checked direct-source iterator constructors now build iterators directly. |
| S4-M930 WeightedChoice checked iterator From direct constructors | `src/seq.zig`, `compare/results/s4-m930-weightedchoice-checked-iterator-from-direct.md` | Closed for the current bar: reusable WeightedChoice checked direct-source iterator constructors now build iterators directly. |
| S4-M931 Distribution Choose checked owned From direct paths | `src/distributions.zig`, `compare/results/s4-m931-distribution-choose-checked-owned-from-direct.md` | Closed for the current bar: distribution Choose checked direct-source allocation-returning helpers now allocate and fill directly. |
| S4-M932 Choice checked owned From direct paths | `src/seq.zig`, `compare/results/s4-m932-choice-checked-owned-from-direct.md` | Closed for the current bar: reusable Choice checked direct-source allocation-returning helpers now allocate and fill directly. |
| S4-M933 WeightedChoice checked owned From direct paths | `src/seq.zig`, `compare/results/s4-m933-weightedchoice-checked-owned-from-direct.md` | Closed for the current bar: reusable WeightedChoice checked direct-source allocation-returning helpers now allocate and fill directly. |
| S4-M934 Distribution Choose checked array From direct paths | `src/distributions.zig`, `compare/results/s4-m934-distribution-choose-checked-array-from-direct.md` | Closed for the current bar: distribution Choose checked direct-source fixed-array helpers now fill directly. |
| S4-M935 Choice checked array From direct paths | `src/seq.zig`, `compare/results/s4-m935-choice-checked-array-from-direct.md` | Closed for the current bar: reusable Choice checked direct-source fixed-array helpers now fill directly. |
| S4-M936 WeightedChoice checked array From direct paths | `src/seq.zig`, `compare/results/s4-m936-weightedchoice-checked-array-from-direct.md` | Closed for the current bar: reusable WeightedChoice checked direct-source fixed-array helpers now fill directly. |
| S4-M937 Choice pointer iterator From direct constructor | `src/seq.zig`, `compare/results/s4-m937-choice-pointer-iter-from-direct.md` | Closed for the current bar: reusable Choice pointer direct-source iterator alias now constructs directly. |
| S4-M938 WeightedChoice pointer iterator From direct constructor | `src/seq.zig`, `compare/results/s4-m938-weightedchoice-pointer-iter-from-direct.md` | Closed for the current bar: reusable WeightedChoice pointer direct-source iterator alias now constructs directly. |
| S4-M939 Choice u32 array From direct path | `src/seq.zig`, `compare/results/s4-m939-choice-u32-array-from-direct.md` | Closed for the current bar: reusable Choice compact direct-source fixed-array helper now fills directly. |
| S4-M940 WeightedChoice u32 array From direct path | `src/seq.zig`, `compare/results/s4-m940-weightedchoice-u32-array-from-direct.md` | Closed for the current bar: reusable WeightedChoice compact direct-source fixed-array helper now fills directly. |
| S4-M941 Distribution Choose array facade direct paths | `src/distributions.zig`, `compare/results/s4-m941-distribution-choose-array-facade-direct.md` | Closed for the current bar: distribution Choose non-checked fixed-array facade helpers now fill directly. |
| S4-M942 Choice array facade direct paths | `src/seq.zig`, `compare/results/s4-m942-choice-array-facade-direct.md` | Closed for the current bar: reusable Choice non-checked fixed-array facade helpers now fill directly. |
| S4-M943 WeightedChoice array facade direct paths | `src/seq.zig`, `compare/results/s4-m943-weightedchoice-array-facade-direct.md` | Closed for the current bar: reusable WeightedChoice non-checked fixed-array facade helpers now fill directly. |
| S4-M944 AliasTable checked owned From direct paths | `src/distributions.zig`, `compare/results/s4-m944-aliastable-checked-owned-from-direct.md` | Closed for the current bar: static AliasTable checked direct-source allocation-returning helpers now allocate and fill directly. |
| S4-M945 AliasTable owned facade direct paths | `src/distributions.zig`, `compare/results/s4-m945-aliastable-owned-facade-direct.md` | Closed for the current bar: static AliasTable allocation-returning facade helpers now allocate and fill directly. |
| S4-M946 AliasTable array direct paths | `src/distributions.zig`, `compare/results/s4-m946-aliastable-array-direct-paths.md` | Closed for the current bar: static AliasTable fixed-array helpers now fill directly. |
| S4-M947 AliasTable checked iterator direct constructors | `src/distributions.zig`, `compare/results/s4-m947-aliastable-checked-iterator-direct.md` | Closed for the current bar: static AliasTable checked iterator constructors now build iterators directly. |
| S4-M948 AliasTable checked u32 iterator From direct constructor | `src/distributions.zig`, `compare/results/s4-m948-aliastable-checked-u32-iterator-from-direct.md` | Closed for the current bar: static AliasTable checked compact direct-source iterator constructor now builds directly. |
| S4-M949 Weighted tree checked iterator direct constructors | `src/distributions.zig`, `compare/results/s4-m949-weighted-tree-checked-iterator-direct.md` | Closed for the current bar: dynamic weighted-tree checked `usize` iterator constructors now build iterators directly. |
| S4-M950 Weighted tree checked u32 iterator direct constructors | `src/distributions.zig`, `compare/results/s4-m950-weighted-tree-checked-u32-iterator-direct.md` | Closed for the current bar: dynamic weighted-tree checked compact iterator constructors now build iterators directly. |
| S4-M951 Weighted tree owned facade direct paths | `src/distributions.zig`, `compare/results/s4-m951-weighted-tree-owned-facade-direct.md` | Closed for the current bar: dynamic weighted-tree allocation-returning facade helpers now allocate and fill directly. |
| S4-M952 Weighted tree array direct paths | `src/distributions.zig`, `compare/results/s4-m952-weighted-tree-array-direct.md` | Closed for the current bar: dynamic weighted-tree fixed-array helpers now fill directly. |
| S4-M953 Weighted tree fill facade direct paths | `src/distributions.zig`, `compare/results/s4-m953-weighted-tree-fill-facade-direct.md` | Closed for the current bar: dynamic weighted-tree facade fill helpers now fill directly. |
| S4-M954 Weighted tree sample From direct paths | `src/distributions.zig`, `compare/results/s4-m954-weighted-tree-sample-from-direct.md` | Closed for the current bar: dynamic weighted-tree canonical direct-source sample helpers now sample directly. |
| S4-M955 AliasTable sample facade direct paths | `src/distributions.zig`, `compare/results/s4-m955-aliastable-sample-facade-direct.md` | Closed for the current bar: static AliasTable canonical facade samples now execute directly. |
| S4-M956 Choice sample facade direct path | `src/seq.zig`, `compare/results/s4-m956-choice-sample-facade-direct.md` | Closed for the current bar: reusable Choice pointer facade sampling now maps a direct facade-generated index. |
| S4-M957 WeightedChoice sample facade direct paths | `src/seq.zig`, `compare/results/s4-m957-weightedchoice-sample-facade-direct.md` | Closed for the current bar: reusable WeightedChoice facade pointer/value sampling now maps direct alias-table facade samples. |
| S4-M958 Choice value sample facade direct path | `src/seq.zig`, `compare/results/s4-m958-choice-value-sample-facade-direct.md` | Closed for the current bar: reusable Choice value facade sampling now maps a direct facade-generated index. |
| S4-M959 Index facade samples direct paths | `src/distributions.zig`, `src/seq.zig`, `compare/results/s4-m959-index-facade-samples-direct.md` | Closed for the current bar: non-checked choice and weighted-choice facade index helpers now sample directly. |
| S4-M960 Distribution Choose sample facade direct paths | `src/distributions.zig`, `compare/results/s4-m960-distribution-choose-sample-facade-direct.md` | Closed for the current bar: distribution Choose pointer/value facade sampling now maps direct facade-generated indexes. |
| S4-M961 ValueChecked facade direct refresh | `src/distributions.zig`, `src/seq.zig`, `compare/results/s4-m961-valuechecked-facade-direct-refresh.md` | Closed for the current bar: current checked value facade aliases now sample directly. |
| S4-M962 AliasTable index From direct refresh | `src/distributions.zig`, `compare/results/s4-m962-aliastable-index-from-direct-refresh.md` | Closed for the current bar: current AliasTable direct-source index alias samples directly. |
| S4-M963 AliasTable u32 From direct refresh | `src/distributions.zig`, `compare/results/s4-m963-aliastable-u32-from-direct-refresh.md` | Closed for the current bar: current AliasTable compact direct-source aliases sample directly. |
| S4-M964 Weighted tree index From direct refresh | `src/distributions.zig`, `compare/results/s4-m964-weighted-tree-index-from-direct-refresh.md` | Closed for the current bar: dynamic weighted-tree direct-source index aliases now sample directly. |
| S4-M965 Bernoulli sample facade direct paths | `src/distributions.zig`, `compare/results/s4-m965-bernoulli-sample-facade-direct.md` | Closed for the current bar: scalar/vector Bernoulli facade samples now sample directly. |
| S4-M966 Bernoulli fill facade direct paths | `src/distributions.zig`, `compare/results/s4-m966-bernoulli-fill-facade-direct.md` | Closed for the current bar: scalar/vector Bernoulli facade fills now fill directly. |
| S4-M967 Binomial sample facade direct paths | `src/distributions.zig`, `compare/results/s4-m967-binomial-sample-facade-direct.md` | Closed for the current bar: scalar/vector Binomial facade samples now sample directly. |
| S4-M968 Binomial fill facade direct paths | `src/distributions.zig`, `compare/results/s4-m968-binomial-fill-facade-direct.md` | Closed for the current bar: scalar/vector Binomial facade fills now fill directly. |
| S4-M969 Binomial top-level facade direct paths | `src/distributions.zig`, `compare/results/s4-m969-binomial-top-level-facade-direct.md` | Closed for the current bar: top-level scalar Binomial checked/fill facade helpers now avoid From wrappers. |
| S4-M970 Vector Binomial top-level facade direct paths | `src/distributions.zig`, `compare/results/s4-m970-vector-binomial-top-level-facade-direct.md` | Closed for the current bar: top-level vector Binomial facade helpers now avoid From wrappers. |
| S4-M971 Binomial Poisson-approx facade direct paths | `src/distributions.zig`, `compare/results/s4-m971-binomial-poisson-approx-facade-direct.md` | Closed for the current bar: scalar binomial Poisson-approx facade helpers now sample directly. |
| S4-M972 Vector Binomial Poisson-approx facade direct paths | `src/distributions.zig`, `compare/results/s4-m972-vector-binomial-poisson-approx-facade-direct.md` | Closed for the current bar: vector binomial Poisson-approx facade helpers now sample/fill directly. |
| S4-M973 NegativeBinomial sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m973-negative-binomial-sampler-facade-direct.md` | Closed for the current bar: scalar/vector NegativeBinomial reusable facade samplers now sample/fill directly. |
| S4-M974 NegativeBinomial top-level facade direct paths | `src/distributions.zig`, `compare/results/s4-m974-negative-binomial-top-level-facade-direct.md` | Closed for the current bar: top-level scalar NegativeBinomial checked/fill facade helpers now avoid From wrappers. |
| S4-M975 Vector NegativeBinomial top-level facade direct paths | `src/distributions.zig`, `compare/results/s4-m975-vector-negative-binomial-top-level-facade-direct.md` | Closed for the current bar: top-level vector NegativeBinomial facade helpers now avoid From wrappers. |
| S4-M976 Hypergeometric sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m976-hypergeometric-sampler-facade-direct.md` | Closed for the current bar: reusable Hypergeometric facade sample/fill helpers now dispatch directly. |
| S4-M977 Vector Hypergeometric facade direct paths | `src/distributions.zig`, `compare/results/s4-m977-vector-hypergeometric-facade-direct.md` | Closed for the current bar: top-level/reusable VectorHypergeometric facade helpers now dispatch directly. |
| S4-M978 Hypergeometric top-level facade direct paths | `src/distributions.zig`, `compare/results/s4-m978-hypergeometric-top-level-facade-direct.md` | Closed for the current bar: top-level scalar Hypergeometric facade helpers now avoid From wrappers. |
| S4-M979 Multinomial facade direct paths | `src/distributions.zig`, `compare/results/s4-m979-multinomial-facade-direct.md` | Closed for the current bar: reusable Multinomial facade helpers now sample directly. |
| S4-M980 Dirichlet facade direct paths | `src/distributions.zig`, `compare/results/s4-m980-dirichlet-facade-direct.md` | Closed for the current bar: reusable Dirichlet facade helpers now sample directly. |
| S4-M981 VectorPoissonAhrensDieter facade direct paths | `src/distributions.zig`, `compare/results/s4-m981-vector-poisson-ad-facade-direct.md` | Closed for the current bar: reusable VectorPoissonAhrensDieter facade sample/fill helpers now sample directly. |
| S4-M982 VectorPoissonAhrensDieter top-level facade direct paths | `src/distributions.zig`, `compare/results/s4-m982-vector-poisson-ad-top-level-facade-direct.md` | Closed for the current bar: top-level vector Poisson Ahrens-Dieter facade helpers now avoid From wrappers. |
| S4-M983 Poisson facade direct paths | `src/distributions.zig`, `compare/results/s4-m983-poisson-facade-direct.md` | Closed for the current bar: scalar/vector Poisson facade helpers now avoid From wrappers. |
| S4-M984 Poisson Ahrens-Dieter top-level facade direct paths | `src/distributions.zig`, `compare/results/s4-m984-poisson-ad-top-level-facade-direct.md` | Closed for the current bar: scalar top-level Poisson Ahrens-Dieter facade helpers now avoid From wrappers. |
| S4-M985 Geometric facade direct paths | `src/distributions.zig`, `compare/results/s4-m985-geometric-facade-direct.md` | Closed for the current bar: scalar Geometric and GeometricFailures facade helpers now avoid From wrappers. |
| S4-M986 Vector Geometric facade direct paths | `src/distributions.zig`, `compare/results/s4-m986-vector-geometric-facade-direct.md` | Closed for the current bar: vector Geometric and GeometricFailures facade helpers now avoid From wrappers. |
| S4-M987 StandardGeometric facade direct paths | `src/distributions.zig`, `compare/results/s4-m987-standard-geometric-facade-direct.md` | Closed for the current bar: scalar/vector StandardGeometric facade helpers now avoid From wrappers. |
| S4-M988 Bernoulli top-level facade direct paths | `src/distributions.zig`, `compare/results/s4-m988-bernoulli-top-level-facade-direct.md` | Closed for the current bar: scalar/vector top-level Bernoulli facade helpers now avoid From wrappers. |
| S4-M989 Uniform sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m989-uniform-sampler-facade-direct.md` | Closed for the current bar: reusable scalar Uniform facade sample/fill helpers now avoid From wrappers. |
| S4-M990 Uniform top-level facade direct paths | `src/distributions.zig`, `compare/results/s4-m990-uniform-top-level-facade-direct.md` | Closed for the current bar: scalar top-level Uniform facade helpers now avoid From wrappers. |
| S4-M991 VectorUniform sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m991-vector-uniform-sampler-facade-direct.md` | Closed for the current bar: reusable VectorUniform facade sample/fill helpers now avoid From wrappers. |
| S4-M992 VectorUniform top-level facade direct paths | `src/distributions.zig`, `compare/results/s4-m992-vector-uniform-top-level-facade-direct.md` | Closed for the current bar: top-level vector Uniform facade helpers now avoid From wrappers. |
| S4-M993 UniformDuration facade direct paths | `src/distributions.zig`, `compare/results/s4-m993-uniform-duration-facade-direct.md` | Closed for the current bar: reusable UniformDuration facade sample/fill helpers now avoid From wrappers. |
| S4-M994 UniformUnicodeScalar facade direct paths | `src/distributions.zig`, `compare/results/s4-m994-uniform-unicode-scalar-facade-direct.md` | Closed for the current bar: reusable UniformUnicodeScalar facade sample/fill helpers now avoid From wrappers. |
| S4-M995 Open01/OpenClosed01 facade direct paths | `src/distributions.zig`, `compare/results/s4-m995-open01-facade-direct.md` | Closed for the current bar: scalar/vector strict-interval facade helpers now avoid direct-source wrappers. |
| S4-M996 Gamma sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m996-gamma-sampler-facade-direct.md` | Closed for the current bar: reusable scalar Gamma facade sample/fill helpers now avoid From wrappers. |
| S4-M997 VectorGamma sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m997-vector-gamma-sampler-facade-direct.md` | Closed for the current bar: reusable VectorGamma facade sample/fill helpers now avoid From wrappers. |
| S4-M998 Gamma top-level facade direct paths | `src/distributions.zig`, `compare/results/s4-m998-gamma-top-level-facade-direct.md` | Closed for the current bar: scalar/vector top-level Gamma facade helpers now avoid From wrappers. |
| S4-M999 ChiSquared sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m999-chi-squared-sampler-facade-direct.md` | Closed for the current bar: reusable scalar/vector ChiSquared facade sample/fill helpers now avoid From wrappers. |
| S4-M1000 ChiSquared top-level facade direct paths | `src/distributions.zig`, `compare/results/s4-m1000-chi-squared-top-level-facade-direct.md` | Closed for the current bar: scalar/vector top-level ChiSquared facade helpers now avoid From wrappers. |
| S4-M1001 Chi sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m1001-chi-sampler-facade-direct.md` | Closed for the current bar: reusable scalar/vector Chi facade sample/fill helpers now avoid From wrappers. |
| S4-M1002 Chi top-level facade direct paths | `src/distributions.zig`, `compare/results/s4-m1002-chi-top-level-facade-direct.md` | Closed for the current bar: scalar/vector top-level Chi facade helpers now avoid From wrappers. |
| S4-M1003 Erlang sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m1003-erlang-sampler-facade-direct.md` | Closed for the current bar: reusable scalar/vector Erlang facade sample/fill helpers now avoid From wrappers. |
| S4-M1004 Erlang top-level facade direct paths | `src/distributions.zig`, `compare/results/s4-m1004-erlang-top-level-facade-direct.md` | Closed for the current bar: scalar/vector top-level Erlang facade helpers now avoid From wrappers. |
| S4-M1005 Beta sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m1005-beta-sampler-facade-direct.md` | Closed for the current bar: reusable scalar Beta facade sample/fill helpers now avoid From wrappers. |
| S4-M1006 VectorBeta sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m1006-vector-beta-sampler-facade-direct.md` | Closed for the current bar: reusable VectorBeta facade sample/fill helpers now avoid From wrappers. |
| S4-M1007 Beta top-level facade direct paths | `src/distributions.zig`, `compare/results/s4-m1007-beta-top-level-facade-direct.md` | Closed for the current bar: scalar/vector top-level Beta facade helpers now avoid From wrappers. |
| S4-M1008 FisherF sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m1008-fisher-f-sampler-facade-direct.md` | Closed for the current bar: reusable scalar/vector FisherF facade sample/fill helpers now avoid From wrappers. |
| S4-M1009 FisherF top-level facade direct paths | `src/distributions.zig`, `compare/results/s4-m1009-fisher-f-top-level-facade-direct.md` | Closed for the current bar: scalar/vector top-level FisherF facade helpers now avoid From wrappers. |
| S4-M1010 StudentT sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m1010-student-t-sampler-facade-direct.md` | Closed for the current bar: reusable scalar/vector StudentT facade sample/fill helpers now avoid From wrappers. |
| S4-M1011 StudentT top-level facade direct paths | `src/distributions.zig`, `compare/results/s4-m1011-student-t-top-level-facade-direct.md` | Closed for the current bar: scalar/vector top-level StudentT facade helpers now avoid From wrappers. |
| S4-M1012 Triangular sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m1012-triangular-sampler-facade-direct.md` | Closed for the current bar: reusable scalar/vector Triangular facade sample/fill helpers now avoid From wrappers. |
| S4-M1013 Arcsine sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m1013-arcsine-sampler-facade-direct.md` | Closed for the current bar: reusable scalar/vector Arcsine facade sample/fill helpers now avoid From wrappers. |
| S4-M1014 Cauchy sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m1014-cauchy-sampler-facade-direct.md` | Closed for the current bar: reusable scalar/vector Cauchy facade sample/fill helpers now avoid From wrappers. |
| S4-M1015 Laplace sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m1015-laplace-sampler-facade-direct.md` | Closed for the current bar: reusable scalar/vector Laplace facade sample/fill helpers now avoid From wrappers. |
| S4-M1016 Logistic sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m1016-logistic-sampler-facade-direct.md` | Closed for the current bar: reusable scalar/vector Logistic facade sample/fill helpers now avoid From wrappers. |
| S4-M1017 LogLogistic sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m1017-log-logistic-sampler-facade-direct.md` | Closed for the current bar: reusable scalar/vector LogLogistic facade sample/fill helpers now avoid From wrappers. |
| S4-M1018 Kumaraswamy sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m1018-kumaraswamy-sampler-facade-direct.md` | Closed for the current bar: reusable scalar/vector Kumaraswamy facade sample/fill helpers now avoid From wrappers. |
| S4-M1019 PowerFunction sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m1019-power-function-sampler-facade-direct.md` | Closed for the current bar: reusable scalar/vector PowerFunction facade sample/fill helpers now avoid From wrappers. |
| S4-M1020 Rayleigh sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m1020-rayleigh-sampler-facade-direct.md` | Closed for the current bar: reusable scalar/vector Rayleigh facade sample/fill helpers now avoid From wrappers. |
| S4-M1021 Maxwell sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m1021-maxwell-sampler-facade-direct.md` | Closed for the current bar: reusable scalar/vector Maxwell facade sample/fill helpers now avoid From wrappers. |
| S4-M1022 Pareto sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m1022-pareto-sampler-facade-direct.md` | Closed for the current bar: reusable scalar/vector Pareto facade sample/fill helpers now avoid From wrappers. |
| S4-M1023 Weibull sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m1023-weibull-sampler-facade-direct.md` | Closed for the current bar: reusable scalar/vector Weibull facade sample/fill helpers now avoid From wrappers. |
| S4-M1024 Gumbel sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m1024-gumbel-sampler-facade-direct.md` | Closed for the current bar: reusable scalar/vector Gumbel facade sample/fill helpers now avoid From wrappers. |
| S4-M1025 Frechet sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m1025-frechet-sampler-facade-direct.md` | Closed for the current bar: reusable scalar/vector Frechet facade sample/fill helpers now avoid From wrappers. |
| S4-M1026 SkewNormal sampler facade direct paths | `src/distributions.zig`, `compare/results/s4-m1026-skew-normal-sampler-facade-direct.md` | Closed for the current bar: reusable scalar/vector SkewNormal facade sample/fill helpers now avoid From wrappers. |
| S4-M1027 next unblocked product gap | `core-rand-coverage.md`, future audits | Not complete; S4-M11 remains blocked and the next independent product improvement has not yet been selected. |
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
S4-M432 additionally adds a dedicated `rand-status-json` build step and includes
it in `validate-local`; it is local comparison validation ergonomics and does
not resolve S4-M11 or complete the long-term objective.
S4-M433 additionally refreshes `validate-local` evidence after adding
`rand-status-json` to the aggregate; it is validation evidence and does not
resolve S4-M11 or complete the long-term objective.
S4-M434 additionally syncs S4-M11 blocker evidence with the fresh
rand-status-json `validate-local` output; it is blocker-evidence maintenance and
does not resolve S4-M11 or complete the long-term objective.
S4-M435 additionally documents and guards the `rand-status-json` schema; it is
tooling documentation reliability and does not resolve S4-M11 or complete the
long-term objective.
S4-M436 additionally adds a direct `rand-status` self-test and includes it in
`validate-local`; it is local comparison tooling reliability and does not
resolve S4-M11 or complete the long-term objective.
S4-M437 additionally refreshes `validate-local` evidence after adding
`rand-status-self-test` to the aggregate; it is validation evidence and does not
resolve S4-M11 or complete the long-term objective.
S4-M438 additionally syncs S4-M11 blocker evidence with the fresh
rand-status-self-test `validate-local` output; it is blocker-evidence
maintenance and does not resolve S4-M11 or complete the long-term objective.
S4-M439 additionally aligns the `validate-local` build-step description with the
expanded status checks; it is tooling accuracy and does not resolve S4-M11 or
complete the long-term objective.
S4-M440 additionally adds stable boolean fields to `rand-status-json`; it is
tooling ergonomics and does not resolve S4-M11 or complete the long-term
objective.
S4-M441 additionally syncs S4-M11 blocker evidence with those JSON boolean
fields; it is blocker-evidence maintenance and does not resolve S4-M11 or
complete the long-term objective.
S4-M442 additionally keeps those JSON boolean fields visible in the current
status snapshot; it is evidence-quality maintenance and does not resolve S4-M11
or complete the long-term objective.
S4-M443 additionally adds a `schema_version` field to `rand-status-json`; it is
tooling compatibility and does not resolve S4-M11 or complete the long-term
objective.
S4-M444 additionally keeps that `schema_version` visible in the current status
snapshot; it is evidence-quality maintenance and does not resolve S4-M11 or
complete the long-term objective.
S4-M445 additionally syncs S4-M11 blocker evidence with that JSON schema version;
it is blocker-evidence maintenance and does not resolve S4-M11 or complete the
long-term objective.
S4-M446 additionally extends `rand-status` self-tests to cover the bad-argument
path; it is tooling reliability and does not resolve S4-M11 or complete the
long-term objective.
S4-M447 additionally adds a `rand-status` schema-version command and build step;
it is tooling compatibility and does not resolve S4-M11 or complete the
long-term objective.
S4-M448 additionally refreshes `validate-local` evidence after adding
`rand-status-schema-version` to the aggregate; it is validation evidence and does
not resolve S4-M11 or complete the long-term objective.
S4-M449 additionally syncs S4-M11 blocker evidence with the fresh schema-version
`validate-local` output; it is blocker-evidence maintenance and does not resolve
S4-M11 or complete the long-term objective.
S4-M450 additionally refreshes the `rand-status` command matrix; it is tooling
validation evidence and does not resolve S4-M11 or complete the long-term
objective.
S4-M451 additionally guards that `rand-status` command matrix evidence; it is
evidence-quality maintenance and does not resolve S4-M11 or complete the
long-term objective.
S4-M452 additionally exposes that command matrix from README; it is
documentation discoverability and does not resolve S4-M11 or complete the
long-term objective.
S4-M453 additionally exposes that command matrix from the core guide and API
reference; it is documentation discoverability and does not resolve S4-M11 or
complete the long-term objective.
S4-M454 additionally exposes that command matrix from the tooling catalog; it is
documentation discoverability and does not resolve S4-M11 or complete the
long-term objective.
S4-M455 additionally records and guards direct documented `rand-status` command
forms; it is tooling validation evidence and does not resolve S4-M11 or complete
the long-term objective.
S4-M456 additionally refreshes this active completion audit with current
rand-status, validate-local, and S4-M11 blocker evidence; it is audit
maintenance and does not resolve S4-M11 or complete the long-term objective.
S4-M457 additionally guards this active completion audit refresh in
roadmapcheck; it is audit quality maintenance and does not resolve S4-M11 or
complete the long-term objective.
S4-M458 additionally adds a latest-validate-local evidence pointer to
`rand-status-json`; it is tooling ergonomics and does not resolve S4-M11 or
complete the long-term objective.
S4-M459 additionally keeps that latest-validate-local evidence pointer visible
in the current status snapshot; it is evidence-quality maintenance and does not
resolve S4-M11 or complete the long-term objective.
S4-M460 additionally syncs S4-M11 blocker evidence with that JSON latest-evidence
field; it is blocker-evidence maintenance and does not resolve S4-M11 or
complete the long-term objective.
S4-M461 additionally adds a blocker-audit pointer to `rand-status-json`; it is
tooling ergonomics and does not resolve S4-M11 or complete the long-term
objective.
S4-M462 additionally keeps that blocker-audit pointer visible in the current
status snapshot; it is evidence-quality maintenance and does not resolve S4-M11
or complete the long-term objective.
S4-M463 additionally refreshes `validate-local` evidence after adding that
blocker-audit pointer to status output; it is validation evidence and does not
resolve S4-M11 or complete the long-term objective.
S4-M464 additionally syncs S4-M11 blocker evidence with that fresh blocker-audit
`validate-local` output; it is blocker-evidence maintenance and does not resolve
S4-M11 or complete the long-term objective.
S4-M465 additionally adds an explicit local-status pointer to `rand-status-json`;
it is tooling ergonomics and does not resolve S4-M11 or complete the long-term
objective.
S4-M466 additionally keeps that local-status pointer visible in the current
status snapshot; it is evidence-quality maintenance and does not resolve S4-M11
or complete the long-term objective.
S4-M467 additionally syncs S4-M11 blocker evidence with that local-status JSON
field; it is blocker-evidence maintenance and does not resolve S4-M11 or
complete the long-term objective.
S4-M468 additionally refreshes `validate-local` evidence after adding that
local-status field to status output; it is validation evidence and does not
resolve S4-M11 or complete the long-term objective.
S4-M469 additionally updates the script-friendly latest validate-local
evidence pointer in `rand-status-json`; it is status-tooling maintenance and
does not resolve S4-M11 or complete the long-term objective.
S4-M470 additionally syncs S4-M11 blocker evidence to that fresh
latest-evidence pointer; it is blocker-evidence maintenance and does not
resolve S4-M11 or complete the long-term objective.
S4-M471 additionally adds root one-shot caller-owned fill helpers for
range/probability buffers; it is API ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M472 additionally adds root allocation-returning batch helpers for
random values, ranges, and probability booleans; it is API ergonomics work and
does not resolve S4-M11 or complete the long-term objective.
S4-M473 additionally adds root one-shot string and Unicode helpers; it is
API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M474 additionally adds root one-shot endpoint-float helpers; it is
API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M475 additionally adds root one-shot duration range helpers; it is
API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M476 additionally adds root one-shot Unicode scalar range helpers; it is
API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M477 additionally adds root one-shot sampler helpers; it is API
ergonomics work and does not resolve S4-M11 or complete the long-term objective.
S4-M478 additionally adds root one-shot choice helpers; it is API
ergonomics work and does not resolve S4-M11 or complete the long-term objective.
S4-M479 additionally adds root one-shot shuffle helpers; it is API
ergonomics work and does not resolve S4-M11 or complete the long-term objective.
S4-M480 additionally adds root one-shot weighted index helpers; it is API
ergonomics work and does not resolve S4-M11 or complete the long-term objective.
S4-M481 additionally adds root one-shot compact index choice helpers; it is
API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M482 additionally adds root one-shot fixed-size choice arrays; it is
API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M483 additionally adds root one-shot const-pointer choice helpers; it is
API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M484 additionally adds root one-shot mutable-pointer choice helpers; it is
API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M485 additionally adds root one-shot compact weighted index helpers; it
is API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M486 additionally adds root one-shot weighted index array helpers; it
is API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M487 additionally adds root one-shot weighted value helpers; it is API
ergonomics work and does not resolve S4-M11 or complete the long-term objective.
S4-M488 additionally adds root one-shot weighted const-pointer helpers; it
is API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M489 additionally adds root one-shot weighted mutable-pointer helpers; it
is API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M490 additionally adds root one-shot no-replacement value sampling; it
is API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M491 additionally adds root one-shot no-replacement index sampling; it
is API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M492 additionally adds root one-shot iterator choice helpers; it is
API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M493 additionally adds root one-shot weighted iterator choice helpers; it
is API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M494 additionally adds root one-shot iterator sampling helpers; it is
API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M495 additionally adds root one-shot caller-owned iterator sampling; it
is API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M496 additionally adds root one-shot fixed-size iterator sample arrays;
it is API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M497 additionally adds root one-shot weighted iterator sampling; it is
API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M498 additionally adds root one-shot caller-owned weighted iterator sampling;
it is API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M499 additionally adds root one-shot fixed-size weighted iterator arrays;
it is API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M500 additionally adds root one-shot weighted no-replacement index sampling;
it is API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M501 additionally adds root one-shot weighted no-replacement value sampling;
it is API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M502 additionally adds root one-shot weighted no-replacement value arrays;
it is API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M503 additionally adds root one-shot weighted no-replacement const-pointer sampling;
it is API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M504 additionally adds root one-shot weighted no-replacement mutable-pointer
sampling; it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M505 additionally adds root one-shot weighted no-replacement caller-owned
index buffers; it is API ergonomics work and does not resolve S4-M11 or complete
the long-term objective.
S4-M506 additionally adds root one-shot weighted no-replacement caller-owned
value buffers; it is API ergonomics work and does not resolve S4-M11 or complete
the long-term objective.
S4-M507 additionally adds root one-shot weighted no-replacement caller-owned
const-pointer buffers; it is API ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M508 additionally adds root one-shot weighted no-replacement caller-owned
mutable-pointer buffers; it is API ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M509 additionally adds root one-shot weighted no-replacement fixed-size index
arrays; it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M510 additionally adds root one-shot compact IndexVec sampling; it is API
ergonomics work and does not resolve S4-M11 or complete the long-term objective.
S4-M511 additionally adds root one-shot weighted no-replacement compact IndexVec
sampling; it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M512 additionally adds root one-shot no-replacement fixed-size index arrays;
it is API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M513 additionally adds root one-shot no-replacement fixed-size value arrays;
it is API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M514 additionally adds root one-shot no-replacement fixed-size const-pointer
arrays; it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M515 additionally adds root one-shot no-replacement fixed-size mutable-pointer
arrays; it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M516 additionally adds root one-shot no-replacement const-pointer sampling; it
is API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M517 additionally adds root one-shot no-replacement mutable-pointer sampling;
it is API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M518 additionally adds root one-shot no-replacement caller-owned value and
pointer buffers; it is API ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M519 additionally adds root chooseMultiple no-replacement aliases; it is API
ergonomics/discoverability work and does not resolve S4-M11 or complete the
long-term objective.
S4-M520 additionally adds root sampled no-replacement value and pointer
iterators; it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M521 additionally adds root one-shot reservoir value and pointer helpers; it
is API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M522 additionally adds root repeated with-replacement fixed-size choice array
aliases; it is API ergonomics/discoverability work and does not resolve S4-M11
or complete the long-term objective.
S4-M523 additionally adds root iterator sample-fill aliases; it is API
ergonomics/discoverability work and does not resolve S4-M11 or complete the
long-term objective.
S4-M524 additionally adds root no-replacement value array choose aliases; it is
API ergonomics/discoverability work and does not resolve S4-M11 or complete the
long-term objective.
S4-M525 additionally adds root one-shot index-weighted index helpers; it is API
ergonomics work and does not resolve S4-M11 or complete the long-term objective.
S4-M526 additionally adds root one-shot index-weighted caller-owned fill helpers;
it is API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M527 additionally adds root one-shot index-weighted batch helpers; it is API
ergonomics work and does not resolve S4-M11 or complete the long-term objective.
S4-M528 additionally adds root one-shot index-weighted fixed-size array helpers;
it is API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M529 additionally adds root one-shot index-weighted value choice helpers; it
is API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M530 additionally adds root one-shot index-weighted const-pointer choice
helpers; it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M531 additionally adds root one-shot index-weighted mutable-pointer choice
helpers; it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M532 additionally adds root one-shot index-weighted caller-owned value fill
helpers; it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M533 additionally adds root one-shot index-weighted caller-owned
const-pointer fill helpers; it is API ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M534 additionally adds root one-shot index-weighted caller-owned
mutable-pointer fill helpers; it is API ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M535 additionally adds root one-shot index-weighted value batch helpers; it
is API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M536 additionally adds root one-shot index-weighted const-pointer batch
helpers; it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M537 additionally adds root one-shot index-weighted mutable-pointer batch
helpers; it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M538 additionally adds root one-shot index-weighted fixed-size value array
helpers; it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M539 additionally adds root one-shot index-weighted fixed-size
const-pointer array helpers; it is API ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M540 additionally adds root one-shot index-weighted fixed-size
mutable-pointer array helpers; it is API ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M541 additionally adds root one-shot item-accessor weighted index helpers;
it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M542 additionally adds root one-shot item-accessor weighted `u32` index
helpers; it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M543 additionally adds root item-accessor weighted `usize` index fill
helpers; it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M544 additionally adds root item-accessor weighted `u32` index fill helpers;
it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M545 additionally adds root item-accessor weighted `usize` index batch
helpers; it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M546 additionally adds root item-accessor weighted `u32` index batch helpers;
it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M547 additionally adds root item-accessor weighted `usize` index array
helpers; it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M548 additionally adds root item-accessor weighted `u32` index array helpers;
it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M549 additionally adds root item-accessor weighted value choice helpers; it
is API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M550 additionally adds root item-accessor weighted const-pointer choice
helpers; it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M551 additionally adds root item-accessor weighted mutable-pointer choice
helpers; it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M552 additionally adds root item-accessor weighted value fill helpers; it is
API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M553 additionally adds root item-accessor weighted const-pointer fill helpers;
it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M554 additionally adds root item-accessor weighted mutable-pointer fill
helpers; it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M555 additionally adds root item-accessor weighted value batch helpers; it is
API ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M556 additionally adds root item-accessor weighted const-pointer batch
helpers; it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M557 additionally adds root item-accessor weighted mutable-pointer batch
helpers; it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M558 additionally adds root item-accessor weighted fixed-size value array
helpers; it is API ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M559 additionally adds root item-accessor weighted fixed-size const-pointer
array helpers; it is API ergonomics work and does not resolve S4-M11 or complete
the long-term objective.
S4-M560 additionally adds root item-accessor weighted fixed-size mutable-pointer
array helpers; it is API ergonomics work and does not resolve S4-M11 or complete
the long-term objective.
S4-M561 additionally adds root item-accessor weighted no-replacement value
sample helpers; it is API ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M562 additionally adds root item-accessor weighted no-replacement
const-pointer sample helpers; it is API ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M563 additionally adds root item-accessor weighted no-replacement
mutable-pointer sample helpers; it is API ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M564 additionally adds root item-accessor weighted no-replacement value
into helpers; it is API ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M565 additionally adds root item-accessor weighted no-replacement
const-pointer into helpers; it is API ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M566 additionally adds root item-accessor weighted no-replacement
mutable-pointer into helpers; it is API ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M567 additionally adds root item-accessor weighted no-replacement index
sample helpers; it is API ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M568 additionally adds root item-accessor weighted no-replacement compact
u32 index sample helpers; it is API ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M569 additionally adds root item-accessor weighted no-replacement
IndexVec sample helpers; it is API ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M570 additionally adds root item-accessor weighted no-replacement index
into helpers; it is API ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M571 additionally adds root item-accessor weighted no-replacement index
array helpers; it is API ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M572 additionally adds root item-accessor weighted no-replacement compact
u32 index array helpers; it is API ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M573 additionally adds root length-weighted no-replacement index sample
helpers; it is API ergonomics work and does not resolve S4-M11 or complete
the long-term objective.
S4-M574 additionally adds root length-weighted no-replacement compact
u32 index sample helpers; it is API ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M575 additionally adds root length-weighted no-replacement IndexVec
sample helpers; it is API ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M576 additionally adds root length-weighted no-replacement index into
helpers; it is API ergonomics work and does not resolve S4-M11 or complete
the long-term objective.
S4-M577 additionally adds root length-weighted no-replacement compact
u32 index into helpers; it is API ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M578 additionally adds root length-weighted no-replacement index array
helpers; it is API ergonomics work and does not resolve S4-M11 or complete
the long-term objective.
S4-M579 additionally adds root length-weighted no-replacement compact
u32 index array helpers; it is API ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M580 additionally adds root item-accessor weighted no-replacement value
array sample helpers; it is API ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M581 additionally adds root item-accessor weighted no-replacement const-pointer
array sample helpers; it is API ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M582 additionally adds root item-accessor weighted no-replacement mutable-pointer
array sample helpers; it is API ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M583 additionally adds root parallel-weighted no-replacement value sample
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M584 additionally adds root parallel-weighted no-replacement const-pointer
sample prevalidation; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M585 additionally adds root parallel-weighted no-replacement mutable-pointer
sample prevalidation; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M586 additionally adds root parallel-weighted no-replacement value array
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M587 additionally adds root parallel-weighted no-replacement const-pointer
array prevalidation; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M588 additionally adds root parallel-weighted no-replacement mutable-pointer
array prevalidation; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M589 additionally adds root weighted-iterator fixed-array lazy entropy;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M590 additionally adds root weighted-iterator allocated sample lazy entropy;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M591 additionally adds root weighted-iterator into/fill lazy entropy; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M592 additionally adds root index fill/batch empty-range prevalidation; it
is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M593 additionally adds root value choose fill/batch empty-input
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M594 additionally adds root const-pointer choose fill/batch empty-input
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M595 additionally adds root mutable-pointer choose fill/batch empty-input
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M596 additionally tightens root weighted-index invalid-weight prevalidation;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M597 additionally tightens root weighted value batch prevalidation; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M598 additionally tightens root weighted const-pointer batch prevalidation;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M599 additionally tightens root weighted mutable-pointer batch prevalidation;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M600 additionally tightens root item-accessor weighted value batch
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M601 additionally tightens root item-accessor weighted const-pointer batch
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M602 additionally tightens root item-accessor weighted mutable-pointer batch
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M603 additionally tightens root by-index weighted value batch
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M604 additionally tightens root by-index weighted const-pointer batch
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M605 additionally tightens root by-index weighted mutable-pointer batch
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M606 additionally tightens root item-accessor weighted index batch
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M607 additionally tightens root item-accessor weighted compact u32 index
batch prevalidation; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M608 additionally tightens root by-index weighted index batch
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M609 additionally tightens root by-index weighted compact u32 index batch
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M610 additionally tightens root checked scalar batch parameter
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M611 additionally tightens root checked inclusive integer batch parameter
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M612 additionally tightens root checked Unicode scalar batch parameter
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M613 additionally tightens root duration range batch parameter
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M614 additionally tightens root unchecked Unicode scalar batch parameter
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M615 additionally tightens root checked value choose batch empty-input
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M616 additionally tightens root checked const-pointer choose batch empty-input
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M617 additionally tightens root checked mutable-pointer choose batch
empty-input prevalidation; it is reliability/ergonomics work and does not
resolve S4-M11 or complete the long-term objective.
S4-M618 additionally tightens root scalar range batch parameter prevalidation;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M619 additionally tightens root boolean probability/ratio batch parameter
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M620 additionally tightens root value batch empty-type prevalidation; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M621 additionally tightens root no-replacement value sample empty-type
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M622 additionally tightens root unchecked Unicode scalar range
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M623 additionally tightens root generic sampler batch empty-type
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M624 additionally tightens root generic value scalar/fill/sample empty-type
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M625 additionally tightens root scalar range prevalidation; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M626 additionally tightens root random iterator empty-type prevalidation;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M627 additionally tightens root boolean probability/ratio scalar/fill
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M628 additionally tightens root secure byte empty-output prevalidation; it
is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M629 additionally tightens root duration scalar range prevalidation; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M630 additionally tightens root weighted value sample empty-type
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M631 additionally tightens root item-accessor weighted value sample
empty-type prevalidation; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M632 additionally tightens root weighted fixed-size value array empty-type
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M633 additionally tightens root item-accessor weighted fixed-size value
array empty-type prevalidation; it is reliability/ergonomics work and does not
resolve S4-M11 or complete the long-term objective.
S4-M634 additionally tightens root item-accessor weighted repeated-choice
fixed-size value array empty-type prevalidation; it is reliability/ergonomics
work and does not resolve S4-M11 or complete the long-term objective.
S4-M635 additionally tightens root parallel-weighted repeated-choice fixed-size
value array empty-type prevalidation; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M636 additionally tightens root by-index weighted repeated-choice fixed-size
value array empty-type prevalidation; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M637 additionally tightens root unweighted value choose empty-type
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M638 additionally tightens root unweighted index-into invalid-count
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M639 additionally tightens root unweighted index allocation invalid-count
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M640 additionally tightens root unweighted no-replacement allocation and
iterator invalid-count prevalidation; it is reliability/ergonomics work and
does not resolve S4-M11 or complete the long-term objective.
S4-M641 additionally tightens root checked iterator exact-short prevalidation;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M642 additionally tightens root unchecked iterator exact-short
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M643 additionally tightens root parallel-weighted index allocation
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M644 additionally tightens direct sequence index allocation invalid-count
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M645 additionally tightens `Rng` no-replacement invalid-count prevalidation;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M646 additionally tightens ASCII charset unchecked empty prevalidation; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M647 additionally tightens Unicode charset unchecked invalid prevalidation;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M648 additionally tightens `Rng` unchecked repeated choice empty
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M649 additionally tightens `seq` unchecked repeated choice empty
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M650 additionally tightens `Rng` repeated choice fill empty-output
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M651 additionally tightens `Rng` weighted nullable batch prevalidation; it
is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M652 additionally tightens `Rng` scalar fill empty-output prevalidation; it
is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M653 additionally tightens `Rng` vector fill empty-output prevalidation; it
is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M654 additionally tightens `Rng` scalar normal/exponential fill empty-output
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M655 additionally tightens `Rng` vector normal/exponential fill empty-output
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M656 additionally tightens `Rng` scalar normal/exponential batch invalid
parameter prevalidation; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M657 additionally tightens `Rng` vector normal/exponential batch invalid
parameter prevalidation; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M658 additionally tightens `Rng` scalar range/probability batch invalid
parameter prevalidation; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M659 additionally tightens `Rng` vector range/probability batch invalid
parameter prevalidation; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M660 additionally tightens `Rng` duration range batch invalid-range
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M661 additionally tightens `Rng` Unicode scalar range batch invalid-parameter
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M662 additionally tightens `Rng` Unicode scalar range fill empty-output
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M663 additionally tightens `Rng` value batch empty-type prevalidation; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M664 additionally tightens `Rng` sample batch empty-type prevalidation; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M665 additionally tightens `Rng` sampler fill empty-output prevalidation; it
is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M666 additionally tightens root checked index batch empty-range prevalidation;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M667 additionally tightens `Rng` no-replacement empty-type prevalidation; it
is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M668 additionally tightens root `chooseMultiple` empty-type prevalidation; it
is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M669 additionally tightens root fixed value array empty-type prevalidation; it
is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M670 additionally tightens root caller-owned value sample empty-type
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M671 additionally tightens `seq` fixed value array empty-type prevalidation;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M672 additionally tightens `seq` caller-owned value sample empty-type
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M673 additionally tightens `seq` owned value sample empty-type prevalidation;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M674 additionally tightens `seq` sampled value iterator empty-type
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M675 additionally tightens `IndexVec` value mapping empty-type prevalidation;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M676 additionally tightens reservoir value sample empty-type prevalidation; it
is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M677 additionally tightens `seq` iterator reservoir value sample empty-type
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M678 additionally tightens root iterator reservoir value sample empty-type
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M679 additionally tightens `seq` weighted iterator reservoir value sample
empty-type prevalidation; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M680 additionally tightens root weighted iterator reservoir value sample
empty-type prevalidation; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M681 additionally tightens `seq` weighted value choice empty-type
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M682 additionally tightens `seq` item-accessor weighted value choice
empty-type prevalidation; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M683 additionally tightens `seq` index-weighted value choice empty-type
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M684 additionally tightens root item-accessor weighted value choice
empty-type prevalidation; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M685 additionally tightens root index-weighted value choice empty-type
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M686 additionally tightens root parallel-weight value choice empty-type
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M687 additionally tightens `Rng` regular-struct empty-type prevalidation; it
is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M688 additionally tightens `seq` parallel-weighted no-replacement value
sample empty-type prevalidation; it is reliability/ergonomics work and does not
resolve S4-M11 or complete the long-term objective.
S4-M689 additionally tightens `seq` item-accessor weighted no-replacement
value sample empty-type prevalidation; it is reliability/ergonomics work and
does not resolve S4-M11 or complete the long-term objective.
S4-M690 additionally tightens root weighted no-replacement caller-owned
value output empty-type prevalidation; it is reliability/ergonomics work and
does not resolve S4-M11 or complete the long-term objective.
S4-M691 additionally tightens `Rng` weighted value-choice empty-type
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M692 additionally tightens `Rng` unweighted value-choice empty-type
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M693 additionally tightens `seq` repeated fixed value array empty-type
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M694 additionally tightens `seq` repeated value fill/batch empty-type
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M695 additionally tightens `seq` one-shot value choice empty-type
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M696 additionally tightens `seq` iterator value choice empty-type
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M697 additionally tightens root iterator value choice empty-type
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M698 additionally tightens root weighted iterator value choice empty-type
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M699 additionally tightens root sampled value iterator empty-type
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M700 additionally tightens `seq` weighted iterator value choice empty-type
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M701 additionally tightens `seq` unchecked caller-owned iterator value
fill empty-type prevalidation; it is reliability/ergonomics work and does not
resolve S4-M11 or complete the long-term objective.
S4-M702 additionally tightens `seq` reusable weighted choice iterator
empty-type prevalidation; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M703 additionally tightens reusable `WeightedChoice` value-copy
empty-type prevalidation; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M704 additionally tightens reusable `Choice` value-copy empty-type
prevalidation; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M705 additionally adds reusable `Choice` checked fixed value arrays; it
is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M706 additionally adds reusable `WeightedChoice` checked fixed value
arrays; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M707 additionally tightens distribution-layer `Choose` value-copy
empty-type prevalidation; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M708 additionally adds distribution-layer `Choose` fixed-size value
arrays; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M709 additionally adds distribution-layer `Choose` owned repeated value
helpers; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M710 additionally adds distribution-layer `Choose` fixed-size and owned
pointer outputs; it is ergonomics work and does not resolve S4-M11 or complete
the long-term objective.
S4-M711 additionally adds distribution-layer `Choose` usize index outputs;
it is ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M712 additionally adds distribution-layer `Choose` u32 index outputs; it
is ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M713 additionally adds distribution-layer `Choose` index iterators; it is
ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M714 additionally adds distribution-layer `Choose` introspection helpers;
it is ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M715 additionally adds distribution-layer `Choose` probability
introspection helpers; it is ergonomics/diagnostics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M716 additionally adds distribution-layer `Choose` checked usize index
aliases; it is ergonomics/discoverability work and does not resolve S4-M11 or
complete the long-term objective.
S4-M717 additionally adds distribution-layer `Choose` checked u32 index
aliases; it is ergonomics/discoverability work and does not resolve S4-M11 or
complete the long-term objective.
S4-M718 additionally adds distribution-layer `Choose` checked scalar value
helpers; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M719 additionally adds distribution-layer `Choose` pointer iterators; it
is ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M720 additionally adds distribution-layer `Choose` checked pointer
aliases; it is ergonomics/discoverability work and does not resolve S4-M11 or
complete the long-term objective.
S4-M721 additionally adds distribution-layer `Choose` value iterators; it is
ergonomics work and does not resolve S4-M11 or complete the long-term objective.
S4-M722 additionally adds distribution-layer `Choose` checked iterator
aliases; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M723 additionally adds reusable `Choice` checked scalar value helpers; it
is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M724 additionally adds reusable `WeightedChoice` checked scalar value
helpers; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M725 additionally adds reusable `Choice` value iterator helpers; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M726 additionally adds reusable `WeightedChoice` value iterator helpers; it
is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M727 additionally adds reusable `Choice` pointer iterator aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M728 additionally adds reusable `WeightedChoice` pointer iterator aliases;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M729 additionally adds reusable `Choice` checked pointer aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M730 additionally adds reusable `WeightedChoice` checked pointer aliases; it
is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M731 additionally adds reusable `Choice` checked `usize` index aliases; it
is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M732 additionally adds reusable `WeightedChoice` checked `usize` index
aliases; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M733 additionally adds reusable `Choice` checked compact `u32` index aliases;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M734 additionally adds reusable `WeightedChoice` checked compact `u32` index
aliases; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M735 additionally adds reusable `Choice` checked value batch aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M736 additionally adds reusable `WeightedChoice` checked value batch aliases;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M737 additionally adds distribution-layer `Choose` checked value batch
aliases; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M738 additionally adds distribution-layer `Choose` checked compact `u32`
iterator aliases; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M739 additionally adds static `AliasTable` checked iterator aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M740 additionally adds dynamic weighted-tree checked iterator aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M741 additionally documents the existing static `AliasTable` checked `usize`
index API surface; it is documentation/discoverability work and does not resolve
S4-M11 or complete the long-term objective.
S4-M742 additionally adds invalid-state no-consumption evidence for dynamic
weighted-tree checked iterators; it is reliability/validation work and does not
resolve S4-M11 or complete the long-term objective.
S4-M743 additionally adds oversized-population no-consumption evidence for
static `AliasTable` checked compact `u32` iterators; it is reliability/validation
work and does not resolve S4-M11 or complete the long-term objective.
S4-M744 additionally adds oversized-population no-consumption evidence for
dynamic weighted-tree checked compact `u32` iterators; it is
reliability/validation work and does not resolve S4-M11 or complete the
long-term objective.
S4-M745 additionally adds checked aliases for canonical repeated pointer
iterators across `Choose`, `Choice`, and `WeightedChoice`; it is
ergonomics/API-consistency work and does not resolve S4-M11 or complete the
long-term objective.
S4-M746 additionally tightens allocation-returning compact `u32` index helpers
for `Choose` and `Choice` so oversized populations fail before allocation or
random-stream use; it is reliability/validation work and does not resolve S4-M11
or complete the long-term objective.
S4-M747 additionally tightens static `AliasTable` allocation-returning compact
`u32` index helper so oversized populations fail before allocation or
random-stream use; it is reliability/validation work and does not resolve S4-M11
or complete the long-term objective.
S4-M748 additionally tightens dynamic `WeightedTree` and `WeightedIntTree`
allocation-returning compact `u32` index helpers so oversized populations fail
before allocation or random-stream use; it is reliability/validation work and
does not resolve S4-M11 or complete the long-term objective.
S4-M749 additionally tightens dynamic `WeightedTree` and `WeightedIntTree`
checked allocation-returning `usize` and compact `u32` index helpers so invalid
all-zero trees fail before allocation or random-stream use; it is
reliability/validation work and does not resolve S4-M11 or complete the
long-term objective.
S4-M750 additionally adds static `AliasTable` checked allocation-returning
compact `u32` index aliases; it is ergonomics/API-consistency work and does not
resolve S4-M11 or complete the long-term objective.
S4-M751 additionally implements the documented static `AliasTable` checked
fixed-size `usize` index array aliases; it is API-correctness/ergonomics work
and does not resolve S4-M11 or complete the long-term objective.
S4-M752 additionally implements the documented static `AliasTable` checked
scalar, fill, and owned `usize` index aliases; it is API-correctness/ergonomics
work and does not resolve S4-M11 or complete the long-term objective.
S4-M753 additionally clarifies the `Rng.*FastFrom` namespace for scalar
normal/exponential fast-path helpers in adoption docs; it is
documentation/discoverability work and does not resolve S4-M11 or complete the
long-term objective.
S4-M754 additionally fixes and covers static/dynamic weighted checked facade
iterator constructors; it is API-correctness/reliability work and does not
resolve S4-M11 or complete the long-term objective.
S4-M755 additionally covers checked value/index iterator facade constructors for
`Choose`, `Choice`, and `WeightedChoice`; it is reliability/validation work and
does not resolve S4-M11 or complete the long-term objective.
S4-M756 additionally covers accessor- and index-weighted checked direct-source
convenience iterators against reusable `WeightedChoice` stream shape; it is
reliability/validation work and does not resolve S4-M11 or complete the
long-term objective.
S4-M757 additionally covers the parallel-weight checked direct-source
convenience iterator against reusable `WeightedChoice` stream shape; it is
reliability/validation work and does not resolve S4-M11 or complete the
long-term objective.
S4-M758 additionally covers static/dynamic weighted checked compact `u32`
iterator facade constructors against direct-source stream shape; it is
reliability/validation work and does not resolve S4-M11 or complete the
long-term objective.
S4-M759 additionally covers unweighted checked convenience iterators against
reusable `Choice` stream shape; it is reliability/validation work and does not
resolve S4-M11 or complete the long-term objective.
S4-M760 additionally tightens checked iterator sampling prevalidation for exact
short iterators; it is reliability/validation work and does not resolve S4-M11
or complete the long-term objective.
S4-M761 additionally tightens optional fixed-size iterator array helpers for
exact short iterators; it is reliability/validation work and does not resolve
S4-M11 or complete the long-term objective.
S4-M762 additionally tightens allocation-returning iterator helpers for
exact-empty sources; it is reliability/validation work and does not resolve
S4-M11 or complete the long-term objective.
S4-M763 additionally tightens caller-owned iterator helpers for exact-empty
sources; it is reliability/validation work and does not resolve S4-M11 or
complete the long-term objective.
S4-M764 additionally tightens weighted iterator one-shot choice helpers for
exact-empty sources; it is reliability/validation work and does not resolve
S4-M11 or complete the long-term objective.
S4-M765 additionally tightens unweighted iterator one-shot choice helpers for
exact-empty sources; it is reliability/validation work and does not resolve
S4-M11 or complete the long-term objective.
S4-M766 additionally tightens root allocation-returning unweighted iterator
samples for exact-empty sources; it is reliability/validation work and does not
resolve S4-M11 or complete the long-term objective.
S4-M767 additionally caps exact-short iterator sampling allocations by known
remaining counts; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M768 additionally avoids extra end-of-iterator probes for exact-short
unweighted iterator samples; it is reliability/ergonomics work and does not
resolve S4-M11 or complete the long-term objective.
S4-M769 additionally avoids extra end-of-iterator probes for exact-short
caller-owned unweighted iterator fills; it is reliability/ergonomics work and
does not resolve S4-M11 or complete the long-term objective.
S4-M770 additionally avoids extra end-of-iterator probes for exact-count checked
unweighted iterator samples; it is reliability/ergonomics work and does not
resolve S4-M11 or complete the long-term objective.
S4-M771 additionally avoids extra end-of-iterator probes for exact-single
weighted iterator choices; it is reliability/ergonomics work and does not
resolve S4-M11 or complete the long-term objective.
S4-M772 additionally avoids heap setup and extra probes for exact-single
allocation-returning weighted iterator samples; it is reliability/ergonomics
work and does not resolve S4-M11 or complete the long-term objective.
S4-M773 additionally avoids key sampling and extra probes for exact-single
caller-owned weighted iterator fills; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M774 additionally avoids extra end-of-iterator probes for exact-single
fixed-size weighted iterator arrays while preserving no-key/no-entropy behavior;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M775 additionally avoids key sampling and extra end-of-iterator probes for
all-positive exact-count fixed-size weighted iterator arrays; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M776 additionally avoids weighted heap/key setup and extra end-of-iterator
probes for allocation-returning exact-cover weighted iterator samples; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M777 additionally avoids key sampling and extra end-of-iterator probes for
caller-owned exact-cover weighted iterator fills; it is reliability/ergonomics
work and does not resolve S4-M11 or complete the long-term objective.
S4-M778 additionally avoids extra end-of-iterator probes for exact-count
weighted iterator one-shot choices while preserving stream shape; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M779 additionally avoids extra end-of-iterator probes for exact-count stable
unweighted iterator one-shot choices while preserving reservoir stream shape; it
is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M780 additionally reuses exact remaining metadata in fixed-size weighted
iterator arrays, avoiding duplicate size-hint/remaining probes; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M781 additionally reuses exact remaining metadata in allocation-returning
weighted iterator samples, avoiding duplicate size-hint/remaining probes; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M782 additionally reuses exact remaining metadata in root caller-owned
weighted iterator fills, avoiding duplicate size-hint/remaining probes; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M783 additionally avoids extra end-of-iterator probes for exact-long
fixed-size unweighted iterator arrays while preserving reservoir stream shape; it
is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M784 additionally avoids extra end-of-iterator probes for exact-long
caller-owned unweighted iterator fills while preserving reservoir stream shape;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M785 additionally avoids extra end-of-iterator probes for exact-long
allocation-returning unweighted iterator samples while preserving reservoir
stream shape; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M786 additionally reuses exact remaining metadata in root unweighted iterator
choice helpers, avoiding duplicate size-hint/remaining probes; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M787 additionally avoids extra end-of-iterator probes for exact-long
fixed-size weighted iterator arrays while preserving weighted-key stream shape;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M788 additionally avoids extra end-of-iterator probes for exact-long
caller-owned weighted iterator fills while preserving weighted-key stream shape;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M789 additionally avoids extra end-of-iterator probes for exact-long
allocation-returning weighted iterator samples while preserving weighted-key
stream shape; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M790 additionally avoids duplicate inexact metadata probes for hinted
iterator choice fallback paths while preserving reservoir stream shape; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M791 additionally reuses the owned index iterator bulk fill path for sampled
value/pointer iterator fills, reducing per-slot iterator overhead; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M792 additionally reuses index-buffer fills for non-owned IndexVec mapped
value/pointer iterator fills, reducing per-slot iterator overhead; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M793 additionally maps IndexVec caller-owned value/pointer outputs with
representation-specific loops, reducing per-slot union dispatch; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M794 additionally prevalidates native IndexVec to u32 owned-slice narrowing,
avoiding allocation before oversized-index failures; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M795 additionally fills uniform choice probability iterators with a direct
constant-probability path, reducing per-slot iterator overhead; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M796 additionally fills static AliasTable weight/probability iterators from
stored weights directly, reducing per-slot lookup overhead; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M797 additionally fills dynamic weighted tree weight/probability iterators
from tree storage directly and caches totals for probability fills, reducing
per-slot lookup overhead; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M798 additionally prevalidates native IndexVec to u32 copied-slice narrowing,
avoiding allocation before oversized-index failures; it is reliability/ergonomics
work and does not resolve S4-M11 or complete the long-term objective.
S4-M799 additionally fills borrowed and consuming IndexVec iterators from the
active backing storage directly, reducing per-slot union dispatch in downstream
index/value/pointer fill paths; it is reliability/ergonomics work and does not
resolve S4-M11 or complete the long-term objective.
S4-M800 additionally searches and validates IndexVec contents with
backing-specific scans, reducing per-slot union dispatch and preserving compact
u32 bounds semantics for oversized native item counts; it is reliability/
ergonomics work and does not resolve S4-M11 or complete the long-term objective.
S4-M801 additionally prevalidates native IndexVec to u32 caller-owned copying,
avoiding partial output mutation before oversized-index failures; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M802 additionally reads borrowed and consuming IndexVec iterator next values
from active backing storage directly, reducing per-step union dispatch in scalar
iterator consumers; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M803 additionally maps unweighted choice pointer/value fills directly from
generated indexes to item storage for reusable and distribution-layer choices,
reducing per-slot wrapper calls while preserving stream shape; it is reliability/
ergonomics work and does not resolve S4-M11 or complete the long-term objective.
S4-M804 additionally maps reusable WeightedChoice pointer/value fills directly
from alias-table sampled indexes to item storage, reducing per-slot wrapper calls
while preserving weighted stream shape; it is reliability/ergonomics work and
does not resolve S4-M11 or complete the long-term objective.
S4-M805 additionally fills static AliasTable usize/u32 index buffers with
inline alias-sampling loops, reducing per-slot sample wrapper calls while
preserving stream shape; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M806 additionally routes reusable WeightedChoice usize/u32 index fills through
the optimized AliasTable direct fill loops, reducing duplicated weighted-index
fill overhead while preserving stream shape; it is reliability/ergonomics work
and does not resolve S4-M11 or complete the long-term objective.
S4-M807 additionally fills dynamic WeightedTree and WeightedIntTree usize/u32
index buffers with direct tree-walk sampling loops, reducing per-slot sample
wrapper calls while preserving stream shape; it is reliability/ergonomics work
and does not resolve S4-M11 or complete the long-term objective.
S4-M808 additionally fills distribution-layer Choose usize index buffers with a
direct uniform index loop, reducing per-slot sample wrapper calls while
preserving stream shape; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M809 additionally fills reusable Choice usize index buffers with a cached
length direct uniform loop, reducing per-slot metadata reloads while preserving
stream shape; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M810 additionally fills distribution-layer Choose compact u32 index buffers
with a cached-length direct uniform loop, reducing per-slot metadata reloads and
preserving checked width/no-consume behavior; it is reliability/ergonomics work
and does not resolve S4-M11 or complete the long-term objective.
S4-M811 additionally fills reusable Choice compact u32 index buffers with a
cached-length direct uniform loop, reducing per-slot metadata reloads and
preserving checked width/no-consume behavior; it is reliability/ergonomics work
and does not resolve S4-M11 or complete the long-term objective.
S4-M812 additionally samples reusable Choice usize/u32 index iterator scalar
outputs directly from cached choice length, reducing per-item wrapper calls while
preserving stream shape; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M813 additionally samples distribution-layer Choose usize/u32 index iterator
scalar outputs directly from cached choice length, reducing per-item wrapper
calls while preserving stream shape; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M814 additionally samples reusable WeightedChoice usize/u32 index iterator
scalar outputs directly from the underlying AliasTable, reducing per-item wrapper
calls while preserving stream shape; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M815 additionally samples static AliasTable compact u32 iterator scalar
outputs through the checked table sampler directly, reducing per-item wrapper
calls while preserving stream shape; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M816 additionally samples dynamic WeightedTree and WeightedIntTree compact u32
iterator scalar outputs through the checked tree sampler directly, reducing
per-item wrapper calls while preserving stream shape; it is reliability/
ergonomics work and does not resolve S4-M11 or complete the long-term objective.
S4-M817 additionally samples reusable Choice value iterator scalar outputs by
mapping generated indexes directly to item storage, reducing per-item wrapper
calls while preserving stream shape; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M818 additionally samples distribution-layer Choose value iterator scalar
outputs by mapping generated indexes directly to item storage, reducing per-item
wrapper calls while preserving stream shape; it is reliability/ergonomics work
and does not resolve S4-M11 or complete the long-term objective.
S4-M819 additionally samples reusable WeightedChoice value iterator scalar outputs
by mapping alias-table indexes directly to item storage, reducing per-item
wrapper calls while preserving weighted stream shape; it is reliability/ergonomics
work and does not resolve S4-M11 or complete the long-term objective.
S4-M820 additionally samples distribution-layer Choose pointer iterator scalar
outputs by mapping generated indexes directly to item storage, reducing per-item
wrapper calls while preserving stream shape; it is reliability/ergonomics work
and does not resolve S4-M11 or complete the long-term objective.
S4-M821 additionally fills mapped samplers by applying the mapper directly to
base sampler outputs, reducing per-item mapped-sampler wrapper calls while
preserving stream shape; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M822 additionally fills Binomial outputs by calling the underlying binomialFrom
sampler directly, reducing per-item sampler wrapper calls while preserving stream
shape; it is reliability/ergonomics work and does not resolve S4-M11 or complete
the long-term objective.
S4-M823 additionally fills NegativeBinomial outputs by calling the underlying
negativeBinomialFrom sampler directly, reducing per-item sampler wrapper calls
while preserving stream shape; it is reliability/ergonomics work and does not
resolve S4-M11 or complete the long-term objective.
S4-M824 additionally fills Hypergeometric outputs by switching once on the
selected method and calling method samplers directly, reducing per-item sampler
wrapper calls while preserving stream shape; it is reliability/ergonomics work
and does not resolve S4-M11 or complete the long-term objective.
S4-M825 additionally fills Geometric outputs by calling the underlying
geometricFrom sampler directly, reducing per-item sampler wrapper calls while
preserving stream shape; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M826 additionally fills GeometricFailures outputs by calling the underlying
geometricFailuresFrom sampler directly, reducing per-item sampler wrapper calls
while preserving stream shape; it is reliability/ergonomics work and does not
resolve S4-M11 or complete the long-term objective.
S4-M827 additionally fills VectorGeometric outputs by drawing lanes with the
underlying geometricFrom sampler directly, reducing per-vector sampler wrapper
calls while preserving stream shape; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M828 additionally fills VectorGeometricFailures outputs by drawing lanes with
the underlying geometricFailuresFrom sampler directly, reducing per-vector sampler
wrapper calls while preserving stream shape; it is reliability/ergonomics work
and does not resolve S4-M11 or complete the long-term objective.
S4-M829 additionally fills VectorNegativeBinomial outputs by drawing lanes with
the underlying negativeBinomialFrom sampler directly, reducing per-vector sampler
wrapper calls while preserving stream shape; it is reliability/ergonomics work
and does not resolve S4-M11 or complete the long-term objective.
S4-M830 additionally fills VectorBinomial outputs by drawing lanes with the
underlying binomialFrom sampler directly, reducing per-vector sampler wrapper
calls while preserving stream shape; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M831 additionally fills VectorBinomialPoissonApprox outputs by drawing lanes
with the underlying binomialPoissonApproxFrom sampler directly, reducing
per-vector sampler wrapper calls while preserving stream shape; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M832 additionally fills VectorHypergeometric outputs by switching once on the
selected method and drawing lanes with method samplers directly, reducing
per-vector sampler wrapper calls while preserving stream shape; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M833 additionally fills VectorPoisson outputs by switching once on the
selected method and drawing lanes with method samplers directly, reducing
per-vector sampler wrapper calls while preserving stream shape; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M834 additionally routes reusable HalfNormal fills through the optimized
fillHalfNormalFrom helper, reducing per-item sample wrapper calls and preserving
stream shape; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M835 additionally routes reusable Exponential fills through shared standard
exponential bulk staging and in-place scaling, reducing per-item sample wrapper
calls and preserving stream shape; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M836 additionally routes reusable VectorExponential fills through shared
standard vector exponential bulk staging and in-place backing-lane scaling,
reducing parameterized dispatch work and preserving stream shape; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M837 additionally routes shape-one reusable Gamma fills through shared
standard exponential bulk staging and in-place scaling, matching the local
rand_distr `GammaRepr::One(Exp)` decomposition while preserving stream shape; it
is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M838 additionally routes shape-one reusable VectorGamma fills through shared
standard vector exponential bulk staging and in-place backing-lane scaling,
matching the same decomposition for vector fills while preserving stream shape;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M839 additionally routes reusable ChiSquared fills through the cached Gamma
sampler fill, reusing Gamma's shape-specific bulk paths including the shape-one
standard-exponential staging while preserving stream shape; it is reliability/
ergonomics work and does not resolve S4-M11 or complete the long-term objective.
S4-M840 additionally routes reusable VectorChiSquared fills through the cached
Gamma sampler via VectorGamma fill, reusing vector Gamma's shape-specific bulk
paths including shape-one standard-vector-exponential staging while preserving
stream shape; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M841 additionally routes reusable Chi fills through cached ChiSquared fills
and applies square root in place, reusing ChiSquared/Gamma bulk paths while
preserving stream shape; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M842 additionally routes reusable VectorChi fills through cached
VectorChiSquared fills and applies vector square root in place, reusing vector
ChiSquared/Gamma bulk paths while preserving stream shape; it is reliability/
ergonomics work and does not resolve S4-M11 or complete the long-term objective.
S4-M843 additionally routes reusable Erlang fills through cached Gamma fills,
reusing Gamma's shape-specific bulk paths while preserving stream shape; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M844 additionally routes reusable VectorErlang fills through cached Gamma via
VectorGamma fills, reusing vector Gamma's shape-specific bulk paths while
preserving stream shape; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M845 additionally routes reusable FisherF fills through direct cached
numerator/denominator Gamma draws and division, preserving stream shape while
avoiding per-output FisherF.sampleFrom wrapper calls; it is reliability/
ergonomics work and does not resolve S4-M11 or complete the long-term objective.
S4-M846 additionally routes reusable VectorFisherF fills through direct cached
numerator/denominator Gamma draws per lane and division, preserving stream shape
while avoiding per-output VectorFisherF.sampleFrom wrapper calls; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M847 additionally routes reusable finite-degree StudentT fills through direct
standard-normal and cached ChiSquared composition, preserving stream shape while
avoiding per-output StudentT.sampleFrom wrapper calls; it is reliability/
ergonomics work and does not resolve S4-M11 or complete the long-term objective.
S4-M848 additionally routes reusable finite-degree VectorStudentT fills through
direct standard-normal and cached ChiSquared composition per lane, preserving
stream shape while avoiding per-output VectorStudentT.sampleFrom wrapper calls;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M849 additionally routes reusable VectorTriangular fills through direct vector
uniform draws and triangular transforms, preserving stream shape while avoiding
per-output VectorTriangular.sampleFrom wrapper calls; it is reliability/
ergonomics work and does not resolve S4-M11 or complete the long-term objective.
S4-M850 additionally routes reusable VectorArcsine fills through direct vector
open-uniform draws and arcsine transforms, preserving stream shape while avoiding
per-output VectorArcsine.sampleFrom wrapper calls; it is reliability/ergonomics
work and does not resolve S4-M11 or complete the long-term objective.
S4-M851 additionally routes reusable VectorCauchy fills through direct vector
open-uniform draws and Cauchy transforms, preserving stream shape while avoiding
per-output VectorCauchy.sampleFrom wrapper calls; it is reliability/ergonomics
work and does not resolve S4-M11 or complete the long-term objective.
S4-M852 additionally routes reusable VectorLaplace fills through direct vector
open-uniform draws and Laplace transforms, preserving stream shape while avoiding
per-output VectorLaplace.sampleFrom wrapper calls; it is reliability/ergonomics
work and does not resolve S4-M11 or complete the long-term objective.
S4-M853 additionally routes reusable VectorLogistic fills through direct vector
open-uniform draws and Logistic transforms, preserving stream shape while
avoiding per-output VectorLogistic.sampleFrom wrapper calls; it is reliability/
ergonomics work and does not resolve S4-M11 or complete the long-term objective.
S4-M854 additionally routes reusable VectorLogLogistic fills through direct vector
open-uniform draws and LogLogistic transforms, including shape-one ratio handling,
preserving stream shape while avoiding per-output VectorLogLogistic.sampleFrom
wrapper calls; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M855 additionally routes reusable VectorKumaraswamy fills through direct
vector open-uniform draws and Kumaraswamy transforms, including beta-one and
alpha-one paths, preserving stream shape while avoiding per-output
VectorKumaraswamy.sampleFrom wrapper calls; it is reliability/ergonomics work
and does not resolve S4-M11 or complete the long-term objective.
S4-M856 additionally routes reusable VectorPowerFunction fills through direct
point-max, uniform range, square-root, and generic power-function transform paths,
preserving stream shape while avoiding per-output VectorPowerFunction.sampleFrom
wrapper calls; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M857 additionally routes reusable VectorRayleigh fills through direct vector
open-uniform draws and Rayleigh transforms, preserving stream shape while avoiding
per-output VectorRayleigh.sampleFrom wrapper calls; it is reliability/ergonomics
work and does not resolve S4-M11 or complete the long-term objective.
S4-M858 additionally routes reusable VectorMaxwell fills through direct vector
normal triples and Maxwell norm transforms, preserving stream shape while
avoiding per-output VectorMaxwell.sampleFrom wrapper calls; it is reliability/
ergonomics work and does not resolve S4-M11 or complete the long-term objective.
S4-M859 additionally routes reusable VectorPareto fills through direct vector
open-uniform draws and Pareto transforms, including shape-one reciprocal handling,
preserving stream shape while avoiding per-output VectorPareto.sampleFrom wrapper
calls; it is reliability/ergonomics work and does not resolve S4-M11 or complete
the long-term objective.
S4-M860 additionally routes reusable VectorWeibull fills through direct vector
open-uniform draws and Weibull transforms, including shape-one standard-exponential
handling, preserving stream shape while avoiding per-output VectorWeibull.sampleFrom
wrapper calls; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M861 additionally routes reusable VectorGumbel fills through direct vector
open-closed-uniform draws and Gumbel transforms, preserving stream shape while
avoiding per-output VectorGumbel.sampleFrom wrapper calls; it is reliability/
ergonomics work and does not resolve S4-M11 or complete the long-term objective.
S4-M862 additionally routes reusable VectorFrechet fills through direct vector
open-closed-uniform draws and Frechet transforms, including shape-one handling,
preserving stream shape while avoiding per-output VectorFrechet.sampleFrom wrapper
calls; it is reliability/ergonomics work and does not resolve S4-M11 or complete
the long-term objective.
S4-M863 additionally routes reusable VectorSkewNormal fills through direct vector
standard-normal draws and skew-normal composition, including symmetric and ±1
shape paths, preserving stream shape while avoiding per-output
VectorSkewNormal.sampleFrom wrapper calls; it is reliability/ergonomics work and
does not resolve S4-M11 or complete the long-term objective.
S4-M864 additionally routes reusable VectorPert fills through a cached VectorBeta
sampler followed by an affine range map, preserving stream shape while avoiding
per-output VectorPert.sampleFrom wrapper calls; it is reliability/ergonomics work
and does not resolve S4-M11 or complete the long-term objective.
S4-M865 additionally routes reusable VectorInverseGaussian fills through direct
vector standard-normal/uniform draws and the shared inverse-Gaussian composition,
preserving stream shape while avoiding per-output VectorInverseGaussian.sampleFrom
wrapper calls; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M866 additionally routes reusable VectorNormalInverseGaussian fills through
direct embedded inverse-Gaussian vector draws and final standard-normal vector
composition, preserving stream shape while avoiding per-output
VectorNormalInverseGaussian.sampleFrom wrapper calls; it is reliability/ergonomics
work and does not resolve S4-M11 or complete the long-term objective.
S4-M867 additionally routes reusable VectorZipf fills through direct cached scalar
Zipf lane sampling, preserving stream shape while avoiding per-output
VectorZipf.sampleFrom wrapper calls; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M868 additionally routes reusable VectorZeta fills through direct cached scalar
Zeta lane sampling, preserving stream shape while avoiding per-output
VectorZeta.sampleFrom wrapper calls; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M869 additionally routes reusable VectorBeta fills through direct cached scalar
Beta lane sampling, preserving stream shape while avoiding per-output
VectorBeta.sampleFrom wrapper calls; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M870 additionally routes reusable VectorPoissonAhrensDieter fills through
direct cached Ahrens-Dieter lane sampling, preserving stream shape while avoiding
per-output VectorPoissonAhrensDieter.sampleFrom wrapper calls; it is reliability/
ergonomics work and does not resolve S4-M11 or complete the long-term objective.
S4-M871 additionally routes reusable VectorBernoulli generic-probability fills
through direct cached-threshold lane comparisons, preserving stream shape while
avoiding per-output VectorBernoulli.sampleFrom wrapper calls; it is reliability/
ergonomics work and does not resolve S4-M11 or complete the long-term objective.
S4-M872 additionally routes reusable VectorGamma generic-shape fills through
direct cached scalar Gamma lane sampling, preserving stream shape while avoiding
per-output VectorGamma.sampleFrom wrapper calls and retaining the shape-one fast
path; it is reliability/ergonomics work and does not resolve S4-M11 or complete
the long-term objective.
S4-M873 additionally routes reusable Gamma generic-shape fills through direct
boosted-small-shape or regular Marsaglia method dispatch, preserving stream shape
while avoiding per-output Gamma.sampleFrom wrapper calls and retaining the
shape-one fast path; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M874 additionally routes reusable Beta generic fills through direct cached
Gamma draws and ratio normalization, preserving stream shape while avoiding
per-output Beta.sampleFrom wrapper calls and retaining edge fast paths; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M875 additionally routes reusable Pert fills through cached beta-parameter bulk
fills followed by in-place affine mapping, preserving stream shape while avoiding
per-output Pert.sampleFrom wrapper calls; it is reliability/ergonomics work and
does not resolve S4-M11 or complete the long-term objective.
S4-M876 additionally routes reusable Kumaraswamy generic fills through direct
open-uniform draws and the inverse-CDF transform, preserving stream shape while
avoiding per-output Kumaraswamy.sampleFrom wrapper calls and retaining edge fast
paths; it is reliability/ergonomics work and does not resolve S4-M11 or complete
the long-term objective.
S4-M877 additionally routes reusable Zipf fills through the direct cached
inverse-CDF proposal and rejection loop, preserving stream shape while avoiding
per-output Zipf.sampleFrom wrapper calls; it is reliability/ergonomics work and
does not resolve S4-M11 or complete the long-term objective.
S4-M878 additionally routes reusable Zeta fills through the direct cached
open-closed proposal and rejection loop, preserving stream shape while avoiding
per-output Zeta.sampleFrom wrapper calls; it is reliability/ergonomics work and
does not resolve S4-M11 or complete the long-term objective.
S4-M879 additionally routes reusable UniformDuration fills through direct
half-open or inclusive duration range helper dispatch, preserving stream shape
while avoiding per-output UniformDuration.sampleFrom wrapper calls; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M880 additionally routes reusable ASCII Charset fills through direct uniform
index sampling and byte-slice mapping, preserving stream shape while avoiding
per-byte Charset.sampleFrom wrapper calls; it is reliability/ergonomics work and
does not resolve S4-M11 or complete the long-term objective.
S4-M881 additionally routes reusable UnicodeCharset fills through direct uniform
index sampling and scalar-slice mapping, preserving stream shape while avoiding
per-scalar UnicodeCharset.sampleFrom wrapper calls; it is reliability/ergonomics
work and does not resolve S4-M11 or complete the long-term objective.
S4-M882 additionally routes UnicodeCharset UTF-8 appends through direct uniform
index sampling and scalar encoding, preserving stream shape while avoiding
per-scalar UnicodeCharset.sampleFrom wrapper calls; it is reliability/ergonomics
work and does not resolve S4-M11 or complete the long-term objective.
S4-M883 additionally routes reusable WeightedChoice pointer iterator scalar outputs
through direct alias-table sampling and item mapping, preserving stream shape
while avoiding per-output WeightedChoice.sampleFrom wrapper calls; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M884 additionally routes reusable WeightedChoice scalar pointer sampling through
direct alias-table sampling and item mapping, preserving stream shape while
avoiding the sampleIndexFrom wrapper call; it is reliability/ergonomics work and
does not resolve S4-M11 or complete the long-term objective.
S4-M885 additionally routes reusable WeightedChoice scalar value sampling through
direct alias-table sampling and item copying, preserving stream shape while
avoiding the sampleFrom wrapper call; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M886 additionally routes reusable Choice scalar value sampling through direct
uniform index generation and item copying, preserving stream shape while avoiding
the sampleFrom pointer wrapper call; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M887 additionally routes distribution-layer Choose scalar value sampling through
direct uniform index generation and item copying, preserving stream shape while
avoiding the sampleFrom pointer wrapper call; it is reliability/ergonomics work
and does not resolve S4-M11 or complete the long-term objective.
S4-M888 additionally routes reusable Choice scalar pointer sampling through direct
uniform index generation and item mapping, preserving stream shape while avoiding
the sampleIndexFrom wrapper call; it is reliability/ergonomics work and does not
resolve S4-M11 or complete the long-term objective.
S4-M889 additionally fills ASCII and Unicode charset probability iterators by
writing known uniform probabilities directly and advancing iterator state once,
avoiding per-slot next() calls; it is reliability/ergonomics work and does not
resolve S4-M11 or complete the long-term objective.
S4-M890 additionally routes reusable WeightedChoice compact index sampling through
the underlying AliasTable u32 sampler directly, preserving stream shape while
avoiding the usize sampleIndexFrom wrapper and cast; it is reliability/ergonomics
work and does not resolve S4-M11 or complete the long-term objective.
S4-M891 additionally routes AliasTable compact index aliases directly to the
checked u32 sampler, preserving stream shape while avoiding an alias wrapper; it
is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M892 additionally routes AliasTable usize index aliases directly to the checked
sampler path, preserving stream shape while avoiding an alias wrapper; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M893 additionally routes dynamic WeightedTree and WeightedIntTree index aliases
directly to checked sampling paths, preserving stream shape while avoiding alias
wrappers; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M894 additionally routes AliasTable checked sampling through direct alias-table
sampling branches, preserving stream shape while avoiding the unchecked sampleFrom
wrapper; it is reliability/ergonomics work and does not resolve S4-M11 or complete
the long-term objective.
S4-M895 additionally routes AliasTable compact checked sampling through direct u32
alias-table branches, preserving stream shape while avoiding sampleFrom plus cast;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M896 additionally routes AliasTable checked index aliases through direct
alias-table sampling branches, preserving stream shape while avoiding the
sampleCheckedFrom wrapper; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M897 additionally routes ASCII and Unicode charset checked samples through
direct uniform index mapping after prevalidation, preserving stream shape while
avoiding unchecked sampleFrom wrappers; it is reliability/ergonomics work and
does not resolve S4-M11 or complete the long-term objective.
S4-M898 additionally routes distribution-layer Choose checked scalar value,
index, and compact-index samples through direct uniform index mapping after
prevalidation, preserving stream shape while avoiding unchecked sample wrappers;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M899 additionally routes reusable Choice checked scalar value, index, and
compact-index samples through direct uniform index mapping after prevalidation,
preserving stream shape while avoiding unchecked sample wrappers; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M900 additionally routes reusable WeightedChoice checked scalar value, index,
and compact-index samples through direct AliasTable sampling after
prevalidation, preserving stream shape while avoiding unchecked sample wrappers;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M901 additionally routes Choose, Choice, and WeightedChoice valueChecked
aliases through direct value sampling after checked prevalidation, preserving
stream shape while avoiding sampleValueChecked wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M902 additionally routes AliasTable checked compact index aliases through
direct u32 alias-table sampling branches, preserving stream shape while avoiding
the sampleU32CheckedFrom wrapper; it is reliability/ergonomics work and does not
resolve S4-M11 or complete the long-term objective.
S4-M903 additionally routes dynamic WeightedTree and WeightedIntTree checked
scalar, index, and compact-index aliases through direct tree sampling after
validation, preserving stream shape while avoiding checked wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M904 additionally routes Choose, Choice, and WeightedChoice facade
sampleValueChecked helpers through direct value sampling after checked
prevalidation, preserving stream shape while avoiding sampleValueCheckedFrom
wrapper aliases; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M905 additionally routes Choose, Choice, and WeightedChoice facade checked
index helpers through direct index sampling after prevalidation, preserving stream
shape while avoiding sampleIndexCheckedFrom/sampleIndexU32CheckedFrom wrapper
aliases; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M906 additionally routes AliasTable checked facade index aliases through
direct alias-table sampling branches, preserving stream shape while avoiding
sampleChecked/sampleU32Checked wrapper aliases; it is reliability/ergonomics work
and does not resolve S4-M11 or complete the long-term objective.
S4-M907 additionally routes AliasTable unchecked facade index aliases through
direct alias-table sampling branches, preserving stream shape while avoiding
sample/sampleU32 wrapper aliases; it is reliability/ergonomics work and does not
resolve S4-M11 or complete the long-term objective.
S4-M908 additionally routes AliasTable compact facade sample helpers through
direct u32 alias-table sampling branches, preserving stream shape while avoiding
checked direct-source wrapper aliases; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M909 additionally routes dynamic WeightedTree and WeightedIntTree facade
sample/index/u32 aliases through direct tree sampling after validation,
preserving stream shape while avoiding checked facade wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M910 additionally routes Choose, Choice, and WeightedChoice compact index
facade fills through direct u32 filling, preserving stream shape while avoiding
direct-source fill wrapper aliases; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M911 additionally routes Choose, Choice, and WeightedChoice checked facade
pointer/value/index fills through direct filling after prevalidation, preserving
stream shape while avoiding direct-source checked fill wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M912 additionally routes Choose, Choice, and WeightedChoice checked compact
index facade fills through direct u32 filling after prevalidation, preserving
stream shape while avoiding direct-source checked compact fill wrapper aliases;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M913 additionally routes distribution-layer Choose checked fixed-array
facade helpers through direct filling after prevalidation, preserving stream
shape while avoiding direct-source checked array wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M914 additionally routes reusable Choice checked fixed-array facade helpers
through direct filling after prevalidation, preserving stream shape while avoiding
direct-source checked array wrapper aliases; it is reliability/ergonomics work
and does not resolve S4-M11 or complete the long-term objective.
S4-M915 additionally routes reusable WeightedChoice checked fixed-array facade
helpers through direct alias-table filling after prevalidation, preserving stream
shape while avoiding direct-source checked array wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M916 additionally routes distribution-layer Choose checked allocation-returning
facade helpers through direct allocation and filling after prevalidation,
preserving stream shape while avoiding direct-source checked owned wrapper
aliases; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M917 additionally routes reusable Choice checked allocation-returning facade
helpers through direct allocation and filling after prevalidation, preserving
stream shape while avoiding direct-source checked owned wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M918 additionally routes reusable WeightedChoice checked allocation-returning
facade helpers through direct alias-table allocation and filling after
prevalidation, preserving stream shape while avoiding direct-source checked owned
wrapper aliases; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M919 additionally routes distribution-layer Choose allocation-returning facade
helpers through direct allocation and filling, preserving stream shape while
avoiding direct-source owned wrapper aliases; it is reliability/ergonomics work
and does not resolve S4-M11 or complete the long-term objective.
S4-M920 additionally routes reusable Choice allocation-returning facade helpers
through direct allocation and filling, preserving stream shape while avoiding
direct-source owned wrapper aliases; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M921 additionally routes reusable WeightedChoice allocation-returning facade
helpers through direct alias-table allocation and filling, preserving stream
shape while avoiding direct-source owned wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M922 additionally routes distribution-layer Choose checked iterator facade
constructors through direct iterator construction after prevalidation, preserving
stream shape while avoiding direct-source checked iterator wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M923 additionally routes reusable Choice checked iterator facade constructors
through direct iterator construction after prevalidation, preserving stream shape
while avoiding direct-source checked iterator wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M924 additionally routes reusable WeightedChoice checked iterator facade
constructors through direct iterator construction after prevalidation, preserving
stream shape while avoiding direct-source checked iterator wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M925 additionally routes distribution-layer Choose iterator facade
constructors through direct iterator construction, preserving stream shape while
avoiding direct-source iterator wrapper aliases; it is reliability/ergonomics work
and does not resolve S4-M11 or complete the long-term objective.
S4-M926 additionally routes reusable Choice iterator facade constructors through
direct iterator construction, preserving stream shape while avoiding direct-source
iterator wrapper aliases; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M927 additionally routes reusable WeightedChoice iterator facade constructors
through direct iterator construction, preserving stream shape while avoiding
direct-source iterator wrapper aliases; it is reliability/ergonomics work and
does not resolve S4-M11 or complete the long-term objective.
S4-M928 additionally routes distribution-layer Choose direct-source checked
iterator constructors through direct iterator construction after prevalidation,
preserving stream shape while avoiding unchecked direct-source iterator wrapper
aliases; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M929 additionally routes reusable Choice direct-source checked iterator
constructors through direct iterator construction after prevalidation, preserving
stream shape while avoiding unchecked direct-source iterator wrapper aliases; it
is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M930 additionally routes reusable WeightedChoice direct-source checked
iterator constructors through direct iterator construction after prevalidation,
preserving stream shape while avoiding unchecked direct-source iterator wrapper
aliases; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M931 additionally routes distribution-layer Choose direct-source checked
allocation-returning helpers through direct allocation and checked direct-source
filling after prevalidation, preserving stream shape while avoiding unchecked
direct-source owned wrapper aliases; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M932 additionally routes reusable Choice direct-source checked
allocation-returning helpers through direct allocation and checked direct-source
filling after prevalidation, preserving stream shape while avoiding unchecked
direct-source owned wrapper aliases; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M933 additionally routes reusable WeightedChoice direct-source checked
allocation-returning helpers through direct allocation and checked direct-source
filling after prevalidation, preserving stream shape while avoiding unchecked
direct-source owned wrapper aliases; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M934 additionally routes distribution-layer Choose direct-source checked
fixed-array helpers through direct stack-array construction and checked
direct-source filling, preserving stream shape while avoiding unchecked
direct-source array wrapper aliases; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M935 additionally routes reusable Choice direct-source checked fixed-array
helpers through direct stack-array construction and checked direct-source filling,
preserving stream shape while avoiding unchecked direct-source array wrapper
aliases; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M936 additionally routes reusable WeightedChoice direct-source checked
fixed-array helpers through direct stack-array construction and checked
direct-source filling, preserving stream shape while avoiding unchecked
direct-source array wrapper aliases; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M937 additionally routes reusable Choice pointer direct-source iterator alias
through direct sample-iterator construction, preserving stream shape while
avoiding a generic direct-source iterator alias hop; it is reliability/ergonomics
work and does not resolve S4-M11 or complete the long-term objective.
S4-M938 additionally routes reusable WeightedChoice pointer direct-source iterator
alias through direct sample-iterator construction, preserving stream shape while
avoiding a generic direct-source iterator alias hop; it is reliability/ergonomics
work and does not resolve S4-M11 or complete the long-term objective.
S4-M939 additionally routes reusable Choice compact direct-source fixed-array
helper through direct stack-array construction and compact-index filling,
preserving stream shape while avoiding a checked direct-source array helper hop;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M940 additionally routes reusable WeightedChoice compact direct-source
fixed-array helper through direct stack-array construction and compact-index
filling, preserving stream shape while avoiding a checked direct-source array
helper hop; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M941 additionally routes distribution-layer Choose non-checked fixed-array
facade helpers through direct stack-array construction and facade filling,
preserving stream shape while avoiding direct-source array wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M942 additionally routes reusable Choice non-checked fixed-array facade
helpers through direct stack-array construction and facade filling, preserving
stream shape while avoiding direct-source array wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M943 additionally routes reusable WeightedChoice non-checked fixed-array
facade helpers through direct stack-array construction and facade filling,
preserving stream shape while avoiding direct-source array wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M944 additionally routes static AliasTable direct-source checked
allocation-returning helpers through direct allocation and checked direct-source
filling after prevalidation, preserving stream shape while avoiding unchecked
direct-source owned wrapper aliases; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M945 additionally routes static AliasTable allocation-returning facade helpers
through direct allocation and facade filling after prevalidation, preserving
stream shape while avoiding direct-source owned wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M946 additionally routes static AliasTable fixed-array helpers through direct
stack-array construction and facade/direct-source filling, preserving stream shape
while avoiding array wrapper aliases; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M947 additionally routes static AliasTable checked iterator constructors
through direct iterator-payload construction after compact-width prevalidation,
preserving stream shape while avoiding iterator wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M948 additionally routes static AliasTable checked compact direct-source
iterator construction through direct iterator-payload construction after width
prevalidation, preserving stream shape while avoiding an unchecked iterator
constructor wrapper; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M949 additionally routes dynamic WeightedTree and WeightedIntTree checked
`usize` iterator constructors through direct iterator-payload construction after
validity checks, preserving stream shape while avoiding unchecked iterator
wrapper aliases; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M950 additionally routes dynamic WeightedTree and WeightedIntTree checked
compact iterator constructors through direct iterator-payload construction after
width and validity checks, preserving stream shape while avoiding iterator wrapper
aliases; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M951 additionally routes dynamic WeightedTree and WeightedIntTree
allocation-returning facade helpers through direct allocation and facade filling
after validation, preserving stream shape while avoiding direct-source owned
wrapper aliases; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M952 additionally routes dynamic WeightedTree and WeightedIntTree fixed-array
helpers through direct stack-array construction and facade/direct-source filling,
preserving stream shape while avoiding array wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M953 additionally routes dynamic WeightedTree and WeightedIntTree facade fill
helpers through direct total-aware fill loops after validation, preserving stream
shape while avoiding checked/direct-source fill wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M954 additionally routes dynamic WeightedTree and WeightedIntTree canonical
direct-source sample helpers through direct total-aware sampling after unchecked
precondition validation, preserving stream shape while avoiding checked sample
wrapper aliases; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M955 additionally routes static AliasTable canonical facade sample helpers
through direct alias-table sampling branches, preserving stream shape while
avoiding direct-source sample wrapper aliases; it is reliability/ergonomics work
and does not resolve S4-M11 or complete the long-term objective.
S4-M956 additionally routes reusable Choice pointer facade sampling through
direct facade-index generation and item mapping, preserving stream shape while
avoiding a direct-source sample wrapper alias; it is reliability/ergonomics work
and does not resolve S4-M11 or complete the long-term objective.
S4-M957 additionally routes reusable WeightedChoice pointer/value facade sampling
through direct AliasTable facade sampling and item mapping, preserving stream
shape while avoiding direct-source sample wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M958 additionally routes reusable Choice value facade sampling through direct
facade-index generation and value copying, preserving stream shape while avoiding
a pointer sample wrapper alias; it is reliability/ergonomics work and does not
resolve S4-M11 or complete the long-term objective.
S4-M959 additionally routes non-checked choice and weighted-choice facade index
helpers through direct facade-index sampling, preserving stream shape while
avoiding direct-source index wrapper aliases; it is reliability/ergonomics work
and does not resolve S4-M11 or complete the long-term objective.
S4-M960 additionally routes distribution-layer Choose pointer/value facade
sampling through direct facade-index generation and item mapping, preserving
stream shape while avoiding direct-source and pointer sample wrapper aliases; it
is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M961 additionally refreshes current checked value facade aliases for Choose,
Choice, and WeightedChoice so they sample directly through facade RNGs after
prevalidation, preserving stream shape while avoiding direct-source value wrapper
aliases; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M962 additionally refreshes current AliasTable direct-source index alias
sampling through direct alias-table sampling branches, preserving stream shape
while avoiding a checked sample wrapper alias; it is reliability/ergonomics work
and does not resolve S4-M11 or complete the long-term objective.
S4-M963 additionally refreshes current AliasTable compact direct-source alias
sampling through direct compact alias-table branches, preserving stream shape
while avoiding checked compact sample wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M964 additionally refreshes current dynamic WeightedTree and WeightedIntTree
direct-source index aliases through direct total-aware tree sampling after
unchecked precondition validation, preserving stream shape while avoiding checked
sample wrapper aliases; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M965 additionally routes scalar and vector Bernoulli facade samples through
direct threshold comparisons and degenerate fast paths, preserving stream shape
while avoiding direct-source sample wrapper aliases; it is reliability/ergonomics
work and does not resolve S4-M11 or complete the long-term objective.
S4-M966 additionally routes scalar and vector Bernoulli facade fills through
direct threshold loops and degenerate fast paths, preserving stream shape while
avoiding direct-source fill wrapper aliases; it is reliability/ergonomics work
and does not resolve S4-M11 or complete the long-term objective.
S4-M967 additionally routes scalar and vector Binomial facade samples through
direct binomial sampling and degenerate fast paths, preserving stream shape while
avoiding direct-source sample wrapper aliases; it is reliability/ergonomics work
and does not resolve S4-M11 or complete the long-term objective.
S4-M968 additionally routes scalar and vector Binomial facade fills through
direct binomial sampling loops and degenerate fast paths, preserving stream shape
while avoiding direct-source fill wrapper aliases; it is reliability/ergonomics
work and does not resolve S4-M11 or complete the long-term objective.
S4-M969 additionally routes top-level scalar Binomial checked/fill facade helpers
through direct reusable-sampler facade sampling/filling after validation,
preserving stream shape while avoiding `From` wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M970 additionally routes top-level vector Binomial sample/fill facade helpers
through direct reusable vector-sampler facade sampling/filling after validation,
preserving stream shape while avoiding `From` wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M971 additionally routes scalar binomial Poisson-approx facade helpers through
direct approximation sampling and checked validation, preserving stream shape
while avoiding `From` wrapper aliases; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M972 additionally routes vector binomial Poisson-approx top-level and reusable
facade helpers through direct approximation sampling/filling after validation,
preserving stream shape while avoiding `From` wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M973 additionally routes scalar and vector NegativeBinomial reusable facade
sample/fill helpers through direct negative-binomial sampling loops and degenerate
fast paths, preserving stream shape while avoiding direct-source wrapper aliases;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M974 additionally routes top-level scalar NegativeBinomial checked/fill facade
helpers through direct reusable-sampler facade sampling/filling after validation,
preserving stream shape while avoiding `From` wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M975 additionally routes top-level vector NegativeBinomial sample/fill facade
helpers through direct reusable vector-sampler facade sampling/filling after
validation, preserving stream shape while avoiding `From` wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M976 additionally routes reusable Hypergeometric facade sample/fill helpers
through direct method dispatch, preserving method-specific stream shape while
avoiding direct-source wrapper aliases; it is reliability/ergonomics work and
does not resolve S4-M11 or complete the long-term objective.
S4-M977 additionally routes top-level and reusable VectorHypergeometric facade
helpers through direct method dispatch after validation, preserving stream shape
while avoiding `From` wrapper aliases; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M978 additionally routes top-level scalar Hypergeometric facade helpers
through direct reusable-sampler facade sampling/filling after validation,
preserving stream shape while avoiding `From` wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the long-term
objective.
S4-M979 additionally routes reusable Multinomial allocation-returning and
caller-buffer facade helpers through direct multinomial sampling loops after
allocation or validation, preserving stream shape while avoiding `From` wrapper
aliases; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M980 additionally routes reusable Dirichlet allocation-returning and
caller-buffer facade helpers through direct gamma-normalization sampling after
allocation or validation, preserving stream shape while avoiding `From` wrapper
aliases; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M981 additionally routes reusable VectorPoissonAhrensDieter facade sample/fill
helpers through direct cached Ahrens-Dieter lane sampling, preserving stream shape
while avoiding direct-source wrapper aliases; it is reliability/ergonomics work
and does not resolve S4-M11 or complete the long-term objective.
S4-M982 additionally routes top-level vector Poisson Ahrens-Dieter facade
helpers through reusable vector facade sample/fill calls, preserving stream shape,
checked invalid-parameter behavior, and zero-length checked fill semantics while
avoiding `From` wrapper aliases; it is reliability/ergonomics work and does not
resolve S4-M11 or complete the long-term objective.
S4-M983 additionally routes scalar/vector Poisson top-level helpers and reusable
Poisson facade sample/fill methods through direct zero/product/Ahrens-Dieter
method dispatch, preserving stream shape, zero-lambda no-consume behavior, checked
invalid-parameter behavior, and zero-length checked fill semantics while avoiding
`From` wrapper aliases; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M984 additionally routes scalar top-level Poisson Ahrens-Dieter facade helpers
through the cached Ahrens-Dieter facade sampler, preserving large-lambda
validation and checked invalid-parameter no-consume behavior while avoiding
`From` wrapper aliases; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M985 additionally routes scalar Geometric and GeometricFailures top-level
helpers and reusable facade sample/fill methods through direct degenerate and
inverse-CDF method bodies, preserving stream shape, degenerate no-consume
behavior, checked invalid-parameter behavior, and zero-length checked fill
semantics while avoiding `From` wrapper aliases; it is reliability/ergonomics
work and does not resolve S4-M11 or complete the long-term objective.
S4-M986 additionally routes vector Geometric and GeometricFailures top-level
helpers and reusable vector facade sample/fill methods through direct degenerate
and inverse-CDF lane loops, preserving vector stream shape, degenerate no-consume
behavior, checked invalid-parameter behavior, and zero-length checked fill
semantics while avoiding `From` wrapper aliases; it is reliability/ergonomics
work and does not resolve S4-M11 or complete the long-term objective.
S4-M987 additionally routes scalar/vector StandardGeometric top-level helpers
and reusable facade sample/fill methods through direct leading-zero loops,
preserving stream shape while avoiding `From` wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M988 additionally routes scalar/vector top-level Bernoulli facade helpers
through reusable Bernoulli facade sample/fill methods, preserving stream shape,
degenerate no-consume behavior, checked invalid-probability behavior, and
zero-length checked fill semantics while avoiding `From` wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M989 additionally routes reusable scalar Uniform facade sample/fill helpers
through direct facade range dispatch, preserving stream shape, inclusive endpoint
behavior, degenerate inclusive no-consume behavior, and zero-length checked fill
semantics while avoiding `sampleFrom` / `fillFrom` wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M990 additionally routes scalar top-level Uniform half-open and inclusive
sample/fill helpers through direct facade range dispatch, preserving stream shape,
inclusive endpoint behavior, invalid-range no-consume behavior, and zero-length
checked fill semantics while avoiding `From` wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M991 additionally routes reusable VectorUniform facade sample/fill helpers
through direct facade vector range dispatch, preserving vector stream shape,
inclusive endpoint behavior, degenerate inclusive no-consume behavior, and
zero-length checked fill semantics while avoiding `sampleFrom` / `fillFrom`
wrapper aliases; it is reliability/ergonomics work and does not resolve S4-M11
or complete the long-term objective.
S4-M992 additionally routes top-level vector Uniform half-open and inclusive
sample/fill helpers through direct facade vector range dispatch, preserving vector
stream shape, inclusive endpoint behavior, invalid-range no-consume behavior, and
zero-length checked fill semantics while avoiding `From` wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M993 additionally routes reusable UniformDuration facade sample/fill helpers
through direct facade duration range dispatch, preserving stream shape and
inclusive point-mass no-consume semantics while avoiding `sampleFrom` /
`fillFrom` wrapper aliases; it is reliability/ergonomics work and does not
resolve S4-M11 or complete the long-term objective.
S4-M994 additionally routes reusable UniformUnicodeScalar facade sample/fill
helpers through direct facade Unicode scalar range dispatch, preserving stream
shape, surrogate-gap handling, and inclusive point-mass behavior while avoiding
`sampleFrom` / `fillFrom` wrapper aliases; it is reliability/ergonomics work and
does not resolve S4-M11 or complete the long-term objective.
S4-M995 additionally routes reusable Open01/OpenClosed01 scalar/vector facade
sample/fill helpers through direct facade strict-interval dispatch, preserving
stream shape while avoiding direct-source wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M996 additionally routes reusable scalar Gamma facade sample/fill helpers
through direct degenerate, shape-one, boosted-small-shape, and regular Marsaglia
paths, preserving stream shape, degenerate no-consume behavior, and zero-length
checked fill semantics while avoiding `sampleFrom` / `fillFrom` wrapper aliases;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M997 additionally routes reusable VectorGamma facade sample/fill helpers
through direct degenerate, shape-one, and general per-lane Gamma sampling,
preserving vector stream shape, degenerate no-consume behavior, and zero-length
checked fill semantics while avoiding `sampleFrom` / `fillFrom` wrapper aliases;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M998 additionally routes top-level scalar/vector Gamma facade helpers through
reusable facade samplers, preserving stream shape, scalar shape-half behavior,
degenerate no-consume behavior, and zero-length checked fill semantics while
avoiding `From` wrapper aliases; it is reliability/ergonomics work and does not
resolve S4-M11 or complete the long-term objective.
S4-M999 additionally routes reusable scalar/vector ChiSquared facade sample/fill
helpers through cached Gamma facade samplers, preserving stream shape,
degenerate no-consume behavior, and zero-length checked fill semantics while
avoiding `sampleFrom` / `fillFrom` wrapper aliases; it is reliability/ergonomics
work and does not resolve S4-M11 or complete the long-term objective.
S4-M1000 additionally routes top-level scalar/vector ChiSquared facade helpers
through reusable facade samplers, preserving stream shape, scalar degree-one
behavior, degenerate no-consume behavior, and zero-length checked fill semantics
while avoiding `From` wrapper aliases; it is reliability/ergonomics work and does
not resolve S4-M11 or complete the long-term objective.
S4-M1001 additionally routes reusable scalar/vector Chi facade sample/fill
helpers through cached ChiSquared facade samplers, preserving stream shape,
degenerate no-consume behavior, and zero-length checked fill semantics while
avoiding `sampleFrom` / `fillFrom` wrapper aliases; it is reliability/ergonomics
work and does not resolve S4-M11 or complete the long-term objective.
S4-M1002 additionally routes top-level scalar/vector Chi facade helpers through
reusable facade samplers, preserving stream shape, scalar degree-one behavior,
degenerate no-consume behavior, and zero-length checked fill semantics while
avoiding `From` wrapper aliases; it is reliability/ergonomics work and does not
resolve S4-M11 or complete the long-term objective.
S4-M1003 additionally routes reusable scalar/vector Erlang facade sample/fill
helpers through cached Gamma facade samplers, preserving stream shape,
degenerate no-consume behavior, and zero-length checked fill semantics while
avoiding `sampleFrom` / `fillFrom` wrapper aliases; it is reliability/ergonomics
work and does not resolve S4-M11 or complete the long-term objective.
S4-M1004 additionally routes top-level scalar/vector Erlang facade helpers
through reusable facade samplers, preserving stream shape, degenerate no-consume
behavior, and zero-length checked fill semantics while avoiding `From` wrapper
aliases; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M1005 additionally routes reusable scalar Beta facade sample/fill helpers
through direct point-mass, uniform, square-root edge, and cached-Gamma-ratio
paths, preserving stream shape, point-mass no-consume behavior, and zero-length
checked fill semantics while avoiding `sampleFrom` / `fillFrom` wrapper aliases;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M1006 additionally routes reusable VectorBeta facade sample/fill helpers
through direct cached scalar Beta facade lane sampling, preserving vector stream
shape, point-mass no-consume behavior, and zero-length checked fill semantics
while avoiding `sampleFrom` / `fillFrom` wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M1007 additionally routes top-level scalar/vector Beta facade helpers through
reusable facade samplers, preserving stream shape, edge-case behavior, point-mass
no-consume behavior, and zero-length checked fill semantics while avoiding `From`
wrapper aliases; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M1008 additionally routes reusable scalar/vector FisherF facade sample/fill
helpers through direct cached numerator/denominator Gamma facade sampling,
preserving stream shape, infinite-degree point-mass no-consume behavior, and
zero-length checked fill semantics while avoiding `sampleFrom` / `fillFrom`
wrapper aliases; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M1009 additionally routes top-level scalar/vector FisherF facade helpers
through reusable facade samplers, preserving stream shape, infinite-degree
point-mass no-consume behavior, and zero-length checked fill semantics while
avoiding `From` wrapper aliases; it is reliability/ergonomics work and does not
resolve S4-M11 or complete the long-term objective.
S4-M1010 additionally routes reusable scalar/vector StudentT facade sample/fill
helpers through direct standard-normal and cached ChiSquared facade sampling,
preserving stream shape, infinite-degree standard-normal behavior, and zero-length
checked fill semantics while avoiding `sampleFrom` / `fillFrom` wrapper aliases;
it is reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M1011 additionally routes top-level scalar/vector StudentT facade helpers
through reusable facade samplers, preserving stream shape, infinite-degree
standard-normal behavior, and zero-length checked fill semantics while avoiding
`From` wrapper aliases; it is reliability/ergonomics work and does not resolve
S4-M11 or complete the long-term objective.
S4-M1012 additionally routes reusable scalar/vector Triangular facade sample/fill
helpers through direct uniform-transform sampling, preserving stream shape,
degenerate point-mass no-consume behavior, and zero-length checked fill semantics
while avoiding `sampleFrom` / `fillFrom` wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M1013 additionally routes reusable scalar/vector Arcsine facade sample/fill
helpers through direct open-uniform transform sampling, preserving stream shape,
degenerate point-mass no-consume behavior, and zero-length checked fill semantics
while avoiding `sampleFrom` / `fillFrom` wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M1014 additionally routes reusable scalar/vector Cauchy facade sample/fill
helpers through direct open-uniform transform sampling, preserving stream shape,
degenerate point-mass no-consume behavior, and zero-length checked fill semantics
while avoiding `sampleFrom` / `fillFrom` wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M1015 additionally routes reusable scalar/vector Laplace facade sample/fill
helpers through direct strict-open-uniform transform sampling, preserving stream
shape, degenerate point-mass no-consume behavior, and zero-length checked fill
semantics while avoiding `sampleFrom` / `fillFrom` wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M1016 additionally routes reusable scalar/vector Logistic facade sample/fill
helpers through direct strict-open-uniform transform sampling, preserving stream
shape, degenerate point-mass no-consume behavior, and zero-length checked fill
semantics while avoiding `sampleFrom` / `fillFrom` wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M1017 additionally routes reusable scalar/vector LogLogistic facade sample/fill
helpers through direct strict-open-uniform ratio/generic transform sampling,
preserving stream shape, degenerate point-mass no-consume behavior, and
zero-length checked fill semantics while avoiding `sampleFrom` / `fillFrom`
wrapper aliases; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M1018 additionally routes reusable scalar/vector Kumaraswamy facade sample/fill
helpers through direct cached-method strict-open-uniform transform sampling,
preserving stream shape, degenerate point-mass no-consume behavior, and
zero-length checked fill semantics while avoiding `sampleFrom` / `fillFrom`
wrapper aliases; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M1019 additionally routes reusable scalar/vector PowerFunction facade
sample/fill helpers through direct cached-method range or strict-open-uniform
transform sampling, preserving stream shape, degenerate point-mass no-consume
behavior, and zero-length checked fill semantics while avoiding `sampleFrom` /
`fillFrom` wrapper aliases; it is reliability/ergonomics work and does not
resolve S4-M11 or complete the long-term objective.
S4-M1020 additionally routes reusable scalar/vector Rayleigh facade sample/fill
helpers through direct strict-open-uniform transform sampling, preserving stream
shape, degenerate point-mass no-consume behavior, and zero-length checked fill
semantics while avoiding `sampleFrom` / `fillFrom` wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M1021 additionally routes reusable scalar/vector Maxwell facade sample/fill
helpers through direct normal-component radius sampling, preserving stream shape,
degenerate point-mass no-consume behavior, and zero-length checked fill semantics
while avoiding `sampleFrom` / `fillFrom` wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M1022 additionally routes reusable scalar/vector Pareto facade sample/fill
helpers through direct strict-open-uniform inverse-power sampling, preserving
stream shape, degenerate point-mass no-consume behavior, and zero-length checked
fill semantics while avoiding `sampleFrom` / `fillFrom` wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M1023 additionally routes reusable scalar/vector Weibull facade sample/fill
helpers through direct standard-exponential or strict-open-uniform transform
sampling, preserving stream shape, degenerate point-mass no-consume behavior, and
zero-length checked fill semantics while avoiding `sampleFrom` / `fillFrom`
wrapper aliases; it is reliability/ergonomics work and does not resolve S4-M11 or
complete the long-term objective.
S4-M1024 additionally routes reusable scalar/vector Gumbel facade sample/fill
helpers through direct open-closed-uniform transform sampling, preserving stream
shape, degenerate point-mass no-consume behavior, and zero-length checked fill
semantics while avoiding `sampleFrom` / `fillFrom` wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M1025 additionally routes reusable scalar/vector Frechet facade sample/fill
helpers through direct open-closed-uniform transform sampling, preserving stream
shape, degenerate point-mass no-consume behavior, and zero-length checked fill
semantics while avoiding `sampleFrom` / `fillFrom` wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.
S4-M1026 additionally routes reusable scalar/vector SkewNormal facade sample/fill
helpers through direct standard-normal component transform sampling, preserving
stream shape, degenerate point-mass no-consume behavior, and zero-length checked
fill semantics while avoiding `sampleFrom` / `fillFrom` wrapper aliases; it is
reliability/ergonomics work and does not resolve S4-M11 or complete the
long-term objective.

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
