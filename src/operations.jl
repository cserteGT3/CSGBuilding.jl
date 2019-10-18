function complement(f::CSGNode, coords)
    ev = evaluate(f, coords)
    ev.signint = -1*ev.signint
    ev.value = -1*ev.value
    return ev
end

function intersection(f::CSGNode, g::CSGNode, coords)
    gt = @spawn evaluate(g, coords)
    ftr = evaluate(f, coords)
    gtr = fetch(gt)
    return max(ftr, gtr)
end

function subtraction(f::CSGNode, g::CSGNode, coords)
    gt = @spawn complement(g, coords)
    ftr = evaluate(f, coords)
    gtr = fetch(gt)
    return max(ftr, gtr)
end

function union(f::CSGNode, g::CSGNode, coords)
    gt = @spawn evaluate(g, coords)
    ftr = evaluate(f, coords)
    gtr = fetch(gt)
    return min(ftr, gtr)
end

const CSGOperations = [complement, intersection, subtraction, union]
