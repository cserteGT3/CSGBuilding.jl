using CSGBuilding
using Test
using StaticArrays: SVector

@testset "CSGBuilding.jl" begin
    @testset "Implicit sphere tests" begin
        include("implspheretests.jl")
    end
end
