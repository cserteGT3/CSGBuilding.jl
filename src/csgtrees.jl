struct CSGNode
    data
    children
end

function evaluate(tree::CSGNode, coords::SVector{3})
    # tree node doesn't have children
    tree.children == () && return evaluate(tree.data, coords)

    # node.data isa Function -> it has children
    return tree.data(tree.children..., coords)
end

AbstractTrees.children(tree::CSGNode) = tree.children
AbstractTrees.printnode(io::IO, tree::CSGNode) = print(io, tree.data)
