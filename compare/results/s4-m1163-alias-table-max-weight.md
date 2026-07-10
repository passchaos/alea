# S4-M1163 AliasTable Per-Weight Maximum Compatibility

## Gap

S4-M1162 aligned tiny-shape `Beta` and all-small `Dirichlet` sampling with local
`rand_distr`. A follow-up weighted-sampler audit found that local
`rand_distr::weighted::WeightedAliasIndex::new(weights)` rejects any individual
weight larger than `W::MAX / weights.len()`. This guard happens before alias
construction because the local implementation scales each weight by `n` while
building `no_alias_odds`.

Alea's `AliasTable(Weight)` already rejected non-finite/negative weights and
floating-point total overflow, but it accepted some individual weights that
local `rand_distr` rejects, such as `[f64::MAX * 0.75, 1.0]` for length 2.
S4-M1163 adds the same per-weight maximum validation while preserving valid
maximum-boundary cases.

## Local Rust baseline

Cached `rand_distr 0.6.0` source:

```text
$ sed -n '93,116p' ~/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src/weighted/weighted_alias.rs
    pub fn new(weights: Vec<W>) -> Result<Self, Error> {
        let n = weights.len();
        if n == 0 || n > u32::MAX as usize {
            return Err(Error::InvalidInput);
        }
        let n = n as u32;

        let max_weight_size = W::try_from_u32_lossy(n)
            .map(|n| W::MAX / n)
            .unwrap_or(W::ZERO);
        if !weights
            .iter()
            .all(|&w| W::ZERO <= w && w <= max_weight_size)
        {
            return Err(Error::InvalidWeight);
        }
```

Focused local cargo probe results:

```text
f64 single_max: ok weights=[1.7976931348623157e308]
f64 two_half: ok weights=[8.988465674311579e307, 8.988465674311579e307]
f64 two_over_half: err InvalidWeight
f64 two_max: err InvalidWeight
f64 two_small: ok weights=[1.0, 2.0]
f64 nan: err InvalidWeight
f64 inf: err InvalidWeight
u32 single_max: ok weights=[4294967295]
u32 two_half: ok weights=[2147483647, 2147483647]
u32 two_over_half: err InvalidWeight
u32 two_max: err InvalidWeight
u32 two_small: ok weights=[1, 2]
```

## Implementation

- `AliasTable(Weight).init` / `new` now validate every individual input weight
  against `floatMax(Weight) / len` for floating weights and `maxInt(Weight) / len`
  for integer weights before scaling.
- `WeightedIndex(Weight)` inherits the same validation because it aliases
  `AliasTable(Weight)`.
- `AliasTable.updateAt`, `AliasTable.updateMany`, and `updateWeights` reject the
  same per-weight overflow before rebuilding the table, preserving the existing
  failed-update table state.
- Valid maximum-boundary tables remain accepted: a single maximum f64/u32 weight
  is valid, and two half-maximum weights are valid.
- Focused tests cover f64 and f32 floating weights, u32 integer weights,
  accepted max-boundary tables, rejected over-boundary construction, and rejected
  updateAt/updateMany without mutating the existing valid table.

## Focused validation

```text
$ zig test src/distributions.zig --test-filter "alias table per-weight"
1/1 distributions.test.alias table per-weight maximum matches local rand_distr...OK
All 1 tests passed.

$ zig test src/distributions.zig --test-filter "alias table"
1/20 distributions.test.alias table init allocation failure cleans up...OK
2/20 distributions.test.alias table samples valid indexes...OK
3/20 distributions.test.alias table per-weight maximum matches local rand_distr...OK
4/20 distributions.test.alias table u32 sampling helpers mirror usize helpers...OK
5/20 distributions.test.alias table owned index batches mirror fills...OK
6/20 distributions.test.alias table index aliases mirror sample helpers...OK
7/20 distributions.test.alias table iterators produce repeated indices...OK
8/20 distributions.test.alias table fixed index arrays mirror fills...OK
9/20 distributions.test.alias table index accessors initialize and update tables...OK
10/20 distributions.test.alias table item accessors initialize and update tables...OK
11/20 distributions.test.alias table exposes totals and reconstructs weights...OK
12/20 distributions.test.zero-length alias table fills do not consume random stream...OK
13/20 distributions.test.single-positive alias table does not consume random stream...OK
14/20 distributions.test.alias table update allocation failure preserves table...OK
15/20 distributions.test.alias table single-weight updateAt mirrors partial update diagnostics...OK
16/20 distributions.test.alias table updateAt allocation failure preserves table...OK
17/20 distributions.test.alias table updateMany applies ordered partial updates atomically...OK
18/20 distributions.test.alias table updateMany allocation failure preserves table...OK
19/20 distributions.test.alias table updateWeights alias mirrors updateMany...OK
20/20 root.test_0...OK
All 20 tests passed.
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
- Current conclusion: S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1163 follow-ups closed for current bar
- Next bar: S4-M1164 post-S4-M1163 exact/default dense SIMD, broader runtime, or new local Rust gap
$ zig build rand-status-json
  "latest_validate_local_evidence": "compare/results/s4-m1163-alias-table-max-weight.md"
$ zig build rand-status-schema-version
1
$ zig build rand-status-self-test
rand-status self-test ok
$ zig build validate-local
rand_distr standard-normal: 38.9 M samples/s checksum=-3.640
rand_distr standard-normal f32: 32.7 M samples/s checksum=-3.640
runtimecheck ok: no additional runtime runner available
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
rand_bench_smoke self-test ok
distcheck ok
statcheck ok
roadmapcheck ok
toolingcheck ok
apicheck ok
readmecheck ok
examplecheck ok
$ zig build test
apicheck ok
roadmapcheck ok
readmecheck ok
toolingcheck ok
examplecheck ok
```

## Result

S4-M1163 is closed for the current bar: `AliasTable(Weight)` and
`WeightedIndex(Weight)` now reject local `rand_distr::WeightedAliasIndex` style
per-weight overflow while preserving valid maximum-boundary tables and failed
update safety. This is not whole-goal completion; S4-M1164 remains active.
