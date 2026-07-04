# S4-M45 Caller-Owned Slice Item Sampling

Date: 2026-07-04

Purpose: add runtime-length caller-owned item subset sampling for slices. S4-M44
added caller-owned index buffers; this milestone maps those indexes into
caller-owned item buffers, complementing allocation-returning `chooseMultiple`
and fixed-size `chooseArray`.

## Change

Added caller-owned slice item helpers in `src/seq.zig`:

- `chooseMultipleInto(rng, T, items, out, scratch_indices) Error!usize`
- `chooseMultipleIntoFrom(source, T, items, out, scratch_indices) Error!usize`
- `chooseMultipleIntoChecked(rng, T, items, out, scratch_indices) Error!void`
- `chooseMultipleIntoCheckedFrom(source, T, items, out, scratch_indices) Error!void`

The optional forms fill up to `out.len` items and return the number filled, so
requesting more output than available items yields a partial fill. The checked
forms require enough input items to fill `out`. Callers provide `scratch_indices`
with at least the number of items to fill, avoiding heap allocation for
runtime-length item subset samples. Zero-length output returns immediately, and
invalid lengths/scratch sizes fail before drawing.

Updated adoption/docs:

- `examples/sequence_sampling.zig` prints `chooseMultipleIntoFrom` output;
- `docs/examples.md` describes caller-owned item subset buffers;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions caller-owned item subsets.

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
- partial-fill behavior when `out.len > items.len`;
- scratch-index length validation;
- zero-length no-consume behavior;
- invalid-length no-consume behavior;
- facade/direct stream-shape parity.

## S4-M45 Decision

S4-M45 is closed for the current caller-owned slice item sampling bar: users can
choose allocation-returning, fixed-size, or runtime caller-owned item subset
workflows.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
