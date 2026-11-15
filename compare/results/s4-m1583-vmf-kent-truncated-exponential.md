# S4-M1583 Exact Truncated-Exponential vMF/Kent Marginal

Date: 2026-11-15

## Hypothesis

For a unit von Mises-Fisher sample on S², the cosine `w = μ·x` of the polar
angle has the exact truncated-exponential marginal `∝ e^{κw}` on `[-1, 1]`.
Wood's rejection loop samples that same marginal through the rational proposal
`w = (1 − (1+b)z)/(1 − (1−b)z)` with acceptance
`exp(κw)(1 − x₀w)²/e^c`, so it pays an inner rejection loop and a log per
candidate even though the marginal inverts in closed form:

    w = −1 + log1p(U·(e^{2κ} − 1))/κ.

Kent's proposal marginal is the same vMF(λ) law (`λ = proposal_lambda`), so
the inner Wood loop can be replaced there too, leaving only the existing
`I₀`-weighted outer acceptance.

## Change

- Added `vmfSampleW3From`: scalar exact inversion. For `κ >= 1e-2` (f64) it
  uses `@log(1 + x)`, whose `1 + x` rounding perturbs the log by at most
  `~1.1e-16`, i.e. `|Δw| <= 1.1e-14`; smaller rates keep `log1p`. For
  `κ >= 354` (f64) or `κ >= 44` (f32) the complementary form
  `1 + log(U + (1−U)e^{−2κ})/κ` avoids `e^{2κ}` overflow.
- Added `vectorVmfSampleW3From`: the shared rate keeps `expm1(2κ)` scalar; the
  per-lane inversion is one log. Lanes with `κ < 1e-4` use the four-term
  `log1p` series with vector FMAs (argument below `2e-4`).
- `vmfSampleWFrom` / `vmfSampleWWithConstantsFrom` dispatch `dim == 3` to the
  exact inversion; `dim > 3` keeps Wood.
- `vectorVmfPointFrom` replaced the Wood rejection loop with one vector
  inversion.
- Kent: `kentSampleWFrom` and the vector Kent loop now draw the proposal
  cosine with the exact inversion; `vectorWoodW`,
  `vectorKentWoodTailFrom`, and the cached `wood_b/wood_x0/wood_c` fields were
  removed. The outer `I₀`-weighted acceptance and `marginal_max_log` envelope
  are unchanged.

Wood's inner loop output is exactly the truncated exponential (verified
against the analytic CDF before the change), so this is a distribution-
preserving algorithm substitution; only the consumed stream changes.

## Performance

Same host, 16MiB rows, best of three trials. Baseline and change were built
from `git stash` A/B pairs; the sanity rows (Bingham/Watson, unchanged
checksums) moved a few percent between periods.

| Row | Baseline | Change | Delta |
| --- | --- | --- | --- |
| `alea von mises-fisher 3d` | 52.1 M samples/s | 126.2 M samples/s | +142% |
| `alea vector von mises-fisher f64x4 3d` | 10.4 M vectors/s | 20.1 M vectors/s | +93% |
| `alea vector kent f64x4 3d` | 4.4-4.6 M vectors/s | 5.0 M vectors/s | +9-14% |
| `alea kent 3d` | 24.7-26.3 M samples/s | 24.8-25.1 M samples/s | parity |
| `alea matrix von mises-fisher 3x1` | 44.3 M samples/s | 49.4 M samples/s | +12% |
| `alea matrix von mises-fisher 3x2` | 44.3 M samples/s | 44.3 M samples/s | unchanged (exact `MatrixFisher` path) |
| `alea bingham 3d` / `alea watson 3d` | 29.5 M / 29.5 M | 30.6 M / 31.3 M | noise, checksums unchanged |
| `alea vector bingham f64x4 3d` / `alea vector watson f64x4 3d` | 7.1 M / 7.2 M | 7.5 M / 7.7 M | noise, checksums unchanged |

The first `log1p`-only version measured `alea kent 3d` at 22.0-22.2M; the
`@log(1 + x)` form for `κ >= 1e-2` recovered it to 24.8-25.1M, matching the
baseline. The same substitution in the vector helper lifted vector Kent from
4.7M to 4.9-5.0M.

Checksums (new streams):

| Row | Baseline checksum | Change checksum |
| --- | --- | --- |
| `alea von mises-fisher 3d` | `13750568254893873330` | `183813184205834138` |
| `alea vector von mises-fisher f64x4 3d` | `11245840066905091996` | `15146673891782920812` |
| `alea kent 3d` | `9761654497349534419` | `16320475167864103015` |
| `alea vector kent f64x4 3d` | `7297499978426234569` | `16727813968867590217` |
| `alea matrix von mises-fisher 3x1` | `13936223317007019539` | `3120856829199790268` |
| `alea matrix von mises-fisher 3x2` | `5952472309509111602` | `5952472309509111602` |
| `alea bingham 3d` / `alea watson 3d` | `3229607846008164661` / `13977792866029483417` | unchanged |

## Accuracy

- New unit test `vMF S2 marginal inversion matches the truncated exponential`
  checks `F(0) = 1/(1 + e^κ)` and the analytic mean
  `coth(κ) − 1/κ` for `κ ∈ {1e-6, 0.25, 5, 50, 400}` over 20k draws.
- New unit test `vector vMF S2 marginal covers the Taylor and complementary
  branches` checks the f64x4 Taylor (`κ = 1e-6`), plain-log (`κ = 5`), and
  complementary (`κ = 400`) branches plus the f32x8 complementary branch at
  `κ = 50`.
- `distcheck` keeps its empirical vMF mean-resultant, Kent mean-resultant,
  Kent major/minor variance, and matrix-vMF first-column gates green.

## Validation

- `zig build test distcheck --summary all` passes 963/963 tests (native
  `alea-tests` 942/942), including `doccheck`/`apicheck`/`roadmapcheck`.
- No public API changed; no new build step or example was added.
- `reproducibility-matrix.md` records the versioned stream change for S² vMF,
  Kent, and the single-column matrix-vMF conditional; `performance-triage.md`
  records the adoption.

## Decision

Adopted as S4-M1583. The S² cosine marginal and the Kent proposal now use the
exact truncated-exponential inversion; `dim > 3` keeps Wood rejection.
