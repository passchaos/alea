# S4-M1552 Reproducibility Matrix HIN Stream Entry

Date: 2026-11-15

## Gap

S4-M1550 changed the HIN small-`p` binomial rejection stream when it added
the left-envelope `c/4` height offset. `compare/results/reproducibility-matrix.md`
is the stream-contract source of truth and did not yet list the change, so the
matrix would have claimed the older HIN stream for the affected parameter
region.

## Change

- The versioned-stream narrative records the S4-M1550 HIN left-envelope
  offset and its `+0.015` mean-bias removal.
- The versioned-stream evidence table adds
  `HIN small-p left-envelope offset (c/4, removes the +0.015 mean bias)`
  pointing at `compare/results/s4-m1550-hin-left-envelope-bias.md`.
- No code, stream, or benchmark changed in this milestone; it is docs-only.

## Validation

- `zig build roadmapcheck` and `zig build doccheck` pass.
- The referenced evidence file records the exactness model, the dominance
  grid, the multi-seed Zig means, and the `distcheck` gates.
