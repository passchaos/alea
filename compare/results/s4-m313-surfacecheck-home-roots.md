# S4-M313 Surfacecheck HOME-Relative Roots

Date: 2026-07-06

## Purpose

`surfacecheck` defaults pointed at the current local Linux paths under
`/home/passchaos/...`. The checker already supported explicit `ALEA_*_ROOT`
overrides, but the default path logic was less portable than the documentation,
which describes local baselines in terms of `~/Work/rand` and cargo cache paths.

## Change

`tools/surfacecheck.zig` now resolves default roots from `$HOME` plus checked-in
relative suffixes when the corresponding override is not set:

- `ALEA_RAND_ROOT` override, otherwise `$HOME/Work/rand/src`;
- `ALEA_RAND_CORE_ROOT` override, otherwise
  `$HOME/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_core-0.10.1/src`;
- `ALEA_RAND_DISTR_ROOT` override, otherwise
  `$HOME/.cargo/registry/src/rsproxy.cn-e3de039b2554c837/rand_distr-0.6.0/src`.

The previous absolute paths remain as fallback literals if `$HOME` is not
available. `docs/tooling.md` now describes the HOME-relative defaults and the
three override variables.

## Validation

Relevant validation:

```sh
zig fmt tools/surfacecheck.zig tools/roadmapcheck.zig
zig build surfacecheck
zig build toolingcheck
zig build roadmapcheck
zig build doccheck
zig build test
git diff --check
```

Current `zig build surfacecheck` summary:

```text
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
```

## Non-Completion Note

This milestone improves local comparison-tool portability. It does not resolve
S4-M11's exact/default-compatible dense SIMD normal/exponential blocker, does not
add an additional architecture/runtime runner, and is not whole-goal completion
evidence.
