@testset "centroid" begin
    poinsI2 = [[0,0], [0,1], [1,0], [1,1]]
    cI2 = centroid(poinsI2)
    @test cI2 == [0.5, 0.5]

    poinsF2 = [[0.,0], [0,1], [1,0], [1,1]]
    cF2 = centroid(poinsF2)
    @test cF2 == [0.5, 0.5]

    poinsI3 = [[0,0,0], [0,0,1], [0,1,0], [0,1,1]]
    cI3 = centroid(poinsI3)
    @test cI3 == [0, 0.5, 0.5]

    poinsF3 = [SVector(i, j, k) for i in 0:1 for j in 0:1 for k in 0:1]
    cF3 = centroid(poinsF3)
    @test cF3 == SVector(0.5, 0.5, 0.5)
end
