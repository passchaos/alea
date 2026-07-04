# S4-M41 Caller-Owned Weighted Index Sampling

Date: 2026-07-04

Purpose: add an allocation-free runtime-length weighted no-replacement index
sample for callers that know output length at runtime and can provide scratch
storage. This complements allocation-returning `sampleWeightedIndices` and
fixed-size `[N]usize` `sampleWeightedIndexArray`.

## Change

Added caller-owned weighted index helpers in `src/seq.zig`:

- `sampleWeightedIndicesInto(rng, Weight, weights, out, scratch_keys) Error!usize`
- `sampleWeightedIndicesIntoFrom(source, Weight, weights, out, scratch_keys) Error!usize`
- `sampleWeightedIndicesIntoChecked(rng, Weight, weights, out, scratch_keys) Error!void`
- `sampleWeightedIndicesIntoCheckedFrom(source, Weight, weights, out, scratch_keys) Error!void`

The optional forms fill up to `out.len` selected indexes and return the number
filled, so requesting more entries than positive weights yields a partial fill.
The checked forms require enough positive weights for `out.len` and return
`error.InvalidParameter` before drawing otherwise. Callers provide `scratch_keys`
with at least `out.len` entries; too-small scratch returns `error.LengthMismatch`
before drawing. Zero-length output returns immediately without validating weights
or consuming randomness, and single-positive inputs return the only possible
index without consuming randomness.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints `sampleWeightedIndicesIntoFrom` output;
- `docs/examples.md` describes caller-owned weighted index buffers;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions caller-owned weighted index buffers;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` record the weighted sequence
  ergonomics comparison.

## Validation

Commands:

```sh
zig build test
zig build run-weighted-sampling
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- optional, checked, facade, and direct-source forms;
- partial-fill behavior when requested output is larger than positive weights;
- caller-owned scratch length validation;
- zero-length and single-positive no-consume behavior;
- invalid-weight no-consume behavior after validation-before-draw;
- facade/direct stream-shape parity.

## S4-M41 Decision

S4-M41 is closed for the current caller-owned weighted index sampling bar: users
can now choose allocation-returning, fixed-size, or runtime caller-owned weighted
index workflows.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
