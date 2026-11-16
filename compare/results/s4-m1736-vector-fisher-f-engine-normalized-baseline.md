# S4-M1736 Vector FisherF Engine-Normalized Baseline

Date: 2026-11-16

## Finding

The recorded `vector fisher-f` gap (about 88M lanes/s against 114-129M scalar)
compared the `FastPrng` generic vector harness with the `ScalarPrng` scalar
rows. Added `alea vector fisher-f f64x4 scalar-prng` to align the engine.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216
"fisher-f"` (two runs):

| Row | Throughput | Checksum |
| --- | --- | --- |
| `alea fisher-f direct` (`ScalarPrng`) | 149.2-154.4 M samples/s | `145543.537` |
| `alea vector fisher-f f64x4` (`FastPrng`) | 20.8-22.3 M vectors/s (83-89 M lanes/s) | `2330907.961` |
| `alea vector fisher-f f64x4 scalar-prng` | 37.8-39.1 M vectors/s (151-156 M lanes/s) | `2329149.166` |

At the same engine the vector lanes are at scalar parity. The difference
between the two vector rows is engine throughput (`Alea4x64` vs `Wyhash64`),
not the two-gamma kernel.

The real vector-slice harness uses `ScalarPrng` for both sides:
`zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216
"FisherF"` reports `fillVectorFisherF f64x4` 74.5M lanes/s,
`fillVectorFisherF f64x4 direct` 133.6M lanes/s, and
`VectorFisherF.fill f64x4` 74.9M lanes/s. The direct row is within about
10-12% of the 149-154M scalar direct row; the facade/sampler rows pay the
`Rng` wrapper across eight gamma draws per vector. The earlier
~88M-vs-114-129M comparison mixed facade/direct and engine choices.

## Rejected Candidate

Hoisting the cached `Gamma` fields, calling `gammaMarsagliaFrom` through a
`*const Gamma` helper, and switching the sampler receivers to `*const Self`
measured 21.6-21.7M vectors/s against a 21.7-21.8M baseline in a three-run
bracketed A/B with the unchanged checksum `2330907.961`. Rejected and
reverted; a dense gamma kernel is not indicated by this row.

## Validation

- Bench-only change; no library code changed.
- `zig build test --summary all` and
  `zig build roadmapcheck doccheck apicheck readmecheck --summary all` pass.
