const v0 = SVector(0.0, 0.0, 0.0)

@testset "set operations on sphere" begin
    @testset "complement" begin
        sphere1 = ImplicitSphere(SVector(-1.0, -1.0, -1.0), 1.0)
        sp1node = CSGNode(sphere1, ())
        compnode = CSGNode(CSGBuilding.complement, (sp1node, ))

        @test isapprox(value(evaluate(compnode, SVector(-1.0, -1.0, -1.0))), 1)
        @test isapprox(value(evaluate(compnode, SVector(-1, -1, 0))), 0)
    end

    @testset "intersection" begin
        sphere1 = ImplicitSphere(v0, 1.0)
        sphere2 = ImplicitSphere(v0, 5.0)
        sp1node = CSGNode(sphere1, ())
        sp2node = CSGNode(sphere2, ())

        node1 = CSGNode(CSGBuilding.intersection, (sp1node, sp2node))

        @test value(evaluate(node1, v0)) < 0
        @test value(evaluate(node1, SVector(100,0,0))) > 0
    end

    @testset "subtraction" begin
        sphere1 = ImplicitSphere(v0, 1.0)
        sphere2 = ImplicitSphere(v0, 5.0)
        sp1node = CSGNode(sphere1, ())
        sp2node = CSGNode(sphere2, ())

        node1 = CSGNode(CSGBuilding.subtraction, (sp1node, sp2node))

        @test value(evaluate(node1, v0)) > 0
        @test value(evaluate(node1, SVector(100,0,0))) > 0
    end
end

@testset "unit cube" begin
    n1 = SVector(1,0,0.0);
    n2 = SVector(0,1,0.0);
    n3 = SVector(0,0,1.0);

    pl1 = ImplicitPlane(n1, n1)
    pln1 = CSGNode(pl1, ())

    pl2 = ImplicitPlane(n2, n2)
    pln2 = CSGNode(pl2, ())

    pl3 = ImplicitPlane(n3, n3)
    pln3 = CSGNode(pl3, ())

    pl4 = ImplicitPlane(-n1, -n1)
    pln4 = CSGNode(pl4, ())

    pl5 = ImplicitPlane(-n2, -n2)
    pln5 = CSGNode(pl5, ())

    pl6= ImplicitPlane(-n3, -n3)
    pln6 = CSGNode(pl6, ())

    tr1 = CSGNode(CSGBuilding.intersection, (pln1, pln2))
    tr2 = CSGNode(CSGBuilding.intersection, (pln3, pln4))
    tr3 = CSGNode(CSGBuilding.intersection, (tr1, tr2))
    tr4 = CSGNode(CSGBuilding.intersection, (tr3, pln5))
    cubetree = CSGNode(CSGBuilding.intersection, (tr4, pln6))

    unitps = [n1, n2, n3, -n1, -n2, -n3]

    @testset "on surface" begin
        for n in unitps
            @test isapprox(value(evaluate(cubetree, n)), 0)
        end
    end

    @testset "over surface" begin
        for n in unitps
            newp = 1.0001*n
            @test value(evaluate(cubetree, newp)) > 0
        end
    end

    @testset "under surface" begin
        for n in unitps
            newp = 0.9999*n
            @test value(evaluate(cubetree, newp)) < 0
        end
    end

    Random.seed!(1234)

    @testset "inside the cube" begin
        for i in 1:10
            @test value(evaluate(cubetree, rand(SVector{3}))) < 0
        end
    end

    @testset "outside the cube" begin
        for i in 1:10
            direction = 1.0001*sqrt(3)*normalize(rand(SVector{3}))
            @test value(evaluate(cubetree, direction)) > 0
        end
    end

end
