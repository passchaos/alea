# S4-M1195 Root Weighted Sampler Aliases

## Gap

S4-M1194 added `distributions.weighted.*` aliases for local
`rand_distr::weighted` sampler discovery names. Root and prelude already exposed
weighted error aliases, but direct weighted sampler discovery still required
users to know the `distributions` namespace. Local Rust examples often import
weighted sampler names directly from prelude/module paths, so Alea's root and
prelude discovery surface should expose the main weighted sampler names too.

## Change

Root and prelude now expose:

- `WeightedIndex(Weight)`
- `WeightedAliasIndex(Weight)`
- `WeightedTreeIndex(Weight)`
- `WeightedIntTreeIndex(Weight)`

These are aliases over Alea's concrete weighted samplers and the nested
`distributions.weighted` aliases. Focused tests construct root and prelude
aliases and verify typed total diagnostics.

## Validation

```text
$ zig test src/root.zig --test-filter "root weighted sampler aliases"
1/2 root.test_0...OK
2/2 root.test.root weighted sampler aliases mirror distributions namespace...OK
All 2 tests passed.
```

Additional validation to run before closing this bar:

```text
zig test src/root.zig --test-filter "weighted"
zig build apicheck
zig build roadmapcheck
zig build toolingcheck
zig build rand-status-self-test
git diff --check
zig build validate-local
```

## Result

S4-M1195 is closed for the current bar: root and prelude now expose direct
weighted sampler aliases for local Rust weighted sampler discovery workflows.
This is public-surface ergonomics evidence, not whole-goal completion; S4-M1196
remains active.
