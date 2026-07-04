# S4-M51 IndexVec Mutable Pointer Mapping

Date: 2026-07-04

Purpose: extend the S4-M49/S4-M50 `IndexVec` item-mapping surface with mutable
pointer mapping. This complements local Rust slice `choose_mut` ergonomics in a
Zig-native way for sampled index vectors: callers can sample indexes once, then
mutate the selected slice positions through checked pointers without allocating
mapped results inside Alea.

## Change

Added `IndexVec` mutable pointer helpers in `src/seq.zig`:

- `IndexVec.MutPtrIterator(T)` with `next()` and `remaining()`;
- `IndexVec.validateDistinctItems(item_len)`;
- `IndexVec.mutPtrs(T, items)`;
- `IndexVec.mutPtrsChecked(T, items)`;
- `IndexVec.mutPtrsInto(T, items, out)`;
- `IndexVec.mutPtrsIntoChecked(T, items, out)`.

The unchecked forms mirror the existing unchecked value/const-pointer mapping
contract: callers are responsible for valid sampled indexes and distinctness.
The checked forms validate that every sampled index is in bounds and that the
sampled indexes are distinct before exposing mutable pointers, avoiding checked
aliasing surprises for user mutation workflows. This matches the normal
no-replacement `IndexVec` generation contract while keeping manually-constructed
`IndexVec` values diagnosable.

Updated adoption/docs:

- `examples/sequence_sampling.zig` prints a mutable-pointer mapping workflow by
  updating sampled score slots through `IndexVec.mutPtrsIntoChecked`;
- `docs/examples.md` describes IndexVec mutable-pointer mapping in the sequence
  example;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions value and pointer `IndexVec` mapping;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M51 evidence.

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

- lazy mutable pointer iteration and `remaining()`;
- caller-owned mutable pointer buffer fill;
- output length mismatch checks;
- checked item-length validation failures;
- checked duplicate-index rejection for manually-constructed `IndexVec` values;
- compact `u32` and native `usize` backing through the existing mapping tests.

## S4-M51 Decision

S4-M51 is closed for the current mutable `IndexVec` mapping bar: sampled index
vectors can now lazily iterate or fill caller-owned mutable pointer buffers after
checked bounds/distinctness validation, without allocating mapped results.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
