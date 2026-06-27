# PractRand Smoke: FastPrng

Timestamp: 2026-06-28 CST

This report records a short external PractRand run against `alea.FastPrng`
(`Alea4x64`) through the raw stream exporter.

## Build PractRand

PractRand was downloaded from SourceForge as `PractRand_0.96.zip` and built
outside the repository under `/tmp/practrand/PractRand`.

```sh
g++ -c src/*.cpp src/RNGs/*.cpp src/RNGs/other/*.cpp -O3 -Iinclude -Wno-constant-logical-operand
ar rcs PractRand.a *.o
g++ -o RNG_test tools/RNG_test.cpp PractRand.a -O3 -Iinclude -Itools -pthread
```

## Command

```sh
zig build -Doptimize=ReleaseFast stream -- --engine fast --bytes 67108864 \
  | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 64MB -tlmax 64MB
```

## Result

```text
RNG_test using PractRand version 0.96
RNG = RNG_stdin64, seed = unknown
test set = core, folding = standard (64 bit)

rng=RNG_stdin64, seed=unknown
length= 64 megabytes (2^26 bytes), time= 0.5 seconds
  no anomalies in 172 test result(s)
```

This is a smoke-level external statistical check, not a substitute for long
multi-gigabyte or multi-terabyte PractRand/TestU01 runs.
