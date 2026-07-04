# S4-M97 Rng Owned Unicode Scalar Batches

Date: 2026-07-04

Purpose: add caller-owned and allocation-returning Unicode scalar batches for
`Rng`. This complements `Rng.unicodeScalar`, Zig-native `u21` Unicode scalar
handling, Rust `StandardUniform<char>`-style repeated scalar generation, and the
existing ASCII/Unicode UTF-8 string helpers.

## Rust rand Comparison

The local Rust `rand` checkout implements `StandardUniform<char>` by drawing a
Unicode scalar while skipping UTF-16 surrogate code points. It also exposes
`UniformChar` as a `char` range sampler. Alea does not have a native `char` type
to mirror, but `Rng.unicodeScalar` already samples valid Unicode scalar values as
`u21` using the same skip-surrogate shape. S4-M97 adds Zig-native repeated scalar
workflows so callers can choose codepoint-level `[]u21` buffers or UTF-8 strings
explicitly.

Local Rust evidence inspected:

- `~/Work/rand/src/distr/other.rs`: `impl Distribution<char> for StandardUniform`
  skips `[0xD800, 0xDFFF]` surrogate values;
- `~/Work/rand/src/distr/uniform_other.rs`: `UniformChar` documents the same
  surrogate-gap handling for char ranges.

## Change

Added Unicode scalar bulk helpers in `src/rng.zig`:

- `Rng.fillUnicodeScalar(dest)`;
- `Rng.fillUnicodeScalarFrom(source, dest)`;
- `Rng.unicodeScalarBatch(allocator, count)`;
- `Rng.unicodeScalarBatchFrom(source, allocator, count)`.

The new helpers preserve scalar stream shape: filling or allocating `N` values
matches `N` repeated calls to `unicodeScalarFrom` for the same source. Owned
batches allocate before drawing, so zero-count and allocation-failure paths do
not consume the stream.

Updated adoption/docs:

- `examples/string_generation.zig` prints `unicode scalar fill` and
  `unicode scalar batch` rows;
- `tools/examplecheck.zig` guards the example tokens;
- `docs/core-guide.md`, `docs/api-reference.md`, `docs/examples.md`, and
  `README.md` list the new APIs;
- `compare/results/reproducibility-matrix.md` records the stream-shape contract;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include S4-M97 evidence.

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

- facade/direct Unicode scalar fill API smoke and valid scalar range checks;
- owned Unicode scalar batch API smoke and valid scalar range checks;
- `fillUnicodeScalarFrom` stream-shape parity with repeated `unicodeScalarFrom`;
- `unicodeScalarBatchFrom` stream-shape parity with repeated `unicodeScalarFrom`;
- zero-count and allocation-failure owned batches returning before stream
  consumption.

## S4-M97 Decision

S4-M97 is closed for the current Unicode scalar bulk/owned batch bar: callers can
now fill caller-owned `[]u21` buffers or request owned Unicode scalar slices
without manually looping over `unicodeScalar`.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
