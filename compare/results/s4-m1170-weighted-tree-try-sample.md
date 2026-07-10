# S4-M1170 Weighted Tree trySample Aliases

## Gap

After S4-M1169 added dynamic weighted-tree `new` and empty/default constructors,
the local `rand_distr::WeightedTreeIndex` audit still had one naming workflow not
exposed directly in Alea: checked dynamic-tree sampling is named `try_sample` in
Rust.

Local Rust source evidence:

```text
$ rg -n "try_sample|sample\(" ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/weighted/weighted_tree.rs
~/.cargo/registry/src/.../weighted_tree.rs:248:    pub fn try_sample<R: Rng + ?Sized>(&self, rng: &mut R) -> Result<usize, Error> {
~/.cargo/registry/src/.../weighted_tree.rs:293:        self.try_sample(rng).unwrap()
```

Alea already had checked sampling (`sampleChecked` / `sampleCheckedFrom`) with
Zig-style error names and no-consume invalid paths. S4-M1170 adds the missing
Rust-discoverable checked-sampling spelling without changing stream shape.

## Implementation

- `WeightedTree(Weight)` now exposes:
  - `trySample(rng)` as an alias for `sampleChecked(rng)`;
  - `trySampleFrom(source)` as an alias for `sampleCheckedFrom(source)`.
- `WeightedIntTree(Weight)` exposes the same aliases for unsigned integer
  dynamic weighted trees.
- Focused tests verify facade and direct-source stream-shape parity with the
  existing checked methods and verify empty/default invalid paths return
  `InsufficientNonZero` without consuming the random stream.
- API reference, core guide, parity matrix, status output, and roadmap guards
  now record the S4-M1170 closure and raise the active product bar to S4-M1171.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "weighted tree trySample"
1/2 distributions.test.weighted tree trySample aliases mirror local Rust try_sample...OK
2/2 root.test_0...OK
All 2 tests passed.
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
roadmapcheck ok
readmecheck ok
examplecheck ok

$ zig build validate-local
apicheck ok
readmecheck ok
toolingcheck ok
examplecheck ok
roadmapcheck ok
statcheck ok
profilecheck ok
distcheck ok
runtimecheck ok: no additional runtime runner available
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
5 passed; 0 failed
"current_conclusion": "S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1170 follow-ups closed for current bar"
"remaining_blocker": "S4-M1171 post-S4-M1170 next product bar"
"latest_validate_local_evidence": "compare/results/s4-m1170-weighted-tree-try-sample.md"
rand_bench_smoke self-test ok
rand-status self-test ok
rand_distr standard-normal: 41.9 M samples/s checksum=-3.640
rand_distr standard-normal f32: 39.2 M samples/s checksum=-3.640
```

## Result

S4-M1170 is closed for the current bar: Alea's dynamic weighted trees now cover
local Rust `WeightedTreeIndex::try_sample` naming through Zig-native
`trySample` / `trySampleFrom` aliases while preserving checked sampling stream
shape. This is not whole-goal completion; S4-M1171 remains active.
