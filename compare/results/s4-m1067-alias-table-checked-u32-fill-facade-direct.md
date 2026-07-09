# S4-M1067 AliasTable Checked U32 Fill Facade Direct Path

## Gap

Reusable `AliasTable(Weight).fillU32Checked` still delegated facade u32 index
fills through `fillU32CheckedFrom`. The usize fill facade already samples cached
alias-table indexes directly through facade `Rng`, so the checked u32 fill facade
can use the same direct sampling pattern while preserving the u32 population
validation.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for weighted index
behavior. Alea exposes compact u32 caller-owned alias-table fills in addition to
usize fills; this change tightens that facade helper so it drives the supplied
facade RNG directly instead of bouncing through the direct-source wrapper.

## Implementation

- `src/distributions.zig` updates `AliasTable(Weight).fillU32Checked` to validate
  output/population, preserve empty-output and constant-index behavior, and fill
  u32 indexes directly through facade `Rng`.
- `AliasTable(Weight).fillU32CheckedFrom` remains unchanged for explicit
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
readmecheck ok
roadmapcheck ok
apicheck ok
examplecheck ok
```

## Result

S4-M1067 is closed for the current bar: reusable `AliasTable(Weight).fillU32Checked`
now avoids the direct-source wrapper alias while preserving stream shape,
population validation, zero-length behavior, and single-positive behavior. This
is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
