# S4-M1724 Inline Gamma Kernel In The Free Function

Date: 2026-11-16

## Change

The free `gamma(rng, T, shape, scale)` constructed a reusable `Gamma(T)`
sampler on every call (computing the cached `d`/`c`/boosted fields) and then
called its `sample`. The function now runs the same Marsaglia-Tsang kernel
inline via `gammaMarsagliaFrom`, keeping the sampler's exact association
order (`scale * (d * v)`), the boosted `shape < 1` path, the `shape == 1`
exponential path, and the historical `shape == 0.5` z² shortcut. The reusable
`Gamma` sampler is unchanged.

`beta(rng, ...)` calls `gamma` twice, so it inherits the speedup.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea gamma` | 171-173.8 M samples/s | 265.9-275.1 M samples/s | +53-58% |
| `alea beta` | 87.1 M samples/s | 121.0-133.4 M samples/s | +39-53% |
| `alea fillVectorBinomial non-dyadic f64x4` | 65.2-65.8 M samples/s | 55-58 M samples/s | -12-15% (code layout) |

The gamma and beta checksums are unchanged (`786790.329`, `37447.095`),
confirming the stream-preserving kernel. The binomial fill row regression is
a code-layout side effect of the larger inlined free function; it was
measured in a bracketed A/B (the gamma/beta gain is much larger and was
adopted).

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 974/974
  tests (native 951/951).

## Changed Files

- `src/distributions.zig`: the inline `gamma` kernel, the
  `gammaMarsagliaFrom` helper, and the restored `shape == 0.5` shortcut.
- `compare/results/reproducibility-matrix.md`: records the stream-preserving
  speedup.
