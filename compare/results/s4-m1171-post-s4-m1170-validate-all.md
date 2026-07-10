# S4-M1171 Post-S4-M1170 Validate-All Refresh

## Gap

S4-M1170 added dynamic weighted-tree `trySample` / `trySampleFrom` aliases after
several weighted-sampler API updates. The next stricter bar was to refresh broad
portability-sensitive validation after those API changes instead of relying only
on focused native tests.

## Validation

```text
$ zig build validate-all
run_wasi_test self-test ok
practrand self-test ok
readmecheck ok
apicheck ok
statcheck ok
distcheck ok
toolingcheck ok
roadmapcheck ok
examplecheck ok
profilecheck ok
profiletailcheck ok
profilestresscheck ok
profilelongcheck ok
wasi sample.wasm --flag
runtimecheck ok: no additional runtime runner available
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
rand_bench_smoke self-test ok
rand-status self-test ok
Alea local rand/rand_distr status (2026-07-10)
- Current conclusion: S4-M11 runtime branch plus S4-M1124/S4-M1127-S4-M1171 follow-ups closed for current bar
- Next bar: S4-M1172 post-S4-M1171 exact/default dense SIMD, broader runtime, or new local Rust gap
rand_distr standard-normal: 41.9 M samples/s checksum=-3.640
rand_distr standard-normal f32: 39.2 M samples/s checksum=-3.640
```

The full output is long; the important coverage signals are native validation,
cross-target compile checks, Node WASI unit/dry/self-test coverage, the chained
WASI report, accepted profile checks through `profilelongcheck ok`, local Rust
surface checks, rand-bench smoke/parser checks, and updated `rand-status`
output.

## Result

S4-M1171 is closed for the current bar: the full `zig build validate-all`
aggregate passes after S4-M1170. This is broad validation evidence, not
whole-goal completion; S4-M1172 remains active.
