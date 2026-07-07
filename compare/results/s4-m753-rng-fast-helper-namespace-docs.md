# S4-M753 Rng Fast Helper Namespace Docs

## Gap

The scalar normal/exponential fast-path helpers are public functions on the
`Rng` namespace in `src/rng.zig`:

- `Rng.standardNormalFastFrom`;
- `Rng.normalFastFrom`;
- `Rng.standardExponentialFastFrom`;
- `Rng.exponentialFastFrom`.

`docs/api-reference.md` and `docs/core-guide.md` listed these helpers as bare
function names, which could mislead users into looking for root-level helpers
that do not exist.

## Local `rand` Baseline

Alea keeps these as explicit Zig namespace functions rather than Rust trait
methods. The docs should name the namespace precisely so users can adopt the
benchmarked direct-source fast paths without guessing imports.

## Documentation Updated

- `docs/api-reference.md` now lists the helpers as `Rng.*FastFrom` in the Rng
  distribution-helper section.
- `docs/core-guide.md` now recommends `Rng.standardNormalFastFrom`,
  `Rng.normalFastFrom`, `Rng.standardExponentialFastFrom`, and
  `Rng.exponentialFastFrom` in the engine/direct-source guidance.

No code behavior changed.

## Validation

Documentation and roadmap validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
examplecheck ok
apicheck ok
readmecheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M753 is closed for the current bar: scalar normal/exponential fast-helper docs
now match the actual `Rng` namespace. This is documentation/discoverability work
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
