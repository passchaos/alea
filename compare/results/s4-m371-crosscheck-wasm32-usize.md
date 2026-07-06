# S4-M371 Crosscheck wasm32 `usize` Width Fix

## Gap

After S4-M369 documented and guarded the `zig build crosscheck` target set,
running the actual crosscheck exposed real portability failures on
`wasm32-wasi-musl`: several tests constructed `@as(usize, std.math.maxInt(u32)) +
1`, which cannot be represented when `usize` is 32 bits.

This was a test portability bug, not a product API change. The affected tests are
intended to validate `u32`-output rejection for lengths greater than `u32.max`, a
case only representable on targets where `usize` is wider than 32 bits.

## Change

`src/seq.zig` now gates those `u32.max + 1` test paths behind:

```zig
if (comptime @bitSizeOf(usize) > 32) { ... }
```

The guarded paths include:

- native `IndexVec` conversion to `u32` when an index exceeds `u32.max`;
- owned native-to-`u32` transfer rejection;
- index-weighted single, array, fill, batch, and no-replacement `u32` output
  invalid-length tests.

The runtime library behavior is unchanged. The tests still run on targets that
can represent the invalid length and no longer fail to compile on 32-bit `usize`
targets.

## Validation

Focused validation command:

```text
$ zig build crosscheck
```

Result: command completed successfully for the guarded target set:

- `wasm32-wasi`
- `aarch64-linux`
- `riscv64-linux`
- `x86_64-windows`
- `x86_64-macos`
- `aarch64-macos`

## Result

S4-M371 is closed for the current bar: cross-target compile coverage now passes
after making width-sensitive tests target-aware. This improves portability
evidence and does not resolve S4-M11 or constitute whole-goal completion.
