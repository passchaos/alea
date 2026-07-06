# S4-M427 Include `rand-status` In Validate-Local

## Gap

S4-M425 added `zig build rand-status`, but `zig build validate-local` did not run
it. Since `validate-local` is the local Rust comparison aggregate, it should also
exercise the quick current-status printer.

## Change

- `build.zig` makes `validate-local` depend on `rand_status_step`.
- README, core guide, API reference, and tooling docs now list `rand-status` in
  the local comparison aggregate prose.
- `tools/readmecheck.zig` and `tools/toolingcheck.zig` guard the expanded
  aggregate wording and dependency shape.

## Validation

Focused validation commands:

```text
$ zig build rand-status
Alea local rand/rand_distr status (2026-07-06)
- Baseline: ~/Work/rand plus cached rand_distr 0.6.0
- Latest gate: zig build validate-local passes
- Public surface: surfacecheck ok for rand/rand_core/rand_distr manifests
- Rust comparison: parser tests and rand-bench-smoke pass
- Runtime runners: node/cargo/rustc found; qemu/wine/wasmtime/wasmer not available
- Current conclusion: no known unblocked local Rust core RNG gap
- Remaining blocker: S4-M11 exact/default dense SIMD winner, new runtime, or new local Rust gap
- Details: compare/results/s4-m420-current-rand-status.md
```

```text
$ zig build toolingcheck
toolingcheck ok
```

```text
$ zig build readmecheck
readmecheck ok
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

## Result

S4-M427 is closed for the current bar: `validate-local` now includes the
current-status printer. This is local comparison validation ergonomics only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
