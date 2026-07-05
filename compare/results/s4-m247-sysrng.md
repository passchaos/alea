# S4-M247 SysRng System Entropy Source

Date: 2026-07-05

## Local Rust Baseline

The local Rust `rand` re-exports `getrandom::SysRng` as
`rand::rngs::SysRng` when the `sys_rng` feature is enabled:

- `~/Work/rand/src/rngs/mod.rs` contains
  `pub use getrandom::{Error as SysError, SysRng};`.
- cached `getrandom-0.4.3/src/sys_rng.rs` defines `pub struct SysRng;` and
  implements `TryRng` with `try_next_u32`, `try_next_u64`, and
  `try_fill_bytes` forwarding to the system random source.
- local `getrandom-0.4.3/tests/sys_rng.rs` smoke-tests construction and two
  `try_next_u64` calls.

This is distinct from `rand::make_rng`: `make_rng` constructs deterministic
engines from system entropy, while `SysRng` is itself a fallible source over the
OS preferred random source and can be passed to `RngReader` or
`SeedableRng::try_from_rng`.

## Alea Change

Alea now provides a Zig-native system entropy RNG source:

- `Rng.SysRng.init(io)` stores an explicit `std.Io` handle.
- Root `sysRng(io)` and root alias `SysRng` mirror the Rust-discoverable name
  without hiding the Zig `std.Io` dependency.
- `SysRng.tryFillBytes(out)` forwards to `std.Io.randomSecure`.
- `SysRng.tryNextU64()` and `tryNextU32()` fill fixed byte arrays and read
  little-endian scalar words from those bytes on Alea's explicit byte policy,
  matching the local x86_64 getrandom scalar-on-fill source shape while keeping
  cross-target byte interpretation documented.
- `SysRng.tryNext()` aliases `tryNextU64()` so it can seed existing Alea
  `tryFromRng` constructors.
- `SysRng.reader(buffer)` uses the S4-M246 `RngReader` adapter, allowing
  `std.Io.Reader` workflows over system entropy.

## Tests and Validation

Focused tests added:

- `src/rng.zig`: `sys rng source uses Io entropy and propagates failures`
  covers native `tryFillBytes`, `tryNextU64`, `tryNextU32`, direct-source
  `Rng.tryFillBytesFrom`, `SysRng.reader`, and deterministic failure
  propagation with `std.Io.failing` through scalar, fill, direct-source, and
  reader paths.
- `src/root.zig`: `root sysRng exposes system entropy source` covers root
  `sysRng(io)` and root `SysRng` alias smoke paths.

Documentation and audit updates:

- `README.md` lists the `Rng.SysRng` / `sysRng(io)` system-entropy source.
- `docs/core-guide.md` explains when to use it versus `makeRng`.
- `docs/api-reference.md` lists root and `Rng` public symbols.
- `compare/results/reproducibility-matrix.md` records `SysRng` / `sysRng` as
  non-stable system entropy.
- `compare/results/core-rand-coverage.md`,
  `active-goal-completion-audit.md`, `linux-no-known-gaps-audit.md`, and
  `tools/roadmapcheck.zig` advance the living roadmap to S4-M248.

Validation commands for this milestone:

```sh
zig test src/rng.zig --test-filter "sys rng source"
zig test src/root.zig --test-filter "root sysRng"
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
```
