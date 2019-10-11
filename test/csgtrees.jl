@testset "evaluating sphere node" begin
    sphere1 = ImplicitSphere(v0, 1.0)
    node1 = CSGNode(sphere1, ())

    @test isapprox(value(evaluate(node1, v0)), -1)
    @test isapprox(value(evaluate(node1, SVector(1, 0, 0))), 0)

    @test value(evaluate(node1, SVector(0, 0, 1.0001))) > 0
end

@testset "normal of nodes" begin
	n1 = SVector(1,0,0.0);

    pl1 = ImplicitPlane(n1, n1)
    pln1 = CSGNode(pl1, ())
	
	@test normal(pl1, v0) == n1
	@test normal(pl1, v0) == normal(pln1, v0)
	@test normal(pln1, rand(SVector{3})) == n1
end

@testset "valueandnormal of plane" begin
	n1 = SVector(1,0,0.0);

    pl1 = ImplicitPlane(n1, n1)
    pln1 = CSGNode(pl1, ())
	
	@test valueandnormal(pln1, n1) == (0, n1)
	
	val1, norm1 = valueandnormal(pln1, SVector(0,0,0))
	@test isapprox(val1, -1)
	@test norm1 == n1
	
	val2, norm2 = valueandnormal(pln1, SVector(2,0,0))
	@test isapprox(val2, 1)
	@test norm2 == n1
end