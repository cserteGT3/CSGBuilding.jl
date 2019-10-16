@testset "crossover depth" begin
    v1 = SVector(0,0,0.0)
    sf1 = ImplicitSphere(v1, 0.5)
    sf2 = ImplicitSphere(v1, 1.0)
    subnode1 = CSGNode(sf1, [])
    subnode2 = CSGNode(sf2, [])

    nd1 = CSGNode(CSGB.union, [subnode1, subnode2])
    nd2 = CSGNode(CSGB.union, [nd1, CSGNode(CSGB.complement, [subnode1])])
    nd31 = CSGNode(CSGB.subtraction, [subnode1, subnode2])
    nd3 = CSGNode(CSGB.subtraction, [nd31, CSGNode(CSGB.complement, [subnode1])])
    p = CSGGeneticBuildParameters(χ=1.1)
    for _ in 1:10
        res = crossover([nd2, nd3], p)
        @test depth(res[1]) <= p.maxdepth
        @test depth(res[2]) <= p.maxdepth
    end
end

@testset "mutate depth" begin
    n1 = SVector(1,0,0.0);
    n2 = SVector(0,1,0.0);
    n3 = SVector(0,0,1.0);
    v1 = SVector(0,0,0.0);

    cyn =  ImplicitCylinder(SVector(0,0,1), SVector(0,0,0),1)
    sf1 = ImplicitSphere(v1, 0.5)
    sf2 = ImplicitSphere(v1, 1.0)
    pl1 = ImplicitPlane(n1, n1)
    pl2 = ImplicitPlane(n2, n2)
    pl3 = ImplicitPlane(n3, n3)
    pl4 = ImplicitPlane(-n1, -n1)
    pl5 = ImplicitPlane(-n2, -n2)
    pl6= ImplicitPlane(-n3, -n3)

    surfac = [cyn, sf1, sf2, pl1, pl2, pl3, pl4, pl5, pl6]

    maximumd = 15

    tr = randomtree(surfac, maximumd)
    p = CSGGeneticBuildParameters(maxdepth=maximumd, μ=0.5, μ_0=0.5)

    for _ in 1:10
        @test depth(mutate(tr, surfac, p)) <= maximumd
    end

end
