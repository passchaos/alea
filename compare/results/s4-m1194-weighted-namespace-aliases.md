# S4-M1194 Weighted Namespace Alias Refresh

## Gap

Alea already exposed `distributions.weighted.WeightedIndex(Weight)` for the
local `rand::distr::weighted` namespace, but cached local `rand_distr 0.6.0`
also exposes weighted samplers under `rand_distr::weighted::*`, including
`WeightedAliasIndex` and `WeightedTreeIndex`. Alea's concrete samplers existed
as `AliasTable(Weight)`, `WeightedTree(Weight)`, and `WeightedIntTree(Weight)`,
but the nested `distributions.weighted` discovery namespace did not yet include
those local `rand_distr::weighted` names.

## Change

`distributions.weighted` now exposes Zig-native aliases:

- `WeightedAliasIndex(Weight)` -> `AliasTable(Weight)`
- `WeightedTreeIndex(Weight)` -> `WeightedTree(Weight)`
- `WeightedIntTreeIndex(Weight)` -> `WeightedIntTree(Weight)`

Focused tests construct all three aliases and verify the expected typed total
and count diagnostics, including the dynamic tree typed total helpers from
S4-M1189.

## Validation

```text
$ zig test src/distributions.zig --test-filter "weighted namespace"
1/3 distributions.test.weighted namespace mirrors Rust weighted module discovery names...OK
2/3 distributions.test.weighted namespace exposes rand_distr weighted sampler aliases...OK
3/3 root.test_0...OK
All 3 tests passed.
```

Repository validation while closing this bar:

```text
$ zig test src/distributions.zig --test-filter "weighted"
All 128 tests passed.

$ zig build rand-status-self-test
rand-status self-test ok

$ zig build roadmapcheck
roadmapcheck ok

$ zig build toolingcheck
toolingcheck ok

$ git diff --check
(no output)


$ zig build validate-all
roadmapcheck ok
apicheck ok
toolingcheck ok
readmecheck ok
examplecheck ok
statcheck ok
distcheck ok
profilecheck ok
profiletailcheck ok
profilestresscheck ok
profilelongcheck ok

$ zig build validate-local
rand_distr standard-normal: 42.8 M samples/s checksum=-3.640
rand_distr standard-normal f32: 38.7 M samples/s checksum=-3.640
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
runtimecheck ok: no additional runtime runner available
apicheck ok
toolingcheck ok
readmecheck ok
examplecheck ok
statcheck ok
distcheck ok
profilecheck ok
rand-status self-test ok
```

## Result

S4-M1194 is closed for the current bar: the weighted namespace now maps local
`rand_distr::weighted::WeightedAliasIndex` and `WeightedTreeIndex` discovery
names onto Alea's concrete weighted samplers while keeping Zig-native APIs. This
is public-surface ergonomics evidence, not whole-goal completion; S4-M1195
remains active.
