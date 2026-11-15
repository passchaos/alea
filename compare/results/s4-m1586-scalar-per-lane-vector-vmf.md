# S4-M1586 Scalar-Per-Lane Vector vMF

Date: 2026-11-15

## Hypothesis

After S4-M1583 the S² vMF cosine marginal inverts in one `log` and the
tangent direction comes from a scalar circle rejection. Those are scalar
transcendental/rejection operations, so packing four lanes into one SIMD loop
pays vector splat/select overhead without vectorizing the expensive work.
Four scalar `vonMisesFisherPointFrom` calls may therefore beat the packed
loop while keeping the `[3]VectorType` per-lane API.

## Probe

`VectorVonMisesFisher.sampleFrom` now fills one vector by calling the scalar
S² vMF sampler once per lane:

```zig
inline for (0..L) |lane| {
    const point = vonMisesFisherPointFrom(source, Child, 3, &mean_dir, kappa);
    inline for (0..3) |i| out[i][lane] = point[i];
}
```

The `kappa == 0` and `kappa > 1e12` early paths are handled by the scalar
sampler (uniform sphere and point mass, respectively). Same host, 16MiB rows:

| Row | Packed SIMD (baseline) | Scalar per lane | Checksum |
| --- | --- | --- | --- |
| `alea vector von mises-fisher f64x4 3d` | 20.1-20.2 M vectors/s | 31.4-32.5 M vectors/s | `15146673891782920812` -> `176802322559618529` |
| `alea von mises-fisher 3d` | 126.2 M samples/s | 125.2 M samples/s | `183813184205834138` (unchanged) |
| `alea vector watson f64x4 3d` | 7.6 M vectors/s | 7.6 M vectors/s | unchanged |
| `alea vector bingham f64x4 3d` | 7.4 M vectors/s | 7.4 M vectors/s | unchanged |
| `alea vector kent f64x4 3d` | 4.8-5.0 M vectors/s | 4.9 M vectors/s | unchanged |

The scalar vMF row is unchanged, so this adoption does not repeat the
scalar-layout regression seen in the earlier vector-Kent scalar fallback.

## Related Probe (Rejected)

The same scalar-per-lane substitution for `VectorKent.sampleFrom` was measured
in the same batch and rejected: `alea vector kent f64x4 3d` moved 5.0 -> 4.6M
and scalar `alea kent 3d` dropped 25.1 -> 18.4M through code layout, matching
the S4-M1346 warning. The Kent vector sampler keeps its SIMD outer loop.

## Decision

Adopted as S4-M1586. `VectorVonMisesFisher` keeps its per-lane vector API but
draws each lane with the exact scalar S² vMF sampler; the stream changes and
`reproducibility-matrix.md` records it. The packed `vectorVmfSampleW3From`
helper remains in use for the Kent proposal.

## Validation

- `zig build test distcheck --summary all` passes 963/963 tests (native
  942/942), including the vector vMF unit-vector/mean tests, the f32x8 vector
  path, and the distcheck vMF mean-resultant and matrix-vMF first-column gates.
- Bingham, Watson, Kent, and scalar vMF checksums are unchanged; only the
  vector vMF stream changes.
