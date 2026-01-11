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

