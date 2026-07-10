# S4-M1199 Ziggurat Table Surface Guard

## Gap

The cached local `rand_distr 0.6.0` `ziggurat_tables.rs` file exposes public
implementation-table symbols:

```text
pub type ZigTable = &'static [f64; 257];
pub const ZIG_NORM_R: f64 = 3.654152885361008796;
pub static ZIG_NORM_X: [f64; 257] = ...;
pub static ZIG_NORM_F: [f64; 257] = ...;
pub const ZIG_EXP_R: f64 = 7.697117470131050077;
pub static ZIG_EXP_X: [f64; 257] = ...;
pub static ZIG_EXP_F: [f64; 257] = ...;
```

S4-M294 listed `ziggurat_tables.rs` and mentioned only `ZigTable`,
`ZIG_NORM_R`, and `ZIG_EXP_R`. The source-driven `surfacecheck` guard also only
extracted top-level `pub mod` / `pub fn` / `pub struct` / `pub enum` /
`pub trait` / `pub type` declarations, so public `const` and `static` table
names were not guarded against future drift.

These Rust table values are implementation scaffolding, not a Zig-native public
workflow Alea should copy. The gap was in manifest precision and guard coverage,
not in production sampling behavior.

## Change

- `compare/results/s4-m294-rand-distr-public-surface-manifest.md` now lists all
  public `ziggurat_tables` symbols: `ZigTable`, `ZIG_NORM_R`, `ZIG_NORM_X`,
  `ZIG_NORM_F`, `ZIG_EXP_R`, `ZIG_EXP_X`, and `ZIG_EXP_F`.
- `tools/surfacecheck.zig` now extracts top-level public `const` and `static`
  declarations, and public `const` / `static` declarations inside public types,
  in addition to functions/types.
- The local `rand_distr` expected-token set now explicitly guards
  `MAX_LAMBDA` plus all public ziggurat table symbols, raising the current
  local `rand_distr` surface count from 64 expected / 178 source tokens to
  72 expected / 185 source tokens.

## Validation

```text
$ zig build surfacecheck
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=72 source-tokens=185
surfacecheck ok

$ zig build validate-local
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=72 source-tokens=185
surfacecheck ok
rand_bench_smoke self-test ok
runtimecheck ok: no additional runtime runner available
```

Additional local comparison validation is recorded in the commit closing this
milestone.

## Result

S4-M1199 is closed for the current bar: the local `rand_distr` public-surface
manifest and `surfacecheck` guard now cover public `const` / `static` table
symbols from `ziggurat_tables.rs`. This is public-surface guard evidence, not
whole-goal completion; S4-M1200 remains active.
