struct CachedSurface
    name::String
    index::Int
end

Base.show(io::IO, surface::CachedSurface) = print(io, surface.name)
_name(s::CachedSurface) = s.name

struct CachedResult
    value::Float64
    signint::Int
    index::Int
end

value(result::CachedResult) = result.value

flipsign(x::CachedResult) = CachedResult(-1*x.value, -1*x.signint, x.index)

function normal(result::CachedResult, cachednormals, ind)
    return result.signint*cachednormals[ind][result.index]
end

function evaluate(surface::CachedSurface, cachedvalues, ind)
    val = cachedvalues[ind][surface.index]
    return CachedResult(val, 1, surface.index)
end

function normal(surface::CachedSurface, cachednormals, ind)
    return cachednormals[ind][surface.index]
end

# complement = -1*
complement(x::CachedResult) = flipsign(x)

# union = min
Base.min(x::CachedResult, y::CachedResult) = ifelse(isless(x.value, y.value), x, y)
union(x::CachedResult, y::CachedResult) = ifelse(isless(x.value, y.value), x, y)

# intersection = max
Base.max(x::CachedResult, y::CachedResult) = ifelse(isless(y.value, x.value), x, y)
intersection(x::CachedResult, y::CachedResult) = ifelse(isless(y.value, x.value), x, y)

# subtraction f,g = f union complement(g)
subtraction(x::CachedResult, y::CachedResult) = intersection(x, complement(y))

struct CachedCSGNode <: AbstractCSGNode
    data::Union{CachedSurface,Symbol}
    children::Array{CachedCSGNode,1}
    sym::Symbol
end

AbstractTrees.children(tree::CachedCSGNode) = tree.children
#AbstractTrees.printnode(io::IO, tree::CachedCSGNode) = print(io, tree.data," ", tree.sym)
AbstractTrees.printnode(io::IO, tree::CachedCSGNode) = print(io, tree.data)

function cachenodes(surfaces, points)
    cached_values = [[value(evaluate(f, p)) for f in surfaces] for p in points]
    cachedsurf = [CachedSurface(_name(surfaces[i])*"$i", i) for i in eachindex(surfaces)]
    nodes = [CachedCSGNode(s, [], gensym()) for s in cachedsurf]
    cached_normals = [[normal(f, p) for f in surfaces] for p in points]
    return (nodes, cached_values, cached_normals)
end

function makecached(surf, n)
    if n == 0 || rand() > 0.7
        return rand(surf)
    else
        # more recursive calls
        op = rand(CSGopsyms)
        s = gensym()
        if op === :complement
            return CachedCSGNode(op, [makecached(surf, n-1)], s)
        else
            return CachedCSGNode(op, [makecached(surf, n-1), makecached(surf, n-1)], s)
        end
    end
end

function randomcachedtree(nodes, maxdepth::Int)
    @assert maxdepth > 0 "Maximum depth should be at least 1!"
    return makecached(nodes, maxdepth)
end

function mapcache(tree, surf)
    if isempty(tree.children)
        return CSGNode(surf[tree.data.index], [])
    else
        op = tree.data
        cs = tree.children
        if op === :complement
            return CSGNode(complement, [mapcache(cs[1], surf)])
        else
            return CSGNode(opDict[op], [mapcache(cs[1], surf), mapcache(cs[2], surf)])
        end
    end
end

function cached2normaltree(tree::CachedCSGNode, surfaces)
    return mapcache(tree, surfaces)
end

function evaluate(tree::CachedCSGNode, cachedcoords, pointind)
    # tree node doesn't have children
    isempty(tree.children) && return evaluate(tree.data, cachedcoords, pointind)

    # node.data isa Function -> it has children
    setop = opDict[tree.data]::Function
    return setop(tree.children..., cachedcoords, pointind)
end

function valueandnormal(tree::CachedCSGNode, ccoords, cnormals, ind)
    val = evaluate(tree, ccoords, ind)
    n = cnormals[ind][val.index]
    return (value(val), n*val.signint)
end
