using CSGBuilding
using Test
using StaticArrays: SVector
using Random
using LinearAlgebra: normalize

@testset "CSGBuilding.jl" begin
    @testset "Implicit surfaces" begin
        include("implicitsurfaces.jl")
    end
    @testset "Set operations" begin
        include("operations.jl")
    end
end
