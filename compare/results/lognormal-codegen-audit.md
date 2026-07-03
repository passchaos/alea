# LogNormal Codegen Audit

Date: 2026-07-03

This note records current local codegen evidence for the exact `LogNormal`
S4-M4 blocker. It is intentionally narrow: it does not propose another default
change, and it exists to prevent repeating expression-level attempts that the
main benchmark has already rejected.

## Focused Probe

Command:

```sh
zig build -Doptimize=ReleaseFast -Dcpu=native log-normal-probe -- 1048576 "sample"
```

Representative rows from the latest local run:

| Row | FastPrng | ScalarPrng | Notes |
| --- | ---: | ---: | --- |
| f64 current | 111.2M | 134.6M | checksum matches expression variants |
| f64 `standard+scale` | 117.3M | 134.7M | small FastPrng movement, ScalarPrng flat |
| f64 `@mulAdd` | 117.5M | 133.2M | not a cross-engine win |
| f64 `std.math.exp` | 117.2M | 134.9M | tied/no durable production win |
| f64 libc `exp` | 117.6M | 133.8M | tied and requires libc/profile-specific linkage |
| f64 `stddev=1` current | 58.5M | 63.7M | wide-spread exact transform remains much slower |
| f32 current | 121.2M | 136.1M | checksum matches exact variants |
| f32 native-normal exact `@exp` | 130.3M | 147.6M | separate output mapping; exposed as opt-in profile |
| f32 `std.math.exp` | 119.6M | 136.3M | not a win |
| f32 libc `expf` | 120.4M | 136.1M | tied and requires libc/profile-specific linkage |
| f32 widened f64 `exp` | 98.4M | 109.2M | slower despite close accuracy |
| f32 `expm1 + 1` | 113.8M | 122.9M | slower for single samples and wider-error profile |
| f32 `stddev=1` current | 56.6M | 61.2M | wide-spread exact transform remains much slower |

## Symbol / Disassembly Observation

The latest `alea-log-normal-probe` ReleaseFast/native binary contains local
compiler-rt symbols for exponential transforms:

```text
0000000001100870 t exp
00000000011009f0 t expf
```

Disassembly shows repeated direct calls to compiler-rt `exp` from the exact
LogNormal transform loops, for example:

```text
call   1100870 <compiler_rt.exp.exp>
```

The exp2 approximation rows similarly call compiler-rt `exp2`:

```text
call   11005f0 <compiler_rt.exp2.exp2>
```

This confirms the exact default bottleneck is the scalar exponential transform
call/codegen rather than missing reusable-sampler dispatch specialization. That
matches the existing `lognormal-transform-notes.md` conclusion and the raw
single-sample rows in `performance-triage.md`.

## Libmvec Follow-up

A later Linux-local probe linked `log-normal-probe` to glibc `libmvec` on
x86_64-linux-gnu and called the vector math ABI symbols directly
(`_ZGVbN2v_exp`, `_ZGVcN4v_exp`, `_ZGVcN8v_expf`). This does provide a
different call pattern from the compiler-rt scalar `exp` / `expf` calls and is
much faster in staged fills, but it is not exact-default evidence: checked
outputs differ from direct `@exp` for roughly half of the samples with max 3
ULP in the `stddev=0.25` and `stddev=1.0` probes. Treat libmvec as a deferred
platform-specific opt-in candidate rather than a replacement for exact
`LogNormal`.

## Current Conclusion

No exact-default expression variant has enough evidence to replace direct
`@exp`. The accepted production changes remain limited to:

- explicit standard-normal expression and `mean == 0` branch for scalar samples,
- staged bulk normal fill plus scale/`@exp`,
- f32 direct-source bulk improvements that preserve exact checksums,
- explicit opt-in f32/native/exp2 profiles with documented output-mapping or
  approximation tradeoffs.

A future exact LogNormal candidate should include both:

1. codegen evidence showing a different exact `exp` lowering or call pattern,
   and
2. same-run `log-normal-probe` plus main `bench` evidence showing no regression
   across f64/f32, facade/direct, and narrow/wide spread rows.
