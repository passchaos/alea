# S4-M648 Rng Repeated Choice Empty Prevalidation

## Gap

`Rng` checked repeated choice batch helpers already reject non-zero empty inputs
before allocation. The unchecked allocation-returning helpers delegated directly
to fill helpers which assert on empty inputs, so direct callers could allocate
first and then hit an assertion.

Unchecked repeated choice/index batch helpers should return a fallible empty-range
error before allocation and before random-stream use when a non-zero request has
no possible choices.

## Local `rand` Baseline

The local Rust checkout remains the baseline comparison source:

- `/home/passchaos/Work/rand/src/seq/slice.rs` documents `choose` returning
  `None` for empty slices and `choose_iter` returning `None` iff the slice is
  empty.
- Alea's allocation-returning `Rng` helpers are fallible Zig APIs; non-zero empty
  repeated choice requests use `error.EmptyRange`.

S4-M648 aligns unchecked allocation-returning repeated choice helpers with the
checked helper prevalidation while preserving zero-count allocation behavior.

## API Changed

`src/rng.zig` now prevalidates non-zero empty inputs in:

- `chooseBatchFrom`
- `chooseConstPtrBatchFrom`
- `choosePtrBatchFrom`
- `chooseIndexBatchFrom`
- `chooseIndexU32BatchFrom`

The public signatures are unchanged.

Deterministic pre-stream behavior is explicit:

- Non-zero empty value/pointer/index choice batch requests return
  `error.EmptyRange` before allocation and random-stream use.
- Zero-count batch requests still return empty allocations before validating the
  choice set.
- Singleton and random valid paths keep existing behavior and stream shape.

## Adoption and Documentation

- Focused rng tests cover non-zero empty value, const-pointer, mutable-pointer,
  usize-index, and u32-index batch failures before allocation and stream
  consumption, plus existing checked/zero-count behavior.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused rng tests:

```text
$ zig test src/rng.zig --test-filter "invalid facade choice helpers"
1/2 rng.test.invalid facade choice helpers do not consume random stream...OK
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
readmecheck ok
examplecheck ok
apicheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M648 is closed for the current bar: `Rng` unchecked repeated choice/index
batch helpers now reject non-zero empty inputs before allocation and random-stream
use. This is reliability and ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
