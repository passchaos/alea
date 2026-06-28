# PractRand 128GiB Follow-Up: DefaultPrng Third Seed

Timestamp: 2026-06-29 CST

PractRand 0.96 was built under `/tmp/practrand/PractRand`. `DefaultPrng`
(`Xoshiro256`) was tested through `zig build stream` with `stdin64`, `-tlmin
128GB`, and `-tlmax 128GB`.

This is the third-seed follow-up requested by
`compare/results/practrand-observation-followup.md` after the default-seed
128GiB run produced one low-bit `unusual` and the first alternate-seed run was
clean.

## Command

```sh
zig build -Doptimize=ReleaseFast stream -- --engine default --seed 0xd1ce5eed --bytes 137438953472 \
  | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 128GB -tlmax 128GB
```

## Result

```text
RNG_test using PractRand version 0.96
RNG = RNG_stdin64, seed = unknown
test set = core, folding = standard (64 bit)

rng=RNG_stdin64, seed=unknown
length= 128 gigabytes (2^37 bytes), time= 963 seconds
  no anomalies in 320 test result(s)
```

## Interpretation

The low-bit `unusual` from the default-seed 128GiB run did not reproduce across
two same-length alternate-seed runs. Keep the observation visible for longer
future stages, but no immediate engine change is indicated by this follow-up.
