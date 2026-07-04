# S4-M98 Unicode Scalar Range Helpers

Date: 2026-07-04

Purpose: add Zig-native Unicode scalar range helpers for `Rng`. This complements
Rust `UniformChar`, `Rng.unicodeScalar`, S4-M97 caller-owned/owned Unicode
scalar batches, and existing UTF-8 string helpers while preserving surrogate-gap
handling.

## Rust rand Comparison

The local Rust `rand` checkout implements `UniformChar` by compressing Unicode
scalar values around the UTF-16 surrogate range before sampling. Alea uses `u21`
for Unicode scalar values instead of a native `char` type. S4-M98 adds bounded
`u21` scalar range helpers that validate endpoints, skip surrogate code points,
and provide one-shot, caller-owned fill, and allocation-returning batch
workflows.

Local Rust evidence inspected:

- `~/Work/rand/src/distr/other.rs`: `StandardUniform<char>` skips
  `[0xD800, 0xDFFF]` surrogate values;
- `~/Work/rand/src/distr/uniform_other.rs`: `UniformChar` compresses char values
  around the surrogate range for bounded char sampling.

## Change

Added Unicode scalar range helpers in `src/rng.zig`:

- `Rng.unicodeScalarRangeLessThan(min, less_than)`;
- `Rng.unicodeScalarRangeLessThanFrom(source, min, less_than)`;
- `Rng.unicodeScalarRangeLessThanChecked(min, less_than)`;
- `Rng.unicodeScalarRangeLessThanCheckedFrom(source, min, less_than)`;
- `Rng.unicodeScalarRangeAtMost(min, at_most)`;
- `Rng.unicodeScalarRangeAtMostFrom(source, min, at_most)`;
- `Rng.unicodeScalarRangeAtMostChecked(min, at_most)`;
- `Rng.unicodeScalarRangeAtMostCheckedFrom(source, min, at_most)`;
- caller-owned `fillUnicodeScalarRangeLessThan*` and
  `fillUnicodeScalarRangeAtMost*` helpers;
- allocation-returning `unicodeScalarRangeLessThanBatch*` and
  `unicodeScalarRangeAtMostBatch*` helpers.

The helpers validate Unicode scalar endpoints, reject invalid surrogate endpoints
on checked paths, skip surrogate code points for ranges that cross the gap, and
preserve degenerate no-consume behavior for single-scalar ranges. Owned checked
batches return zero-count slices before validation and return invalid-parameter
errors before allocation or stream consumption for positive counts.

Updated adoption/docs:

- `examples/string_generation.zig` prints `unicode scalar range fill` and
  `unicode scalar range batch` rows;
- `tools/examplecheck.zig` guards the example tokens;
- `docs/core-guide.md`, `docs/api-reference.md`, `docs/examples.md`, and
  `README.md` list the range helpers;
- `compare/results/reproducibility-matrix.md` records stream-shape contracts;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include S4-M98 evidence.

## Validation

Commands for final validation:

```sh
git diff --check
zig build test
zig build run-string-generation
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- checked/unchecked scalar range fill and owned-batch stream-shape parity;
- ranges crossing the surrogate gap without returning surrogate code points;
- degenerate range no-consume behavior;
- invalid scalar endpoints and empty ranges returning before consuming the stream;
- zero-length checked fills returning before validation.

## S4-M98 Decision

S4-M98 is closed for the current Unicode scalar range bar: callers can now sample
bounded Unicode scalar ranges, fill caller-owned `[]u21` buffers, or request
owned scalar range batches without manually compressing around surrogate code
points.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
