# AGENTS.md

## Project Mission

`alea` is a Zig 0.16 random-number library whose explicit goal is to surpass
Rust's `rand` ecosystem in ergonomics, feature coverage, reproducibility,
statistical quality, and performance.

Use the local Rust `rand` checkout at `~/Work/rand` as the primary reference for
existing behavior, APIs, algorithms, tests, and benchmarks. Treat `rand` as the
baseline to study and exceed, not as a ceiling or a compatibility constraint.

## Working Guidelines

- These guidelines apply to all code development in this repository, not only
  random-number algorithm work.
- Preserve idiomatic Zig APIs while keeping `std.Random` interoperability where
  it helps users adopt the library.
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
