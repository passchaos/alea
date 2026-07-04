# S4-M35 Caller-Owned Reservoir Sampling

Date: 2026-07-04

Purpose: improve sequence-sampling ergonomics and allocation control after adding
fixed-size item arrays and one-shot weighted item choice. Alea already exposed
allocation-returning reservoir sampling; this milestone adds a caller-owned
output-buffer form for stream/sample-fill style workflows.

## Change

Added caller-owned reservoir helpers in `src/seq.zig`:

- `reservoirSampleInto(rng, T, items, out) Error!void`
- `reservoirSampleIntoFrom(source, T, items, out) Error!void`

The helpers fill `out` with a uniform sample without replacement from `items`.
They return `error.InvalidParameter` before drawing when `out.len > items.len`.
Zero-length output returns immediately without consuming randomness. The existing
allocation-returning `reservoirSampleFrom` now delegates to `reservoirSampleIntoFrom`
after allocation, so allocated and caller-owned reservoir paths share the same
sampling logic.

Updated adoption/docs:

- `examples/sequence_sampling.zig` prints both allocated `reservoirSample` and
  caller-owned `reservoirSampleInto` samples;
- `docs/examples.md` describes allocated/caller-owned reservoir sampling;
- `docs/core-guide.md` and `docs/api-reference.md` list the new APIs;
- `README.md` mentions caller-owned reservoir sampling;
- `compare/results/distribution-parity-matrix.md` and
  `compare/results/linux-no-known-gaps-audit.md` record the sequence ergonomics
  improvement.

## Validation

Commands:

```sh
zig build test
zig build run-sequence-sampling
zig build doccheck
zig build -Doptimize=ReleaseFast validate
```

Result: passed.

Focused tests cover:

- caller-owned output length and facade/direct forms;
- zero-length no-consume behavior;
- invalid output length no-consume behavior;
- allocated and caller-owned stream-shape parity through facade/direct tests.

## S4-M35 Decision

S4-M35 is closed for the current caller-owned reservoir sampling bar: users can
choose allocation-returning reservoir samples or fill their own buffers while
retaining checked no-consume behavior for invalid lengths.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
