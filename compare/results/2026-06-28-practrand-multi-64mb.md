# PractRand Smoke: Multiple Engines

Timestamp: 2026-06-28 CST

PractRand 0.96 was built under `/tmp/practrand/PractRand` and each engine was
tested through `zig build stream` with `stdin64`, `-tlmin 64MB`, and
`-tlmax 64MB`.

## Commands

```sh
zig build -Doptimize=ReleaseFast stream -- --engine default --bytes 67108864 | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 64MB -tlmax 64MB
zig build -Doptimize=ReleaseFast stream -- --engine wyhash64 --bytes 67108864 | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 64MB -tlmax 64MB
zig build -Doptimize=ReleaseFast stream -- --engine pcg64 --bytes 67108864 | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 64MB -tlmax 64MB
zig build -Doptimize=ReleaseFast stream -- --engine 'xoshiro256++' --bytes 67108864 | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 64MB -tlmax 64MB
zig build -Doptimize=ReleaseFast stream -- --engine chacha12 --bytes 67108864 | /tmp/practrand/PractRand/RNG_test stdin64 -tlmin 64MB -tlmax 64MB
```

## Results

| Engine | Result |
| --- | --- |
| `default` / `Xoshiro256` | no anomalies in 172 test results |
| `wyhash64` | no anomalies in 172 test results |
| `pcg64` | no anomalies in 172 test results |
| `xoshiro256++` | no anomalies in 172 test results |
| `chacha12` | one `unusual` result: `[Low1/64]DC6-9x1Bytes-1 R=-5.9 p=1-1.3e-3`; 171 results without anomalies |

PractRand `unusual` is not a failure, but the `chacha12` low-bit note should be
watched in longer runs.
