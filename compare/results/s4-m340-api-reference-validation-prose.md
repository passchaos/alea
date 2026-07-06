# S4-M340 API Reference Validation Aggregate Prose

## Gap

`docs/api-reference.md` listed validation and tooling commands but did not
explain which aggregate to choose for API-related work. After README and the core
guide gained aggregate-selection prose, the API reference still needed local
context for `zig build validate`, `zig build validate-local`, and `zig build
validate-all`.

## Change

`docs/api-reference.md` now explains:

- use `zig build validate` for broad native API checks;
- use `zig build validate-local` when API work changes local `rand` /
  `rand_distr` comparison evidence because it adds `surfacecheck` and
  `runtimecheck`;
- use `zig build validate-all` for portability-sensitive API evidence because it
  adds cross-target compile checks, WASI unit tests, and the chained WASI report.

`tools/toolingcheck.zig` now guards those API-reference guidance tokens.

## Validation

Focused validation command:

```text
$ zig build toolingcheck
toolingcheck ok
```

Broader documentation/roadmap validation command:

```text
$ zig build doccheck
apicheck ok
readmecheck ok
roadmapcheck ok
toolingcheck ok
examplecheck ok
```

## Result

S4-M340 is closed for the current bar: the API reference now tells users which
validation aggregate to choose for native API checks, local Rust comparison
evidence, and portability-sensitive API evidence. This is documentation/tooling
hardening only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
