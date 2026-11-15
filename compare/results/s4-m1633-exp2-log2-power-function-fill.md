# S4-M1633 exp2/log2 PowerFunction Fill Transform

Date: 2026-11-15

The PowerFunction bulk fill (`powerFunctionFromOpenUniformsVector`) still used
`@exp(@log(u) * inverse_shape)` per vector lane and in its scalar tail.
Converted both to the exact `@exp2(@log2(u) * inverse_shape)` form.

| Row | `exp`/`log` baseline | `exp2`/`log2` | Change |
| --- | --- | --- | --- |
| `alea fillPowerFunction` | 219.5 M | 255.2-292.5 M | +16-33% |

The printed checksum is unchanged (`163864.966`); the fill stream changes at
the ulp level and is versioned in `reproducibility-matrix.md`. The vector lane
helper test reference was updated to the `exp2`/`log2` form.

The same Pareto fill rewrite measured neutral (297.3 -> 299.5 M) and was
reverted.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native `alea-tests` 950/950).
