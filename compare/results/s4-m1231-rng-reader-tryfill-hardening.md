# S4-M1231 Rng Reader / Try-Fill Hardening

## Gap

The S4-M1231 correctness/structure audit found two related byte-stream risks in
`src/rng.zig`:

1. `Rng.tryFillBytesFrom(source, buf)` had its own dispatch path and did not use
   the same fallback as `RngReader`: sources that only expose fallible
   `tryNext`/`tryNextU64` but not `tryFillBytes` were expected to be fillable by
   chunking words, yet the public helper bypassed that shared path.
2. The `std.Io.Reader` adapter already handled Zig's zero-length `readVec`
   refill contract by appending at `Reader.end`; that subtle invariant needed
   explicit tests because refilling at the wrong offset can corrupt bytes that
   were peeked/taken only partially from the buffer.

Both are correctness-first issues: byte streams back seeding, reproducibility,
secure-style entropy adapters, and arbitrary callers using Alea as an `std.Io`
reader.

## Change

`src/rng.zig` now:

- routes public `Rng.tryFillBytesFrom` through the shared `fillSourceBytesFrom`
  implementation used by `RngReader`;
- makes shared byte filling return immediately for zero-length buffers before
  probing or touching the source;
- keeps a comment on the `readVec` zero-length refill path documenting why the
  adapter must append at `Reader.end` after rebase/partial consumption;
- adds focused regression tests for try-next-only fallible sources, zero-length
  fallible fills, and buffered `peek`/`take` refill preservation.

## Validation

Focused tests:

```console
$ zig test src/rng.zig --test-filter "tryFillBytesFrom preserves fallible tryNext fallback"
1/1 rng.test.tryFillBytesFrom preserves fallible tryNext fallback...OK
All 1 tests passed.

$ zig test src/rng.zig --test-filter "rng reader adapter"
1/5 rng.test.rng reader adapter streams deterministic bytes...OK
2/5 rng.test.rng reader adapter integrates with Io stream and discard...OK
3/5 rng.test.rng reader adapter preserves buffered data across peek refills...OK
4/5 rng.test.rng reader adapter propagates fallible sources...OK
5/5 root.test_0...OK
All 5 tests passed.
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

S4-M1231 closes the byte-stream hardening follow-up: public try-fill helpers and
`RngReader` share one fallible byte-fill path, zero-length fills are harmless,
and the buffered `std.Io.Reader` refill invariant is covered by tests. The whole
product goal remains active under the next S4-M1232 bar.
