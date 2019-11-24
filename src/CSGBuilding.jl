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
# cone
using RANSAC: project2cone
# translational
using RANSAC: project2sketchplane, impldistance2segment, outwardsnormal
# conversion
using RANSAC: FittedPlane, FittedSphere, FittedCylinder, FittedCone, ExtractedTranslational
using RANSAC: PointCloud, ScoredShape, ShapeCandidate

export  ImplicitResult,
        value,
        normal,
        ImplicitSphere,
        ImplicitPlane,
        ImplicitCylinder,
        ImplicitCone,
        ImplicitTranslational,
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

export  toimplicit,
        scored2implicit

include("implicitsurfaces.jl")
include("csgtrees.jl")
include("cachedtrees.jl")
include("operations.jl")
include("codegen.jl")
include("visualize.jl")
include("genetic.jl")
include("deprecated.jl")
include("ransaccompat.jl")

end # module
