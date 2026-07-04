# S4-M86 Rng Owned Byte Buffers

Date: 2026-07-04

Purpose: add allocation-returning random byte buffers for `Rng`. This
complements caller-owned `Rng.bytes`, `Rng.fill(u8, ...)`, direct-source
`fillFrom(..., u8, ...)`, and S4-M85 owned value/sample batches with a
byte-specific owned buffer helper that preserves engine byte-fill policies.

## Change

Added owned byte helpers in `src/rng.zig`:

- `Rng.bytesAlloc(allocator, count)`;
- `Rng.bytesAllocFrom(source, allocator, count)`.

The helpers allocate before filling, so allocation failures and zero-length
requests do not consume randomness. The direct-source variant delegates through
the same byte-fill path used by `fill(u8, ...)`, preserving engine-specific
`fill` behavior where available.

Updated adoption/docs:

- `examples/basic.zig` prints a `bytesAlloc` row;
- `docs/examples.md` describes owned byte/value/sample batches in the basic
  example;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions allocation-returning byte buffers;
- `tools/examplecheck.zig` guards the basic example token;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` include the S4-M86 evidence.

## Validation

Commands for final validation:

```sh
git diff --check
zig build test
zig build run-basic
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- facade/direct stream-shape parity for `bytesAlloc` / `bytesAllocFrom`;
- allocation-failure paths without stream consumption;
- zero-length owned byte buffers returning before allocation failure or stream
  consumption.

## S4-M86 Decision

S4-M86 is closed for the current `Rng` owned byte-buffer bar: callers can now
request owned random byte slices without manually allocating and calling
`bytes`/`fill(u8, ...)` themselves.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
