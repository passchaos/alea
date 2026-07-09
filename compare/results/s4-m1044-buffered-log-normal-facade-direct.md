# S4-M1044 BufferedLogNormal Facade Direct Paths

## Gap

Stateful reusable `BufferedLogNormal(T, buffer_len)` facade `sample` / `fill`
still routed refills through `sampleFrom` / `fillFrom`. The facade-level
log-normal fill helper already drives facade `Rng` directly and preserves the
explicit refill stream contract, so the buffered facade can refill through facade
helpers directly while keeping its buffer semantics.

## Local `rand` / `rand_distr` Baseline

The local `rand` checkout remains the primary baseline. Alea's buffered
LogNormal sampler is an explicit Zig-native refill-contract sampler, but it still
follows the reusable-sampler rule: facade helpers should drive the supplied
facade RNG directly and avoid avoidable wrapper hops while preserving documented
stream shape.

## Implementation

- `src/distributions.zig` updates `BufferedLogNormal.sample` to refill its
  internal buffer via `fillLogNormal(rng, ...)` directly when empty.
- `src/distributions.zig` updates `BufferedLogNormal.fill` to drain buffered
  values, fill full chunks via facade `fillLogNormal`, and refill the internal
  buffer directly for the tail.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows.

## Validation

Focused buffered LogNormal test:

```text
$ zig test src/distributions.zig --test-filter "buffered log-normal sampler has explicit refill stream contract"
1/2 distributions.test.buffered log-normal sampler has explicit refill stream contract...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
roadmapcheck ok
apicheck ok
toolingcheck ok
readmecheck ok
examplecheck ok
```

## Result

S4-M1044 is closed for the current bar: stateful reusable BufferedLogNormal
facade sample/fill helpers now avoid direct-source wrapper aliases while
preserving the explicit refill stream contract and degenerate no-consume behavior.
This is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
