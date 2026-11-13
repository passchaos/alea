# S4-M1282 — WASI report restoration and post-feature cross-target validation

## Goal

Refresh cross-target evidence after the Bingham/copula/matrix-normal/matrix-t/CDF
additions, and fix any portability regressions found by the WASI report path.

## Finding

`zig build wasi-report` failed to compile `tools/distcheck.zig` for
`wasm32-wasi-musl`:

```
error: type 'void' does not support struct initialization syntax
  std/heap/PageAllocator.zig:135:10
```

`checkMultivariateNormal` used `std.heap.smp_allocator` unconditionally. On
`wasm32-wasi` that allocator resolves to the page allocator, which is not
available for this target. The WASI branch of `distcheck` still analyzes the
function through `runChecks`, so the report could not compile.

## Fix

`tools/distcheck.zig` now selects the allocator per target:

```zig
const allocator = if (builtin.target.os.tag == .wasi)
    std.heap.wasm_allocator
else
    std.heap.smp_allocator;
```

This preserves the native `smp_allocator` path and uses the WASI allocator on
`wasm32-wasi`.

## Validation

- `zig build wasi-report` passes and ends with `profilelongcheck ok`; the
  report executes repro, statcheck, distcheck, profilecheck,
  profiletailcheck, profilestresscheck, and profilelongcheck through Node's
  WASI runtime.
- `zig build crosscheck` passes for `wasm32-wasi`, `aarch64-linux`,
  `riscv64-linux`, `x86_64-windows`, `x86_64-macos`, and `aarch64-macos`.
- `zig build test-wasi` passes, so the new Bingham/copula/matrix/CDF unit tests
  compile and run under WASI.
- `zig build validate` passes all native gates.
- `zig build test` passes 826/826 tests with all documentation gates.

## Tests added

No new unit tests; this milestone restores and refreshes existing cross-target
and WASI validation evidence. The allocator fix is covered by the `wasi-report`
compile/runtime path itself.

## Notes

- The native `distcheck` behavior is unchanged; only the WASI allocator
  selection changed.
- The `wasi-report` output includes the accepted vector-profile long sweep,
  which now runs after the new distribution code is linked into the WASI
  build.
- This milestone is a validation/portability refresh rather than a new
  distribution feature.

## Next bar

Matrix von Mises-Fisher, Kent distribution, vector/SIMD copula/Bingham sampling,
longer statistical validation runs, or newly discovered core gaps against local
Rust `rand` / `rand_distr` evidence.
