const v0 = SVector(0.0, 0.0, 0.0)

@testset "set operations on sphere" begin
    @testset "complement" begin
        sphere1 = ImplicitSphere(SVector(-1.0, -1.0, -1.0), 1.0)
        sp1node = CSGNode(sphere1, ())
        compnode = CSGNode(CSGBuilding.complement, (sp1node, ))

        @test isapprox(evaluate(compnode, SVector(-1.0, -1.0, -1.0)), 1)
        @test isapprox(evaluate(compnode, SVector(-1, -1, 0)), 0)
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

        @test evaluate(node1, v0) > 0
        @test evaluate(node1, SVector(100,0,0)) > 0
    end
end
