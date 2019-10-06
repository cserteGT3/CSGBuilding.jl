module CSGBuilding

using AbstractTrees
using LinearAlgebra: dot
using StaticArrays: SVector

export  CSGNode,
        evaluate

export  ImplicitSphere

export  complement,
        intersection,
        subtraction,
        union

include("csgtrees.jl")
include("implicitsurfaces.jl")
include("operations.jl")

end # module
