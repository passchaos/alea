# S4-M1281 — Advanced multivariate/directional benchmark rows

## Goal

Add benchmark coverage for the multivariate and directional families added after
the original M3 benchmark matrix:

- Bingham on S² (`Bingham(f64, 3)`).
- Static Gaussian copula 3D.
- Static Student-t copula 3D.
- Static matrix normal 2×3.
- Static matrix-t 2×3.

These rows give a regression baseline and performance evidence for the new
families. Local Rust `rand` / `rand_distr` has no matching copula, matrix-t, or
Bingham rows, so these are Zig-only evidence rows rather than parity rows.

## Implementation

- `bench/throughput.zig` gains `benchBingham`, `benchGaussianCopula`,
  `benchStudentTCopula`, `benchMatrixNormal`, and `benchMatrixT`.
- Each function follows the existing harness contract:
  - honors `bench_filter`,
  - runs `trials = 3` trials with a fixed `FastPrng` seed,
  - times `count` samples with `std.Io.Clock.awake.now`,
  - keeps the best M samples/s and a bit-pattern checksum,
  - calls `std.mem.doNotOptimizeAway` on the checksum.
- A new `advanced multivariate throughput` section invokes the five rows with
  `bytes / 64` sample counts.

## Evidence

Command: `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216 <filter>`

| Row | M samples/s | Notes |
| --- | ---: | --- |
| `alea bingham 3d` | 19.8 | Jacobi setup once, ACG rejection per sample |
| `alea gaussian copula 3d` | 63.1 | MVN transform plus 3 `normCdf` evaluations |
| `alea student-t copula 3d` | 4.5 | shared χ² draw plus 3 continued-fraction t-CDF evaluations |
| `alea matrix normal 2x3` | 86.2 | in-place `L_U Z L_Vᵀ` transform |
| `alea matrix t 2x3` | 63.5 | matrix normal plus one χ² scale |

The Student-t copula row is expected to be the slowest because
`studentTCdf` evaluates a continued fraction per coordinate; the matrix and
Gaussian-copula rows confirm the shared in-place/transform infrastructure is
fast.

## Validation

- `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216 "bingham"`
  prints `alea bingham 3d: 19.8 M samples/s`.
- `... "copula"` prints the Gaussian and Student-t copula rows.
- `... "matrix"` prints the matrix normal and matrix-t rows.
- `zig build test` passes 826/826 tests with all doc gates.
- `compare/results/core-rand-coverage.md` S4-M1281 row added.

## Deviations and notes

- The rows use `Static*` samplers so the benchmark measures the transform and
  rejection/CDF work rather than allocator traffic.
- No Rust comparison rows are added because local `rand` / `rand_distr` has no
  matching copula, matrix-t, or Bingham APIs.
- The fixed seeds and checksums make the rows reproducible on the same host;
  absolute throughput remains host/compiler dependent.

## Next bar

Matrix von Mises-Fisher, Kent distribution, vector/SIMD copula/Bingham sampling,
longer statistical validation runs, or newly discovered core gaps against local
Rust `rand` / `rand_distr` evidence.
