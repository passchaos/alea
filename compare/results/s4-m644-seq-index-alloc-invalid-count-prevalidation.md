# S4-M644 Direct Sequence Index Allocation Invalid-Count Prevalidation

## Gap

The root layer already rejects oversized unweighted index allocation requests
before output allocation and secure-engine construction. The direct `seq` layer
still relied on debug assertions in unchecked `From` helpers, so direct callers
could hit an assertion in safe builds instead of getting a fallible Zig error.

Direct index allocation helpers should report invalid counts explicitly before
allocation and before random-stream use.

## Local `rand` Baseline

The local Rust checkout remains the baseline comparison source:

- `/home/passchaos/Work/rand/src/seq/index.rs` documents
  `rand::seq::index::sample` as panicking when `amount > length` and performs
  that check before selecting a sampling algorithm.
- Alea's direct `seq` APIs are fallible Zig APIs; checked variants already return
  `error.InvalidParameter`.

S4-M644 aligns unchecked direct helpers with Alea's fallible API style and the
root prevalidation work while preserving the same signatures.

## API Changed

`src/seq.zig` now prevalidates oversized sample amounts in:

- `sampleIndexVecFrom`
- `sampleIndicesFrom`
- `sampleIndicesU32From`

The public signatures are unchanged.

Deterministic pre-stream behavior is explicit:

- Oversized sample amounts return `error.InvalidParameter` before any allocation
  or random-stream use.
- Valid calls keep the existing algorithm selection and stream shape.
- Checked wrappers continue to return the same error for the same invalid inputs.

## Adoption and Documentation

- Focused seq tests cover invalid-count failures before allocation and random
  stream consumption for all three helpers.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq tests:

```text
$ zig test src/seq.zig --test-filter "invalid unchecked index allocation"
1/2 seq.test.invalid unchecked index allocation helpers fail before allocation and stream use...OK
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
roadmapcheck ok
examplecheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M644 is closed for the current bar: direct sequence unchecked index allocation
helpers now reject oversized sample amounts before allocation and random-stream
use. This is reliability and ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
