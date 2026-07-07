# S4-M667 Rng No-Replacement Empty-Type Prevalidation

## Gap

Root no-replacement helpers already reject non-zero uninhabited value types before
allocation and entropy. The `Rng` no-replacement helpers did not explicitly
validate empty enum-containing value types, so checked direct calls could start
pool allocation before reaching impossible value construction paths.

`Rng` no-replacement value sampling should reject non-zero uninhabited value
types before allocation and before random-stream use.

## Local `rand` Baseline

The local Rust `rand` checkout exposes no-replacement sampling over slices where
empty inputs or impossible counts are rejected before sampling. Rust's type
system prevents empty enum values from existing in normal slices; Alea's
Zig-native generic APIs can still name empty enum-containing output types, so
`error.EmptyRange` is the deterministic pre-sampling validation path.

## API Changed

`src/rng.zig` now prevalidates empty enum-containing value types in:

- `sampleWithoutReplacement`
- `sampleWithoutReplacementFrom`
- `sampleWithoutReplacementCheckedFrom`

The public signatures are unchanged.

Deterministic pre-stream behavior is explicit:

- Zero-count requests still return empty allocations before validating the value
  type.
- Non-zero empty enum-containing value types return `error.EmptyRange` before
  allocation and random-stream use.
- Oversized counts still return `error.InvalidParameter` before allocation.
- Habitable value types keep existing no-replacement stream shape.

## Adoption and Documentation

- Focused rng tests cover method, direct unchecked, and direct checked empty
  enum-containing no-replacement requests before allocation and stream
  consumption, plus existing zero-count behavior.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused rng test:

```text
$ zig test src/rng.zig --test-filter "sample without replacement validates empty value types before allocation"
1/2 rng.test.sample without replacement validates empty value types before allocation...OK
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
apicheck ok
readmecheck ok
toolingcheck ok
examplecheck ok
```

## Result

S4-M667 is closed for the current bar: `Rng` no-replacement value sampling now
rejects non-zero empty enum-containing value types before allocation,
random-stream use, or assertions. This is reliability and ergonomics work only;
it does not resolve S4-M11 and is not whole-goal completion evidence.
