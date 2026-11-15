# S4-M1585 Vector Circle-Rejection Probe (Rejected)

Date: 2026-11-15

## Hypothesis

`vectorVmfPointFrom` and `vectorWatsonPointFrom` draw the uniform tangent
angle with four independent scalar `unitCircleFrom` calls. Each scalar call is
a rejection loop (2 words per attempt, π/4 acceptance, ~1.27 attempts), so
four lanes run four sequential branchy loops. A vectorized rejection with lane
retirement should replace them with ~1.8 vector rounds and vector arithmetic.

## Probe

Added a private `vectorUnitCircleRejectionFrom`: each round draws two
`@Vector(L, f64)` uniforms, computes `(x² − y², 2xy)/(x² + y²)` for every lane,
and retires accepted lanes. Used it for the vMF and Watson tangent angle. Same
host, 16MiB rows, A/B builds:

| Row | Per-lane scalar (baseline) | Vector rejection | Checksum |
| --- | --- | --- | --- |
| `alea vector von mises-fisher f64x4 3d` | 20.2 M vectors/s | 19.3 M vectors/s | `15146673891782920812` -> `1099239467985723792` |
| `alea vector watson f64x4 3d` | 7.6 M vectors/s | 7.6 M vectors/s | `4618392559654806221` -> `13841586174260344571` |

The vectorized loop is 4-5% slower on vMF and neutral on Watson. Each vector
round consumes eight words for all lanes, including lanes accepted in earlier
rounds, so the probe draws about 44% more RNG words than per-lane rejection
(~10.2 words per vector). FastPrng words are cheap enough that the extra words
outweigh the saved scalar branches.

## Decision

Rejected and reverted. The per-lane `unitCircleFrom` draws stay. Recorded in
`performance-triage.md` so the substitution is not retried without a cheaper
lane-compaction scheme (for example reusing accepted lanes' words or packing
the two coordinates into one round only for pending lanes).

## Validation

- `git stash drop` discarded the probe; `git status` is clean at the S4-M1584
  state.
- The rebuilt baseline reproduces the vMF/Watson checksums
  `15146673891782920812` / `4618392559654806221` at 20.2M / 7.6M vectors/s.
- Docs-only milestone: no code, stream, or public API changed.
