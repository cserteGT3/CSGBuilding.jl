function complement(f::CSGNode, coords)
    ev = evaluate(f, coords)
    ev.signint = -1*ev.signint
    ev.value = -1*ev.value
    return ev
end

function intersection(f::CSGNode, g::CSGNode, coords)
    return max(evaluate(f, coords), evaluate(g, coords))
end

function subtraction(f::CSGNode, g::CSGNode, coords)
    return max(evaluate(f, coords), complement(g, coords))
end

function union(f::CSGNode, g::CSGNode, coords)
    return min(evaluate(f, coords), evaluate(g, coords))
end

const CSGOperations = [complement, intersection, subtraction, union]
