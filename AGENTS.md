# AGENTS.md

## Project Mission

`alea` is a Zig 0.16 random-number library whose explicit goal is to surpass
Rust's `rand` in core random-number functionality, ergonomics, reproducibility,
statistical quality, and performance.

The target is not a one-for-one port of Rust ecosystem shapes. Do not copy
Rust-only mechanisms such as traits, serde integration, crate feature matrices,
or API forms that do not fit Zig. Instead, use Zig-native designs that exceed
`rand` where it matters for random-number work: deterministic and secure-style
engines, seeding and stream derivation, uniform and ranged sampling,
distributions, reusable samplers, sequence and collection sampling, string
generation, interoperability with `std.Random`, statistical validation, and
benchmarked throughput.

Use the local Rust `rand` checkout at `~/Work/rand` as the primary reference for
existing behavior, algorithms, tests, and benchmarks. Treat `rand` as the
baseline to study and exceed for core RNG functionality, not as a checklist of
ecosystem-specific abstractions to reproduce.

## Working Guidelines

- These guidelines apply to all code development in this repository, not only
  random-number algorithm work.
- Preserve idiomatic Zig APIs while keeping `std.Random` interoperability where
  it helps users adopt the library.
- Prefer Zig-native APIs over direct translations of Rust traits or ecosystem
  integration points.
- Prioritize completing and surpassing core random-number functionality before
  spending time on performance tuning, except where performance is part of the
  feature's basic viability.
- If a feature genuinely needs trait-like abstraction, evaluate the local
  `~/project-z/zigraft` library before inventing a custom abstraction. Do not
  introduce trait-like machinery just to mirror Rust's API shape.
- When implementing engines, distributions, samplers, or sequence utilities,
  compare against Rust `rand` and document meaningful deviations.
- Favor deterministic reproducibility: seed handling, named streams, and
  snapshot-sensitive behavior should be stable and well tested.
- Validate changes with focused tests and, for performance-sensitive paths,
  benchmarks against the local Rust `rand` checkout.
- After adding or changing functionality, run the relevant validation and create
  a git commit that saves the completed change.
- Keep the core library broad enough that common non-uniform distributions,
  reusable samplers, string generation, and collection sampling are available
  without forcing users into separate companion packages.
