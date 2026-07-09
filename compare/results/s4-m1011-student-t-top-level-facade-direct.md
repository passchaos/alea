# S4-M1011 StudentT Top-Level Facade Direct Paths

## S4-M1149 Supersession Note

S4-M1149 later replaces the former StudentT infinite-degree standard-normal limit extension with local `rand_distr`-compatible NaN output while preserving the corresponding StandardNormal plus ChiSquared/Gamma draw shape. The direct finite-degree composition conclusions below remain relevant; infinite-degree edge semantics now come from S4-M1149.

## Gap

Top-level scalar/vector StudentT facade helpers still routed through direct-source
`From` wrappers. S4-M1010 made reusable scalar/vector StudentT facade sample/fill
paths direct; the top-level checked/nonchecked helpers can now construct reusable
samplers once and call facade `sample` / `fill` directly while preserving
current S4-M1149 infinite-degree NaN/draw-shape behavior and zero-length checked-fill semantics.

## Local `rand` Baseline

Local Rust `rand_distr` `StudentT` workflows sample via reusable samplers and RNG
references. Alea's top-level scalar/vector StudentT helpers should likewise drive
facade `Rng` directly rather than bouncing through direct-source aliases.

## Implementation

- `src/distributions.zig` updates scalar `studentT` / `studentTChecked` to
  construct `StudentT(T)` once and call facade `sample` directly, with
  infinite-degree behavior now superseded by S4-M1149's rand_distr-compatible
  NaN/draw-shape edge.
- `src/distributions.zig` updates scalar `fillStudentT` / `fillStudentTChecked`
  to construct `StudentT(T)` once and call facade `fill` directly, preserving
  the current S4-M1149 infinite-degree NaN/draw-shape edge and checked
  zero-length fast paths.
- `src/distributions.zig` updates `vectorStudentT`, `vectorStudentTChecked`,
  `fillVectorStudentT`, and `fillVectorStudentTChecked` to construct
  `VectorStudentT` once and call facade `sample` / `fill` directly.

## Validation

Focused StudentT tests:

```text
$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused with sample iterators"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "infinite-dof student-t preserves rand_distr-compatible stream shape"
1/2 distributions.test.infinite-dof student-t preserves rand_distr-compatible stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "zero-length core continuous distribution fills do not validate or consume random stream"
1/2 distributions.test.zero-length core continuous distribution fills do not validate or consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "zero-length distribution vector fills do not validate or consume random stream"
1/2 distributions.test.zero-length distribution vector fills do not validate or consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
roadmapcheck ok
apicheck ok
readmecheck ok
examplecheck ok
toolingcheck ok
```

## Result

S4-M1011 is closed for the current bar: top-level scalar/vector StudentT facade
helpers now avoid direct-source wrapper aliases while preserving stream shape,
current S4-M1149 infinite-degree NaN/draw-shape behavior, and zero-length checked fill semantics.
This is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
