# S4-M711 Distribution Choose Index Outputs

## Gap

Distribution-layer `Choose` now has owned/fixed value and pointer outputs. It
still lacked direct index-output helpers, requiring callers to use separate
`Rng.chooseIndex*` calls and manually keep lengths aligned with the sampler's
items.

Distribution-layer `Choose` should expose its own repeated index outputs matching
its item sampling stream policy.

## Local `rand` Baseline

The local Rust `rand` checkout exposes index-oriented slice sampling utilities in
addition to reference choices. Alea's distribution-layer `Choose(T)` can expose
index outputs directly, preserving a sampler-centric API for users who need
indexes and values from the same item set.

## API Added

`src/distributions.zig` adds usize index helpers to `Choose(T)`:

- `Choose(T).sampleIndex`
- `Choose(T).sampleIndexFrom`
- `Choose(T).fillIndices`
- `Choose(T).fillIndicesFrom`
- `Choose(T).indices`
- `Choose(T).indicesFrom`
- `Choose(T).indexArray`
- `Choose(T).indexArrayFrom`

`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- Index outputs use the same stream shape as the equivalent value/pointer choice
  over the sampler's item length.
- Singleton choices fill index outputs with zero without random-stream use.
- Owned/fixed/caller-owned shapes are available for repeated index output.

## Adoption and Documentation

- Focused distribution tests compare scalar index choice with `Rng.chooseIndex`,
  fixed index arrays against index fills, and owned index output against index
  fills. Singleton no-consumption behavior is also covered.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "distribution Choose sampler mirrors slice choices"
1/2 distributions.test.distribution Choose sampler mirrors slice choices...OK
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
examplecheck ok
apicheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M711 is closed for the current bar: distribution-layer `Choose` now has
scalar, caller-owned, owned, and fixed-size usize index outputs aligned with its
item sampling stream shape. This is ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
