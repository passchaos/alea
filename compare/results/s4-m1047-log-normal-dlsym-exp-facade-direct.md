# S4-M1047 LogNormalDlsymExp Facade Direct Paths

## Gap

Stateful reusable `LogNormalDlsymExp(T, buffer_len)` facade `sample` / `fill`
still routed refills through `sampleFrom` / `fillFrom`. The sampler already has a
single `refill` routine that can draw normals from any source and apply the
runtime-loaded scalar-libm exponential mapping; facade methods can call
`refill(rng, ...)` directly while preserving availability checks and buffer
semantics.

## Local `rand` / `rand_distr` Baseline

The local `rand` checkout remains the primary baseline. Alea's dlsym/libm
LogNormal sampler is an explicit opt-in profile, but it still follows the
reusable-sampler contract: facade helpers should drive the supplied facade RNG
directly and avoid avoidable wrapper hops while preserving documented
availability and stream semantics.

## Implementation

- `src/distributions.zig` updates `LogNormalDlsymExp.sample` to refill its
  internal buffer via `self.refill(rng, ...)` directly when empty.
- `src/distributions.zig` updates `LogNormalDlsymExp.fill` to drain buffered
  values, fill full chunks via facade `Rng`, and refill the internal buffer
  directly for the tail.
- Direct-source `sampleFrom` / `fillFrom` and runtime availability behavior remain
  unchanged.

## Validation

Focused dlsym/libm LogNormal test:

```text
$ zig test src/distributions.zig --test-filter "dlsym exp log-normal opt-in loads explicitly when available"
1/2 distributions.test.dlsym exp log-normal opt-in loads explicitly when available...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
readmecheck ok
roadmapcheck ok
apicheck ok
toolingcheck ok
examplecheck ok
```

## Result

S4-M1047 is closed for the current bar: stateful reusable LogNormalDlsymExp
facade sample/fill helpers now avoid direct-source wrapper aliases while
preserving runtime availability checks, buffer semantics, and degenerate
no-consume behavior. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
