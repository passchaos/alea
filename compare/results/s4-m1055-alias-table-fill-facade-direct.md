# S4-M1055 AliasTable Fill Facade Direct Path

## Gap

Reusable `AliasTable.fill` still routed through `fillFrom`. The direct-source
path already maps cached alias-table samples directly into output indexes; the
facade path can do the same through facade `Rng`, preserving zero-length and
single-positive no-consume behavior.

## Local `rand` / `rand_distr` Baseline

The local `rand` checkout remains the primary baseline. Alea's AliasTable surface
is broader than Rust's weighted-index APIs, but the reusable-sampler contract is
the same: facade helpers should drive the supplied facade RNG directly and avoid
avoidable wrapper hops.

## Implementation

- `src/distributions.zig` updates `AliasTable.fill` to return early for empty
  output, preserve constant-index no-consume behavior, and use the cached
  one-word or two-draw alias sampling loops directly through facade `Rng`.
- `AliasTable.fillFrom` remains unchanged for explicit direct-source workflows.

## Validation

Focused AliasTable tests:

```text
$ zig test src/distributions.zig --test-filter "alias table samples valid indexes"
1/2 distributions.test.alias table samples valid indexes...OK
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
readmecheck ok
toolingcheck ok
examplecheck ok
roadmapcheck ok
apicheck ok
```

## Result

S4-M1055 is closed for the current bar: reusable AliasTable facade fill now avoids
the direct-source wrapper alias while preserving stream shape, zero-length, and
single-positive no-consume behavior. This is reliability/ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
