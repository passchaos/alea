# S4-M259 Root Top-Level Random Helpers

Date: 2026-07-05

## Local Rust Baseline

The local Rust `rand` checkout exposes top-level helpers in
`~/Work/rand/src/lib.rs`:

- `random<T>()`;
- `random_iter<T>()`;
- `random_range(range)`;
- `random_bool(p)`;
- `random_ratio(numerator, denominator)`;
- `fill(dest)`.

Those helpers are shorthand for using Rust's hidden thread-local RNG. Alea keeps
entropy ownership explicit in Zig, so the equivalent root helpers take an
explicit `std.Io` and use `std.Io.randomSecure` through the existing ChaCha12
secure-style engine construction.

## Alea Change

Alea now provides root helpers:

- `random(T, io)` and `randomValue(T, io)`;
- `randomValueChecked(T, io)`;
- `randomIter(T, io)` returning `RandomIterator(T)`;
- `randomRange(T, io, min, max)` and `randomRangeChecked`;
- `randomRangeAtMost(T, io, min, max)` and `randomRangeAtMostChecked`;
- `randomBool(io, p)` and `randomBoolChecked`;
- `randomRatio(io, numerator, denominator)` and `randomRatioChecked`;
- `fill(T, io, dest)`.

`RandomIterator(T)` exposes `next`, `nextValue`, `fill`, and `sizeHint`, with
the same unbounded size-hint shape as the existing facade value/random
iterators.

The helpers intentionally do not add a hidden thread-local RNG. They seed a
temporary `SecurePrng` from caller-provided `std.Io`, then delegate through the
existing `Rng` facade. Checked helpers validate empty enums, invalid ranges, and
invalid probabilities before requesting entropy; deterministic no-consume cases
such as singleton ranges or probability 0/1 also return before entropy.

## Tests and Validation

Focused tests cover:

- successful use of `random`, `randomValue`, `randomValueChecked`,
  `randomIter`, `randomRange`, `randomRangeAtMost`, `randomBool`,
  `randomRatio`, and `fill` with native thread-local `std.Io`;
- `RandomIterator.sizeHint`;
- deterministic checked/no-consume cases with `std.Io.failing`;
- entropy-error propagation for non-deterministic helper calls.

Documentation/example updates:

- `examples/basic.zig` prints `root random helpers`.
- `tools/examplecheck.zig` checks that example token.
- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, and
  `docs/examples.md` document the new root helpers.
- `compare/results/reproducibility-matrix.md` records the helpers as not
  stable because their source is system entropy.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M260.

Validation commands for this milestone:

```sh
zig test src/root.zig --test-filter "root random helpers"
zig build run-basic
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```
