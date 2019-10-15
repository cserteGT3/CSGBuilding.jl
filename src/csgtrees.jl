struct CSGNode
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

AbstractTrees.children(tree::CSGNode) = tree.children
AbstractTrees.printnode(io::IO, tree::CSGNode) = print(io, tree.data)

function normal(tree::CSGNode, coords)
    return normal(evaluate(tree, coords), coords)
end

function valueandnormal(tree::CSGNode, coords)
    val = evaluate(tree, coords)
    n = normal(val, coords)
    return (value(val), n)
end

function depth(tree::CSGNode)
    childs = collect(children(tree))
    i = 0
    while true
        if childs == fill([], size(childs))
            return i
        end
        i += 1

        newchilds = Array{CSGNode,1}(undef,0)
        for a in childs
            append!(newchilds, children(a))
        end
        childs = newchilds
    end
end

function make(surf, n)
    if n == 0 || rand() > 0.7
        return CSGNode(rand(surf), [])
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
