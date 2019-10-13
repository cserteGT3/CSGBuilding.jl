module CSGBuilding

using AbstractTrees
using LinearAlgebra: dot, norm, normalize
using StaticArrays: SVector

export  ImplicitResult,
        value,
        normal,
        ImplicitSphere,
        ImplicitPlane,
        ImplicitCylinder,
        evaluate

export  CSGNode,
        valueandnormal

export  writeparaviewformat

include("implicitsurfaces.jl")
include("csgtrees.jl")
include("operations.jl")
include("visualize.jl")

end # module
