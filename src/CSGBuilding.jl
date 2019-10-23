module CSGBuilding

using AbstractTrees
using LinearAlgebra: dot, norm, normalize
using StaticArrays: SVector
using Random
using Parameters
using Logging
#import Base.Threads.@spawn
using Base.Threads
using GeometryTypes: normals, vertices
using FileIO: load

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

export  CachedCSGNode,
        CachedSurface,
        CachedResult,
        randomcachedtree,
        cachenodes,
        cached2normaltree,
        cachedgeneticbuildtree,
        leaf2code,
        node2code,
        tree2code,
        code2func,
        tree2func

export  writeparaviewformat,
        readobj

export  CSGGeneticBuildParameters,
        rankpopulation,
        crossover,
        mutate,
        geneticbuildtree

include("implicitsurfaces.jl")
include("csgtrees.jl")
include("cachedtrees.jl")
include("operations.jl")
include("codegen.jl")
include("visualize.jl")
include("genetic.jl")

end # module
