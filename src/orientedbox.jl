function centroid(points)
    com = sum(points)
    return com/size(points, 1)
end

function normedcovmat(points)
    @assert size(points,1) > 1
    com = centroid(points)
    vdiff = [p-com for p in points]
    m = sum(vdiff*vdiff')
    return m/(size(points,1)-1)
end
