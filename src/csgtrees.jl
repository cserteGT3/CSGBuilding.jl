abstract type AbstractCSGNode end

struct CSGNode <: AbstractCSGNode
    data::Union{AbstractImplicitSurface, Function}
    children::Array{CSGNode,1}
end

function evaluate(tree::CSGNode, coords)
    # tree node doesn't have children
    isempty(tree.children) && return evaluate(tree.data, coords)

    # node.data isa Function -> it has children
    setop = tree.data::Function
    return setop(tree.children..., coords)
end

AbstractTrees.children(tree::AbstractCSGNode) = tree.children
AbstractTrees.printnode(io::IO, tree::AbstractCSGNode) = print(io, tree.data)

function normal(tree::CSGNode, coords)
    return normal(evaluate(tree, coords), coords)
end

function valueandnormal(tree::CSGNode, coords)
    val = evaluate(tree, coords)
    n = normal(val, coords)
    return (value(val), n)
end

# compatibility for dual contouring
function isosurface(tree::CSGNode, isolevel, bounding_box, resolution; df=nothing)
    isosurface(p->value(evaluate(tree, p)), isolevel, bounding_box, resolution; df=df)
end

function depth(tree::AbstractCSGNode)
    childs = collect(children(tree))
    i = 0
    while true
        if childs == fill([], size(childs))
            return i
        end
        i += 1

        newchilds = Array{typeof(tree),1}(undef,0)
        for a in childs
            append!(newchilds, children(a))
        end
        childs = newchilds
    end
end


function treesize(tree::AbstractCSGNode)
    s = 0
    for _ in PreOrderDFS(tree)
        s+=1
    end
    return s
end

function numberofnodes(it::AbstractTrees.TreeIterator)
    n = 0
    for i in it
        isempty(i.children) && continue
        n += 1
    end
    return n
end

function selectfirstchildnode(it::AbstractTrees.TreeIterator, ind)
    n = 0
    for i in it
        isempty(i.children) && continue
        n += 1
        if n == ind
            return i.children[1]
        end
    end
    throw(BoundsError(it, ind))
end

function make(surf, n)
    if n == 0 || rand() > 0.7
        return rand(surf)
    else
        # more recursive calls
        op = rand(CSGOperations)
        if op == complement
            return CSGNode(op, [make(surf, n-1)])
        else
            return CSGNode(op, [make(surf, n-1), make(surf, n-1)])
        end
    end
end

function randomtree(surfaces, maxdepth::Int)
    @assert maxdepth > 0 "Maximum depth should be at least 1!"
    return make(surfaces, maxdepth)
end

"""
    evaldistance(tree::CSGNode, points)

Compute the sum of squared distances to the surface of the `tree` from every point of `points`.
"""
function evaldistance(tree::CSGNode, points)
    sum = 0.0
    for p in points
        d = value(evaluate(tree, p))
        sum+=d^2
    end
    return sum
end
