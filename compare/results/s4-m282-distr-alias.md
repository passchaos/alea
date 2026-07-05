# S4-M282 Root `distr` Alias

Date: 2026-07-06

## Local Rust Baseline

The local Rust `rand` checkout exposes distribution APIs under `rand::distr`.
Alea's canonical Zig-native module name is `distributions`, but users comparing
local Rust examples often look for the shorter `distr` namespace.

## Alea Change

Alea now provides:

```zig
pub const distr = distributions;
```

The alias is purely discoverability-oriented. It does not rename or deprecate
`distributions`, which remains the canonical Zig-native module name.

## Tests and Validation

Focused test coverage in `src/root.zig`:

- `root distr alias mirrors distributions module` verifies `distr == distributions`
  and sample stream shape through `distr.Uniform` against the canonical
  `distributions.Uniform` sampler.

Documentation/evidence updates:

- `README.md`, `docs/core-guide.md`, and `docs/api-reference.md` document the
  alias.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`,
  `compare/results/linux-no-known-gaps-audit.md`, and `tools/roadmapcheck.zig`
  record the milestone and advance the next-gap row to S4-M283.

Validation commands for this milestone:

```sh
zig fmt src/root.zig tools/roadmapcheck.zig
zig test src/root.zig --test-filter "distr alias"
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
git diff --check
```

## Non-Completion Note

This milestone closes an unblocked local Rust namespace discoverability gap
only. It does not resolve S4-M11's exact/default-compatible dense SIMD
normal/exponential blocker, does not add a new architecture/runtime runner, and
is not whole-goal completion evidence.
