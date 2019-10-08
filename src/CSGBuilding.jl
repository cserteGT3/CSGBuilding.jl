module CSGBuilding

using AbstractTrees
using LinearAlgebra: dot, norm, normalize
using StaticArrays: SVector

export  CSGNode,
        evaluate

export  ImplicitSphere,
        ImplicitPlane,
        ImplicitResult,
        value

export  writeparaviewformat

include("implicitsurfaces.jl")
include("csgtrees.jl")
include("operations.jl")
include("visualize.jl")

end # module
