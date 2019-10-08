const v0 = SVector(0.0, 0.0, 0.0)

@testset "evaluating sphere" begin
    sphere1 = ImplicitSphere(v0, 1.0)
    @test sphere1.center == v0
    @test sphere1.radius == 1.0

    @test isapprox(evaluate(sphere1, v0), -1)

    @test isapprox(evaluate(sphere1, SVector(1, 0, 0)), 0)
    @test isapprox(evaluate(sphere1, SVector(1.0, 0.0, 0.0)), 0)
    @test isapprox(evaluate(sphere1, SVector(0.0, 1.0, 0.0)), 0)
    @test isapprox(evaluate(sphere1, SVector(0.0, 0.0, 1.0)), 0)

    @test evaluate(sphere1, SVector(0, 0, 1.0001)) > 0

    sphere2 = ImplicitSphere(SVector(-1.0, -1.0, -1.0), 1.0)
    @test isapprox(evaluate(sphere2, SVector(-1.0, -1.0, -1.0)), -1)

    @test isapprox(evaluate(sphere2, SVector(-1, -1, 0)), 0)
    @test isapprox(evaluate(sphere2, SVector(-1.0, -1.0, 0.0)), 0)
    @test isapprox(evaluate(sphere2, SVector(-1.0, 0.0, -1.0)), 0)
    @test isapprox(evaluate(sphere2, SVector(-1.0, -1.0, 0.0)), 0)

    @test evaluate(sphere2, SVector(0, 0, 0)) > 0
    @test evaluate(sphere2, SVector(-1.0001, -1.0, 0.0)) > 0

    sphere3 = ImplicitSphere(SVector(5, 5, 5), 5)

    @test isapprox(evaluate(sphere3, SVector(5, 5, 0)), 0)
    @test isapprox(evaluate(sphere3, SVector(5.0, 5.0, 0.0)), 0)
    @test isapprox(evaluate(sphere3, SVector(5.0, 0.0, 5.0)), 0)
    @test isapprox(evaluate(sphere3, SVector(0.0, 5.0, 5.0)), 0)

    @test evaluate(sphere3,SVector(0.0, 5.0001, 5.0)) > 0

    # Integer
    sphere4 = ImplicitSphere(SVector(0, 0, 0), 1)
    @test isapprox(evaluate(sphere1, v0), -1)
end

@testset "evaluating sphere node" begin
    sphere1 = ImplicitSphere(v0, 1.0)
    node1 = CSGNode(sphere1, ())

    @test isapprox(evaluate(node1, v0), -1)
    @test isapprox(evaluate(node1, SVector(1, 0, 0)), 0)

    @test evaluate(node1, SVector(0, 0, 1.0001)) > 0
end
