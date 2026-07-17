# S4-M1235 TryNextU32 Direct-Source Native Fallback

## Gap

After the `std.Random` adapter `nextU32` byte-shape fix, the adjacent direct
source fallback path still had a stream-shape inconsistency: `Rng.nextU32From`
dispatched to a source-provided `nextU32`, but `Rng.tryNextU32From` only used
`tryNextU32` and otherwise fell back through `tryNextU64From`. For sources that
expose infallible native `nextU32` but no fallible `tryNextU32`, the fallible
facade over-consumed a u64 draw and disagreed with the infallible direct helper.

This matters for u32-native deterministic sources and for callers using the
fallible-shaped facade as a generic API even when the underlying source is
infallible.

## Change

`src/rng.zig` now makes `tryNextU32From` use source-native `nextU32` when no
`tryNextU32` is available before falling back to a u64 draw. A comment documents
why this preserves direct-source u32 stream shape and keeps parity with
`nextU32From`.

## Validation

Focused test:

```console
$ zig test src/rng.zig --test-filter "rng direct raw aliases dispatch source native nextU32"
1/1 rng.test.rng direct raw aliases dispatch source native nextU32...OK
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

S4-M1235 closes the direct-source fallible raw-u32 fallback hardening: fallible
and infallible direct u32 helpers now agree for sources with native `nextU32`,
while sources without native u32 support keep the existing u64 high-half fallback.
The whole product goal remains active under the next S4-M1236 bar.
