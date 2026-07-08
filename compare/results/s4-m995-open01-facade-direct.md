# S4-M995 Open01/OpenClosed01 Facade Direct Paths

## Gap

Reusable `Open01` and `OpenClosed01` facade sample/fill helpers still routed
through direct-source wrapper functions. These strict-interval samplers can
dispatch directly through facade `Rng` scalar/vector open and open-closed helpers
while preserving scalar/vector stream shape.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` exposes `Open01` and `OpenClosed01` distribution
samplers that sample from the supplied RNG reference. Alea's scalar/vector
strict-interval facade helpers should likewise use facade `Rng` directly instead
of bouncing through direct-source aliases.

## Implementation

- `src/distributions.zig` updates `Open01.sample` and `OpenClosed01.sample` to
  dispatch scalar floats through facade `rng.floatOpen` / `rng.floatOpenClosed`
  and vector floats through facade `rng.vectorOpen` / `rng.vectorOpenClosed`.
- `src/distributions.zig` updates `Open01.fill` and `OpenClosed01.fill` to
  dispatch scalar fills through facade `rng.fillOpen` / `rng.fillOpenClosed` and
  vector fills through facade `rng.fillVectorOpen` / `rng.fillVectorOpenClosed`.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows.

## Validation

Focused strict-interval tests:

```text
$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused with sample iterators"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
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
examplecheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M995 is closed for the current bar: scalar/vector `Open01` and `OpenClosed01`
facade sample/fill helpers now avoid direct-source wrapper aliases while
preserving strict-interval semantics and stream shape. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
