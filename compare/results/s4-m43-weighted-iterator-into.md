# S4-M43 Caller-Owned Weighted Iterator Sampling

Date: 2026-07-04

Purpose: add runtime-length caller-owned weighted iterator sampling. S4-M39 added
fixed-size weighted iterator arrays; this milestone adds buffer-fill forms for
weighted streams when the requested count is only known at runtime.

## Change

Added caller-owned weighted iterator helpers in `src/seq.zig`:

- `sampleIteratorWeightedInto(rng, T, iterator, out, scratch_keys) !usize`
- `sampleIteratorWeightedIntoFrom(source, T, iterator, out, scratch_keys) !usize`
- `sampleIteratorWeightedIntoChecked(rng, T, iterator, out, scratch_keys) !void`
- `sampleIteratorWeightedIntoCheckedFrom(source, T, iterator, out, scratch_keys) !void`

The optional forms fill up to `out.len` items and return the number filled. The
checked forms require enough positive-weight iterator entries to fill `out`.
Callers provide `scratch_keys` with at least `out.len` entries, avoiding heap
allocation for runtime-length weighted iterator samples. Zero-length output does
not read the iterator, and single-positive inputs return the only possible item
without consuming randomness.

Updated adoption/docs:

- `examples/sequence_sampling.zig` prints `sampleIteratorWeightedIntoFrom` output;
- `docs/examples.md` describes fixed-size/caller-owned weighted iterator helpers;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions fixed-size/caller-owned weighted iterator helpers.

## Validation

Commands:

```sh
zig build test
zig build run-sequence-sampling
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- optional, checked, facade, and direct-source forms;
- partial-fill behavior when requested output is larger than positive iterator entries;
- caller-owned scratch-key length validation;
- zero-length and single-positive no-consume behavior;
- invalid-weight no-consume behavior for validation-before-draw cases;
- facade/direct stream-shape parity.

## S4-M43 Decision

S4-M43 is closed for the current caller-owned weighted iterator sampling bar:
users can now choose allocation-returning, fixed-size, or runtime caller-owned
weighted iterator workflows.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
