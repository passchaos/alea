# S4-M65 Example Content Drift Check

Date: 2026-07-04

Purpose: harden example validation beyond catalog presence. Earlier roadmap work
caught a case where evidence claimed an example demonstrated a feature before the
example actually printed it; this milestone makes that class of drift harder to
reintroduce for key adoption examples.

## Change

Updated `tools/examplecheck.zig`:

- each catalog entry can now include `source_tokens`;
- `zig build examplecheck` reads the example source and verifies those tokens;
- focused token checks now cover recent adoption surfaces:
  - `examples/basic.zig`: `index choice`, `const pointer choice`;
  - `examples/weighted_sampling.zig`: `generic weighted index`,
    `weighted ptrs into`, `weighted no-replacement ptrs`;
  - `examples/sequence_sampling.zig`: `IndexVec.valuesInto`,
    `chooseMultiplePtrs`, `reservoirSamplePtrsInto`;
  - `examples/caller_owned_sampling.zig`: `chooseMultiplePtrsInto`,
    `reservoirSamplePtrsInto`, `weighted ptrs into`.

Updated docs:

- `docs/examples.md` explains that `examplecheck` verifies key adoption-output
  tokens in addition to catalog/source/run-step coverage;
- `docs/tooling.md` documents the stronger checker purpose.

## Validation

Commands:

```sh
git diff --check
zig build examplecheck
zig build doccheck
zig build test
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

## S4-M65 Decision

S4-M65 is closed for the current example-content drift bar: key examples now have
source-token checks for the recently added pointer/index/weighted adoption
outputs, so catalog and evidence drift is more likely to be caught by normal
validation.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
