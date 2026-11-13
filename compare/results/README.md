# Comparison and Validation Evidence

This directory contains the checked-in evidence behind the roadmap. Most files
are named `s4-m<id>-<slug>.md` and correspond to one roadmap milestone in
`core-rand-coverage.md`; the roadmap row is the short summary and the evidence
file carries the full command output, benchmark notes, and implementation
details.

Start with these entry points:

- `core-rand-coverage.md` — living roadmap, milestone status, and the source of
  truth for milestone evidence paths.
- `active-goal-completion-audit.md` — current thread-level completion audit.
- `linux-no-known-gaps-audit.md` — local Linux `rand` / `rand_distr` gap audit.
- `performance-triage.md` — adopted and rejected performance changes.
- `reproducibility-matrix.md` — stable, versioned-stable, and non-stable output
  contracts.
- `distribution-parity-matrix.md` — distribution coverage against local Rust.
- `rust-benchmark-coverage-audit.md` — Rust benchmark row coverage.
- `chacha-stream-contract-and-fill-only.md` — ChaCha rekeying contract and
  fill-only throughput evidence.

`zig build roadmapcheck` parses `core-rand-coverage.md` directly, so adding a
new milestone means adding the roadmap row and its evidence file together; no
separate hardcoded evidence list needs to be maintained.
