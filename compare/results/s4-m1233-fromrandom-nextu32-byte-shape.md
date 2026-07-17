# S4-M1233 `std.Random` Adapter `nextU32` Byte-Shape Hardening

## Gap

`Rng.fromRandom` adapts an existing Zig `std.Random` byte-stream interface into
Alea's `Rng` facade. Its `nextU32` adapter previously called
`std.Random.int(u64)` and returned the high 32 bits. That consumed eight bytes
per `nextU32` call and produced the second half of the u64 draw instead of
matching `std.Random.int(u32)`'s native four-byte stream shape.

This is a correctness and interop issue: callers using `fromRandom` reasonably
expect Alea's raw `nextU32` facade to preserve the byte-stream semantics of the
wrapped `std.Random` source, especially for deterministic adapters and sources
that track exact requested byte counts.

## Change

`src/rng.zig` now maps `Rng.fromRandom(...).nextU32()` directly to
`std.Random.int(u32)`, while keeping `nextU64` mapped to `std.Random.int(u64)`.
A comment documents why the u32 path intentionally preserves `std.Random`'s
native byte shape rather than using Alea's high-half fallback rule for direct
engines.

## Validation

Focused test:

```console
$ zig test src/rng.zig --test-filter "fromRandom nextU32"
1/1 rng.test.fromRandom nextU32 preserves std.Random byte shape...OK
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

S4-M1233 closes the `std.Random` adapter raw-u32 interop gap: `fromRandom`
`nextU32` now consumes exactly four bytes and matches native `std.Random` u32
output, while `nextU64` remains unchanged. The whole product goal remains active
under the next S4-M1234 bar.
