# S4-M1587 Vector Kent Uniform-Angle Branch

Date: 2026-11-15

## Hypothesis

`vectorKentPointFrom` always drew the conditional angle through the vector von
Mises path: `@cos`, `@log`, and `acos` per rejection round, then `@cos`/`@sin`
of the half angle. The scalar Kent sampler instead uses a uniform-circle
proposal for `a < 1.5` and accepts with the Exp(1) race
`E >= 2a(1 − cos²φ)`, returning the circle point directly with no
trigonometric round trip. Since `a = ovalness·s² ≤ ovalness`, the branch
covers every lane whenever `ovalness < 1.5` (and the benchmark's
`ovalness = 1.5` reaches `a = 1.5` only at `w = 0`).

## Change

After the outer `I₀` acceptance, the vector Kent angle now checks
`@reduce(.And, a < 1.5)`:

- if true, draw four per-lane uniform circle points, run the vector Exp(1)
  race `E >= 2a(1 − cos²φ)`, and retire accepted lanes; the accepted circle
  point is `(cos φ, sin φ)` directly;
- otherwise keep the existing von Mises half-angle path (large `a`).

The scalar `kentPointFrom` path is untouched.

## Performance

Same host, 16MiB rows, best of three trials:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea vector kent f64x4 3d` | 4.8-5.0 M vectors/s | 6.5 M vectors/s | +30-35% |
| `alea kent 3d` | 25.0 M samples/s | 24.9-25.0 M samples/s | parity |
| `alea vector von mises-fisher f64x4 3d` | 32.4-32.5 M vectors/s | 32.4 M vectors/s | unchanged |
| `alea vector watson f64x4 3d` / `alea vector bingham f64x4 3d` | 7.6 M / 7.4-7.5 M | 7.6 M / 7.5 M | unchanged |
| `alea von mises-fisher 3d` / `alea watson 3d` / `alea bingham 3d` | 125-126 / 30.9-31.3 / 30.4-30.6 M | 128.1 / 31.2 / 30.6 M | noise, checksums unchanged |

The vector Kent checksum changes (`16727813968867590217` ->
`5861445844103430486`) because the angle proposal stream changes; the scalar
Kent checksum is unchanged.

## Validation

- `zig build test -Dtest-filter=kent` passes.
- `zig build test distcheck --summary all` passes 963/963 tests (native
  942/942), including the distcheck Kent mean-resultant and major/minor
  variance gates.
- No public API changed; the vector Kent stream is versioned in
  `reproducibility-matrix.md`.
