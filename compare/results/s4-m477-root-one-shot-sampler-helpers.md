# S4-M477 Root One-Shot Sampler Helpers

## Gap

The root system-entropy API gained one-shot helpers for many built-in value,
range, string, duration, and Unicode workflows, but users still had to construct
a secure engine before sampling from arbitrary reusable samplers such as
`distributions.Uniform`, mapped samplers, or other Zig-native sampler values.
Alea should let root callers provide a sampler directly while preserving explicit
`std.Io` entropy.

## API Added

`src/root.zig` now exposes:

- `sample`
- `fillSample`
- `sampleBatch`

Empty caller-owned fills and zero-count batches return without drawing entropy.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `root sampler helpers` output.
- `tools/examplecheck.zig` guards those example tokens.
- `docs/api-reference.md` lists the new root public symbols.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused root tests:

```text
$ zig test src/root.zig --test-filter "root random helpers"
1/3 root.test_0...OK
2/3 root.test.root random helpers use explicit system entropy...OK
3/3 root.test.root random helpers validate deterministic cases before entropy...OK
All 3 tests passed.
```

Runnable example and guard checks:

```text
$ zig build run-basic
root sampler helpers: sampleDie=2, sampleFill={ 4, 3, 5, 2 }, sampleBatch={ 1, 3, 5, 4 }
```

```text
$ zig build examplecheck
examplecheck ok
```

```text
$ zig build apicheck
apicheck ok
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

Broader native test gate:

```text
$ zig build test
examplecheck ok
readmecheck ok
toolingcheck ok
apicheck ok
roadmapcheck ok
```

```text
$ git diff --check
```

## Result

S4-M477 is closed for the current bar: root system-entropy callers can sample,
fill, and allocate from arbitrary reusable samplers without manually constructing
a secure engine. This is API ergonomics work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
