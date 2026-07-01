# Cross-Platform Reproducibility Infrastructure Blocker

`S4-M1` raises the previous local-only reproducibility requirement. It requires
stable-output validation on at least one additional OS or architecture, or a
strong blocker with exact missing infrastructure.

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
current environment. Zig can list cross-compilation targets, but S4-M1 requires
executed snapshots, not merely cross-compiled artifacts.

Checked runtime tools on 2026-07-02:

```text
qemu-aarch64: missing
qemu-riscv64: missing
wine: missing
wasmtime: missing
```

There is no local Zig 0.16.0 aarch64, macOS, Windows, RISC-V, or WASI runner
available for executing `zig build repro`, `zig build test`, and
`zig build -Doptimize=ReleaseFast distcheck` on a second platform.

## Completed Evidence

The current x86_64 Linux baseline is checked in at:

```text
compare/results/2026-06-28-repro-x86_64-linux.md
```

The x86_64 Linux snapshot was re-run during S4-M1 review and still matches the
checked-in baseline. It was rechecked again on 2026-07-01 with `zig build repro`,
`zig build test`, and `zig build -Doptimize=ReleaseFast statcheck`; all passed
on the local x86_64 Linux Zig 0.16.0 toolchain. The second-platform runtime
blocker was refreshed on 2026-07-02 with `command -v qemu-aarch64`,
`command -v qemu-riscv64`, `command -v wine`, `command -v wasmtime`,
`uname -a`, and `zig version`; the host is still x86_64 Linux with Zig 0.16.0
and no second-platform runtime was available.

## Follow-Up

To close S4-M1, provide one of:

- a second physical or virtual runner with Zig 0.16.0,
- a working QEMU user-mode runner for a non-x86_64 Linux target,
- a Windows runner or Wine setup suitable for Zig 0.16.0 outputs,
- a WASI runner if the repro and test steps are adapted to the WASI target.

Then run:

```sh
zig build repro
zig build test
zig build -Doptimize=ReleaseFast statcheck
```

Then add a second snapshot report and compare the stable-output rows against the
x86_64 Linux baseline.
