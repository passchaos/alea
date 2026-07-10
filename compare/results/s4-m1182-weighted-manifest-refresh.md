# S4-M1182 Weighted Manifest Typed-Diagnostics Refresh

## Gap

S4-M1180 added typed static weighted diagnostics for `AliasTable(Weight)` /
`WeightedIndex(Weight)`, and S4-M1181 refreshed the full `validate-all`
aggregate after that API change. The local Rust public-surface manifests still
needed an explicit refresh so future audits do not rediscover Rust
`WeightedIndex::weight`, `WeightedIndex::weights`, `WeightedIndex::total_weight`,
or `WeightedAliasIndex::weights` typed accessor workflows as open gaps.

## Local Rust Reference

```text
$ grep -n "pub fn weight\|pub fn weights\|pub fn total_weight" ~/Work/rand/src/distr/weighted/weighted_index.rs
308:    pub fn weight(&self, index: usize) -> Option<X>
342:    pub fn weights(&self) -> WeightedIndexIter<'_, X>
353:    pub fn total_weight(&self) -> X {

$ grep -n "pub fn weights" ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/weighted/weighted_alias.rs
244:    pub fn weights(&self) -> Vec<W> {
```

## Manifest Changes

- `compare/results/s4-m288-local-rand-public-surface-manifest.md` now maps the
  local Rust `WeightedIndex` typed `weight`, `weights`, and `total_weight`
  workflows to Alea `typedWeight*` / `weightValue*`, `typedWeights*` /
  `weightsValue*`, `typedTotalWeight` / `totalWeightValue`, and typed iterator
  diagnostics.
- `compare/results/s4-m294-rand-distr-public-surface-manifest.md` now maps
  `WeightedAliasIndex::weights` and the re-exported weighted `WeightedIndex`
  accessors to the same typed static weighted diagnostics.

## Validation

```text
$ zig build roadmapcheck
roadmapcheck ok

$ zig build toolingcheck
toolingcheck ok

$ zig build rand-status-self-test
rand-status self-test ok

$ zig build validate-local
rand_distr standard-normal: 41.2 M samples/s checksum=-3.640
rand_distr standard-normal f32: 38.6 M samples/s checksum=-3.640
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
rand_bench_smoke self-test ok
runtimecheck ok: no additional runtime runner available

$ git diff --check
```

## Result

S4-M1182 is closed for the current bar: the local Rust and `rand_distr` public
surface manifests now explicitly record the typed static weighted diagnostics
closure. This is audit/status evidence, not whole-goal completion; S4-M1183
remains active.
