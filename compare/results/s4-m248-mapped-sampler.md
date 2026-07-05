# S4-M248 Mapped Sampler Adapter

Date: 2026-07-05

## Local Rust Baseline

The local `~/Work/rand/src/distr/distribution.rs` defines
`Distribution::map`, returning a `Map<D, F, T, S>` adapter that transforms
sampled values from one reusable distribution into another output type. The
local Rust tests demonstrate `Uniform::new_inclusive(0, 5).unwrap().map(...)`
and sample the transformed distribution.

This is an ergonomic reusable-sampler gap rather than a new distribution family:
callers can already sample and then transform manually, but Rust exposes a
composable adapter that keeps the transformation packaged with the sampler.

## Alea Change

Alea now provides a Zig-native mapped sampler adapter:

- `distributions.map(In, Out, sampler, mapper)` constructs a concrete
  `MappedSampler` without adding trait machinery.
- `MappedSampler.map(NextOut, mapper)` chains mappings.
- Mapper structs may expose `map`, `apply`, or `call`; each can be a static
  one-argument function or an instance two-argument method.
- The adapter exposes `sample`, `sampleFrom`, `fill`, and `fillFrom`, so it
  integrates with `Rng.sample`, `Rng.sampleFrom`, `Rng.sampleIterFrom`, and
  existing fill workflows.

## Tests and Validation

Focused test added in `src/distributions.zig`:

- `mapped samplers transform reusable sampler outputs` maps a reusable
  inclusive `Uniform(u8)` die to an even/odd bool, chains another mapping to an
  integer score, and verifies scalar direct-source, facade `Rng.sample`, fill,
  and `Rng.sampleIterFrom` workflows preserve the wrapped sampler's stream
  shape against manual mapping.

Documentation/example updates:

- `README.md` mentions reusable sampler `map` adapters.
- `docs/api-reference.md` lists `map`, `MappedSampler`, and nested public
  methods.
- `docs/core-guide.md` documents the Rust `Distribution::map` comparison.
- `examples/range_sampling.zig` demonstrates `mapped Uniform even die`, and
  `tools/examplecheck.zig` guards that adoption token.
- `compare/results/reproducibility-matrix.md` records mapped sampler stream
  shape evidence.

Validation commands for this milestone:

```sh
zig test src/distributions.zig --test-filter "mapped samplers"
zig build run-range-sampling
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
```
