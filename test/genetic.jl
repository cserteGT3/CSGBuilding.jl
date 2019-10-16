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
