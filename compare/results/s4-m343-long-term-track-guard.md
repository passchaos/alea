# S4-M343 Long-Term Product Track Guard

## Gap

The roadmap's Long-Term Product Tracks section explains why closing stage
milestones is not whole-goal completion: Alea must keep pressure on feature
breadth, statistical confidence, performance, ergonomics, and portability versus
Rust `rand` / `rand_distr`. Before S4-M343, `roadmapcheck` did not guard this
section, so a future edit could accidentally remove the long-term framing while
leaving milestone rows intact.

## Change

`tools/roadmapcheck.zig` now verifies that
`compare/results/core-rand-coverage.md` retains:

- the `## Long-Term Product Tracks` section;
- the non-completion framing that closing a stage only means the current evidence
  bar was met, not that Alea has finished surpassing Rust `rand` / `rand_distr`;
- the five track names: Feature breadth, Statistical confidence, Performance,
  Ergonomics, and Portability;
- representative current-pressure evidence paths such as
  `compare/results/practrand-observation-followup.md`,
  `compare/results/reproducibility-matrix.md`, and
  `compare/results/performance-triage.md`;
- portability pressure for Linux/WASI validation and future QEMU/Wine/native
  second-OS runners.

## Validation

Focused validation command:

```text
$ zig build roadmapcheck
roadmapcheck ok
```

Broader documentation/roadmap validation command:

```text
$ zig build doccheck
apicheck ok
examplecheck ok
toolingcheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M343 is closed for the current bar: the roadmap's long-term product pressure
is now checked by tooling, helping prevent milestone closure from being confused
with whole-goal completion. This is evidence/tooling hardening only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
