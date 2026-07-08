# S4-M962 AliasTable Index From Direct Refresh

## Gap

A current-code audit found `AliasTable.sampleIndexFrom` routing through
`sampleCheckedFrom(source) catch unreachable` again. Regardless of earlier
milestones, the actual current index direct-source alias should execute the
alias-table sampling branches directly while preserving stream shape and
unchecked alias semantics.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` weighted-index workflows sample indexes directly
from reusable weighted samplers. Alea's `AliasTable.sampleIndexFrom` is the
Rust-discoverable direct-source index alias and should avoid checked wrapper hops
in the current codebase.

## Implementation

- `src/distributions.zig` updates `AliasTable.sampleIndexFrom` to execute the
  constant-index, one-word power-of-two, and general alias-table sampling branches
  directly from the provided source.
- Focused tests compare index alias stream shape against sample helpers and cover
  checked alias behavior.

## Validation

Focused AliasTable test:

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
examplecheck ok
readmecheck ok
roadmapcheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M962 is closed for the current bar: `AliasTable.sampleIndexFrom` again matches
the direct alias-table sampling intent in the current codebase while preserving
stream shape. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
