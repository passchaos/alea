# S4-M1792 Gate the Vector von Mises Slow Test on the Squeeze

Date: 2026-11-20

## Gap

The SIMD von Mises sampler (`vonMisesVectorFrom`) evaluated both Best–Fisher
acceptance tests for every lane on every round:

```zig
const fast = (c * (two - c) - ub) > zero;
const slow = (@log(c / ub) + one - c) >= zero;
const accept = active & (fast | slow);
```

The scalar path only pays for the `log` when the squeeze test fails, but the
vector path always ran a four-lane `@log` (plus a division), even when every
active lane already passed the squeeze. The vector row measured 6.8-7.0M
vectors/s against 37.4M scalar samples/s.

## Change

The slow test is now computed only when at least one active lane needs it:

```zig
const needs_slow = active & ~fast;
const accept = if (@reduce(.Or, needs_slow))
    active & (fast | ((@log(c / ub) + one - c) >= zero))
else
    active & fast;
```

The acceptance decision is unchanged (the same `fast | slow` mask), and no
random draws are added or removed, so the emitted stream is identical — the
harness checksum is unchanged.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M vectors/s) | After (M vectors/s) |
| --- | --- | --- |
| `vector von mises f64x4` | 6.8, 6.8, 7.0, 7.0 | 7.4, 7.5, 7.7, 7.7 |

About +10% with every new run above every old run and an unchanged checksum.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

The other vector directional samplers are already at scalar parity per
sample; the wrapped skew-normal quantile remains the slowest model row.
