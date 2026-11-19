# S4-M1761 LogNormalFastExp Inlined-Exponential Profile

Date: 2026-11-19

## Gap

The exact `LogNormal(T)` default keeps the system `@exp` transform for stable
output mapping. On the local macOS aarch64 host that out-of-line libSystem call
dominates the distribution:

- Alea default f64: 123.3M facade, 135.8M scalar direct samples/s.
- Local Rust `rand_distr 0.6.0` f64: 236.2M samples/s.

Disassembling the Rust benchmark binary shows why: `rand_distr`'s `LogNormal`
resolves `exp` through `num-traits`' `libm` crate, so a pure-Rust exponential is
inlined into the sampling loop. Zig's `@exp` lowers to a `libSystem` call, which
cannot be pipelined across samples.

The same effect appears in the vector surface: `vectorLogNormal f64x4` reaches
only 26.1M vectors/s (104M lanes/s) and default `fillVectorLogNormal f64x4`
reaches 162.6M lanes/s.

## Change

Added an explicit opt-in profile with an inlined exponential kernel:

- `LogNormalFastExp(T)`, `VectorLogNormalFastExp(V)` sampler types.
- `logNormalFastExp`, `logNormalFastExpFrom`, `logNormalFastExpChecked`,
  `logNormalFastExpCheckedFrom`, `fillLogNormalFastExp`,
  `fillLogNormalFastExpFrom`, `fillLogNormalFastExpChecked`,
  `fillLogNormalFastExpCheckedFrom`, and the matching
  `vectorLogNormalFastExp*` / `fillVectorLogNormalFastExp*` helpers.
- `fastExp64` / `fastExp32`: branchless fdlibm/musl-style kernels using a
  two-step Cody-Waite reduction plus the classic rational approximation, with a
  cold lane guard that hands `|x| >= 708.39` (f64) / `|x| >= 87.34` (f32),
  NaN, infinity, overflow, and subnormal results to the system `@exp`.
- Vector kernels for f64 and f32 vectors; f32 fill paths use the native f32
  kernel rather than promoting to f64.

The normal draw stream is unchanged: the profile consumes exactly the same
engine words as exact `LogNormal(T)`. Only the final transform mapping is a
separate versioned opt-in output profile.

## Accuracy

`fastExp64` versus system `@exp` on the local host:

- dense grid over `[-745, 709]` with 200M points plus 60M random normals scaled
  by 0.25/1/3: max observed error 1 ULP;
- unit tests gate the same grid/random shapes at `<= 2 ULP` to tolerate other
  libm implementations;
- `exp(0) = 1`, NaN -> NaN, +inf -> +inf, -inf -> 0, overflow -> +inf, and
  underflow -> 0 are covered.

`fastExp32` versus system `@exp` (expf): max observed error 1 ULP on a 1M-point
grid over `[-103, 88]` plus 300k scaled normals, gated at `<= 2 ULP`.

## Throughput

Same host, `ReleaseFast -Dcpu=native`, 128MiB rows unless noted.

| Row | Before (default) | After (fast-exp) | Local Rust |
| --- | --- | --- | --- |
| `log-normal` f64 facade | 123.3M | 342.9M | 236.2M |
| `log-normal` f64 FastPrng direct | 125.1M | 334.0M | - |
| `log-normal` f64 ScalarPrng direct | 135.8M | 375.6M | - |
| `log-normal` f64 stddev=1 direct | 130.1M | 377.5M | 116.2M |
| `log-normal` f32 direct | 456.6M | 456.5M | 248.7M |
| `fillLogNormal` f64 direct | - | 331.2-332.3M | - |
| `fillLogNormal` f64 stddev=1 direct | - | 340.7M | - |
| `fillLogNormal` f32 direct | - | 454.5-474.6M | - |

Vector fills, `vectorbench -- 16777216`:

| Row | Default | fast-exp |
| --- | --- | --- |
| `fillVectorLogNormal f64x4` | 162.6M lanes/s | 334.1M |
| `fillVectorLogNormal f64x4 direct` | 152.0M | 294.4M |
| `VectorLogNormal.fill f64x4` | - | 333.4M |
| `fillVectorLogNormal f32x8` | 386.9M | 478.6M |
| `fillVectorLogNormal f32x8 direct` | 404.3M | 517.0M |
| `VectorLogNormalFastExp.fill f32x8` | - | 490.3M |

The f64 profile is 1.42-1.59x local Rust on the standard row and 3.2x on the
stddev=1 row. The f32 single-sample profile is at parity with Alea's default
f32 row (which already exceeds Rust by 1.8x) and is kept for API consistency;
the f32 fill rows are 1.24-1.28x the default vector fill.

A repeat run after formatting the source showed the same range: 356.7M facade,
345.2M FastPrng direct, 389.3M ScalarPrng direct f64, 388.8M stddev=1, 343.9M /
342.3M f64 fills, and 520.0M / 511.0M f32 fills.

## Rejected shapes

- Branchy musl form with the `|x| > 0.5 ln2` split: 258-284M f64 samples/s,
  below the branchless form.
- f32 polynomial transform: 385-420M samples/s, below the rational f32 kernel.
- f32 promotion through the f64 kernel: 353M samples/s at 16MiB, below the
  native f32 kernel and the default.

## Stability

The exact `LogNormal(T)` default still uses `@exp` and its output mapping is
unchanged. `LogNormalFastExp` is recorded in
`compare/results/reproducibility-matrix.md` as a separate versioned opt-in
profile with checked-in snapshot bits for f64/f32 samples, fills, and
`fromZScore`.

## Validation

- `zig build test --summary all`: 29/29 steps, 994/994 tests.
- `zig build distcheck`: `distcheck ok` with new scalar f64/f32 mean gates.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: `apicheck ok`, `roadmapcheck ok`, `toolingcheck ok`,
  `examplecheck ok`, `readmecheck ok`.
- `zig build run-lognormal-profiles` demonstrates the new profile.
- `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 134217728 "fast-exp"`
  and `vectorbench -- 16777216 "LogNormalFastExp"` produced the rows above.

## Next Bar

Refresh `validate-all`/long-run evidence with the new profile, and watch for an
exact-transform codegen improvement that could make the inlined kernel the
default under a deliberate versioned output change.
