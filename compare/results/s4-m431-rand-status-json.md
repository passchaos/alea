# S4-M431 `rand-status` JSON/Help Output

## Gap

`zig build rand-status` printed a human-readable status summary, but scripts had
no stable machine-readable output and users had no command-local help text.

## Change

`tools/rand_status.zig` now supports:

- default text output;
- `--json` for stable JSON status output;
- `--help` for command usage.

The tool has helper tests for text tokens, JSON keys, and argument parsing.
README, core guide, API reference, and tooling docs mention
`zig build rand-status -- --json`; `readmecheck` and `toolingcheck` guard the new
discovery and output tokens.

## Validation

Observed JSON output:

```text
$ zig build rand-status -- --json
{
  "date": "2026-07-06",
  "baseline": {
    "rand": "~/Work/rand",
    "rand_distr": "cached rand_distr 0.6.0"
  },
  "latest_gate": "zig build validate-local passes",
  "public_surface": "surfacecheck ok for rand/rand_core/rand_distr manifests",
  "rust_comparison": "parser tests and rand-bench-smoke pass",
  "runtime_runners": "node/cargo/rustc found; qemu/wine/wasmtime/wasmer not available",
  "current_conclusion": "no known unblocked local Rust core RNG gap",
  "remaining_blocker": "S4-M11 exact/default dense SIMD winner, new runtime, or new local Rust gap",
  "details": "compare/results/s4-m420-current-rand-status.md"
}
```

Observed help output:

```text
$ zig build rand-status -- --help
usage: rand-status [--json]
       rand-status --help
       --json prints the current local rand/rand_distr status as stable JSON
```

Focused validation commands:

```text
$ zig build rand-status -- --json
```

```text
$ zig build rand-status -- --help
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

S4-M431 is closed for the current bar: `rand-status` now has stable JSON and
help output. This is tooling ergonomics only; it does not resolve S4-M11 and is
not whole-goal completion evidence.
