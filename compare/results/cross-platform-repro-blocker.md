# Cross-Platform Reproducibility Blocker

`S2-M5` requires stable-output validation on at least two architectures or OS
targets, or a documented local blocker.

## Local Environment

Available Zig installations:

```text
/home/passchaos/Temp/zig-x86_64-linux-0.16.0/zig
/home/passchaos/.zvm/0.15.2/zig
```

Host:

```text
Linux robot-NUC13RNGi5 6.8.0-124-generic #124-Ubuntu SMP PREEMPT_DYNAMIC Tue May 26 13:00:45 UTC 2026 x86_64 x86_64 x86_64 GNU/Linux
```

Only the Zig 0.16.0 x86_64 Linux toolchain is suitable for this project in the
current environment. There is no local Zig 0.16.0 aarch64, macOS, or Windows
runner available.

## Completed Evidence

The current x86_64 Linux baseline is checked in at:

```text
compare/results/2026-06-28-repro-x86_64-linux.md
```

## Follow-Up

When another supported environment is available, run:

```sh
zig build repro
zig build test
zig build -Doptimize=ReleaseFast statcheck
```

Then add a second snapshot report and compare the stable-output rows against the
x86_64 Linux baseline.
