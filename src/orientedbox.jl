function centroid(points)
    com = sum(points)
    return com/size(points, 1)
end

"""
    normedcovmat(points)

Compute the normed covariance matrix of the points.
"""
function normedcovmat(points)
    @assert size(points,1) > 1
    com = centroid(points)
    vdiff = [p-com for p in points]
    m = sum(vdiff*vdiff')
    return m/(size(points,1)-1)
end

"""
    normedcovmat(points, centr)

Compute the normed covariance matrix with the given centroid.
"""
function normedcovmat(points, centr)
    @assert size(points,1) > 1
    vdiff = [p-centr for p in points]
    m = sum(vdiff*vdiff')
    return m/(size(points,1)-1)
end

"""
    vec2homvec(ps::AbstractArray)

Convert 3D vectors to homogeneous vectors: append 1 to each vector.
Return a vector of SVectors.
"""
function vec2homvec(ps::AbstractArray)
    return [SVector{4,Float64}(p[i]..., 1) for i in eachindex(ps)]
end

function findOOBB(points)
    c = centroid(points)
    m = normedcovmat(points, c)
    evs = eigvecs(m)
    zv = cross(evs[:,1], evs[:,2])
    if abs(dot(zv, evs[:,3])) < cosd(5)
        @warn "evs[3]: $(evs[3]) and zv: $zv are not parallel!"
    end
    evs[:,3] = zv
    # transformation matrix
    rmat = zeros(4,4)
    rmat[4,4] = 1
    rmat[1:3,1:3] = evs'
    rmat[1:3,4] = -1 .* c
    rm = SMatrix{4,4,Float64}(rmat)
end
