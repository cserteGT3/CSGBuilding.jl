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
using MeshIO
using FileIO: load
using Base: Semaphore, acquire, release

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

export  CachedSurface,
        CachedResult,
        CachedCSGNode,
        cachenodes,
        randomcachedtree,
        cached2normaltree

export  tree2func

export  writeparaviewformat,
        readobj

export  CSGGeneticBuildParameters,
        rankpopulation,
        crossover,
        mutate,
        geneticbuildtree,
        cachedgeneticbuildtree,
        cachedfuncgeneticbuildtree

include("implicitsurfaces.jl")
include("csgtrees.jl")
include("cachedtrees.jl")
include("operations.jl")
include("codegen.jl")
include("visualize.jl")
include("genetic.jl")
include("deprecated.jl")

end # module
