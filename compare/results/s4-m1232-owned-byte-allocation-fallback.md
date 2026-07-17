# S4-M1232 Owned Byte Allocation Fallback Hardening

## Gap

S4-M1231 made public try-fill helpers and `RngReader` share the same fallible
byte-fill fallback, but the owned byte allocation helper still filled through the
infallible `fillBytesFrom` path after allocation. That meant `bytesAllocFrom`
worked for deterministic engines with `fill`, but did not support the same
fallible source contracts as `tryFillBytesFrom` / `RngReader` for sources that
only expose `tryFillBytes`, `tryNextU64`, or `tryNext`.

This is a correctness and API-consistency risk: owned byte buffers are part of
Alea's seeding/entropy and reproducibility surface, so allocation helpers should
not silently have narrower source support than caller-owned byte fills.

## Change

`src/rng.zig` now:

- fills `bytesAllocFrom` outputs through the shared `fillSourceBytesFrom`
  fallback after allocation succeeds;
- keeps `errdefer allocator.free(out)` around the fill so entropy/source errors
  release the owned buffer;
- adds focused coverage showing `bytesAllocFrom` matches try-next-only
  `tryFillBytesFrom` byte shape, propagates try-next failures, treats
  zero-length allocation as non-consuming, and propagates `SysRng` entropy
  failures.

## Validation

Focused tests:

```console
$ zig test src/rng.zig --test-filter "tryFillBytesFrom preserves fallible tryNext fallback"
1/1 rng.test.tryFillBytesFrom preserves fallible tryNext fallback and bytesAllocFrom shares it...OK
All 1 tests passed.

$ zig test src/rng.zig --test-filter "sys rng source uses Io entropy"
1/1 rng.test.sys rng source uses Io entropy and propagates failures...OK
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

S4-M1232 closes the owned byte-allocation follow-up: owned byte buffers now share
Alea's fallible byte-source fallback contract with caller-owned try-fill and
`std.Io.Reader` adapters. The whole product goal remains active under the next
S4-M1233 bar.
