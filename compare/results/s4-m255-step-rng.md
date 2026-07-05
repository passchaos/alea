# S4-M255 StepRng Deterministic Mock Source

Date: 2026-07-05

## Local Rust Baseline

The local `~/Work/rand/src/lib.rs` test helpers define `StepRng(x, increment)`
and use it to validate `RngReader` byte streams. Cached historical `rand`
sources also expose `rand::rngs::mock::StepRng`, with `StepRng::new(initial,
increment)` yielding an arithmetic `u64` sequence via wrapping addition and
`fill_bytes` writing little-endian words.

Alea already had private ad-hoc step sources in tests, but no public
deterministic mock source that users could reuse for reproducible byte-shape
tests, examples, or adapter validation.

## Alea Change

Alea now provides:

- root `StepRng`;
- root `stepRng(initial, increment)`;
- root `constRng(value)`;
- `StepRng.init` / `new` / `constant` / `constRng`;
- raw helpers `next`, `nextU64`, `nextU32`, `tryNext`, `tryNextU64`,
  `tryNextU32`;
- byte helpers `fill`, `fillBytes`, and `tryFillBytes`;
- `random()` interop with `std.Random`;
- `fromSeedBytes([16]u8)` for `makeRng(StepRng, io)` compatibility.

The type is intentionally documented as a mock/test source, not a statistical
or secure engine.

## Tests and Validation

Focused tests in `src/engines/step.zig` cover:

- wrapping arithmetic sequence behavior;
- constant streams when increment is zero;
- `fromSeedBytes` initial/increment loading;
- local Rust `StepRng(255, 1)` little-endian byte shape;
- `std.Random` byte-stream interop.

Focused root tests cover:

- `stepRng` and `constRng` helpers mirror `StepRng` constructors;
- `makeRng(StepRng, io)` compiles and draws entropy for its 16-byte state.

Documentation/example updates:

- `examples/basic.zig` prints `StepRng bytes` and `constRng next`.
- `tools/examplecheck.zig` checks both tokens.
- `tools/apicheck.zig` now verifies `src/engines/step.zig` public symbols.
- `README.md`, `docs/core-guide.md`, `docs/api-reference.md`, and
  `docs/examples.md` document `StepRng`.
- `compare/results/distribution-parity-matrix.md`,
  `compare/results/reproducibility-matrix.md`,
  `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and
  `tools/roadmapcheck.zig` record the milestone and advance the next-gap row
  to S4-M256.

Validation commands for this milestone:

```sh
zig test src/engines/step.zig
zig test src/root.zig --test-filter "StepRng"
zig test src/root.zig --test-filter "makeRng"
zig build run-basic
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
```
