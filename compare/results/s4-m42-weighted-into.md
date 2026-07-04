# S4-M42 Caller-Owned Weighted Item Sampling

Date: 2026-07-04

Purpose: add runtime-length caller-owned weighted no-replacement item sampling.
S4-M41 added caller-owned weighted index buffers; this milestone maps those
indexes into caller-owned item buffers, complementing allocation-returning
`sampleWeighted` and fixed-size `sampleWeightedArray`.

## Change

Added caller-owned weighted item helpers in `src/seq.zig`:

- `sampleWeightedInto(rng, T, Weight, items, weights, out, scratch_indices, scratch_keys) !usize`
- `sampleWeightedIntoFrom(source, T, Weight, items, weights, out, scratch_indices, scratch_keys) !usize`
- `sampleWeightedIntoChecked(rng, T, Weight, items, weights, out, scratch_indices, scratch_keys) !void`
- `sampleWeightedIntoCheckedFrom(source, T, Weight, items, weights, out, scratch_indices, scratch_keys) !void`

The optional forms fill up to `out.len` items and return the number filled. The
checked forms require enough positive weights to fill `out`. Callers provide both
`scratch_indices` and `scratch_keys` with at least `out.len` entries, avoiding
heap allocation for runtime-length weighted item samples. Zero-length output
returns immediately, and single-positive inputs return the only possible item
without consuming randomness.

Updated adoption/docs:

- `examples/weighted_sampling.zig` prints `sampleWeightedIntoFrom` output;
- `docs/examples.md` describes caller-owned weighted index/value buffers;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions caller-owned weighted index/value buffers;
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
- caller-owned scratch-index and scratch-key length validation;
- zero-length and single-positive no-consume behavior;
- invalid-weight no-consume behavior after validation-before-draw;
- facade/direct stream-shape parity.

## S4-M42 Decision

S4-M42 is closed for the current caller-owned weighted item sampling bar: users
can now choose allocation-returning, fixed-size, caller-owned index, or
caller-owned item weighted no-replacement workflows.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
