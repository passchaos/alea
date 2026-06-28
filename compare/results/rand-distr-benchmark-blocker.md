# Rand Distr Benchmark Blocker

`S2-M4` asks for Rust-side benchmark rows where local Rust `rand` /
`rand_distr` exposes matching functionality.

The local `~/Work/rand` checkout does not include `rand_distr`, and this
environment's Cargo configuration replaces crates.io with a non-remote
`rsproxy-sparse` source. Running:

```sh
cargo search rand_distr --limit 1
```

fails with:

```text
error: crates-io is replaced with non-remote-registry source registry `rsproxy-sparse`;
include `--registry crates-io` to use crates.io
```

Therefore the current Rust-side comparison is limited to functionality exposed
by the local `rand` checkout itself: bytes, fill-only, bounded range, sequence
index sampling, random bool, alphanumeric, and weighted index sampling.

If `rand_distr` becomes locally available, extend `compare/rand_bench` with
matching rows for normal, exponential, gamma, beta, poisson, binomial, and
derived distributions.
