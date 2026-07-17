# S4-M1238 Generic NextFrom Native-U64 Fallback

## Gap

S4-M1236 made the raw scalar helpers accept direct sources that expose the
Rust-discoverable `nextU64()` alias without Zig's `next()` spelling, and S4-M1237
extended byte helpers to the same native-u64 fallback shape. The generic
infallible draw primitive, `Rng.nextFrom`, still called `source.next()` directly.

That left many higher-level direct-source helpers (`booleanFrom`, `valueFrom`,
integer/float/vector fills, probability helpers, and reusable sampler paths that
draw through `nextFrom`) unable to use a source that exposes only `nextU64()`.
This was an API consistency and correctness gap: raw byte/scalar helpers accepted
native-u64 direct sources, but generic random-value workflows did not.

## Change

`src/rng.zig` now:

- makes `Rng.nextFrom` prefer the existing Zig-native `next()` spelling when it
  is available, preserving existing stream shape for current direct engines;
- falls back to source-native `nextU64()` otherwise, so Rust-style direct sources
  work across generic infallible helpers;
- reuses the centralized `sourceHasDecl` capability helper via a small
  `sourceCanNext` probe;
- adds focused coverage for a `nextU64`-only source through boolean, integer,
  float, and bulk bool-fill direct-source helpers.

## Validation

Focused test:

```console
$ zig test src/rng.zig --test-filter "rng direct generic helpers accept source native nextU64 only"
1/1 rng.test.rng direct generic helpers accept source native nextU64 only...OK
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

S4-M1238 closes the generic direct-source native-u64 fallback hardening: the
common `nextFrom` primitive now supports Rust-style `nextU64`-only sources while
preserving `next()` precedence for existing Zig-native engines. The whole product
goal remains active under the next S4-M1239 bar.
