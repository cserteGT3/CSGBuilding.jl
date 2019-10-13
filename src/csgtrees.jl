struct CSGNode
    data::Union{AbstractImplicitSurface, Function}
    children::Tuple{Vararg{CSGNode}}
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
