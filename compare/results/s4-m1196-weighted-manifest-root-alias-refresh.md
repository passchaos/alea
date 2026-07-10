# S4-M1196 Weighted Manifest Root-Alias Refresh

## Gap

S4-M1195 added root and prelude weighted sampler aliases (`WeightedIndex`,
`WeightedAliasIndex`, `WeightedTreeIndex`, and `WeightedIntTreeIndex`). The local
`rand` public-surface manifest still described weighted sampler coverage through
`WeightedIndex`, `AliasTable`, and `distributions.weighted.WeightedIndex`, but
did not explicitly cite the new root/prelude direct sampler aliases.

## Change

`compare/results/s4-m288-local-rand-public-surface-manifest.md` now records that
local Rust weighted sampler discovery is covered by root/prelude `WeightedIndex`
and root/prelude weighted sampler aliases in addition to the distribution
namespace and concrete samplers. The weighted row now cites S4-M1195 evidence.

## Validation

```text
$ zig build roadmapcheck
roadmapcheck ok

$ zig build toolingcheck
toolingcheck ok

$ zig build rand-status-self-test
rand-status self-test ok

$ git diff --check
(no output)
```

## Result

S4-M1196 is closed for the current bar: the local `rand` public-surface manifest
now reflects the root/prelude weighted sampler aliases added in S4-M1195. This
is public-surface evidence refresh, not whole-goal completion; S4-M1197 remains
active.
