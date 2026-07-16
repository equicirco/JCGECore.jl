# Usage

`JCGECore` defines the canonical model interface: RunSpec, sections, sets,
mappings, scenarios, and validation. It contains no solver-specific code.

## Typical workflow

```julia
using JCGECore

sets = Sets(goods, activities, factors, institutions)
mappings = Mappings(Dict(a => a for a in activities))

sections = [
    section(:production, blocks_prod),
    section(:households, blocks_hh),
    section(:markets, blocks_mkt),
]

spec = build_spec("MyModel", sets, mappings, sections)
```

## Validation

```julia
report = validate_spec(spec)
report.ok || error("Invalid RunSpec")
```

## Numeraire

`ClosureSpec` records the model's price normalization. Commodity and factor
numeraires can use the legacy one-argument form:

```julia
ClosureSpec(:LAB)
```

Use an explicit kind when the numeraire is a model-defined price index. The
model must include a block that defines and fixes the chosen index to the
normalization value.

```julia
ClosureSpec(:EU_CPI; kind = :price_index)  # for a European consumption-price index
ClosureSpec(:US_CPI; kind = :price_index)  # for a United States consumption-price index
```

This lets validation distinguish a price-index numeraire from a missing member
of the commodity or factor sets.

## Scenarios

Use `ScenarioSpec` to describe deltas relative to a baseline.

## Equation expressions

`JCGECore` provides a backend-neutral expression tree for model equations. Use
`EVar`, `EParam`, `EConst`, `EAdd`, `EMul`, `EPow`, `EDiv`, `ENeg`, `ESum`, and
`EProd` to build algebraic expressions.

Relations are represented explicitly:

```julia
EEq(lhs, rhs)  # lhs == rhs
ELe(lhs, rhs)  # lhs <= rhs
EGe(lhs, rhs)  # lhs >= rhs
```

Natural logarithms can be represented with `ELog(expr)`, including in objective
expressions compiled by downstream runtimes.

`JCGECore` defines these symbolic nodes only. Solver-specific compilation is
handled by runtime packages such as `JCGERuntime`.
