# S4-M56 Const-Pointer Single Choice

Date: 2026-07-04

Purpose: add explicit one-shot const-pointer choice helpers for immutable slices.
This complements value-returning `Rng.choose`, mutable `Rng.choosePtr`, and the
recent fixed-size/caller-owned pointer subset APIs without requiring users to
spell `const T` through the mutable-pointer helper shape.

## Change

Added const-pointer choice helpers in `src/rng.zig`:

- `Rng.chooseConstPtr(T, items)`;
- `Rng.chooseConstPtrFrom(source, T, items)`;
- `Rng.chooseConstPtrChecked(T, items)`;
- `Rng.chooseConstPtrCheckedFrom(source, T, items)`.

The optional forms return `null` for empty slices; checked forms return
`error.EmptyRange` before drawing. Single-item slices return the first pointer
without consuming randomness, matching `choose` and `choosePtr` point-mass
behavior.

Updated adoption/docs:

- `examples/basic.zig` prints a const-pointer choice from an immutable slice;
- `docs/examples.md` mentions const-pointer choice in the basic example;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions const/mutable pointer choice;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M56 evidence.

## Validation

Commands:

```sh
git diff --check
zig build test
zig build run-basic
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- optional and checked const-pointer choice;
- empty checked no-consume behavior;
- single-item no-consume behavior;
- facade/direct stream-shape parity.

## S4-M56 Decision

S4-M56 is closed for the current const-pointer single-choice bar: one-shot
choice can now return `*const T` from immutable slices without copying item
values and without requiring mutable slice input.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
