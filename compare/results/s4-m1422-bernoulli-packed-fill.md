# S4-M1422 — Bernoulli bulk fill through the packed chance kernels

## Goal

Route the reusable `Bernoulli` sampler's bulk fill through the packed chance
kernels. `Bernoulli.fill` and `fillFrom` only special-cased p = 0.5 and 0.25;
p = 3/4, 1/8, 3/8, and 1/16 fell back to the per-element threshold loop even
though `Rng.fillChance` already had packed kernels for them.

## Change

`Bernoulli.fill` and `fillFrom` now delegate to a shared `fillDispatch`
helper. After the zero/one point masses, it compares the sampler's stored
threshold against the packed probabilities `{0.5, 0.25, 0.75, 0.375, 0.0625,
0.125}` with a comptime `inline for` and calls `Rng.fillChanceFrom` for a
match. Everything else keeps the per-element threshold loop. The refactor
also removes the duplicated dispatch from the two public methods.

## Results

Interleaved same-period A/B with two saved binaries (16 MiB, three rounds):

- `alea fillBernoulli p=3/4`: 845-846M -> 3339-3396M samples/s (+295%),
  checksum `1572620` -> `1572601`,
- `alea fillBernoulli p=1/8`: 839-851M -> 1837-1845M samples/s (+118%),
  checksum `262550` -> `261478`,
- `alea fillBernoulli p=0.25`: 3360-3425M with an unchanged checksum
  (`524551`), so the refactor preserves the existing packed path.

Sensitive rows stay in range with unchanged checksums: `alea binomial large`
35.8-36.3M, `alea binomial mean-12` 33.9-34.5M, `alea negative-binomial`
170.9-180.3M, `alea beta binomial` 51.1-51.9M, `alea skew-normal`
572.6-587.9M.

## Validation

- `zig build test --summary all` passes 903/903,
- `zig build distcheck` and `zig build statcheck` pass,
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.

## Next bar

Broader platform runners, packed `fillRatio` for small non-power-of-two
denominators, or newly discovered core gaps.
