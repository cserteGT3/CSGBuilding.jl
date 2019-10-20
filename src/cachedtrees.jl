struct CachedSurface
    name::String
    index::Int
end

Base.show(io::IO, surface::CachedSurface) = print(io, surface.name)

mutable struct CachedResult{F<:Real}
    value::F
    signint::Int
end

value(result::CachedResult) = result.value

function evaluate(surface::CachedSurface, cachedvalues, ind)
    val = cachedvalues[ind][surface.index]
    return CachedResult(val, 1)
end

function normal(surface::CachedSurface, result::CachedResult, cachednormals, ind)
    n = cachednormals[ind][surface.index]
    return n*result.signint
end

struct CachedCSGNode <: AbstractCSGNode
    data::Union{CachedSurface,Function}
    children::Array{CachedCSGNode,1}
end

function evaluate(tree::CachedCSGNode, cachedcoords, pointind)
    # tree node doesn't have children
    isempty(tree.children) && return evaluate(tree.data, cachedcoords, pointind)

    # node.data isa Function -> it has children
    setop = tree.data::Function
    return setop(tree.children..., cachedcoords, pointind)
end

AbstractTrees.children(tree::CachedCSGNode) = tree.children
AbstractTrees.printnode(io::IO, tree::CachedCSGNode) = print(io, tree.data)

Base.min(x::CachedResult, y::CachedResult) = ifelse(isless(x.value, y.value), x, y)
Base.max(x::CachedResult, y::CachedResult) = ifelse(isless(y.value, x.value), x, y)

function makecached(surf, n)
    if n == 0 || rand() > 0.7
        return rand(surf)
    else
        # more recursive calls
        op = rand(CSGOperations)
        if op == complement
            return CachedCSGNode(op, [make(surf, n-1)])
        else
            return CachedCSGNode(op, [make(surf, n-1), make(surf, n-1)])
        end
    end
end

function randomcachedtree(nodes, maxdepth::Int)
    @assert maxdepth > 0 "Maximum depth should be at least 1!"
    return makecached(nodes, maxdepth)
end

function buildcache(surfaces, points)
    cached_values = [[value(evaluate(f, p)) for f in surfaces] for p in points]
    cachedsurf = [CachedSurface(_name(surfaces[i])*"$i", i) for i in eachindex(surfaces)]
    nodes = [CachedCSGNode(s, []) for s in cachedsurf]
    cached_normals = [[normal(f, p) for f in surfaces] for p in points]
    return (nodes, cached_values, cached_normals)
end

function cached2tree(cachedtree, surfaces)
    treemap((x,y,z)->mapcache(x,y,z,surfaces), PostOrderDFS(cachedtree))
end

function mapcache(i, n, children, suf)
    if n.data isa Function
        return CSGNode(n.data, children)
    else
        return CSGNode(suf[n.data.index], children)
    end
end
