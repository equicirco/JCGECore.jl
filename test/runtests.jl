using Test
using JCGECore

@testset "JCGECore" begin
    struct DummyBlock <: AbstractBlock end
    sets = Sets([:a], [:a], [:f], [:h])
    mappings = Mappings(Dict(:a => :a))
    closure = ClosureSpec(:a)
    scenario = ScenarioSpec(:baseline, Dict{Symbol,Any}())
    sections = [section(:production, Any[DummyBlock()]), section(:trade, Any[])]
    tpl = template("Demo"; required_sections=[:production, :trade])
    spec = build_spec(
        tpl,
        sets,
        mappings,
        sections;
        closure=closure,
        scenario=scenario,
        allowed_sections=[:production, :trade],
        required_nonempty=Symbol[],
    )
    @test spec.name == "Demo"
    @test length(spec.model.blocks) == 1
    report = validate_spec(spec)
    @test report.ok
end
