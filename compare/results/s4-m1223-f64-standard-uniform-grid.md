# S4-M1223 f64 StandardUniform 53-bit Grid Consistency

## Why this was correctness-first

While auditing ordinary uniform float paths after S4-M1222, Alea had an
internal inconsistency:

- facade `Rng.float(f64)` used the local Rust `StandardUniform`-style high
  53-bit grid, `n / 2^53`;
- direct-source `Rng.floatFrom(source, f64)`, f64 bulk fills, and ordinary f64
  vector generation used a faster exponent-bit construction with only the high
  52 bits.

That made `Rng.value(f64)`, `distributions.StandardUniform.sampleFrom`,
`fill(..., f64)`, value-iterator fills, and vector ordinary uniform generation
less precise than the facade scalar path and less aligned with the local Rust
reference in `~/Work/rand/src/distr/float.rs`, whose `StandardUniform` f64
implementation consumes the high 53 random bits.

Correctness takes precedence over the previously documented speed win from the
52-bit exponent-bit bulk path. Any performance recovery should happen later
without changing the public `[0, 1)` f64 grid contract.

## Change

- `src/rng.zig` now maps ordinary direct-source f64 uniforms with
  `@floatFromInt(raw >> 11) * 2^-53`.
- `vectorF64From` now uses the same high-53-bit conversion per lane.
- Strict-open f64 helpers still use their endpoint-specific exponent-bit grid;
  this change is limited to ordinary half-open `[0, 1)` f64 StandardUniform
  semantics.
- Added a focused unit test covering:
  - raw zero -> `0.0`;
  - raw `1 << 11` -> the first 53-bit ULP, `2^-53`;
  - raw max -> `1.0 - 2^-53`;
  - facade/direct scalar parity;
  - bulk fill parity;
  - ordinary `@Vector(4, f64)` parity.

## Local Rust reference

`~/Work/rand/src/distr/float.rs` documents and implements `StandardUniform` for
f64 as a multiply-based method using 53 random bits:

```rust
let precision = $fraction_bits + 1; // f64: 53
let scale = 1.0 / ((1 as $u_scalar << precision) as $f_scalar);
let value: $uty = rng.random();
let value = value >> $uty::splat(float_size - precision);
$ty::splat(scale) * $ty::cast_from_int(value)
```

Alea now matches that grid for ordinary f64 StandardUniform workflows.

## Validation

Focused regression:

```console
$ zig test src/rng.zig --test-filter "ordinary f64 standard uniform"
1/1 rng.test.ordinary f64 standard uniform uses full 53-bit grid on all paths...OK
All 1 tests passed.
```

Project unit and documentation gate:

```console
$ zig build test
examplecheck ok
apicheck ok
toolingcheck ok
roadmapcheck ok
readmecheck ok
```

Broader native validation after roadmap/status synchronization:

```console
$ zig build validate
...
toolingcheck ok
roadmapcheck ok
statcheck ok
distcheck ok
profilecheck ok
```

Local Rust comparison/status aggregate:

```console
$ zig build validate-local
...
surfacecheck ok
runtimecheck ok: no additional runtime runner available
rand-status self-test ok
```

S4-M1223 is closed for the current bar: the newly discovered f64
StandardUniform precision/consistency gap is fixed and guarded. The next product
bar is S4-M1224.
