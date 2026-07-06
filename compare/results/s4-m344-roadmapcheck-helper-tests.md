# S4-M344 Roadmapcheck Helper Tests

## Gap

`roadmapcheck` has become a central guard for the roadmap, active-goal audit,
Linux no-known-gaps audit, local Rust public-surface manifests, S4-M11 blocker
evidence, completion criteria, current-rule policy, and long-term product-track
pressure. Before S4-M344, `zig build roadmapcheck` only ran the executable audit;
its helper token-checking logic had no focused unit tests wired into the build
step.

## Change

`tools/roadmapcheck.zig` now includes focused tests for `checkManifestTokens`:

- missing-token paths increment the missing counter and report the absent token;
- all-present paths leave the missing counter and output empty.

`build.zig` now creates `alea-roadmapcheck-tests` and makes `zig build
roadmapcheck` run those tests before the `alea-roadmapcheck` executable audit.
`zig build doccheck` now depends on the full `roadmapcheck` step, not only the
checker executable, so documentation validation also includes the helper tests.

`tools/toolingcheck.zig` guards the new roadmapcheck dependency shape, and
`docs/tooling.md` documents that roadmapcheck runs helper tests.

## Validation

Focused validation command:

```text
$ zig build roadmapcheck
roadmapcheck ok
```

Broader documentation/roadmap validation command:

```text
$ zig build doccheck
toolingcheck ok
readmecheck ok
roadmapcheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M344 is closed for the current bar: roadmap/audit evidence checking now has a
focused helper-test layer that runs before the executable audit. This is
evidence/tooling hardening only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
