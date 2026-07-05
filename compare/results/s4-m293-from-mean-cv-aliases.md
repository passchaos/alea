# S4-M293 `rand_distr` `from_mean_cv` Aliases

Date: 2026-07-06

## Local Rust Baseline

The cached local `rand_distr 0.6.0` crate exposes coefficient-of-variation
constructors on normal-family samplers:

- `Normal::from_mean_cv(mean, cv)`
- `LogNormal::from_mean_cv(mean, cv)`

Alea already exposed the same parameterization through Zig-native
`initMeanCv(mean, coefficient_of_variation)` constructors on `Normal(T)` and
`LogNormal(T)`. The missing piece was the Rust-discoverable constructor name.

## Alea Change

Alea now provides:

```zig
pub fn Normal(T).fromMeanCv(mean: T, coefficient_of_variation: T) Error!Normal(T)
pub fn LogNormal(T).fromMeanCv(mean: T, coefficient_of_variation: T) Error!LogNormal(T)
```

These aliases delegate to the existing `initMeanCv` constructors, preserving
Alea's existing validation, diagnostics, and linear/log-space parameterization.

## Tests and Validation

Focused test coverage in `src/distributions.zig`:

- `rand_distr fromMeanCv aliases mirror initMeanCv constructors` verifies that
  the alias constructors match canonical `initMeanCv` outputs for normal and
  log-normal samplers, and verifies representative invalid-parameter errors.

Documentation/evidence updates:

- `docs/core-guide.md` and `docs/api-reference.md` document the aliases.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M294.

Validation commands for this milestone:

```sh
zig fmt src/distributions.zig tools/roadmapcheck.zig
zig test src/distributions.zig --test-filter "fromMeanCv aliases"
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```

## Non-Completion Note

This milestone closes a local `rand_distr` constructor-discovery side gap only.
It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
