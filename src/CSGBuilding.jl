module CSGBuilding

using AbstractTrees
using LinearAlgebra: dot, norm, normalize
using StaticArrays: SVector
using Random
using Parameters
using Logging
import Base.Threads.@spawn
using Base.Threads

export  ImplicitResult,
        value,
        normal,
        ImplicitSphere,
        ImplicitPlane,
        ImplicitCylinder,
        evaluate

export  CSGNode,
        valueandnormal,
        depth,
        treesize,
        randomtree

export  writeparaviewformat

export  CSGGeneticBuildParameters,
        rankpopulation,
        crossover,
        mutate,
        geneticbuildtree

include("implicitsurfaces.jl")
include("csgtrees.jl")
include("operations.jl")
include("visualize.jl")
include("genetic.jl")

end # module
