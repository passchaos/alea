# S4-M198 Charset Probability Iterator

Result: passed.

Purpose: add a lazy probability iterator to custom ASCII charsets. Alea already
exposed `Charset.probabilityAt`, bulk `probabilities` / `probabilitiesInto`,
and S4-M197 optional `Charset.probability`; S4-M198 adds allocation-free
iterator diagnostics matching the reusable `Choice` and weighted sampler
probability iterator shape.

## Local Reference

Local Rust `rand` exposes `Alphanumeric` / `Alphabetic` distributions for string
workflows, while Alea's Zig-native `Charset` provides explicit charset
introspection. This milestone improves that above-Rust diagnostic surface rather
than copying a Rust trait shape.

## Alea API Added

`src/ascii.zig` now exposes:

- `Charset.ProbabilityIterator`;
- `Charset.probabilityIter`;
- `Charset.ProbabilityIterator.next`;
- `Charset.ProbabilityIterator.remaining`;
- `Charset.ProbabilityIterator.len`;
- `Charset.ProbabilityIterator.fill`.

Semantics:

- streams uniform charset probabilities in byte-index order;
- `next()` returns `null` after the final probability;
- `remaining()` and `len()` report exact remaining counts;
- `fill()` drains up to the destination length and returns the filled count;
- preserves existing checked `probabilityAt`, optional `probability`, and bulk
  probability export behavior.

Focused tests verify `next`, exact remaining counts, `len`, caller-buffer fill,
and exhaustion for predefined `Alphanumeric`.

## Adoption and Documentation

- `examples/string_generation.zig` prints a
  `custom charset probabilityIter fill` row.
- `tools/examplecheck.zig` verifies that example source token.
- `docs/api-reference.md` lists the new public symbols.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the iterator.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M199.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "ascii"`
- `zig build run-string-generation`
- `zig build doccheck`
- `zig build test`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked charset diagnostics ergonomics gap only. It
does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
