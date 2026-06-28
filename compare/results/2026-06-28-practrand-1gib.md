# PractRand 1GiB Runs

Timestamp: 2026-06-28 CST

PractRand 0.96 was built under `/tmp/practrand/PractRand`. The following
engines were tested through `zig build stream` with `stdin64`, `-tlmin 1GB`,
and `-tlmax 1GB`.

## Commands

```sh
zig build -Doptimize=ReleaseFast stream -- --engine fast --bytes 1073741824 | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 1GB -tlmax 1GB
zig build -Doptimize=ReleaseFast stream -- --engine default --bytes 1073741824 | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 1GB -tlmax 1GB
zig build -Doptimize=ReleaseFast stream -- --engine wyhash64 --bytes 1073741824 | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 1GB -tlmax 1GB
zig build -Doptimize=ReleaseFast stream -- --engine pcg64 --bytes 1073741824 | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 1GB -tlmax 1GB
zig build -Doptimize=ReleaseFast stream -- --engine 'xoshiro256++' --bytes 1073741824 | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 1GB -tlmax 1GB
zig build -Doptimize=ReleaseFast stream -- --engine chacha12 --bytes 1073741824 | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 1GB -tlmax 1GB
```

## Results

| Engine | Result |
| --- | --- |
| `fast` / `Alea4x64` | no anomalies in 227 test results |
| `default` / `Xoshiro256` | no anomalies in 227 test results |
| `wyhash64` | no anomalies in 227 test results |
| `pcg64` | no anomalies in 227 test results |
| `xoshiro256++` | no anomalies in 227 test results |
| `chacha12` | no anomalies in 227 test results |

Each run reported `test set = core, folding = standard (64 bit)` and length
`1 gigabyte (2^30 bytes)`.
