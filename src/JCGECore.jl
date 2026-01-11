"""
Core data model and block interfaces for JCGE.
"""
module JCGECore

export Sets, Mappings, ModelSpec, ClosureSpec, ScenarioSpec, RunSpec
export SectionSpec, RunSpecTemplate, section, template, build_spec
export allowed_sections
export AbstractBlock, calibrate!, build!, report
export validate
export validate_spec
export getparam
export EquationExpr, EIndex, EVar, EParam, EConst, EAdd, EMul, EPow, EDiv, ENeg, ESum, EProd, EEq, ERaw

"""
Canonical set containers.

Holds the standard sets used across models.
"""
struct Sets
    commodities::Vector{Symbol}
    activities::Vector{Symbol}
    factors::Vector{Symbol}
    institutions::Vector{Symbol}
end

"""
Canonical mapping containers.

The minimal mapping is activity to output commodity.
"""
struct Mappings
    activity_to_output::Dict{Symbol,Symbol}
end

"""
Model structure: blocks plus sets and mappings.
"""
struct ModelSpec
    blocks::Vector{Any}          # typically Vector{<:AbstractBlock}
    sets::Sets
    mappings::Mappings
end

"""
Closure choices for a run.

Currently only numeraire is required.
"""
struct ClosureSpec
    numeraire::Symbol
end

"""
Scenario changes relative to a baseline.
"""
struct ScenarioSpec
    name::Symbol
    shocks::Dict{Symbol,Any}
end

"""
Full run specification for a model run.
"""
struct RunSpec
    name::String
    model::ModelSpec
    closure::ClosureSpec
    scenario::ScenarioSpec
end

"""
Named section grouping a set of blocks.
"""
struct SectionSpec
    name::Symbol
    blocks::Vector{Any}
end

"""
Template for standardized RunSpec assembly.
"""
struct RunSpecTemplate
    name::String
    required_sections::Vector{Symbol}
end

"""
Return the canonical section names for RunSpec assembly.
"""
function allowed_sections()
    return [
        :production,
        :factors,
        :government,
        :savings,
        :households,
        :prices,
        :external,
        :trade,
        :markets,
        :objective,
        :init,
        :closure,
    ]
end

"""
Create a named section from blocks.
"""
section(name::Symbol, blocks::Vector{Any}) = SectionSpec(name, blocks)

"""
Create a template describing required sections.

This is a lightweight declaration for a model family; the template is
used by `build_spec` to enforce required sections consistently.
"""
function template(name::String; required_sections::Vector{Symbol}=Symbol[])
    return RunSpecTemplate(name, required_sections)
end

"""
Assemble a RunSpec from sections and a template.

Validates required and allowed sections before building the RunSpec.

This variant takes a `RunSpecTemplate` and reuses its `required_sections`.
"""
function build_spec(
    tpl::RunSpecTemplate,
    sets::Sets,
    mappings::Mappings,
    sections::Vector{SectionSpec};
    closure::ClosureSpec,
    scenario::ScenarioSpec,
    allowed_sections::Vector{Symbol}=Symbol[],
    required_nonempty::Vector{Symbol}=Symbol[],
)
    return build_spec(tpl.name, sets, mappings, sections; closure=closure, scenario=scenario,
        required_sections=tpl.required_sections,
        allowed_sections=allowed_sections,
        required_nonempty=required_nonempty)
end

"""
Assemble a RunSpec from sections.

Optionally validates required/allowed sections and required-nonempty sections.

Arguments:
- `required_sections`: sections that must be present.
- `allowed_sections`: if non-empty, only these section names are allowed.
- `required_nonempty`: sections that must exist and contain at least one block.

Notes:
- Sections are flattened into a single `ModelSpec.blocks` vector.
- A minimal structural `validate` is performed at the end.
"""
function build_spec(
    name::String,
    sets::Sets,
    mappings::Mappings,
    sections::Vector{SectionSpec};
    closure::ClosureSpec,
    scenario::ScenarioSpec,
    required_sections::Vector{Symbol}=Symbol[],
    allowed_sections::Vector{Symbol}=Symbol[],
    required_nonempty::Vector{Symbol}=Symbol[],
)
    seen = Set{Symbol}()
    for sec in sections
        sec.name in seen && error("Duplicate section: $(sec.name)")
        if !isempty(allowed_sections) && !(sec.name in allowed_sections)
            error("Unknown section: $(sec.name)")
        end
        push!(seen, sec.name)
    end
    for req in required_sections
        req in seen || error("Missing required section: $(req)")
    end
    for req in required_nonempty
        req in seen || error("Missing required section: $(req)")
        sec = only(filter(s -> s.name == req, sections))
        isempty(sec.blocks) && error("Section must be non-empty: $(req)")
    end
    blocks = Vector{Any}()
    for sec in sections
        append!(blocks, sec.blocks)
    end
    spec = RunSpec(name, ModelSpec(blocks, sets, mappings), closure, scenario)
    validate(spec)
    return spec
end

"""
Abstract interface for model blocks.
"""
abstract type AbstractBlock end

"""
Equation expression AST (backend-agnostic).
"""
abstract type EquationExpr end

"""
Variable reference expression.
"""
struct EVar <: EquationExpr
    name::Symbol
    idxs::Union{Nothing,Vector{Any}}
end

"""
Parameter reference expression.
"""
struct EParam <: EquationExpr
    name::Symbol
    idxs::Union{Nothing,Vector{Any}}
end

"""
Constant expression.
"""
struct EConst <: EquationExpr
    value::Real
end

"""
Raw expression placeholder (string-based).
"""
struct ERaw <: EquationExpr
    text::String
end

"""
Index placeholder used in param/var references.
"""
struct EIndex <: EquationExpr
    name::Symbol
end

"""
Addition expression.
"""
struct EAdd <: EquationExpr
    terms::Vector{EquationExpr}
end

"""
Multiplication expression.
"""
struct EMul <: EquationExpr
    factors::Vector{EquationExpr}
end

"""
Power expression.
"""
struct EPow <: EquationExpr
    base::EquationExpr
    exponent::EquationExpr
end

"""
Division expression.
"""
struct EDiv <: EquationExpr
    numerator::EquationExpr
    denominator::EquationExpr
end

"""
Negation expression.
"""
struct ENeg <: EquationExpr
    expr::EquationExpr
end

"""
Summation expression over a domain.
"""
struct ESum <: EquationExpr
    index::Symbol
    domain::Vector{Symbol}
    expr::EquationExpr
end

"""
Product expression over a domain.
"""
struct EProd <: EquationExpr
    index::Symbol
    domain::Vector{Symbol}
    expr::EquationExpr
end

"""
Equality expression.
"""
struct EEq <: EquationExpr
    lhs::EquationExpr
    rhs::EquationExpr
end

"""
Shorthand for variable references without indices.
"""
EVar(name::Symbol) = EVar(name, nothing)
"""
Shorthand for parameter references without indices.
"""
EParam(name::Symbol) = EParam(name, nothing)

"""
Calibration hook for blocks.
"""
function calibrate!(block::AbstractBlock, data, benchmark, params)
    throw(MethodError(calibrate!, (block, data, benchmark, params)))
end

"""
Build hook for blocks.
"""
function build!(block::AbstractBlock, ctx, spec::RunSpec)
    throw(MethodError(build!, (block, ctx, spec)))
end

"""
Reporting hook for blocks.
"""
function report(block::AbstractBlock, solution)
    throw(MethodError(report, (block, solution)))
end

"""
Validate that the RunSpec is structurally consistent (minimal checks).

Throws on missing core sets. This is intentionally minimal and used by
the builder; for richer diagnostics use `validate_spec`.
"""
function validate(spec::RunSpec)
    isempty(spec.model.sets.commodities) && error("Sets.commodities is empty")
    isempty(spec.model.sets.activities) && error("Sets.activities is empty")
    isempty(spec.model.sets.factors) && error("Sets.factors is empty")
    isempty(spec.model.sets.institutions) && error("Sets.institutions is empty")
    return true
end

"""
Validate RunSpec structure and closure; returns a report instead of throwing.

This function is meant for pre-solve diagnostics and returns a report
with categorized errors and warnings.
"""
function validate_spec(spec::RunSpec; data=nothing)
    report = _new_report()
    structural = _category!(report, :structural)
    closure = _category!(report, :closure)
    accounting = _category!(report, :accounting)

    if isempty(spec.model.blocks)
        push!(structural[:errors], "RunSpec has no blocks")
    end
    if isempty(spec.model.sets.commodities)
        push!(structural[:errors], "Sets.commodities is empty")
    end
    if isempty(spec.model.sets.activities)
        push!(structural[:errors], "Sets.activities is empty")
    end
    if isempty(spec.model.sets.factors)
        push!(structural[:errors], "Sets.factors is empty")
    end
    if isempty(spec.model.sets.institutions)
        push!(structural[:errors], "Sets.institutions is empty")
    end

    num = spec.closure.numeraire
    if !(num in spec.model.sets.commodities || num in spec.model.sets.factors)
        push!(closure[:warnings], "Numeraire $(num) not found in commodities or factors")
    end

    if data === nothing
        push!(accounting[:notes], "No data provided for SAM or flow consistency checks")
    end

    return _finalize_report(report)
end

"""
Create a new validation report container.
"""
function _new_report()
    return Dict{Symbol,Dict{Symbol,Vector{String}}}()
end

"""
Get or create a category entry within a validation report.
"""
function _category!(report, name::Symbol)
    if !haskey(report, name)
        report[name] = Dict(
            :errors => String[],
            :warnings => String[],
            :notes => String[],
        )
    end
    return report[name]
end

"""
Finalize a report into a summary NamedTuple.
"""
function _finalize_report(report)
    errors = 0
    warnings = 0
    for cat in values(report)
        errors += length(cat[:errors])
        warnings += length(cat[:warnings])
    end
    return (ok=errors == 0, errors=errors, warnings=warnings, categories=report)
end

"""
Get parameter values from dict- or table-like containers.

This is the canonical parameter accessor used by blocks.
"""
function getparam(params, name::Symbol, idxs...)
    hasproperty(params, name) || error("Missing parameter: $(name)")
    data = getproperty(params, name)
    return getindex(data, idxs...)
end

end # module
