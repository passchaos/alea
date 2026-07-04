# S4-M50 IndexVec Caller-Owned Item Mapping

Date: 2026-07-04

Purpose: complement S4-M49's lazy `IndexVec` value/pointer iterators with
caller-owned output-buffer mapping. This lets callers materialize sampled items
or item pointers without allocating inside Alea.

## Change

Added `IndexVec` caller-owned mapping helpers in `src/seq.zig`:

- `IndexVec.valuesInto(T, items, out)`;
- `IndexVec.valuesIntoChecked(T, items, out)`;
- `IndexVec.ptrsInto(T, items, out)`;
- `IndexVec.ptrsIntoChecked(T, items, out)`.

The unchecked forms require `out.len == index_vec.len()` and assume indexes
match the item slice. The checked forms validate every sampled index before
filling the output buffer. Pointer forms write `*const T` into caller-owned
pointer buffers.

Updated adoption/docs:

- `examples/sequence_sampling.zig` prints `IndexVec.valuesInto` and
  `IndexVec.ptrsInto` output;
- `docs/examples.md` describes lazy and caller-owned IndexVec item mapping;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions caller-owned IndexVec item mapping.

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

- value-buffer and pointer-buffer mapping;
- output length mismatch checks;
- checked item-length validation failures before filling;
- compact `u32` and native `usize` backing through the existing mapping tests.

## S4-M50 Decision

S4-M50 is closed for the current IndexVec caller-owned mapping bar: sampled index
vectors can now lazily iterate or fill caller-owned value/pointer buffers without
allocating mapped results.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
