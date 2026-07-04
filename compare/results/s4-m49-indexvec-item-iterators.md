# S4-M49 IndexVec Item Iterators

Date: 2026-07-04

Purpose: make compact sampled indexes easier to use without allocating a mapped
item slice. Local Rust indexed samples can lazily map indexes back to slice
items; this milestone adds Zig-native value/pointer iterators on `IndexVec`.

## Change

Added `IndexVec` item mapping helpers in `src/seq.zig`:

- `IndexVec.ValueIterator(T)` with `next()` and `remaining()`;
- `IndexVec.PtrIterator(T)` with `next()` and `remaining()`;
- `IndexVec.validateItems(item_len)`;
- `IndexVec.values(T, items)`;
- `IndexVec.valuesChecked(T, items)`;
- `IndexVec.ptrs(T, items)`;
- `IndexVec.ptrsChecked(T, items)`.

The unchecked iterators are lightweight views for callers that know the sampled
indexes match the item slice. The checked constructors validate every sampled
index before returning the iterator, so out-of-range item slices fail before any
iteration.

Updated adoption/docs:

- `examples/sequence_sampling.zig` prints `IndexVec.values` output;
- `docs/examples.md` describes IndexVec item mapping;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions lazy `IndexVec` item mapping.

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

- value iterator and pointer iterator mapping;
- remaining-count tracking;
- compact `u32` and native `usize` backing;
- checked item-length validation failures before iteration.

## S4-M49 Decision

S4-M49 is closed for the current IndexVec item-mapping bar: sampled index vectors
can now lazily produce values or pointers from caller-provided slices without
allocating a mapped result.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
