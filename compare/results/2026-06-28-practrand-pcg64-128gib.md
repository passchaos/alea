# PractRand 128GiB Runs: Pcg64

Timestamp: 2026-06-28 CST

PractRand 0.96 was built under `/tmp/practrand/PractRand`. `Pcg64` was tested
through `zig build stream` with `stdin64`, `-tlmin 128GB`, and `-tlmax 128GB`.

## Default Seed Command

```sh
zig build -Doptimize=ReleaseFast stream -- --engine pcg64 --bytes 137438953472 \
  | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 128GB -tlmax 128GB
```

## Default Seed Result

```text
RNG_test using PractRand version 0.96
RNG = RNG_stdin64, seed = unknown
test set = core, folding = standard (64 bit)

rng=RNG_stdin64, seed=unknown
length= 128 gigabytes (2^37 bytes), time= 945 seconds
  Test Name                         Raw       Processed     Evaluation
  [Low1/64]BDayS2(4,24)[60]         R=  +3.9  p~=  5.0e-5   unusual
  ...and 319 test result(s) without anomalies
```

## Alternate Seed Command

```sh
zig build -Doptimize=ReleaseFast stream -- --engine pcg64 --seed 0x9e3779b97f4a7c15 --bytes 137438953472 \
  | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 128GB -tlmax 128GB
```

## Alternate Seed Result

```text
RNG_test using PractRand version 0.96
RNG = RNG_stdin64, seed = unknown
test set = core, folding = standard (64 bit)

rng=RNG_stdin64, seed=unknown
length= 128 gigabytes (2^37 bytes), time= 945 seconds
  no anomalies in 320 test result(s)
```

## Interpretation

The default-seed run produced one PractRand `unusual` result in a low-bit
birthday-spacing test. The same-length alternate-seed rerun did not reproduce
the anomaly.

Current action: keep `Pcg64` under observation for repeated or longer Stage 4
runs. Do not count this as a clean all-seed pass.
