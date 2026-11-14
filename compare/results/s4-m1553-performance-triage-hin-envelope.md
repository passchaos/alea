# S4-M1553 Performance Triage HIN Envelope Adoption

Date: 2026-11-15

## Gap

`compare/results/performance-triage.md` still listed the two rejected HIN
envelope probes (region-1 `c` correction and region-2 `c2 = −0.2`) as the
latest state and told future work to try "a mean-dependent envelope
correction or the original paper's discrete constants". S4-M1550 found the
actual root cause and fixed it, so the triage would have sent the next
attempt down the same failed path.

## Change

- Adds an `HIN small-p envelope dominance` row recording that the offset was
  a dominance failure for the flat cells below the mode, not a constant
  shift, and that `c2 = +c/4` restores exactness (zero violations on the
  66-parameter grid; exact model `20.000000`; Zig means `19.9992..20.0004`).
- Notes the about 19% region-2 envelope-mass increase and roughly 5%
  acceptance-rate cost.
- Updates the `Next Candidate` central-binomial bullet so the remaining
  binomial pressure is facade overhead and the small-mean inverse-CDF
  layout, not a missing envelope correction.
- No code, stream, or benchmark changed in this milestone; it is docs-only.

## Validation

- `zig build roadmapcheck` and `zig build doccheck` pass.
- The referenced S4-M1550 evidence file records the exactness model,
  dominance grid, multi-seed means, and `distcheck` gates.
