# S4-M1237 FillBytes Direct-Source Fallback

## Gap

S4-M1236 closed the direct-source native-`nextU64` raw-scalar fallback, but the
adjacent byte helpers still had two direct-source shape gaps:

- `Rng.fillBytesFrom` only accepted Zig-style `fill(out)` and missed sources that
  expose the Rust-discoverable raw alias `fillBytes(out)` without also exposing
  `fill(out)`.
- the infallible byte helper did not share the same native-u64 fallback shape as
  `tryFillBytesFrom`: a source with `nextU64()` but no Zig-style `next()` could
  be used for scalar `nextU64From` but not for infallible byte filling.

Both cases are correctness/ergonomics issues for direct-source workflows. Alea's
public surface advertises Rust-discoverable raw aliases, so direct-source byte
helpers should preserve those aliases before requiring Zig-only method spellings.

## Change

`src/rng.zig` now:

- routes `Rng.fillBytesFrom` through `fillBytes(out)`, then `fill(out)`, then an
  infallible little-endian `nextU64From` word fallback;
- keeps `Rng.tryFillBytesFrom`, `Rng.bytesAllocFrom`, and `RngReader` on the
  shared fallible path, so they also accept `fillBytes(out)` before falling back
  to `tryNextU64From`;
- centralizes direct-source declaration checks with `sourceHasDecl`, reducing
  pointer/value dispatch duplication across raw-source capability probes;
- adds focused tests for `fillBytes`-only sources and `nextU64`-only byte-fill
  fallback without drawing from `next()`.

## Validation

Focused tests:

```console
$ zig test src/rng.zig --test-filter "rng direct byte helpers dispatch raw fillBytes alias"
1/1 rng.test.rng direct byte helpers dispatch raw fillBytes alias...OK
All 1 tests passed.

$ zig test src/rng.zig --test-filter "rng direct infallible byte helpers fall back to native nextU64"
1/1 rng.test.rng direct infallible byte helpers fall back to native nextU64...OK
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

S4-M1237 closes the direct-source byte-helper fallback hardening: byte helpers now
accept Rust-style `fillBytes` sources, preserve the existing shared fallible
fallback behavior, and keep infallible byte fills aligned with `nextU64From` for
native-u64 direct sources. The whole product goal remains active under the next
S4-M1238 bar.
