# S4-M1167 Weighted Sampler Clone and Equality Helpers

## Gap

After S4-M1166 refreshed `validate-all`, the next weighted-sampler audit found a
small ergonomics/reproducibility gap against local Rust weighted samplers:
`rand::distr::weighted::WeightedIndex` derives `Clone` and `PartialEq`, and
`rand_distr::weighted::WeightedTreeIndex` derives `Clone`, `Default`, `Debug`, and
`PartialEq`.

Alea intentionally does not copy Rust's trait surface, but explicit Zig-native
`clone` and `eql` helpers are useful for the same workflows: snapshot a reusable
weighted sampler, compare dynamic update state, and verify failed updates leave a
sampler unchanged.

## Local Rust baseline

Local Rust source evidence:

```text
$ rg -n "derive|pub struct WeightedIndex|pub struct WeightedTreeIndex" ~/Work/rand/src/distr/weighted/weighted_index.rs ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/weighted/weighted_tree.rs
~/Work/rand/src/distr/weighted/weighted_index.rs:79:#[derive(Debug, Clone, PartialEq)]
~/Work/rand/src/distr/weighted/weighted_index.rs:81:pub struct WeightedIndex<X: SampleUniform + PartialOrd> {
~/.cargo/registry/src/.../weighted_tree.rs:89:#[derive(Clone, Default, Debug, PartialEq)]
~/.cargo/registry/src/.../weighted_tree.rs:90:pub struct WeightedTreeIndex<...> {
```

`WeightedAliasIndex` does not derive `Clone`/`PartialEq` in the cached
`rand_distr 0.6.0` source, but Alea's `AliasTable(Weight)` is also the local
`WeightedIndex(Weight)` implementation, so the helper belongs there as the
Rust-discoverable `WeightedIndex` alias surface.

## Implementation

- `AliasTable(Weight)` / `WeightedIndex(Weight)` now expose:
  - `clone(allocator) !Self`, which deep-copies probability, threshold, alias,
    weight, total, and diagnostic state;
  - `eql(other) bool`, which compares table internals and diagnostics.
- `WeightedTree(Weight)` and `WeightedIntTree(Weight)` now expose:
  - `clone(allocator) !Self`, which deep-copies subtotals and diagnostic state;
  - `eql(other) bool`, which compares subtotals, positive count, and single
    positive index.
- Focused tests verify clones compare equal, diverge after mutating the clone,
  preserve the original sampler state, and propagate allocation failure without
  leaking.
- API reference, core guide, and parity matrix now document the new helpers.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "weighted samplers clone"
1/1 distributions.test.weighted samplers clone and equality mirror local Rust derives...OK
All 1 tests passed.

$ zig test src/distributions.zig --test-filter "weighted"
1/118 distributions.test.weighted samplers clone and equality mirror local Rust derives...OK
...
118/118 seq.test.sampleIteratorWeightedArray returns fixed-size weighted iterator samples...OK
All 118 tests passed.
```

## Full validation

```text
$ git diff --check

$ zig build roadmapcheck
roadmapcheck ok

$ zig build toolingcheck
toolingcheck ok

$ zig build rand-status
Alea local rand/rand_distr status (2026-07-10)
- Current conclusion: S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1167 follow-ups closed for current bar
- Next bar: S4-M1168 post-S4-M1167 exact/default dense SIMD, broader runtime, or new local Rust gap

$ zig build rand-status-json
  "current_conclusion": "S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1167 follow-ups closed for current bar",
  "remaining_blocker": "S4-M1168 post-S4-M1167 next product bar",
  "latest_validate_local_evidence": "compare/results/s4-m1167-weighted-sampler-clone-eql.md"

$ zig build rand-status-schema-version
1

$ zig build rand-status-self-test
rand-status self-test ok

$ zig build validate-local
apicheck ok
toolingcheck ok
roadmapcheck ok
readmecheck ok
examplecheck ok
statcheck ok
distcheck ok
rand_bench_smoke self-test ok
rand_distr standard-normal: 56.5 M samples/s checksum=-3.640
rand_distr standard-normal f32: 54.2 M samples/s checksum=-3.640
runtimecheck ok: no additional runtime runner available
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok

$ zig build test
readmecheck ok
toolingcheck ok
apicheck ok
examplecheck ok
roadmapcheck ok
```

## Result

S4-M1167 is closed for the current bar: Alea's reusable weighted samplers now
have explicit Zig-native clone/equality helpers covering the local Rust
`Clone`/`PartialEq` weighted-sampler workflow. This is not whole-goal completion;
S4-M1168 remains active.
