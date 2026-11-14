# S4-M1416 — Lead-category ordering in multinomial sampling

## Goal

Draw the most probable multinomial category first. The sequential-conditional
sampler previously always started at index 0, so a distribution like
`{1, 2, 3}` paid an expensive HIN draw for the small `1/6` category before
reaching the `1/2` category that hits the fair path.

## Probe

Manual reorder probe on the local aarch64 host (2M draws, best of runs):

- current `Multinomial(100, {1,2,3})` draw: 126.3 ns,
- reordered (`Binomial(100, 1/2)` then `Binomial(remaining, 1/3)`): 33.9 ns,
- reordered with the second draw on the `2/3` side: 35.1 ns.

The fair path for the `1/2` category costs a few ns, and the remaining trial
count drops to about 50, which puts the next conditional binomial on the
small-trial path instead of the HIN rejection loop.

## Change

- `Multinomial.init` records `lead_index` (largest probability, lowest index
  on ties) and caches the HIN setup for that category instead of index 0.
- `sampleInto` and `sampleIntoFrom` delegate to `sampleCountsFrom`, which
  draws the lead category first and then the remaining categories in input
  order, skipping the remainder slot. `remainderIndex` is the last index
  unless the lead already occupies it, in which case it is `len - 2`.
- `sampleManyIntoFrom` adapts its second-conditional HIN cache to the actual
  second category in the new draw order.
- The sampled distribution is unchanged (categories are exchangeable); only
  the order in which the conditional binomials are drawn changes.

## Results

Interleaved same-period A/B with two saved binaries (three alternating
rounds, 16 MiB):

- `alea multinomial`: 8.3M -> 34.6-34.7M samples/s (+317%), checksum
  `546091` -> `545454`,
- `alea multinomial direct`: 9.1-9.2M -> 44.5-44.6M samples/s (+385%),
  checksum `545072` -> `545476`,
- `alea multinomial many direct`: 11.4M -> 43.2-43.3M samples/s (+279%),
  checksum `545072` -> `545476`.

The checksums shift because the stream shape changes; the new
`multinomial lead-category ordering keeps moments` test checks the marginal
means and variances of all three categories over 50,000 samples, the
two-category case where the lead is the last index, and a sparse
`{0, 1, 3}` input whose zero category must stay zero.

## Validation

- `zig build test --summary all` passes 903/903,
- `zig build distcheck` and `zig build statcheck` pass,
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.

## Next bar

Broader platform runners, BTPE-style central binomial rejection, or newly
discovered core gaps.
