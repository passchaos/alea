# S4-M253 Hinted Iterator Choice

Date: 2026-07-05

## Local Rust Baseline

The local `~/Work/rand/src/seq/iterator.rs` exposes two related iterator
choice workflows:

- `IteratorRandom::choose`, which uses exact `Iterator::size_hint` information
  to select by index when possible and can therefore be hint-sensitive;
- `IteratorRandom::choose_stable`, which intentionally keeps selection stable
  across iterator hint shapes.

Alea already exposed stable reservoir iterator choice through
`seq.chooseIterator*` plus the Rust-discoverable `chooseIteratorStable*`
aliases from S4-M122. The missing shape was an explicit hint-sensitive helper
for callers who want local Rust `IteratorRandom::choose`-style exact-size
iterator behavior without changing Alea's stable default.

## Alea Change

Alea now provides:

- `seq.chooseIteratorHinted`;
- `seq.chooseIteratorHintedFrom`;
- `seq.chooseIteratorHintedChecked`;
- `seq.chooseIteratorHintedCheckedFrom`.

When an iterator exposes an exact remaining length via `sizeHint()` with
`lower == upper`, `len()`, or `remaining()`, these helpers draw one bounded
index and advance to that item. Empty and singleton exact-size iterators return
without drawing. Iterators without exact hints fall back to the existing stable
reservoir `chooseIteratorFrom` stream shape.

This keeps Alea's default iterator choice reproducibility contract intact while
making the local Rust hint-sensitive workflow explicit and discoverable.

## Tests and Validation

Focused tests in `src/seq.zig` cover:

- facade/direct stream-shape preservation for exact-size hinted iterators;
- checked empty hinted iterators failing without consuming randomness;
- singleton hinted iterators returning the only item without consuming;
- fallback equivalence with `chooseIteratorFrom` for unhinted iterators.

Documentation/example updates:

- `examples/sequence_sampling.zig` prints
  `chooseIteratorHintedFrom exact counter[0..20)`.
- `tools/examplecheck.zig` checks the new example token.
- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, and
  `docs/examples.md` document the hint-sensitive iterator choice shape.
- `compare/results/distribution-parity-matrix.md`,
  `compare/results/reproducibility-matrix.md`,
  `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and
  `tools/roadmapcheck.zig` record the milestone and advance the next-gap row
  to S4-M254.

Validation commands for this milestone:

```sh
zig test src/seq.zig --test-filter "hinted iterator choice"
zig build run-sequence-sampling
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
```
