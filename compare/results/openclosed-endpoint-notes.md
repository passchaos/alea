# OpenClosed f64 Endpoint Notes

This note captures the current evidence for exact `(0, 1]` f64 bulk sampling.
The remaining gap is not endpoint semantics or a Rust algorithm mismatch; it is
throughput while preserving the 53-bit endpoint grid.

## Current Baseline

Production `fillOpenClosed(f64)` uses raw `u64` words from byte-fill-capable
sources, converts the high 53 bits to the exact `(0, 1]` grid, and stores f64
values into the destination slice.

The current conversion shape is:

```zig
(@as(f64, @floatFromInt(raw >> 11)) + 1.0) * (1.0 / 9007199254740992.0)
```

Focused rows are at the local Rust noise boundary:

- facade / FastPrng direct / ScalarPrng direct: about 776M / 775M / 782M
  samples/s,
- local Rust `OpenClosed01 f64`: about 778M samples/s in the latest focused
  rerun.

A later fresh focused rerun on the same host was slower overall and again shows
a measurable gap: Alea facade / FastPrng direct / ScalarPrng direct about
653M / 631M / 649M samples/s versus Rust `OpenClosed01 f64` about 685M.
Repeated `open-closed-probe -- 134217728` runs show raw 96-word and 128-word
buffers remain tied within noise, so the adopted 128-word path remains the
simplest no-regression production choice.

## Rust Algorithm Audit

Local `~/Work/rand/src/distr/float.rs` uses the same multiply-based 53-bit
method for `OpenClosed01<f64>`:

1. take the high 53 random bits,
2. add one,
3. cast to float,
4. multiply by `2^-53`.

Therefore the remaining gap is not an algorithm-family mismatch with local
Rust.

## Rejected Or Exhausted Shapes

- Scalar loop without raw-word buffering is slower.
- 64/96/128/160/192/224/256 word buffers are all within noise or worse; 128
  remains the simplest no-regression choice.
- Integer-domain `+1` before float conversion is tied with the adopted
  float-plus-one expression.
- Division by `2^53` is tied with the adopted multiply-by-reciprocal expression.
- Bitcast-based `(0, 1]` constructions regress.
- In-place conversion, raw-vector conversion, and manual unrolling regress.
- Complement-grid mappings such as `1.0 - float(raw >> 11) * 2^-53` and
  `float(2^53 - (raw >> 11)) * 2^-53` are exact endpoint-equivalent but
  regress in `open-closed-probe`.
- Skipping explicit `littleToNative(u64, raw_word)` in the local x86_64 probe
  keeps matching checksums but regresses or ties, so the portable endian-normalized
  form remains preferable.
- Narrowing the 53-bit shifted raw value to `u53` / `u54` before
  `@floatFromInt` keeps matching checksums but regresses versus the current
  `u64` shift-plus-one expression.
- Raw byte-buffer reads that skip proper word conversion can appear fast but
  produce invalid means/checksums and are rejected.

## Requirements For A Future Change

A future production candidate must:

1. Preserve the exact `(0, 1]` endpoint grid, including the ability to produce
   `1.0` and never produce `0.0`.
2. Keep checksums/means in the expected range for benchmark rows.
3. Beat the current 128-word raw-buffer path in both facade and direct-source
   focused rows, or be explicitly scoped to one source profile.
4. Be measured against local Rust `OpenClosed01 f64` in the same focused rerun.

Until a candidate meets those requirements, keep the current raw-word
multiply-by-reciprocal path.
