# S4-M1392 — Direct formulas for the Fisher-F, Student-t, and chi facades

## Goal

Route the top-level `fisherF`, `studentT`, and `chi` functions (and their
checked variants) through the existing direct formulas instead of constructing
a reusable sampler per call, so the facade rows stop paying the sampler setup
on every draw.

## Implementation

- `fisherF`/`fisherFChecked`/`fisherFCheckedFrom` now validate parameters and
  call `fisherFFrom`, which evaluates `χ²(d1)/d1 ÷ χ²(d2)/d2` directly. The
  reusable `FisherF` sampler still caches its two Gamma samplers for
  repeated draws.
- `studentT`/`studentTChecked`/`studentTCheckedFrom` validate and call
  `studentTFrom` (`normal · √(dof/χ²(dof))`), with the infinite-dof path
  unchanged.
- `chi`/`chiChecked`/`chiCheckedFrom` validate and call `chiFrom`
  (`√χ²(dof)`), and the `chiSquaredChecked` variants call `chiSquaredFrom`.
- All three facades keep bit-identical benchmark checksums: the direct
  formulas consume the same stream and produce the same values as the
  per-call sampler path.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea fisher-f` | 88.2-89.0M samples/s | 144.4-145.4M samples/s | +63% |
| `alea student-t` | 220.5-226.5M samples/s | 227.7-228.7M samples/s | +2% (within noise) |
| `alea chi` | 206.5-208.6M samples/s | 203.6-211.1M samples/s | neutral |

Checksums are unchanged for every row: `fisher-f` `145671.291`, `student-t`
`-266.472`, and `chi` `246273.507`. The Fisher-F gain comes from removing two
`Gamma(T).init` calls per draw (the Marsaglia constants and validation), which
cost about 6.6 ns of the previous 11.1 ns.

## Validation

- All Fisher-F, Student-t, chi, and chi-squared tests pass.
- `zig build test` passes 899/899, including `apicheck` and `roadmapcheck`.
- `zig build distcheck` passes and `zig build statcheck` passes.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners, further facade-overhead reduction, or newly
discovered core gaps.
