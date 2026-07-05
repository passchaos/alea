# S4-M278 Root RngReader Aliases

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout exposes `RngReader` at the crate root in
`~/Work/rand/src/lib.rs`:

- `pub struct RngReader<R: TryRng>(pub R);`

Alea already had the Zig-native adapter as `Rng.RngReader(Source)` plus
`Rng.rngReader(source, buffer)`, requiring an explicit caller-owned buffer to fit
Zig 0.16 `std.Io.Reader` usage. The remaining gap was root-level discovery.

## Alea Change

Alea now provides root aliases:

```zig
pub fn RngReader(comptime Source: type) type { ... }
pub fn rngReader(source: anytype, buffer: []u8) RngReader(@TypeOf(source)) { ... }
```

They forward to `Rng.RngReader(Source)` and `Rng.rngReader`, preserving explicit
buffer ownership, value-source ownership, pointer-source borrowing, fallible
source `lastError()` diagnostics, and byte stream shape.

## Tests and Validation

Focused test coverage in `src/root.zig`:

- `root RngReader aliases mirror Rng namespace adapter` verifies type equality,
  byte stream equality against `Rng.rngReader`, and matching source advancement
  using the local-Rust-shaped `StepRng(255, 1)` byte stream.

Documentation/evidence updates:

- `README.md`, `docs/core-guide.md`, and `docs/api-reference.md` document the
  root aliases.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M279.

Validation commands for this milestone:

```sh
zig fmt src/root.zig tools/roadmapcheck.zig
zig test src/root.zig --test-filter "root RngReader"
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```

## Non-Completion Note

This milestone closes an unblocked local Rust root discovery gap only. It does
not resolve S4-M11's exact/default-compatible dense SIMD normal/exponential
blocker, does not add a new architecture/runtime runner, and is not whole-goal
completion evidence.
