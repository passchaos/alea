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

## Local Rust `rand_distr` Codegen Check

The matching Rust benchmark binary (`compare/rand_bench/target/release/alea-rand-compare`)
links dynamically against glibc `libm` and imports `exp`:

```text
libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6
                 U exp
```

Local `rand_distr 0.6.0` implements `LogNormal.sample` as
`self.norm.sample(rng).exp()`. Disassembly of the focused benchmark rows shows
both `LogNormal<f64>` and `LogNormal<f32>` call `exp@GLIBC_2.29` rather than an
`expf` symbol, for example:

```text
<alea_rand_compare::bench_distr_f32::<rand_distr::normal::LogNormal<f32>>>:
    call   *... <exp@GLIBC_2.29>
<alea_rand_compare::bench_distr_f64::<rand_distr::normal::LogNormal<f64>>>:
    call   *... <exp@GLIBC_2.29>
```

A fresh focused Rust run remains around 144.8M f64, 158.9M f32, 80.0M
`stddev=1` f64, and 79.0M `stddev=1` f32 samples/s. This narrows the exact
LogNormal blocker: Rust is not faster because it uses a different distribution
algorithm or an `expf` f32 transform; its benchmark is using dynamic glibc libm
`exp` with LLVM/Rust codegen around the normal source and transform.

A same-host Zig `log-normal-probe -- 4194304 "libc"` rerun after this audit
confirms that simply calling libc from Zig is not enough to match Rust's
single-sample rows. Zig libc sample rows were about 118.3M f64 FastPrng,
133.8M f64 ScalarPrng, 119.9M f32 FastPrng, and 136.6M f32 ScalarPrng, with
wide `stddev=1` rows about 58.4M/63.9M f64 and 56.0M/61.6M f32. Staged libc
fill rows were better, about 136.5M/143.1M f64 and 142.0M/150.8M f32, but
still below or only near Rust's single-sample rows and not a production default
replacement. The remaining gap is therefore likely Rust/Zig codegen and loop
context around the dynamic libm call, not just the choice of libm symbol.

A direct `zig build-exe -dynamic -lc` build of `tools/log_normal_probe.zig`
confirms that forcing the probe executable itself to be dynamically linked does
not change this conclusion. The dynamic binary links `libm.so.6` and `libc.so.6`
(and `libmvec.so.1` because the probe contains libmvec rows), but focused
`"libc"` rows stay in the same range: about 118M/134M f64 FastPrng/ScalarPrng,
120M/137M f32, and staged libc fill around 137M/143M f64 and 142M/151M f32.
Thus executable link mode alone does not reproduce Rust's LogNormal codegen
advantage.

A direct `zig build-exe -fno-compiler-rt -lc -lm` experiment failed to link the
`log-normal-probe` binary because other parts of the Zig/std code still require
compiler-rt integer helper symbols such as `__floattidf` and `__divti3`. This
means the exact `@exp` lowering cannot be redirected to system libm by simply
removing compiler-rt from this executable.

`-fbuiltin` / `-fno-builtin` command-line variants of the libc-linked
`log-normal-probe` also do not change the conclusion. Focused `"sample current"`
rows stayed in the same band: `-fbuiltin` around 115.7M/136.2M f64 and
119.8M/135.6M f32, `-fno-builtin` around 117.4M/134.2M f64 and 121.4M/135.9M
f32 for FastPrng/ScalarPrng. Builtin function knowledge is not the missing
exact-default lever.

A scratch probe also checked whether a function-pointer or `noinline` boundary around
Zig `@exp` itself reproduces the dlsym speedup while preserving exact compiler-rt
outputs. It does not: direct/noinline/function-pointer/inline-wrapper `@exp`
rows all stayed around 116M FastPrng and 131-132M ScalarPrng for f64
`stddev=0.25`, with matching checksums. The dlsym improvement is therefore tied
to glibc's scalar `exp` implementation/call target, not merely to introducing a
function-call boundary around compiler-rt `@exp`.

A further scratch probe resolved glibc `exp` once with `std.DynLib.open("libm.so.6")`
/ `dlsym` and called the function pointer directly. This call-boundary shape is
much faster for f64 single-sample rows: about 162.8M FastPrng and 186.2M
ScalarPrng at `stddev=0.25`, and the same rates at `stddev=1`. It differs from
Zig `@exp` by at most 1 ULP in a 4Mi f64 sample. For f32, default-normal rows
are only about 131.2M/146.3M, while native-normal+dlsym reaches about
138.9M/161.5M with max 1 ULP versus default f32 `@exp`. This is useful evidence
for a high-accuracy platform opt-in shape, but it is not an exact default
replacement because it changes bit outputs and is slower than the already added
`LogNormalLibmvec` platform profile for throughput.

A follow-up scratch probe checked whether mimicking Rust's f32 `exp` symbol by
widening f32 log-space samples to f64, calling libc `exp`, and casting back to
f32 helps. It does not: default-normal rows were about 98.9M FastPrng and
108.7M ScalarPrng, while native-normal rows were about 105.5M and 117.8M. This
is below current exact f32 rows and far below Rust f32 around 159M, so the Rust
f32 `exp@GLIBC_2.29` observation is not by itself a production direction for
Alea.

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

A full-sample-loop `@setFloatMode(.optimized)` scratch probe was also too small
and mixed to matter: narrow f64 rows moved only from about 118M/133M to
120M/135M FastPrng/ScalarPrng, and `stddev=1` stayed around 57M/60M.

No exact-default expression variant has enough evidence to replace direct
`@exp`. The accepted production changes remain limited to:

- explicit standard-normal expression and `mean == 0` branch for scalar samples,
- staged bulk normal fill plus scale/`@exp`,
- f32 direct-source bulk improvements that preserve exact checksums,
- `BufferedLogNormal` for repeated-sample users with an explicit refill contract,
- `LogNormalDlsymExp` and `LogNormalLibmvec` as libc-linked platform opt-ins
  with documented ULP/output-mapping and availability tradeoffs,
- explicit opt-in f32/native/exp2 profiles with documented output-mapping or
  approximation tradeoffs.

A future exact LogNormal candidate should include both:

1. codegen evidence showing a different exact `exp` lowering or call pattern,
   and
2. same-run `log-normal-probe` plus main `bench` evidence showing no regression
   across f64/f32, facade/direct, and narrow/wide spread rows.
