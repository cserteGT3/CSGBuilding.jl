module CSGBuilding

using AbstractTrees
using LinearAlgebra: dot, norm, normalize, eigvecs, cross
using StaticArrays: SVector, SMatrix
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
using RANSAC: project2sketchplane, dn2shape_outw, outwardsnormal
# conversion
using RANSAC: FittedPlane, FittedSphere, FittedCylinder, FittedCone, ExtractedTranslational
using RANSAC: PointCloud, ScoredShape, ShapeCandidate
# others
using RANSAC: findAABB
# visualize and write
import JSON


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
        toNiceTree,
        toJSON,
        readobj

export  centroid,
        findOBB,
        issame,
        ransacresult2implicit

export  CSGGeneticBuildParameters,
        rankpopulation,
        crossover,
        mutate,
        geneticbuildtree,
        cachedgeneticbuildtree,
        cachedfuncgeneticbuildtree

export  toimplicit,
        scored2implicit

export  tree2tex,
        json2tex

export  isosurface,
        writeOBJ


include("implicitsurfaces.jl")
include("csgtrees.jl")
include("cachedtrees.jl")
include("operations.jl")
include("codegen.jl")
include("visualize.jl")
include("orientedbox.jl")
include("genetic.jl")
include("deprecated.jl")
include("ransaccompat.jl")
include("textree.jl")
include("dual_contour.jl")

end # module
