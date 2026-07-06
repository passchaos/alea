# S4-M425 `rand-status` Status Printer

## Gap

S4-M420 added a current local `rand` / `rand_distr` comparison status snapshot,
and S4-M421..S4-M424 made it discoverable and guarded. There was still no quick
build-step command for printing the current status in the terminal.

## Change

- `tools/rand_status.zig` prints a concise current local `rand` / `rand_distr`
  status summary and the status-file path.
- `build.zig` wires `zig build rand-status`, running helper tests before the
  status printer.
- README and `docs/tooling.md` list the new command.
- `tools/readmecheck.zig` and `tools/toolingcheck.zig` guard the command,
  checked-in tool file, helper-test dependency shape, and documentation tokens.

## Validation

Observed status output:

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

Focused validation commands:

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

S4-M425 is closed for the current bar: `zig build rand-status` gives a fast
terminal summary of the current local Rust comparison status. This is tooling and
discoverability only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
