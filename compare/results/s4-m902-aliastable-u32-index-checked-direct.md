# S4-M902 AliasTable U32 Checked Index Alias Direct Path

## Gap

`AliasTable.sampleIndexU32CheckedFrom` still routed through
`sampleU32CheckedFrom`. Earlier milestones made unchecked compact index aliases,
checked `usize` aliases, and compact checked sampling direct, but the checked
compact index alias retained one wrapper hop before executing the same u32
alias-table sampling branches.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` weighted-index workflows expose sampled indexes
from a reusable weighted sampler. Alea's `AliasTable` keeps Zig-native aliases for
Rust-discoverable index naming and compact `u32` output. The checked compact index
alias should preserve output-size validation and stream shape while executing the
same alias-table sampling branches directly.

## Implementation

- `src/distributions.zig` updates `AliasTable.sampleIndexU32CheckedFrom` to check
  compact output size, handle constant-index tables without consuming randomness,
  and then execute either the one-word power-of-two alias path or the general
  column/probability branch directly.
- The focused AliasTable alias test now compares `sampleIndexU32CheckedFrom` with
  `sampleU32CheckedFrom` for stream shape, alongside existing `usize` checked
  alias and compact fill checks.

## Validation

Focused AliasTable alias test:

```text
$ zig test src/distributions.zig --test-filter "alias table index aliases mirror sample helpers"
1/2 distributions.test.alias table index aliases mirror sample helpers...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
roadmapcheck ok
readmecheck ok
toolingcheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M902 is closed for the current bar: `AliasTable.sampleIndexU32CheckedFrom` now
avoids the `sampleU32CheckedFrom` wrapper while preserving compact output
validation, constant-index behavior, stream shape, and checked error behavior.
This is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
