# S4-M1386 — Exponential-kernel geometric sampling

## Goal

Replace the `log(1−u) / log(1−p)` transform in the geometric and negative
binomial samplers with the standard exponential kernel, whose tail is exactly
the geometric tail, and route the facade sampler paths through the shared
helpers instead of their hand-inlined log formulas.

## Implementation

- `geometricFailuresFrom` now returns `floor(E / q)` where `E ~ Exp(1)` comes
  from the ziggurat kernel and `q = −log(1−p)`. Because
  `P(K ≥ k) = exp(−q·k) = (1−p)^k`, this is exactly the geometric law of
  `floor(log(1−u) / log(1−p))`, but it replaces two libm logs with one
  ziggurat draw, one log (for `q`), and one division.
- `negativeBinomialFrom` computes `q` once per call instead of once per
  success and sums the shared `geometricFailuresFromLogQ` helper, keeping the
  previous saturation behaviour for probabilities below the representable
  geometric range.
- The `Geometric`, `GeometricFailures`, `VectorGeometric`, and
  `VectorGeometricFailures` `sample`/`fill` methods had hand-inlined copies of
  the log formula; they now call `geometricFrom` / `geometricFailuresFrom`, so
  every facade and direct path uses the exponential kernel.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea geometric` | 224.3M samples/s | 750-811M samples/s | +235-260% |
| `alea fillGeometric` | 201.9M samples/s | 638-688M samples/s | +215-240% |
| `alea fillGeometric scalar direct` | 224.0M samples/s | 767-818M samples/s | +240-265% |
| `alea geometric failures` | 224.5M samples/s | 828-891M samples/s | +270-300% |
| `alea fillGeometricFailures` | 203.0M samples/s | 737-780M samples/s | +260-285% |
| `alea fillGeometricFailures scalar direct` | 228.4M samples/s | 831-918M samples/s | +265-300% |
| `alea negative-binomial` | 45.2M samples/s | 179-180M samples/s | +297% |
| `alea standard-geometric` | 1671.9M samples/s | unchanged | `p = 0.5` fast path |

The sampled law is unchanged, but the consumed random stream differs, so the
checksums shift and are stable: `geometric` `1046997` → `1047724`,
`geometric failures` `784853` → `785580`, and `negative-binomial` `982915` →
`982200`; the direct fill checksums move similarly. `standard-geometric`
keeps its checksum and throughput because it never used the log formula.

## Validation

- All 9 geometric tests and the negative-binomial moment test pass.
- `zig build test` passes 899/899, including `apicheck` and `roadmapcheck`.
- `zig build distcheck` passes and `zig build statcheck` passes.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners, further discrete rejection-kernel tuning, or newly
discovered core gaps.
