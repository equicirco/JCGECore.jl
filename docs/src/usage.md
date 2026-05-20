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
