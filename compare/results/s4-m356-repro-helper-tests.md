# S4-M356 Repro Helper Tests

## Gap

`zig build repro` prints deterministic engine and seed snapshots used by the
reproducibility evidence workflow. Before S4-M356, the executable initialized
engines inline and printed snapshots without focused helper tests wired into the
build step.

## Change

`tools/repro.zig` now factors deterministic engine initialization through
`initEngine` and includes focused tests for:

- canonical deterministic initialization for regular engines;
- ChaCha's `initFromU64` initialization path;
- stable `Seed.fromString("repro")` and `seed.stream(7)` snapshots.

`build.zig` now creates `alea-repro-tests` and makes `zig build repro` run those
tests before `alea-repro` prints deterministic snapshots.

`tools/toolingcheck.zig` guards this new dependency shape, and `docs/tooling.md`
documents that repro runs helper tests.

## Validation

Focused validation command:

```text
$ zig build repro
alea4x64 ...
...
seed.fromString(repro)=0x80d3f431deaa1604
seed.stream(7)=0x57d26fe02eebb5a4
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

S4-M356 is closed for the current bar: reproducibility snapshot output now has a
focused helper-test layer that runs before printing snapshots. This is
evidence/tooling hardening only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
