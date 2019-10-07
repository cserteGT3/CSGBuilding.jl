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

    sphere2 = ImplicitSphere(SVector(-1.0, -1.0, -1.0), 1.0)
    @test isapprox(evaluate(sphere2, SVector(-1.0, -1.0, -1.0)), -1)

    @test isapprox(evaluate(sphere2, SVector(-1, -1, 0)), 0)
    @test isapprox(evaluate(sphere2, SVector(-1.0, -1.0, 0.0)), 0)
    @test isapprox(evaluate(sphere2, SVector(-1.0, 0.0, -1.0)), 0)
    @test isapprox(evaluate(sphere2, SVector(-1.0, -1.0, 0.0)), 0)

    sphere3 = ImplicitSphere(SVector(5, 5, 5), 5)

    @test isapprox(evaluate(sphere3, SVector(5, 5, 0)), 0)
    @test isapprox(evaluate(sphere3, SVector(5.0, 5.0, 0.0)), 0)
    @test isapprox(evaluate(sphere3, SVector(5.0, 0.0, 5.0)), 0)
    @test isapprox(evaluate(sphere3, SVector(5.0, 5.0, 0.0)), 0)
end

@testset "evaluating sphere node" begin
    sphere1 = ImplicitSphere(v0, 1.0)
    node1 = CSGNode(sphere1, ())

    @test isapprox(evaluate(node1, v0), -1)
    @test isapprox(evaluate(node1, SVector(1, 0, 0)), 0)
end

@testset "set operations on sphere" begin
    @testset "complement" begin
        sphere1 = ImplicitSphere(v0, 1.0)
        sp1node = CSGNode(sphere1, ())

        @test isapprox(evaluate(sp1node, v0), -1)
        @test isapprox(evaluate(sp1node, SVector(1, 0, 0)), 0)
    end

    @testset "intersection" begin
        sphere1 = ImplicitSphere(v0, 1.0)
        sphere2 = ImplicitSphere(v0, 5.0)
        sp1node = CSGNode(sphere1, ())
        sp2node = CSGNode(sphere2, ())

        node1 = CSGNode(CSGBuilding.intersection, (sp1node, sp2node))

        @test evaluate(node1, v0) < 0
        @test evaluate(node1, SVector(100,0,0)) > 0
    end

    @testset "subtraction" begin
        sphere1 = ImplicitSphere(v0, 1.0)
        sphere2 = ImplicitSphere(v0, 5.0)
        sp1node = CSGNode(sphere1, ())
        sp2node = CSGNode(sphere2, ())

        node1 = CSGNode(CSGBuilding.subtraction, (sp1node, sp2node))

        @test evaluate(node1, v0) < 0
        @test evaluate(node1, SVector(100,0,0)) < 0
    end
end
