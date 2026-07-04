# S4-M74 IndexVec U32 Export Mapping

Date: 2026-07-04

Purpose: extend compact `IndexVec` ergonomics with direct `u32` export helpers.
This complements `IndexVec.copyInto`, `IndexVec.toOwnedSlice`, S4-M73 fixed-size
`u32` index arrays, and the allocation/caller-owned weighted `u32` index APIs.

## Change

Added `IndexVec` compact export helpers in `src/seq.zig`:

- `IndexVec.copyIntoU32(out)`;
- `IndexVec.toOwnedU32Slice(allocator)`.

For `.u32` backing these helpers copy directly. For `.usize` backing they check
each value before narrowing and return `error.InvalidParameter` when an index
cannot be represented as `u32`.

Updated adoption/docs:

- `examples/sequence_sampling.zig` prints `IndexVec.copyIntoU32` and
  `IndexVec.toOwnedU32Slice` rows;
- `docs/examples.md` describes IndexVec u32 export mapping;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions IndexVec u32 export mapping;
- `tools/examplecheck.zig` guards the sequence example token;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M74 evidence.

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

- `IndexVec.copyIntoU32` for compact and native backing;
- `IndexVec.toOwnedU32Slice` for compact and native backing;
- length-mismatch errors;
- too-large `usize` backing rejection before narrowing;
- allocation-failure handling for owned `u32` copies;
- zero-length checked IndexVec no-consume behavior.

## S4-M74 Decision

S4-M74 is closed for the current IndexVec compact-export bar: sampled index
vectors can now fill caller-owned `u32` buffers or allocate owned `[]u32` copies
without forcing callers through `[]usize` when compact indexes are desired.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
