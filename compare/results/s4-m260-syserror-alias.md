# S4-M260 SysError Alias

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout re-exports the system-random error name beside
`SysRng` when the `sys_rng` feature is enabled:

- `~/Work/rand/src/rngs/mod.rs` contains
  `pub use getrandom::{Error as SysError, SysRng};`.

S4-M247 added Alea's explicit-I/O `SysRng` source and `SysRng.Error`, but the
root `SysError` discovery name was still missing.

## Alea Change

Alea now provides:

- `SysError = SysRng.Error` at the root.

This is an alias, not a new error model. It preserves the existing
`std.Io.RandomSecureError` / `SysRng.Error` contract while matching local Rust's
`rand::rngs::SysError` naming for users searching system-entropy APIs.

## Tests and Validation

Focused root tests verify:

- `SysError` is assignable as `SysRng.Error`;
- the existing root `sysRng(io)` and `SysRng.init(io)` smoke paths still work.

Documentation/evidence updates:

- `README.md`, `docs/core-guide.md`, and `docs/api-reference.md` document the
  alias alongside `SysRng`.
- `compare/results/reproducibility-matrix.md`,
  `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M261.

Validation commands for this milestone:

```sh
zig test src/root.zig --test-filter "root sysRng"
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```
