# S4-M1169 Weighted Tree New and Default Constructors

## Gap

After S4-M1168 added Zig-native formatter diagnostics for reusable weighted
samplers, the local Rust weighted-tree audit still showed one construction
workflow Alea did not expose directly:
`rand_distr::weighted::WeightedTreeIndex` has a Rust `new(...)` constructor and
also derives `Default`.

Local Rust source evidence:

```text
$ rg -n "derive|pub fn new|pub struct WeightedTreeIndex" ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/weighted/weighted_tree.rs
~/.cargo/registry/src/.../weighted_tree.rs:89:#[derive(Clone, Default, Debug, PartialEq)]
~/.cargo/registry/src/.../weighted_tree.rs:90:pub struct WeightedTreeIndex<...> {
~/.cargo/registry/src/.../weighted_tree.rs:104:    pub fn new<I>(weights: I) -> Result<Self, Error>
```

Alea keeps Zig-native allocation-explicit APIs instead of Rust traits, but the
same workflows are useful for dynamic weighted samplers: constructing through a
Rust-discoverable `new` alias and creating an empty/default tree that can later
be populated with `push`.

## Implementation

- `WeightedTree(Weight)` now exposes:
  - `new(allocator, weights)`, a Rust-discoverable alias for `init`;
  - `initEmpty(allocator)`, an allocation-free empty tree constructor;
  - `default(allocator)`, a Zig-native explicit-allocation analogue of local
    Rust `Default` for empty dynamic weighted trees.
- `WeightedIntTree(Weight)` exposes the same helpers for unsigned-integer
  dynamic weighted trees.
- Focused tests verify that `new` matches `init`, `initEmpty` matches
  `default`, empty/default trees match `init(..., &.{})`, empty/default trees
  report invalid sampling readiness, and pushed defaults transition to a valid
  single-positive tree.
- API reference, core guide, parity matrix, status output, and roadmap guards
  now record the S4-M1169 closure and raise the active product bar to S4-M1170.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "weighted tree default"
1/1 distributions.test.weighted tree default constructors mirror local Rust default...OK
All 1 tests passed.
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
examplecheck ok
readmecheck ok
roadmapcheck ok
toolingcheck ok
apicheck ok

$ zig build validate-local
runtimecheck ok: no additional runtime runner available
apicheck ok
examplecheck ok
toolingcheck ok
statcheck ok
profilecheck ok
distcheck ok
rand_bench_smoke self-test ok
5 passed; 0 failed
"current_conclusion": "S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1169 follow-ups closed for current bar"
"remaining_blocker": "S4-M1170 post-S4-M1169 next product bar"
"latest_validate_local_evidence": "compare/results/s4-m1169-weighted-tree-default.md"
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
rand-status self-test ok
rand_distr standard-normal: 59.9 M samples/s checksum=-3.640
rand_distr standard-normal f32: 55.9 M samples/s checksum=-3.640
```

## Result

S4-M1169 is closed for the current bar: Alea's dynamic weighted trees now cover
local Rust `WeightedTreeIndex::new` and `Default`-style construction through
Zig-native explicit-allocation helpers. This is not whole-goal completion;
S4-M1170 remains active.
