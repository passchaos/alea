# S4-M131 Seq One-Shot Choice Aliases

Result: passed.

Purpose: make one-shot slice value and pointer choices discoverable in the
`seq` namespace under terminology matching local Rust `IndexedRandom::choose`
and `IndexedMutRandom::choose_mut`. Alea already had `Rng.choose*`; this
milestone adds explicit `seq.choose*` aliases for sequence users.

## Local Rust Reference

Audited `/home/passchaos/Work/rand/src/seq/slice.rs`:

- `IndexedRandom::choose(rng)` returns an optional shared reference to one item;
- `IndexedMutRandom::choose_mut(rng)` returns an optional mutable reference;
- empty slices return `None`;
- single-item slices do not need randomness.

## Alea API Added

`src/seq.zig` now exposes:

- `seq.choose`;
- `seq.chooseFrom`;
- `seq.chooseChecked`;
- `seq.chooseCheckedFrom`;
- `seq.chooseConstPtr`;
- `seq.chooseConstPtrFrom`;
- `seq.chooseConstPtrChecked`;
- `seq.chooseConstPtrCheckedFrom`;
- `seq.choosePtr`;
- `seq.choosePtrFrom`;
- `seq.choosePtrChecked`;
- `seq.choosePtrCheckedFrom`.

The optional forms forward to the existing `Rng` value/const-pointer/mutable
pointer choice helpers. Checked forms preserve `seq`-style `error.EmptyInput`
for empty slices instead of exposing `Rng`'s `error.EmptyRange`.

Focused tests verify:

- facade/direct stream-shape parity against the existing `Rng` helpers;
- value, const-pointer, and mutable-pointer outputs;
- empty optional and checked no-consume behavior;
- singleton no-consume behavior.

## Adoption and Documentation

- `examples/sequence_sampling.zig` prints `seq.chooseFrom`,
  `seq.chooseConstPtrFrom`, and `seq.choosePtrFrom` rows.
- `tools/examplecheck.zig` verifies those example tokens.
- `docs/api-reference.md` lists all new public symbols.
- `docs/core-guide.md`, `README.md`,
  `compare/results/distribution-parity-matrix.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and the active-goal audit
  describe the `seq.choose` aliases.

## Validation

The relevant validation for this milestone is:

- `git diff --check`
- `zig test src/root.zig --test-filter "seq one-shot choice"`
- `zig build test`
- `zig build run-sequence-sampling`
- `zig build doccheck`
- `zig build -Doptimize=ReleaseFast validate`

These commands passed before commit.

## Non-Completion Note

This milestone closes an unblocked sequence API discoverability gap only. It
does not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not add a new architecture/runtime runner, and is not whole-goal
completion evidence.
