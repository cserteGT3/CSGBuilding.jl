@testset "evaluating sphere" begin
    sphere1 = ImplicitSphere(v0, 1.0)
    @test sphere1.center === v0
    @test sphere1.radius === 1.0

	sp2 = ImplicitSphere([0,0,0], 15.0)
	@test sp2.center === SVector(0.0, 0, 0)
	@test sp2.radius === 15.0

	sp3 = ImplicitSphere([0,0,0], 15)
	@test sp3.center === SVector(0, 0, 0)
	@test sp3.radius === 15

	sp4 = ImplicitSphere([0,0,0.], 15)
	@test sp4.center === SVector(0., 0, 0)
	@test sp4.radius === 15.0

    @test isapprox(value(evaluate(sphere1, v0)), -1)

    @test isapprox(value(evaluate(sphere1, SVector(1, 0, 0))), 0)
    @test isapprox(value(evaluate(sphere1, SVector(1.0, 0.0, 0.0))), 0)
    @test isapprox(value(evaluate(sphere1, SVector(0.0, 1.0, 0.0))), 0)
    @test isapprox(value(evaluate(sphere1, SVector(0.0, 0.0, 1.0))), 0)

    @test value(evaluate(sphere1, SVector(0, 0, 1.0001))) > 0

    sphere2 = ImplicitSphere(SVector(-1.0, -1.0, -1.0), 1.0)
    @test isapprox(value(evaluate(sphere2, SVector(-1.0, -1.0, -1.0))), -1)

    @test isapprox(value(evaluate(sphere2, SVector(-1, -1, 0))), 0)
    @test isapprox(value(evaluate(sphere2, SVector(-1.0, -1.0, 0.0))), 0)
    @test isapprox(value(evaluate(sphere2, SVector(-1.0, 0.0, -1.0))), 0)
    @test isapprox(value(evaluate(sphere2, SVector(-1.0, -1.0, 0.0))), 0)

    @test value(evaluate(sphere2, SVector(0, 0, 0))) > 0
    @test value(evaluate(sphere2, SVector(-1.0001, -1.0, 0.0))) > 0

    sphere3 = ImplicitSphere(SVector(5, 5, 5), 5)

    @test isapprox(value(evaluate(sphere3, SVector(5, 5, 0))), 0)
    @test isapprox(value(evaluate(sphere3, SVector(5.0, 5.0, 0.0))), 0)
    @test isapprox(value(evaluate(sphere3, SVector(5.0, 0.0, 5.0))), 0)
    @test isapprox(value(evaluate(sphere3, SVector(0.0, 5.0, 5.0))), 0)

    @test value(evaluate(sphere3,SVector(0.0, 5.0001, 5.0))) > 0

    # Integer
    sphere4 = ImplicitSphere(SVector(0, 0, 0), 1)
    @test isapprox(value(evaluate(sphere1, v0)), -1)
end

@testset "evaluating plane" begin
    n1 = SVector(1,0,0.0);
    pl1 = ImplicitPlane(n1, n1)

    @test pl1.normal === n1
    @test pl1.point === n1

	pl2 = ImplicitPlane([0,0,0], [1,0,0])
	@test pl2.point === SVector(0,0,0)
	@test pl2.normal === SVector(1,0,0)

	pl3 = ImplicitPlane([0.,0,0], [1,0,0])
	@test pl3.point === SVector(0.,0,0)
	@test pl3.normal === SVector(1.,0,0)

    @test isapprox(value(evaluate(pl1, n1)), 0)
    @test isapprox(value(evaluate(pl1, SVector(0,0,0))), -1)
    @test isapprox(value(evaluate(pl1, SVector(2,0,0))), 1)

    @test value(evaluate(pl1, SVector(0.9999,0,0))) < 0
    @test value(evaluate(pl1, SVector(1.0001,0,0))) > 0

    @test isapprox(value(evaluate(pl1, SVector(1, 17.52, -37.12))), 0)
    @test isapprox(value(evaluate(pl1, SVector(1, 9446.644, -151677.09))), 0)

    @test value(evaluate(pl1, SVector(1.0001, 17.52, -37.12))) > 0
    @test value(evaluate(pl1, SVector(1.0001, 9446.644, -151677.09))) > 0


    @test value(evaluate(pl1, SVector(0.9999, 17.52, -37.12))) < 0
    @test value(evaluate(pl1, SVector(0.9999, 9446.644, -151677.09))) < 0
end

@testset "evaluating cylinder" begin
	n1 = SVector(0, 0, 1.0)
	cyl = ImplicitCylinder(n1, v0, 1.)

	@test cyl.center === v0
	@test cyl.axis === n1
	@test cyl.radius === 1.

	cyl2 = ImplicitCylinder([0,0,1], [0,0,0], 0.00001)
	@test cyl2.axis === SVector(0.0, 0, 1)
	@test cyl2.center === SVector(0.0, 0, 0)

	cyl3 = ImplicitCylinder([0,0,1.], [0,0,0], 15)
	@test cyl3.axis === SVector(0.0, 0, 1)
	@test cyl3.center === SVector(0.0, 0, 0)

	@test isapprox(value(evaluate(cyl, [1, 0, 0])), 0)
	@test isapprox(value(evaluate(cyl, [0, 1, 0])), 0)
	@test isapprox(value(evaluate(cyl, [-1, 0, 0])), 0)
	@test isapprox(value(evaluate(cyl, [0, -1, 0])), 0)

	@test isapprox(value(evaluate(cyl, [0, 0, 1])), -1)
	@test isapprox(value(evaluate(cyl, [0, 0, -1])), -1)

	@test value(evaluate(cyl, [1.0001, 0, 0])) > 0
	@test value(evaluate(cyl, [0, 1.0001, 0])) > 0
	@test value(evaluate(cyl, [-1.0001, 0, 0])) > 0
	@test value(evaluate(cyl, [0, -1.0001, 0])) > 0

	@test value(evaluate(cyl, [0.9999, 0, 0])) < 0
	@test value(evaluate(cyl, [0, 0.9999, 0])) < 0
	@test value(evaluate(cyl, [-0.9999, 0, 0])) < 0
	@test value(evaluate(cyl, [0, -0.9999, 0])) < 0
end


@testset "surface normals" begin
	@testset "plane" begin
		n1 = SVector(1,0,0.0);
		pl1 = ImplicitPlane(n1, n1)

		@test normal(pl1, v0) == n1
		@test normal(pl1, rand(SVector{3})) == n1
		@test isapprox(dot(normal(pl1, rand(SVector{3})), [1,0,0]), 1)
	end

	@testset "cylinder" begin
		n1 = SVector(0, 0, 1.0)
		cyl = ImplicitCylinder(n1, v0, 1.)

		cyl2 = ImplicitCylinder(n1, v0, 17)

		@test normal(cyl, [1,0,0]) == normal(cyl2, [1,0,0])
		@test normal(cyl, [1,0,0]) == [1, 0, 0]

		@test normal(cyl, [3.14, 0, 5]) == [1, 0, 0]
		@test normal(cyl, [-3.14, 0, -5]) == [-1, 0, 0]

		@test normal(cyl, [0, 3.14, 5]) == [0, 1, 0]
		@test normal(cyl, [0, -3.14, -5]) == [0, -1, 0]
	end

end
