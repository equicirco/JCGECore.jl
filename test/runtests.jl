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

    market_identity = ClosureCondition(:regional_market, :composite_market, :g1, :r1)
    pool_identity = ClosureCondition(:investment_pool, :pool_clearing)
    closure_with_checks = ClosureSpec(
        :P_INDEX;
        kind = :price_index,
        condition_roles = Dict(
            market_identity => :accounting_check,
            pool_identity => :accounting_check,
        ),
    )
    @test closure_condition_role(
        closure_with_checks, :regional_market, :composite_market, :g1, :r1) == :accounting_check
    @test is_enforced(closure_with_checks, :regional_market, :composite_market, :g2, :r1)
    @test accounting_checks(closure_with_checks) == [pool_identity, market_identity]
    checked_spec = RunSpec("CheckedPriceIndexDemo", spec.model, closure_with_checks, scenario)
    checked_report = validate_spec(checked_spec)
    @test checked_report.ok
    @test checked_report.categories[:closure][:notes] == [
        "Price-index numeraire P_INDEX must be registered and fixed by a model block",
        "Accounting check: investment_pool.pool_clearing",
        "Accounting check: regional_market.composite_market [g1, r1]",
    ]
    @test_throws ErrorException ClosureSpec(
        :P_INDEX;
        kind = :price_index,
        condition_roles = Dict(market_identity => :unsupported),
    )
    @test_throws ErrorException ClosureSpec(
        :P_INDEX;
        kind = :price_index,
        condition_roles = Dict(:not_a_condition => :accounting_check),
    )

    x = EVar(:x)
    @test ELe(x, EConst(1.0)).lhs === x
    @test EGe(x, EConst(0.0)).rhs.value == 0.0
    @test ELog(x).expr === x
end
