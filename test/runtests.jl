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

    price_index_closure = ClosureSpec(:P_INDEX; kind = :price_index)
    price_index_spec = RunSpec("PriceIndexDemo", spec.model, price_index_closure, scenario)
    price_index_report = validate_spec(price_index_spec)
    @test price_index_report.ok
    @test price_index_report.warnings == 0
    @test price_index_report.categories[:closure][:notes] == [
        "Price-index numeraire P_INDEX must be registered and fixed by a model block",
    ]

    @test_throws ErrorException ClosureSpec(:P_INDEX; kind = :unsupported)

    x = EVar(:x)
    @test ELe(x, EConst(1.0)).lhs === x
    @test EGe(x, EConst(0.0)).rhs.value == 0.0
    @test ELog(x).expr === x
end
