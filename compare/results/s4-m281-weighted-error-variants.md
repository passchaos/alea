# S4-M281 Weighted Error Variant Diagnostics

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout defines weighted-distribution errors in
`~/Work/rand/src/distr/weighted/mod.rs`:

```rust
pub enum Error {
    InvalidInput,
    InvalidWeight,
    InsufficientNonZero,
    Overflow,
}
```

These errors are documented for `WeightedIndex::new`,
`WeightedIndex::update_weights`, and related weighted distributions.

## Alea Change

Alea already exposed `distributions.WeightedError` and
`distributions.WeightError` aliases. S4-M281 extends the shared distribution
error set with the local Rust variant names and maps static weighted samplers to
those diagnostics:

- `InvalidInput`: empty `AliasTable` / `WeightedIndex` construction;
- `InvalidWeight`: negative, NaN, or infinite individual weights;
- `InsufficientNonZero`: all-zero or update-to-zero static weights;
- `Overflow`: non-finite total weight after summation/update.

The change is intentionally scoped to `distributions.AliasTable` /
`WeightedIndex`, the direct static weighted-index surface corresponding to local
Rust `WeightedIndex`. Broader `Rng` and `seq` weighted helpers keep their
existing error contracts for this milestone. `seq.WeightedChoice` wraps the
static table internally, so its wrapper maps the new table diagnostics back to
the pre-existing `seq.Error` outcomes (`EmptyInput` / `InvalidWeight`) to avoid
changing the public sequence API contract.

## Tests and Validation

Focused test coverage in `src/distributions.zig`:

- `distribution weight error aliases mirror Error` verifies the alias error set
  includes `InvalidInput`, `InvalidWeight`, `InsufficientNonZero`, and
  `Overflow`, and checks representative `AliasTable` / `WeightedIndex` paths;
- existing alias-table update tests verify `InsufficientNonZero` for updates
  that would remove the final positive weight.

Documentation/evidence updates:

- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`,
  `compare/results/distribution-parity-matrix.md`, and the historical
  `compare/results/s4-m271-weighted-error-aliases.md` evidence now mention the
  variant diagnostics.
- `src/seq.zig` keeps `WeightedChoice` compatibility by translating the new
  static table diagnostics back to the existing sequence error names.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M282.

Validation commands for this milestone:

```sh
zig fmt src/distributions.zig tools/roadmapcheck.zig
zig test src/distributions.zig --test-filter "distribution weight error aliases"
zig test src/distributions.zig --test-filter "alias table"
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```

## Non-Completion Note

This milestone closes an unblocked local Rust weighted-diagnostics side gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
