# ChaCha Stream Contract and Fill-Only Benchmark

## Change

- `src/engines/chacha.zig` now exposes a generic `ChaChaRng(Cipher)` and keeps
  `ChaCha = ChaChaRng(ChaCha12IETF)`.
- `src/engines/chacha8.zig` and `src/engines/chacha20.zig` are thin
  `ChaChaRng(...)` aliases with their existing snapshot tests.
- Added a known-answer test that documents the buffered rekeying construction:
  the first 480 output bytes equal the standard ChaCha12 keystream bytes
  `32..512`, and the next block is keyed by the first 32 bytes of the previous
  block.
- Added a `chacha12 fill-only` throughput row so the fill body can be measured
  separately from the checksum-heavy byte-throughput row.

## Stream Contract

Each 512-byte refill runs the selected ChaCha round function with the current
key and a zero nonce. The first `key_length` bytes become the next key and are
not emitted; the remaining 480 bytes are output. This is a rekeying chain, not
a standard counter-mode stream. The behavior is now documented in
`docs/core-guide.md`, `docs/api-reference.md`, and
`compare/results/reproducibility-matrix.md`.

## Benchmark

Host: macOS aarch64, `-Doptimize=ReleaseFast -Dcpu=native`, 64 MiB per trial.

```text
$ zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 67108864 "chacha"
byte throughput
chacha12: 1532.9 MiB/s checksum=17
fill-only throughput
chacha12 fill-only: 2432.9 MiB/s tail=78
```

The historical Linux comparison in `compare/results/2026-06-27-rand-comparison.md`
reported `rand StdRng` at 3434.4 MiB/s for the checksum-heavy row. That is a
different host and date; rerun the Rust comparison on the local Linux host
before treating it as a current regression.

An isolated 512-byte-buffer check measured the zeroing cost directly:

```text
zeroing: 2126.6 MiB/s
no zeroing: 2675.5 MiB/s
raw Cipher.stream: 2612.9 MiB/s
```

The production `fill` intentionally keeps zeroing consumed keystream bytes for
the secure-style engine. A future standard counter-mode engine or an explicit
zeroing policy would need a separate stable-output contract.
