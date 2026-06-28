# PractRand Observation Follow-Up

This file keeps Stage 4 statistical observations visible after the 128GiB Linux
validation stage. It exists because Alea's long-term target is product-level
confidence, not merely closing a single milestone.

## Current Observations

| Engine | Observation | Immediate follow-up |
| --- | --- | --- |
| `default` / `Xoshiro256` | One default-seed 128GiB PractRand `unusual` in `[Low4/64]DC6-9x1Bytes-1`; alternate-seed 128GiB run was clean. | Repeat one more 128GiB run with a third seed, then run 256GiB if any low-bit `unusual` recurs. |
| `pcg64` | One default-seed 128GiB PractRand `unusual` in `[Low1/64]BDayS2(4,24)[60]`; alternate-seed 128GiB run was clean. | Repeat one more 128GiB run with a third seed, then run 256GiB if any low-bit `unusual` recurs. |

## Escalation Rules

- A single PractRand `unusual` result is not treated as a failure.
- Repeated `unusual` results in the same low-bit family should trigger engine
  investigation before claiming stronger statistical confidence.
- A `suspicious` or worse PractRand result should be treated as a blocking
  quality issue until investigated.
- Follow-up reports must include the exact seed, byte count, command, result,
  and interpretation.

## Suggested Commands

```sh
zig build -Doptimize=ReleaseFast stream -- --engine default --seed 0xd1ce5eed --bytes 137438953472 \
  | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 128GB -tlmax 128GB

zig build -Doptimize=ReleaseFast stream -- --engine pcg64 --seed 0xd1ce5eed --bytes 137438953472 \
  | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 128GB -tlmax 128GB
```

If either follow-up repeats a low-bit observation:

```sh
zig build -Doptimize=ReleaseFast stream -- --engine <engine> --seed <seed> --bytes 274877906944 \
  | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 256GB -tlmax 256GB
```
