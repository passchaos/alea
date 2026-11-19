# S4-M1773 Inlined Exponential Becomes the LogNormal Default

Date: 2026-11-20

## Change

The S4-M1761 `LogNormalFastExp` inlined branchless exponential kernel is now
the exact `LogNormal(T)` default transform. This is a deliberate versioned
output-mapping change, allowed by the reproducibility matrix's LogNormal row
("a deliberate versioned distribution change or an explicit opt-in"). The
previous `@exp` mapping is superseded.

The same kernel now also backs:

- `LogNormal.fromZScore`;
- the `BufferedLogNormal` degenerate (zero-stddev) paths;
- vector `LogNormal` (`vectorLogNormal` / `fillVectorLogNormal`), which
  previously used the slow vector `@exp` call.

`LogNormalFastExp(T)` / `VectorLogNormalFastExp(V)` remain as explicit profile
names for the same mapping; the bounded f32 approximation and native-f32
profiles are unchanged.

Additionally, `logNormalFrom`, `logNormalFastExpFrom`, and the `LogNormal`
sampler methods are marked `inline` so the inlined kernel is not left
out-of-line in some monomorphizations (without this, the sampler row was
1.9x slower than the identical `LogNormalFastExp` sampler).

## Measurements

Same host, `ReleaseFast -Dcpu=native`, 128MiB rows:

| Row | Previous default | Inlined default | Local Rust |
| --- | --- | --- | --- |
| `log-normal` f64 facade | 123.3M | 345.5M (2.80x) | 236.2M |
| `log-normal` f64 FastPrng direct | 125.1M | 283.6-328.1M | - |
| `log-normal` f64 ScalarPrng direct | 135.8M | 334.8-379.1M | - |
| `log-normal` f64 stddev=1 direct | 130.1M | 364.6M (2.80x) | 116.2M |
| `log-normal` f32 direct | 456.6M | 471.7M | 248.7M |
| `vector log-normal f64x4` | 26.0M vectors/s | 61.8M vectors/s (2.38x) | - |

The default now exceeds the local Rust `rand_distr` f64 row by 1.42-1.46x,
the stddev=1 row by 3.1x, and the f32 row by 1.9x. The mapping is also
platform-independent (pure Zig) instead of libm-dependent.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests (the LogNormal
  snapshot and stream-shape tests pass with the new mapping).
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: all checks pass.
- The reproducibility matrix LogNormal rows and `lognormal-transform-notes.md`
  record the versioned change.

## Next Bar

Continue with the remaining slow sampling rows (vector-directional
kent/bingham/watson) and broaden the platform evidence.
