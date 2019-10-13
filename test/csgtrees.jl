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

@testset "depth()" begin
	sf1 = ImplicitSphere([0,0,0], 1)
	sn1 = CSGNode(sf1, ())
	@test depth(sn1) == 0

	sf2 = ImplicitSphere([64.5,8.4,5.4], 15)
	sn2 = CSGNode(sf2, ())

	nd1 = CSGNode(CSGB.union, (sn1, sn2))
	@test depth(nd1) == 1

	nd2 = CSGNode(CSGB.union, (nd1, CSGNode(CSGB.complement, (sn1, ))))
	@test depth(nd2) == 2

	nd3 = CSGNode(CSGB.subtraction, (nd1, CSGNode(CSGB.complement, (sn2, ))))
	@test depth(nd3) == 2

	nd4 = CSGNode(CSGB.intersection, (nd3, nd2))
	@test depth(nd4) == 3
end
