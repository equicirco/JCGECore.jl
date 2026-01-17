<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/src/assets/jcge_core_logo_dark.png">
  <source media="(prefers-color-scheme: light)" srcset="docs/src/assets/jcge_core_logo_light.png">
  <img alt="JCGE Core logo" src="docs/src/assets/jcge_core_logo_light.png" height="150">
</picture>

# JCGECore

## What is a CGE?
A Computable General Equilibrium (CGE) model is a quantitative economic model that represents an economy as interconnected markets for goods and services, factors of production, institutions, and the rest of the world. It is calibrated with data (typically a Social Accounting Matrix) and solved numerically as a system of nonlinear equations until equilibrium conditions (zero-profit, market-clearing, and income-balance) hold within tolerance.

## What is JCGE?
JCGE is a block-based CGE modeling and execution framework in Julia. It defines a shared RunSpec structure and reusable blocks so models can be assembled, validated, solved, and compared consistently across packages.

## What is this package?
Canonical internal data model and interfaces for JCGE.

## Responsibilities
- Core types for sets, mappings, benchmark containers, and RunSpec (run specification)
- Block interfaces and validation hooks
- Standard RunSpec builder and section/template helpers
- No JuMP dependency

## RunSpec builder (sections + templates)
JCGECore provides a lightweight builder to standardize RunSpec assembly:
- `SectionSpec` groups blocks by semantic section (e.g., `:production`, `:trade`).
- `RunSpecTemplate` declares required sections for a model family.
- `build_spec` assembles a `RunSpec` with required-section validation, optional
  allowed-section checks, and required-nonempty sections.

## Non-goals
- Solving, model construction, or calibration implementations

## Validation
Use `validate_spec` for optional structural checks on a `RunSpec`:
```julia
report = JCGECore.validate_spec(spec)
report.ok || println(report.categories)
```

## How to cite
If you use the JCGE framework, please cite:

Boero, R. *JCGE - Julia Computable General Equilibrium Framework* [software], 2026.
DOI: 10.5281/zenodo.18282436
URL: https://JCGE.org

```bibtex
@software{boero_jcge_2026,
  title  = {JCGE - Julia Computable General Equilibrium Framework},
  author = {Boero, Riccardo},
  year   = {2026},
  doi    = {10.5281/zenodo.18282436},
  url    = {https://JCGE.org}
}
```

If you use this package, please cite:

Boero, R. *JCGECore.jl* [software], 2026.
DOI: 10.5281/zenodo.18214951
URL: https://Core.JCGE.org
SourceCode: https://github.com/equicirco/JCGECore.jl

```bibtex
@software{boero_jcgecore_2026,
  title  = {JCGECore.jl},
  author = {Boero, Riccardo},
  year   = {2026},
  doi    = {10.5281/zenodo.18214951},
  url    = {https://Core.JCGE.org}
}
```

If you use a specific tagged release, please cite the version DOI assigned on Zenodo for that release (preferred for exact reproducibility).
