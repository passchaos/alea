# PractRand 128GiB Runs: DefaultPrng

Timestamp: 2026-06-28 CST

PractRand 0.96 was built under `/tmp/practrand/PractRand`. `DefaultPrng`
(`Xoshiro256`) was tested through `zig build stream` with `stdin64`, `-tlmin
128GB`, and `-tlmax 128GB`.

## Default Seed Command

```sh
zig build -Doptimize=ReleaseFast stream -- --engine default --bytes 137438953472 \
  | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 128GB -tlmax 128GB
```

## Default Seed Result

```text
RNG_test using PractRand version 0.96
RNG = RNG_stdin64, seed = unknown
test set = core, folding = standard (64 bit)

rng=RNG_stdin64, seed=unknown
length= 128 gigabytes (2^37 bytes), time= 971 seconds
  Test Name                         Raw       Processed     Evaluation
  [Low4/64]DC6-9x1Bytes-1           R=  -4.9  p =1-3.0e-3   unusual
  ...and 319 test result(s) without anomalies
```

## Alternate Seed Command

```sh
zig build -Doptimize=ReleaseFast stream -- --engine default --seed 0x9e3779b97f4a7c15 --bytes 137438953472 \
  | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 128GB -tlmax 128GB
```

## Alternate Seed Result

```text
RNG_test using PractRand version 0.96
RNG = RNG_stdin64, seed = unknown
test set = core, folding = standard (64 bit)

rng=RNG_stdin64, seed=unknown
length= 128 gigabytes (2^37 bytes), time= 965 seconds
  no anomalies in 320 test result(s)
```

## Interpretation

The default-seed run produced one PractRand `unusual` result in a low-bit test.
PractRand `unusual` is not a failure by itself, but it is a signal to track. A
same-length alternate-seed rerun did not reproduce the anomaly.

Current action: keep `DefaultPrng` / `Xoshiro256` under observation for longer
or repeated Stage 4 runs. Do not count this as a clean all-seed pass.
