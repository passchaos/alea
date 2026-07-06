# S4-M318 `validate-local` Evidence Normalization

Date: 2026-07-06

## Purpose

S4-M317 added `zig build validate-local`. While reviewing the evidence before
continuing, the command shown in the "Change" section had been overwritten with
the ReleaseFast validation invocation. S4-M318 fixes the evidence wording so the
feature command and the proof command are distinct.

## Change

`compare/results/s4-m317-validate-local.md` now records:

- `zig build validate-local` as the generic command added by the milestone;
- `zig build -Doptimize=ReleaseFast validate-local` as the actual validation
  command executed for local proof.

## Validation

Relevant validation:

```sh
zig build roadmapcheck
zig build doccheck
zig build test
git diff --check
```

## Non-Completion Note

This milestone improves evidence clarity. It does not resolve S4-M11's
exact/default-compatible dense SIMD normal/exponential blocker, does not add an
additional architecture/runtime runner, and is not whole-goal completion
evidence.
