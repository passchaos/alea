# S4-M1270 — Allocator-backed runtime-dimension copulas

## Goal

Complete the copula family with allocator-backed runtime-dimension variants:

- `GaussianCopula(T)` — `u_i = Φ(z_i)` with `z ~ N(0, R)`.
- `StudentTCopula(T)` — `u_i = F_ν(z_i/√(s/ν))` with shared `s ~ χ²(ν)`.

The static `StaticGaussianCopula(T, dim)` / `StaticStudentTCopula(T, dim)`
variants cover comptime dimensions; the dynamic variants mirror the existing
`MultivariateNormal(T)` allocator-backed API so runtime-dimensional dependence
models do not force callers into comptime specialization.

## Implementation

### Public API

`GaussianCopula(T)`:

- `init(allocator, correlation: []const T) !Self` / `new(...) !Self`
- `deinit(*Self)`, `clone(self, allocator) !Self`
- `dimensionValue`, `rankValue`, `isDegenerate`
- `correlationValue(allocator) ![]T`, `correlationInto(out) Error!void`
- `sample(allocator, rng) ![]T`, `sampleFrom(allocator, source) ![]T`
- `sampleInto(rng, out)`, `sampleIntoFrom(source, out)` (zero-alloc)
- `sampleIntoChecked` / `sampleIntoCheckedFrom`
- `sampleManyInto` / `sampleManyIntoFrom` (zero-alloc batch)

`StudentTCopula(T)`:

- Same surface plus `degreesOfFreedomValue`, `dfValue`, and a
  `degrees_of_freedom` argument to `init`/`new`.

`multi.GaussianCopula(T)` and `multi.StudentTCopula(T)` re-export the dynamic
types alongside `multi.MultivariateNormal(T)`.

### Validation and sampling

1. `dynamicCopulaCorrelation` validates the flat row-major input:
   non-empty, perfect-square length, finite entries, unit diagonal, and
   `[-1,1]` correlations. Non-symmetric inputs are symmetrized.
2. The owned symmetrized matrix and a zero mean are passed to
   `MultivariateNormal(T).init`, which performs the O(d³) factorization once
   and supports rank-deficient correlations.
3. `sampleInto` is allocation-free: the owned MVN factor draws the normal
   vector and `mapCopulaUniforms` applies `normCdf` and the open-interval
   clamp.
4. The t-copula draws one shared `χ²(ν)` scale per sample through
   `chiSquaredFrom` and maps through `studentTCdf`.
5. Batch helpers loop over the single-sample path so repeated-sample stream
   shape is preserved exactly.

## Tests added (6 new, total 795)

1. `GaussianCopula (dynamic) validates correlation matrices` — empty,
   non-square, NaN, non-unit diagonal, and non-PSD inputs.
2. `GaussianCopula (dynamic) samples match the static copula` — bit-for-bit
   facade parity against `StaticGaussianCopula` for 32 samples.
3. `GaussianCopula (dynamic) clone and caller buffers work` — clone,
   `correlationInto`, checked output lengths, batch fills, and allocating
   `sample`.
4. `StudentTCopula (dynamic) validates parameters and matches static` — df
   `0`/negative/NaN rejection and bit-for-bit parity against
   `StaticStudentTCopula`.
5. `StudentTCopula (dynamic) clone and caller buffers work`.
6. `GaussianCopula and StudentTCopula (dynamic) f32 support`.

The tests use `std.testing.allocator`, so leaks in `init`/`clone`/`deinit`
would fail the test binary.

## Validation

- `zig build test` passes: 795/795 tests; `apicheck`, `readmecheck`,
  `toolingcheck`, `roadmapcheck`, and `examplecheck` all green.
- Focused `zig test src/root.zig --test-filter "dynamic"` passes all matching
  dynamic copula and dynamic multivariate tests.
- `docs/api-reference.md` updated for all 40 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1270 row added.

## Deviations and notes

- The dynamic variants own both the symmetrized correlation matrix and the
  `MultivariateNormal(T)` factor; `deinit` frees both, and `clone` duplicates
  both with errdefer chains covering partial failure.
- Batch helpers intentionally loop over the single-sample path rather than
  calling the MVN batch entry point, preserving the exact stream shape of
  repeated single samples.
- The static variants remain the right choice for comptime-known dimensions
  because they are allocation-free end to end.

## Next bar

Matrix von Mises-Fisher, Kent distribution, vector/SIMD copula or Bingham
sampling, longer statistical validation runs, or newly discovered core gaps
against local Rust `rand` / `rand_distr` evidence.
