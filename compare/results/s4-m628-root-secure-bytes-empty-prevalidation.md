# S4-M628 Root Secure Bytes Empty Prevalidation

## Gap

Root `secureBytes` delegated directly to `std.Io.randomSecure` even for empty
buffers. Empty buffers do not need entropy and should return deterministically.

This milestone aligns `secureBytes` with the rest of Alea's root fill helpers,
which return before entropy for empty destinations.

## API Changed

`src/root.zig` now prevalidates:

- `secureBytes`

The public signature is unchanged.

Deterministic pre-entropy behavior is explicit:

- Empty buffers return before requesting system entropy.
- Non-empty buffers still delegate to `std.Io.randomSecure` and report entropy
  failures normally.

## Adoption and Documentation

- Focused root tests cover empty-buffer no-entropy behavior and failing-entropy
  non-empty behavior.
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

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

Broader native test gate:

```text
$ zig build test
examplecheck ok
apicheck ok
toolingcheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M628 is closed for the current bar: root secure byte helper now returns for
empty buffers before requesting system entropy. This is reliability and
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
