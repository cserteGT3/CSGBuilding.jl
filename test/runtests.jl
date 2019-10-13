using CSGBuilding
using Test
using StaticArrays: SVector
using Random
using LinearAlgebra

const v0 = SVector(0.0, 0.0, 0.0)
const CSGB = CSGBuilding

@testset "CSGBuilding.jl" begin
	@testset "Implicit surfaces" begin
        include("implicitsurfaces.jl")
    end
	@testset "csg tree" begin
		include("csgtrees.jl")
	end
    @testset "Set operations" begin
        include("operations.jl")
    end
end
