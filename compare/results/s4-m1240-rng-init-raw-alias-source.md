# S4-M1240 Rng.init Raw-Alias Source Fallback

## Gap

After S4-M1236 through S4-M1239, direct-source helpers, generic value helpers,
byte helpers, and seed/fork workflows accepted Rust-style `nextU64` /
`tryNextU64` / `fillBytes` raw aliases. The type-erased `Rng.init(&source)`
facade still required a Zig-native `next()` and `fill()` pair, so an otherwise
valid raw-alias-only source could not be wrapped in `Rng` for ergonomic facade
use.

This was both a correctness/ergonomics inconsistency and a structure smell: the
facade constructor had its own hard-coded source contract instead of delegating
to the same direct-source dispatch helpers used by the rest of the library.

## Change

`src/rng.zig` now:

- lets `Rng.init` accept sources exposing either `next()` or `nextU64()`;
- routes the type-erased `next`, `nextU32`, and byte-fill vtable functions
  through `nextFrom`, `nextU32From`, and `fillBytesFrom` respectively;
- no longer requires source-native `fill()` when byte filling can be served by a
  `fillBytes()` alias or by the shared u64-word fallback;
- adds focused coverage for a raw-alias-only source wrapped through `Rng.init`,
  including `nextU64`, `nextU32`, and `fillBytes` facade calls.

## Validation

Focused test:

```console
$ zig test src/rng.zig --test-filter "rng facade init accepts raw alias-only sources"
1/1 rng.test.rng facade init accepts raw alias-only sources...OK
All 1 tests passed.
```

Full validation for the committed change:

```console
$ zig build test
$ zig build validate
$ zig build validate-local
$ zig build crosscheck
$ zig build roadmapcheck toolingcheck rand-status-self-test
$ git diff --check
```

## Result

S4-M1240 closes the facade-constructor raw-alias fallback hardening: sources that
only expose Rust-discoverable raw aliases can now be used through both direct
`From` helpers and the type-erased `Rng` facade, while existing `next()` /
`fill()` engine behavior remains routed through the same shared helper paths. The
whole product goal remains active under the next S4-M1241 bar.
