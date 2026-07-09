# S4-M1068 AliasTable Checked Fill Facade Direct Path

## Gap

Reusable `AliasTable(Weight).fillChecked` still delegated facade checked usize
fills through `fillCheckedFrom`. `AliasTable.fill` already samples cached
alias-table indexes directly through facade `Rng`, so the checked usize fill
facade can reuse that direct path instead of bouncing through the direct-source
wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for weighted index
behavior. Alea exposes caller-owned checked alias-table index fills; this change
tightens that facade helper so it drives the supplied facade RNG directly.

## Implementation

- `src/distributions.zig` updates `AliasTable(Weight).fillChecked` to call
  `self.fill(rng, dest)` directly.
- `AliasTable(Weight).fillCheckedFrom` remains unchanged for explicit
  direct-source workflows.

## Validation

Focused AliasTable tests:

```text
$ zig test src/distributions.zig --test-filter "alias table index aliases mirror sample helpers"
1/2 distributions.test.alias table index aliases mirror sample helpers...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "alias table owned index batches mirror fills"
1/2 distributions.test.alias table owned index batches mirror fills...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "zero-length alias table fills do not consume random stream"
1/2 distributions.test.zero-length alias table fills do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "single-positive alias table does not consume random stream"
1/2 distributions.test.single-positive alias table does not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
toolingcheck ok
apicheck ok
roadmapcheck ok
examplecheck ok
readmecheck ok
```

## Result

S4-M1068 is closed for the current bar: reusable `AliasTable(Weight).fillChecked`
now avoids the direct-source wrapper alias while preserving stream shape,
zero-length behavior, and single-positive behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
