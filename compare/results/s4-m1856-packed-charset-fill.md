# S4-M1856 Packed Bulk Fill for the Standard Charsets

Date: 2026-11-20

## Gap

`Charset.fill`/`fillFrom` drew one bounded `u64` per character
(`uintLessThanFrom`, a 128-bit multiply-high plus a near-never rejection),
so the `alea alphanumeric` row sat at 1.02x local Rust. Rust's
`Alphanumeric` draws a `u32` per character and takes six bits, and the
comparison harness measured 1028.1M against Alea's 1045.3M.

## Change

Fills of the standard charset widths now use a packed bit-chunk kernel:
one `u64` per `64 / width` characters, `width` bits per character, and a
rejection for values at or above the charset length. The standard alphabets
map to 4-bit (digits, 16 chars/word, 37.5% rejection), 5-bit (26-letter
alphabets, 12 chars/word, 18.75%), and 6-bit (52/62, 10 chars/word, 0-3.1%)
chunks. `sample`/`sampleFrom` keep the per-character bounded draw, and
fills of other lengths keep the generic bounded-draw loop; this is a
versioned bulk-fill policy recorded in `reproducibility-matrix.md`. The
`alea alphanumeric` checksum moves `182252759` -> `182224526`.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216 "alphanumeric"`), four alternating
pairs. Every candidate run is above every baseline run:

| Row | Baseline (M chars/s) | Candidate (M chars/s) |
| --- | --- | --- |
| `alea alphanumeric` | 999.8, 889.3, 863.0, 757.7 | 1269.8, 1213.7, 1261.1, 1261.5 |

Medians: 876M -> 1261M (about +44%). A standalone probe of the same kernel
against the old loop measured 715.8M -> 1023.6M (about 1.43x) in the same
window. With local Rust at about 1028M in the no-known-gaps window, the row
moves from 1.02x to roughly 1.2-1.4x.

## Statistical Quality

Each `width`-bit chunk is uniform over `[0, 2^width)` when the engine word
is uniform, and the rejection makes the accepted index exactly uniform over
the charset. Chunks come from independent bit positions of successive
engine words, the same bit-slicing Rust's `Alphanumeric` uses. A constant
all-ones engine would spin on the rejection branch, which matches the
existing rejection-sampling assumption used by the ziggurat and other
samplers; the degenerate-engine tests keep using zero-valued streams.

## Tests And Snapshots

- `src/ascii.zig` "ascii helpers have stable snapshots" is updated with the
  new versioned fill/string/engine state (`Y52jPKMSUniDB5d7`, then
  `0aY6sk3H3dkxp3Ld`, `0xb1b16`, the new UTF-8 bytes, and
  `0x2aa90fc028513e3`).
- "ascii charset fills requested length" now documents that the bulk fill
  is a versioned policy and checks fill == fillFrom plus alphanumeric
  content instead of fill == repeated `sampleFrom`.
- The direct-stream-shape and alias tests still pass because facade and
  direct sources share the same kernel.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: `doccheck ok`.

## Next Bar

Refresh `validate-all` and the 1e9 long run on this tree; the
large-hypergeometric codegen gap remains the only sub-parity comparable
workload.
