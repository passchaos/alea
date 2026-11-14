# S4-M1531 Validate-All Refresh After S4-M1530

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1869/1869
tests with the hypergeometric HIN overflow fallback and the new variance
gates present:

- native `alea-tests` 921/921,
- WASI Node tests 921/921,
- native and WASI distcheck with the four hypergeometric variance gates,
  the huge-lambda Poisson quantile gates, the heavy-tail mean gates, the
  Wishart gates, and the long-run blocks,
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 940/940 tests (native
921/921). The fallback changes method selection only for parameter sets that
previously errored or panicked; previously working streams are unchanged.
