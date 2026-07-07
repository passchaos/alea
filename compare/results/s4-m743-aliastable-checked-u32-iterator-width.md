# S4-M743 AliasTable Checked U32 Iterator Width

## Gap

S4-M739 added checked compact `u32` iterator aliases to static `AliasTable` and
stated that they preserve compact width validation. The focused tests covered
valid stream-shape parity but did not explicitly prove that oversized alias
tables reject checked compact iterator construction before random-stream use.

`AliasTable.iterU32CheckedFrom` should have explicit no-consumption evidence for
populations that do not fit `u32`.

## Local `rand` Baseline

The local Rust `rand` / `rand_distr` weighted-index workflows are index-oriented.
Alea additionally offers compact `u32` index output paths; checked compact paths
must clearly reject oversized populations without consuming randomness.

## Coverage Added

`src/distributions.zig` extends the focused `AliasTable` iterator test with a
fake oversized alias table whose length is `maxInt(u32) + 1`. The test verifies:

- `AliasTable(Weight).iterU32CheckedFrom` returns `error.InvalidParameter`;
- the random stream is unchanged after the failed checked constructor.

The fake table is never sampled or deinitialized; it is used only to exercise the
length prevalidation branch without allocating impossible memory.

No public API changed.

## Adoption and Documentation

- Compact checked iterator width validation now has explicit no-consumption test
  evidence.
- Valid stream-shape parity tests from S4-M739 remain in the same focused test.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "alias table iterators produce repeated indices"
1/2 distributions.test.alias table iterators produce repeated indices...OK
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
apicheck ok
readmecheck ok
examplecheck ok
roadmapcheck ok
```

## Result

S4-M743 is closed for the current bar: static `AliasTable` checked compact `u32`
iterator construction now has explicit oversized-population no-consumption
evidence. This is reliability/validation work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
