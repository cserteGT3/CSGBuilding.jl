module CSGBuilding

using AbstractTrees
using LinearAlgebra: dot, norm, normalize
using StaticArrays: SVector
using Random

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
        randomtree

export  writeparaviewformat

include("implicitsurfaces.jl")
include("csgtrees.jl")
include("operations.jl")
include("visualize.jl")

end # module
