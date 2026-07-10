# S4-M1164 WeightedTree Zero-Total Sampling Errors

## Gap

After S4-M1163 aligned `AliasTable(Weight)` construction/update validation with
local `rand_distr::WeightedAliasIndex`, the next weighted-sampler audit found a
remaining diagnostic mismatch in dynamic weighted trees.

Local `rand_distr::weighted::WeightedTreeIndex::try_sample` returns
`Error::InsufficientNonZero` when the tree is empty or all weights are zero. Alea's
checked dynamic tree sampling-style APIs previously reported `error.InvalidWeight`
for the same zero-total state. That made all-zero dynamic tree sampling less
specific than local `rand_distr`, even though Alea already exposes
`error.InsufficientNonZero` for weighted samplers elsewhere.

## Local Rust baseline

Cached `rand_distr 0.6.0` source:

```text
$ sed -n '244,254p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/weighted/weighted_tree.rs
    pub fn try_sample<R: Rng + ?Sized>(&self, rng: &mut R) -> Result<usize, Error> {
        let total_weight = self.subtotals.first().cloned().unwrap_or(W::ZERO);
        if total_weight == W::ZERO {
            return Err(Error::InsufficientNonZero);
        }
        let mut target_weight = rng.random_range(W::ZERO..total_weight);
```

The same source documents that `Distribution::sample` panics for empty/all-zero
weighted trees because it unwraps `try_sample`, while `try_sample` itself uses
`InsufficientNonZero` for zero total.

## Implementation

- `WeightedTree(Weight)` now validates checked sampling totals through a shared
  `validateTreeSamplingTotal(total: f64)` helper.
  - `total == 0` returns `error.InsufficientNonZero`, matching local
    `WeightedTreeIndex::try_sample` for empty and all-zero trees.
  - non-positive/non-finite nonzero totals still return `error.InvalidWeight`,
    preserving Alea's diagnostic for invalid floating tree state.
- `WeightedIntTree(Weight)` checked sampling-style paths now return
  `error.InsufficientNonZero` for `total == 0`.
- Sampling-like checked paths are aligned consistently: single samples,
  `sampleIndex*` aliases, caller-owned fills, owned index batches, fixed index
  arrays, and checked iterators.
- Zero-length checked fills and owned batches still do not validate, allocate
  beyond the zero-sized result, or consume the random stream.
- Non-sampling diagnostics intentionally remain `error.InvalidWeight` on invalid
  zero-total trees: `probabilityAt` and `probabilitiesInto` are probability
  export/diagnostic APIs, not local `try_sample` equivalents.
- Owned checked batch helpers prevalidate nonzero requests before allocation,
  preserving the previous invalid-tree-before-OOM/no-consume behavior while
  returning the local `rand_distr`-compatible `InsufficientNonZero` error.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "weighted tree supports dynamic updates"
1/2 distributions.test.weighted tree supports dynamic updates...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "weighted int tree supports dynamic updates"
1/2 distributions.test.weighted int tree supports dynamic updates...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "weighted"
1/117 distributions.test.weighted tree init failures clean up...OK
...
117/117 seq.test.sampleIteratorWeightedArray returns fixed-size weighted iterator samples...OK
All 117 tests passed.
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
- Current conclusion: S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1164 follow-ups closed for current bar
- Next bar: S4-M1165 post-S4-M1164 exact/default dense SIMD, broader runtime, or new local Rust gap

$ zig build rand-status-json
  "current_conclusion": "S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1164 follow-ups closed for current bar",
  "remaining_blocker": "S4-M1165 post-S4-M1164 next product bar",
  "latest_validate_local_evidence": "compare/results/s4-m1164-weighted-tree-zero-total.md"

$ zig build rand-status-schema-version
1

$ zig build rand-status-self-test
rand-status self-test ok

$ zig build validate-local
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
apicheck ok
roadmapcheck ok
runtimecheck ok: no additional runtime runner available
statcheck ok
distcheck ok
rand-status self-test ok
rand_bench_smoke self-test ok
rand_distr standard-normal: 39.6 M samples/s checksum=-3.640
rand_distr standard-normal f32: 37.7 M samples/s checksum=-3.640

$ zig build test
readmecheck ok
roadmapcheck ok
toolingcheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M1164 is closed for the current bar: checked sampling-style
`WeightedTree(Weight)` and `WeightedIntTree(Weight)` APIs now match local
`rand_distr::WeightedTreeIndex::try_sample` zero-total diagnostics while keeping
Alea's probability diagnostics and invalid non-finite generic totals distinct.
This is not whole-goal completion; S4-M1165 remains active.
