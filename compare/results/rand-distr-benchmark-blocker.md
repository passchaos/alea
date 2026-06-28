# Rand Distr Benchmark Availability

`S2-M4` asks for Rust-side benchmark rows where local Rust `rand` /
`rand_distr` exposes matching functionality. This file records the dependency
availability history.

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

This blocker was resolved by explicitly using crates.io:

```sh
cargo add rand_distr --registry crates-io --manifest-path compare/rand_bench/Cargo.toml
```

The Rust-side comparison now includes matching rows for normal, exponential,
gamma, beta, poisson, and binomial in addition to default `rand` rows.
