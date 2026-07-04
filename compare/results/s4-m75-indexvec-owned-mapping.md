# S4-M75 IndexVec Owned Item Mapping

Date: 2026-07-04

Purpose: extend `IndexVec` item mapping with allocation-returning helpers. This
complements S4-M49 lazy value/pointer iterators, S4-M50 caller-owned value/pointer
buffers, S4-M51 mutable-pointer mapping, and S4-M74 compact u32 exports.

## Change

Added allocation-returning IndexVec mapping helpers in `src/seq.zig`:

- `IndexVec.valuesOwned(allocator, T, items)`;
- `IndexVec.valuesOwnedChecked(allocator, T, items)`;
- `IndexVec.ptrsOwned(allocator, T, items)`;
- `IndexVec.ptrsOwnedChecked(allocator, T, items)`;
- `IndexVec.mutPtrsOwned(allocator, T, items)`;
- `IndexVec.mutPtrsOwnedChecked(allocator, T, items)`.

The checked forms validate bounds first. Mutable-pointer checked forms also
validate that indexes are distinct before returning mutable pointers.

Updated adoption/docs:

- `examples/sequence_sampling.zig` prints `IndexVec.valuesOwned`,
  `IndexVec.ptrsOwned`, and `IndexVec.mutPtrsOwned` rows;
- `docs/examples.md` describes allocation-returning IndexVec item mapping;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions allocation-returning IndexVec mapping;
- `tools/examplecheck.zig` guards the sequence example tokens;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M75 evidence.

## Validation

Commands for final validation:

```sh
git diff --check
zig build test
zig build run-sequence-sampling
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- allocation-returning value, const-pointer, and mutable-pointer IndexVec mapping;
- checked invalid-index and duplicate-index rejection;
- allocation-failure cleanup paths;
- zero-length checked IndexVec no-consume behavior.

## S4-M75 Decision

S4-M75 is closed for the current IndexVec owned-mapping bar: sampled index
vectors can now allocate mapped values or const/mutable pointer slices directly
when an owned mapped result is more convenient than lazy iteration or
caller-owned buffers.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
