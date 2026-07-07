# S4-M701 Seq Unchecked Iterator Into Empty-Type Prevalidation

## Gap

`seq` iterator owned/fixed/checked caller-owned value reservoir helpers now reject
empty enum-containing output types before allocation or iterator consumption. The
unchecked caller-owned iterator value fill helper (`sampleIteratorIntoFrom`) has
a `usize` result rather than an error channel, and could still consume iterators
or draw from the random stream for uninhabited output types.

`seq.sampleIteratorIntoFrom` should make this impossible request a deterministic
zero-fill no-op before iterator consumption or random-stream use, matching its
short-stream partial-fill semantics.

## Local `rand` Baseline

The local Rust `rand` checkout exposes iterator/slice sampling workflows over
inhabited values or references. Rust's type flow avoids constructing impossible
output values, while Alea's Zig-native caller-owned value buffers can name empty
enum-containing output types.

For Alea's infallible `usize`-returning unchecked helper, returning `0` is the
stable pre-sampling no-op for uninhabited value outputs.

## API Changed

`src/seq.zig` now prevalidates empty enum-containing value types in:

- `sampleIteratorIntoFrom`

Public wrappers `sampleIteratorInto` and `sampleIteratorFill` inherit this
behavior. Public signatures are unchanged.

Deterministic behavior is explicit:

- Empty output buffers still return `0` before validating the value type.
- Non-empty empty enum-containing value buffers return `0` before iterator
  consumption, random-stream use, or value copying.
- Checked caller-owned iterator fills continue to return `error.EmptyInput` for
  non-empty uninhabited output types.
- Habitable value types keep existing partial-fill and reservoir behavior.

## Adoption and Documentation

- Focused seq tests cover unchecked caller-owned iterator fill for an empty enum
  output buffer with zero random-stream consumption, alongside the existing
  checked error-path coverage.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq tests:

```text
$ zig test src/seq.zig --test-filter "iterator reservoir samples validate empty value types before allocation"
1/3 seq.test.iterator reservoir samples validate empty value types before allocation...OK
2/3 seq.test.weighted iterator reservoir samples validate empty value types before allocation...OK
3/3 root.test_0...OK
All 3 tests passed.
```

```text
$ zig test src/seq.zig --test-filter "sampleIteratorInto fills caller-owned reservoirs"
1/2 seq.test.sampleIteratorInto fills caller-owned reservoirs...OK
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
toolingcheck ok
roadmapcheck ok
readmecheck ok
apicheck ok
examplecheck ok
```

## Result

S4-M701 is closed for the current bar: `seq` unchecked caller-owned iterator
value fills now treat non-empty empty enum-containing output buffers as a
zero-fill no-op before iterator consumption, random-stream use, value copying, or
assertions. This is reliability and ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
