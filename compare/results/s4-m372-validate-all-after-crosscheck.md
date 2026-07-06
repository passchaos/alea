# S4-M372 Validate-All After Crosscheck Fix

## Gap

S4-M371 fixed a real `zig build crosscheck` failure on the guarded
`wasm32-wasi` target caused by tests that tried to construct `u32.max + 1` as a
32-bit `usize`. After fixing those target-width assumptions, the broader
portability aggregate needed to be re-run so the roadmap had evidence that native
validation, cross-target compile checks, WASI execution, and the WASI report
chain all work together.

## Validation

Command executed from the repository root after S4-M371:

```text
$ zig build validate-all
```

Observed result: the command completed successfully.

The run covered the `validate-all` aggregate, including:

- native validation through `zig build validate`;
- `zig build crosscheck` for the guarded target set:
  - `wasm32-wasi`
  - `aarch64-linux`
  - `riscv64-linux`
  - `x86_64-windows`
  - `x86_64-macos`
  - `aarch64-macos`
- `zig build test-wasi` through Node's WASI runtime;
- `zig build wasi-report`, including the chained WASI repro/statcheck/distcheck
  and accepted vector profile checks.

Representative success tokens observed in the long output included:

- `toolingcheck ok`
- `examplecheck ok`
- `readmecheck ok`
- `apicheck ok`
- `roadmapcheck ok`
- `statcheck ok`
- `distcheck ok`
- `profilecheck ok`
- `profiletailcheck ok`
- `profilestresscheck ok`
- `profilelongcheck ok`

## Result

S4-M372 is closed for the current bar: after the wasm32 `usize` test fix, the
full native + cross-target + WASI aggregate passed. This is portability evidence
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
