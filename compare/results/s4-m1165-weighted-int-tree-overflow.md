# S4-M1165 WeightedIntTree Overflow Diagnostics

## Gap

S4-M1164 aligned dynamic weighted-tree zero-total checked sampling errors with
local `rand_distr::weighted::WeightedTreeIndex::try_sample`. A follow-up audit of
local `rand_distr::WeightedTreeIndex` integer overflow behavior found that
integer total-weight overflow is reported as `Error::Overflow`, not
`Error::InvalidWeight`.

Alea's `WeightedIntTree(Weight)` already stores unsigned integer subtotals in a
`u64` accumulator and preserves failed-update state, but several total-overflow
paths returned `error.InvalidWeight`. That conflated two local Rust weighted
error variants: a weight value that cannot be represented by Alea's `u64`
accumulator remains `InvalidWeight`, while an otherwise valid sequence/update
whose summed total overflows should report `Overflow`.

## Local Rust baseline

Cached `rand_distr 0.6.0` source builds `WeightedTreeIndex` by checked-adding
child subtotals and maps addition failure to `Error::Overflow`:

```text
$ sed -n '112,123p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/weighted/weighted_tree.rs
        let n = subtotals.len();
        for i in (1..n).rev() {
            let w = subtotals[i].clone();
            let parent = (i - 1) / 2;
            subtotals[parent]
                .checked_add_assign(&w)
                .map_err(|()| Error::Overflow)?;
        }
```

The same file maps `push` and increasing `update` overflow to
`Error::Overflow`:

```text
$ sed -n '176,184p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/weighted/weighted_tree.rs
        if let Some(total) = self.subtotals.first() {
            let mut total = total.clone();
            if total.checked_add_assign(&weight).is_err() {
                return Err(Error::Overflow);
            }
        }

$ sed -n '203,210p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/weighted/weighted_tree.rs
            if let Some(total) = self.subtotals.first() {
                let mut total = total.clone();
                if total.checked_add_assign(&difference).is_err() {
                    return Err(Error::Overflow);
                }
            }
```

Focused local cargo probe results:

```text
new_u64_max_plus_one: err Overflow
push_overflow: err Overflow
update_overflow: err Overflow
update_ok: ok ()
```

## Implementation

- `WeightedIntTree(Weight).init`, `initByIndex`, and `initBy` now return
  `error.Overflow` when summing otherwise representable unsigned weights would
  overflow the `u64` subtotal accumulator.
- `WeightedIntTree.push`, increasing `update`, `updateMany`, `updateAll`,
  `updateAllByIndex`, and `updateAllBy` now preserve the previous tree state and
  return `error.Overflow` when the total would overflow.
- Values from integer weight types wider than `u64` that do not fit the Alea
  accumulator still return `error.InvalidWeight`, preserving the existing
  representability diagnostic distinct from summation overflow.
- Sampling zero-total behavior from S4-M1164 remains unchanged:
  `InsufficientNonZero` for checked sampling-style zero-total paths and
  `InvalidWeight` for probability/export diagnostics.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "weighted int tree"
1/6 distributions.test.weighted int tree supports dynamic updates...OK
2/6 distributions.test.weighted int tree updateMany applies ordered partial updates atomically...OK
3/6 distributions.test.weighted int tree updateWeights alias mirrors updateMany...OK
4/6 distributions.test.weighted int tree push allocation failure preserves tree...OK
5/6 distributions.test.zero-length weighted int tree fills do not validate or consume random stream...OK
6/6 root.test_0...OK
All 6 tests passed.

$ zig test src/distributions.zig --test-filter "weighted tree init failures"
1/1 distributions.test.weighted tree init failures clean up...OK
All 1 tests passed.

$ zig test src/distributions.zig --test-filter "weighted tree index accessor failures"
1/1 distributions.test.weighted tree index accessor failures preserve trees...OK
All 1 tests passed.

$ zig test src/distributions.zig --test-filter "weighted tree item accessor failures"
1/1 distributions.test.weighted tree item accessor failures preserve trees...OK
All 1 tests passed.
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
- Current conclusion: S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1165 follow-ups closed for current bar
- Next bar: S4-M1166 post-S4-M1165 exact/default dense SIMD, broader runtime, or new local Rust gap

$ zig build rand-status-json
  "current_conclusion": "S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1165 follow-ups closed for current bar",
  "remaining_blocker": "S4-M1166 post-S4-M1165 next product bar",
  "latest_validate_local_evidence": "compare/results/s4-m1165-weighted-int-tree-overflow.md"

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
rand_distr standard-normal: 38.6 M samples/s checksum=-3.640
rand_distr standard-normal f32: 37.0 M samples/s checksum=-3.640

$ zig build test
readmecheck ok
roadmapcheck ok
toolingcheck ok
examplecheck ok
apicheck ok

$ zig build rand-status -- --json
  "remaining_blocker": "S4-M1166 post-S4-M1165 next product bar",
  "latest_validate_local_evidence": "compare/results/s4-m1165-weighted-int-tree-overflow.md"

$ zig build rand-status -- --schema-version
1

$ zig build rand-status -- --self-test
rand-status self-test ok
```

## Result

S4-M1165 is closed for the current bar: `WeightedIntTree(Weight)` now matches
local `rand_distr::WeightedTreeIndex` integer total-overflow diagnostics while
preserving Alea's wider-than-`u64` `InvalidWeight` representability check. This
is not whole-goal completion; S4-M1166 remains active.
