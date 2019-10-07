complement(f, coords) = -1*evaluate(f, coords)

function intersection(f, g, coords)
    return max(evaluate(f, coords), evaluate(g, coords))
end

function subtraction(f, g, coords)
    return max(evaluate(f, coords), complement(g, coords))
end

function union(f, g, coords)
    return min(evaluate(f, coords), evaluate(g, coords))
end
