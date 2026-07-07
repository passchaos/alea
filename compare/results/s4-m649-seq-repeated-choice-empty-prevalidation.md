# S4-M649 Seq Repeated Choice Empty Prevalidation

## Gap

S4-M648 tightened the underlying `Rng` unchecked repeated choice/index batch
helpers so non-zero empty inputs fail before allocation and random-stream use.
The `seq` namespace aliases still forwarded directly to `Rng`, which produced
`error.EmptyRange` or assertion-style behavior instead of seq's documented
`error.EmptyInput` semantics.

`seq` aliases should preserve seq-style error names while still prevalidating
before allocation and stream use.

## Local `rand` Baseline

The local Rust checkout remains the baseline comparison source:

- `/home/passchaos/Work/rand/src/seq/slice.rs` documents `choose` returning
  `None` for empty slices and `choose_iter` returning `None` iff the slice is
  empty.
- Alea's `seq` namespace consistently reports empty sequence inputs as
  `error.EmptyInput`.

S4-M649 keeps that Zig-native seq error shape for allocation-returning repeated
choice aliases.

## API Changed

`src/seq.zig` now prevalidates non-zero empty inputs in:

- `chooseBatchFrom`
- `chooseConstPtrBatchFrom`
- `choosePtrBatchFrom`
- `chooseIndexBatchFrom`
- `chooseIndexU32BatchFrom`

The public signatures are unchanged.

Deterministic pre-stream behavior is explicit:

- Non-zero empty value/pointer/index choice batch requests return
  `error.EmptyInput` before allocation and random-stream use.
- Zero-count batch requests still return empty allocations before validating the
  choice set.
- Singleton and random valid paths keep existing behavior and stream shape.

## Adoption and Documentation

- Focused seq tests cover non-zero empty value, const-pointer, mutable-pointer,
  usize-index, and u32-index batch failures before allocation and stream
  consumption, plus existing checked/zero-count behavior.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq tests:

```text
$ zig test src/seq.zig --test-filter "seq choice batch aliases"
1/2 seq.test.seq choice batch aliases mirror Rng batch helpers...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/seq.zig --test-filter "seq index choice aliases"
1/2 seq.test.seq index choice aliases mirror Rng index helpers...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

No output.

Broader native test gate:

```text
$ zig build test
roadmapcheck ok
readmecheck ok
toolingcheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M649 is closed for the current bar: `seq` unchecked repeated choice/index
batch aliases now reject non-zero empty inputs before allocation and random-stream
use while preserving `error.EmptyInput`. This is reliability and ergonomics work
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
