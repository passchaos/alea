# S4-M197 Charset Optional Probability Lookup

Result: passed.

Purpose: add `Charset.probability()` as an optional single-probability lookup for
custom ASCII charsets. Alea already exposed checked `probabilityAt` and bulk
`probabilities` / `probabilitiesInto`; S4-M197 adds null-on-missing ergonomics
matching the reusable choice and weighted sampler diagnostics added in recent
milestones.

## Local Reference

Local Rust `rand` exposes `Alphanumeric` / `Alphabetic` distributions for string
workflows, while Alea's Zig-native `Charset` provides explicit charset
introspection. This milestone improves that above-Rust diagnostic surface rather
than copying a Rust trait shape.

## Alea API Added

`src/ascii.zig` now exposes:

- `Charset.probability`.

Semantics:

- returns `?f64`;
- mirrors `probabilityAt(index)` for valid indexes;
- returns `null` out of bounds;
- preserves existing checked `probabilityAt`, allocation-returning
  `probabilities`, and caller-buffer `probabilitiesInto` behavior.

Focused tests verify in-range probabilities and out-of-range `null` behavior for
predefined `Alphanumeric`.

## Adoption and Documentation

- `examples/string_generation.zig` prints
  `custom charset probability(0)=... missing=true`.
- `tools/examplecheck.zig` verifies that example source token.
- `docs/api-reference.md` lists the new public symbol.
- `docs/core-guide.md`, `README.md`, `docs/examples.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, the active-goal audit, and
  `core-rand-coverage.md` describe the optional probability lookup.
- `tools/roadmapcheck.zig` now requires this evidence file and advances the
  next unblocked product-gap marker to S4-M198.

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
