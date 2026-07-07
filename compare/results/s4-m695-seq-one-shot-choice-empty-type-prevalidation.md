# S4-M695 Seq One-Shot Choice Empty-Type Prevalidation

## Gap

`Rng` one-shot value choice helpers now reject non-zero empty enum-containing
value types before sampling. The `seq` one-shot value choice aliases still
forwarded directly to `Rng` and returned root-style errors for uninhabited output
types instead of preserving seq-style `error.EmptyInput` through the checked
alias.

`seq.choose*` value aliases should reject non-empty uninhabited value choices
before random-stream use or value copying while preserving seq-style error
mapping.

## Local `rand` Baseline

The local Rust `rand` checkout exposes one-shot slice choice APIs returning
references. Rust's normal type flow avoids constructing impossible output values,
while Alea's Zig-native value-returning `seq` aliases can name empty
enum-containing output types.

For Alea, optional one-shot `seq.chooseFrom` returns `null` and checked variants
return `error.EmptyInput` for non-empty uninhabited value requests.

## API Changed

`src/seq.zig` now prevalidates empty enum-containing value types in:

- `chooseFrom`
- `chooseCheckedFrom` (inherited through `chooseFrom`)

Pointer choice aliases are unchanged because they return addresses into
caller-owned slices. Public signatures are unchanged.

Deterministic behavior is explicit:

- Empty inputs still return `null` / `error.EmptyInput` without sampling.
- Non-empty empty enum-containing value types return `null` / `error.EmptyInput`
  before random-stream use or value copying.
- Singleton deterministic behavior remains unchanged for habitable value types.

## Adoption and Documentation

- Focused seq tests cover optional and checked one-shot value choices for a
  regular struct containing an empty enum field, with zero stream consumption.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq test:

```text
$ zig test src/seq.zig --test-filter "seq one-shot choice aliases mirror Rng choice helpers"
1/2 seq.test.seq one-shot choice aliases mirror Rng choice helpers...OK
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
toolingcheck ok
apicheck ok
examplecheck ok
readmecheck ok
```

## Result

S4-M695 is closed for the current bar: `seq` one-shot value choice aliases now
reject non-empty empty enum-containing output types before random-stream use,
value copying, or assertions while preserving seq-style `error.EmptyInput`. This
is reliability and ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
