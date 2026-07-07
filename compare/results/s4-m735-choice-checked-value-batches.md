# S4-M735 Choice Checked Value Batches

## Gap

Reusable `Choice` now has checked scalar values, fixed value arrays, and value
iterators. Its caller-owned and allocation-returning value-copy batch helpers
still only exposed unchecked names, even though they already need explicit
empty-type handling for non-zero uninhabited value outputs.

Reusable `Choice` should provide checked value batch aliases that return a
seq-style error before random-stream use, allocation, or value copying for empty
enum-containing value types.

## Local `rand` Baseline

The local Rust `rand` checkout exposes repeated choice workflows through
reference-oriented slice choice and iterator collection. Alea's reusable
`Choice(T)` exceeds the reference-only shape with value-copy fills and owned
batches; checked aliases make those value-copy batch paths explicit for fallible
Zig workflows involving uninhabited value types.

## API Added

`src/seq.zig` adds checked value batch aliases to `Choice(T)`:

- `Choice(T).fillValuesChecked`
- `Choice(T).fillValuesCheckedFrom`
- `Choice(T).valuesChecked`
- `Choice(T).valuesCheckedFrom`

`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- Checked value-fill aliases preserve `fillValuesFrom` stream shape for inhabited
  value types.
- Checked owned value aliases preserve `valuesFrom` stream shape for inhabited
  value types.
- Non-empty empty enum-containing value outputs return `error.EmptyInput` before
  random-stream use, allocation, or value copying.
- Zero-length checked fills and owned batches preserve existing no-consumption /
  zero-allocation-shape behavior.

## Adoption and Documentation

- Focused seq tests compare checked and unchecked caller-owned value fills and
  owned value batches for stream parity.
- Empty-type tests cover `fillValuesCheckedFrom` and `valuesCheckedFrom` returning
  `error.EmptyInput` with zero stream consumption and no induced allocation
  failure.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq test:

```text
$ zig test src/seq.zig --test-filter "choice sampler repeatedly samples slice references"
1/2 seq.test.choice sampler repeatedly samples slice references...OK
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
examplecheck ok
toolingcheck ok
roadmapcheck ok
apicheck ok
readmecheck ok
```

## Result

S4-M735 is closed for the current bar: reusable `Choice` now has checked aliases
for caller-owned and allocation-returning value-copy batches. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
