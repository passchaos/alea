# S4-M291 `rand_distr::multi::Dirichlet` Alias

Date: 2026-07-06

## Local Rust Baseline

The cached local `rand_distr 0.6.0` crate exposes multivariate distribution
APIs under the `multi` namespace:

- `~/.../rand_distr-0.6.0/src/lib.rs` declares `pub mod multi;`.
- `~/.../rand_distr-0.6.0/src/multi/mod.rs` defines Rust trait abstractions
  `MultiDistribution<T>` and `ConstMultiDistribution<T>`.
- The same module re-exports `pub use dirichlet::Dirichlet;`.
- `~/.../rand_distr-0.6.0/src/multi/dirichlet.rs` defines
  `pub struct Dirichlet<F>`.

Alea already had a Zig-native reusable `Dirichlet(T)` sampler with
allocation-returning samples, caller-owned `sampleInto`, batched
`sampleManyInto`, parameter/moment diagnostics, and checked output-buffer APIs.
The missing piece was the local Rust namespace discovery path
`rand_distr::multi::Dirichlet`.

## Alea Change

Alea now provides:

```zig
pub const multi = struct {
    pub fn Dirichlet(comptime T: type) type {
        return distributions.Dirichlet(T);
    }
};
```

This is a namespace alias over the existing sampler. It intentionally does not
copy Rust's `MultiDistribution` / `ConstMultiDistribution` trait machinery:
Alea's concrete sampler methods (`sample`, `sampleFrom`, `sampleInto`,
`sampleIntoFrom`, `sampleManyInto`, and checked variants) provide the relevant
Zig-native workflows directly.

## Tests and Validation

Focused test coverage in `src/distributions.zig`:

- `rand_distr multi Dirichlet namespace alias mirrors Dirichlet` verifies
  `multi.Dirichlet(T)` type equality with `Dirichlet(T)`, parameter/moment
  accessors, caller-owned sample stream shape, and source advancement.

Documentation/evidence updates:

- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, and
  `compare/results/distribution-parity-matrix.md` document the namespace alias.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M292.

Validation commands for this milestone:

```sh
zig fmt src/distributions.zig tools/roadmapcheck.zig
zig test src/distributions.zig --test-filter "multi Dirichlet"
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```

## Non-Completion Note

This milestone closes a local `rand_distr` namespace discovery side gap only. It
does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
