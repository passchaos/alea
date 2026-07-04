# S4-M22 Reproducible Streams Adoption Example

Date: 2026-07-04

Purpose: add runnable adoption guidance for deterministic seeding, named streams,
engine aliases, split/jump operations, and stream-selectable reproducible engines.

## Change

Added `examples/reproducible_streams.zig` and build step:

```sh
zig build run-reproducible-streams
```

The example demonstrates:

- `Seed.fromString`, `Seed.mix`, and `Seed.stream` for stable named substreams;
- engine aliases `DefaultPrng`, `FastPrng`, `ScalarPrng`, `ReproduciblePrng`, and
  `SecurePrng` via root constructors;
- `secureFromSeed` as a deterministic secure-style stream for reproducible
  demos/tests;
- `Xoshiro256.split` reproducibility;
- `Xoshiro256PlusPlus.jump`;
- `Pcg64.initTwo(seed, stream)` stream selection.

It prints deterministic streams and a short decision guide for selecting engines
by workload and reproducibility contract.

## Validation

Command:

```sh
zig build run-reproducible-streams
```

Result: passed and printed deterministic seed/stream/engine outputs.

`zig build examples` includes this example, so `zig build validate` covers it
through the examples validation gate added in S4-M15.

## S4-M22 Decision

S4-M22 is closed for the current reproducible-stream adoption bar: users now have
runnable guidance for stable named streams and engine selection in addition to
API docs, reproducibility snapshots, and `repro` tooling.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
