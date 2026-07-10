# S4-M1168 Weighted Sampler Format Helpers

## Gap

After S4-M1167 added explicit Zig-native `clone` / `eql` helpers for weighted
samplers, the same local Rust weighted-sampler audit still exposed one
remaining diagnostics ergonomics gap: local Rust weighted samplers provide
`Debug` output.

Local evidence:

```text
$ rg -n "derive|fmt::Debug|impl<.*Debug|pub struct WeightedIndex|pub struct WeightedTreeIndex" \
  ~/Work/rand/src/distr/weighted/weighted_index.rs \
  ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/weighted/weighted_alias.rs \
  ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/weighted/weighted_tree.rs
~/Work/rand/src/distr/weighted/weighted_index.rs:79:#[derive(Debug, Clone, PartialEq)]
~/.cargo/registry/src/.../weighted_alias.rs:284:impl<W: AliasableWeight> fmt::Debug for WeightedAliasIndex<W>
~/.cargo/registry/src/.../weighted_tree.rs:89:#[derive(Clone, Default, Debug, PartialEq)]
```

Alea does not import Rust trait shapes, but Zig-native formatter hooks are useful
for the same workflow: debugging a reusable weighted sampler state after
construction or dynamic updates.

## Implementation

- `AliasTable(Weight)` / `WeightedIndex(Weight)` now expose `format(self,
  writer)` for `std.Io.Writer.print("{f}", .{table})` diagnostics. The output
  includes length, total weight, positive-count/constant-index diagnostics,
  probability thresholds, alias table indexes, and reconstructed weights.
- `WeightedTree(Weight)` now exposes `format(self, writer)` for `{f}`
  diagnostics with length, total, positive-count/index diagnostics, and stored
  subtotals.
- `WeightedIntTree(Weight)` now exposes matching `{f}` diagnostics for unsigned
  integer dynamic weighted trees.
- The API reference, core guide, distribution parity matrix, roadmap/status
  snapshots, and status tooling now point at this S4-M1168 evidence.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "weighted samplers format"
1/1 distributions.test.weighted samplers format expose local Rust debug-style state...OK
All 1 tests passed.

$ zig test src/distributions.zig --test-filter "weighted"
1/119 distributions.test.weighted samplers clone and equality mirror local Rust derives...OK
2/119 distributions.test.weighted samplers format expose local Rust debug-style state...OK
...
119/119 seq.test.sampleIteratorWeightedArray returns fixed-size weighted iterator samples...OK
All 119 tests passed.
```

## Full validation

```text
$ git diff --check

$ zig build apicheck
apicheck ok

$ zig build roadmapcheck
roadmapcheck ok

$ zig build toolingcheck
toolingcheck ok

$ zig build rand-status-self-test
rand-status self-test ok

$ zig build test
apicheck ok
toolingcheck ok
examplecheck ok
roadmapcheck ok
readmecheck ok

$ zig build validate-local
practrand self-test ok
runtimecheck ok: no additional runtime runner available
readmecheck ok
toolingcheck ok
examplecheck ok
roadmapcheck ok
"current_conclusion": "S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1168 follow-ups closed for current bar"
"remaining_blocker": "S4-M1169 post-S4-M1168 next product bar"
"latest_validate_local_evidence": "compare/results/s4-m1168-weighted-sampler-format.md"
apicheck ok
5 passed; 0 failed
rand_bench_smoke self-test ok
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
distcheck ok
profilecheck ok
rand-status self-test ok
rand_distr standard-normal: 38.0 M samples/s checksum=-3.640
rand_distr standard-normal f32: 38.1 M samples/s checksum=-3.640
```

## Result

S4-M1168 is closed for the current bar: Alea's reusable weighted samplers now
have explicit Zig-native `{f}` formatter output covering the local Rust
`Debug` weighted-sampler diagnostics workflow. This is not whole-goal
completion; S4-M1169 remains active.
