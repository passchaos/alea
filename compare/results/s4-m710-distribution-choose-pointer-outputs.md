# S4-M710 Distribution Choose Pointer Outputs

## Gap

Distribution-layer `Choose` now has fixed-size and owned repeated value outputs.
It still lacked stack-friendly and allocation-returning pointer outputs, forcing
users to manually allocate/fill `*const T` buffers even though `Choose` primarily
samples references over a caller-owned slice.

Distribution-layer `Choose` should offer pointer array and owned pointer helpers
matching its existing caller-owned pointer fill.

## Local `rand` Baseline

The local Rust `rand` checkout exposes distribution/slice choice samplers that
return references. Alea's distribution-layer `Choose(T)` can expose this
reference-oriented workflow directly as fixed-size arrays and allocator-returning
slices of pointers.

## API Added

`src/distributions.zig` adds pointer output helpers to `Choose(T)`:

- `Choose(T).ptrs`
- `Choose(T).ptrsFrom`
- `Choose(T).ptrArray`
- `Choose(T).ptrArrayFrom`

`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- Pointer arrays and owned pointer batches delegate to the existing `fillFrom`
  stream policy.
- Zero-length outputs are supported through the allocator/array shape.
- Singleton choices preserve no-random-stream behavior.

## Adoption and Documentation

- Focused distribution tests compare owned pointer output and fixed pointer
  arrays against `fillFrom`, confirming identical stream shape.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "distribution Choose sampler mirrors slice choices"
1/2 distributions.test.distribution Choose sampler mirrors slice choices...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

No output.

Broader native test gate:

```text
$ zig build test
apicheck ok
examplecheck ok
roadmapcheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M710 is closed for the current bar: distribution-layer `Choose` now has
fixed-size and owned pointer outputs matching local Rust's reference-oriented
choice workflow. This is ergonomics work only; it does not resolve S4-M11 and is
not whole-goal completion evidence.
