# S4-M276 Uniform Range Constructor Aliases

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout implements range-based `Uniform` construction in
`~/Work/rand/src/distr/uniform.rs`:

- `impl<X: SampleUniform> TryFrom<Range<X>> for Uniform<X>` calls
  `Uniform::new(r.start, r.end)`;
- `impl<X: SampleUniform> TryFrom<RangeInclusive<X>> for Uniform<X>` calls
  `Uniform::new_inclusive(r.start(), r.end())`.

Alea does not have Rust `Range` / `RangeInclusive` objects or `TryFrom` traits,
so the Zig-native surface should expose the same discovery intent without
copying Rust trait machinery.

## Alea Change

Alea now provides scalar and vector aliases:

```zig
Uniform(T).tryFromRange(low, high)
Uniform(T).tryFromRangeInclusive(low, high)
VectorUniform(VectorType).tryFromRange(low, high)
VectorUniform(VectorType).tryFromRangeInclusive(low, high)
```

They forward to the existing `init` / `initInclusive` constructors, preserving
half-open vs inclusive semantics, `EmptyRange` / `NonFinite` error behavior, and
sampling stream shape.

## Tests and Validation

Focused test coverage in `src/distributions.zig`:

- `Uniform tryFromRange aliases mirror constructors` verifies scalar and vector
  constructor parity, sample stream shape, inclusive flags, finite invalid range
  errors, and non-finite float errors.

Documentation/evidence updates:

- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, and
  `compare/results/distribution-parity-matrix.md` document the aliases.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M277.

Validation commands for this milestone:

```sh
zig fmt src/distributions.zig tools/roadmapcheck.zig
zig test src/distributions.zig --test-filter "Uniform tryFromRange"
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```

## Non-Completion Note

This milestone closes an unblocked local Rust uniform construction discovery gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
