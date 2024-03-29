function centroid(points)
    com = sum(points)
    return com/size(points, 1)
end

function covmat(points, com)
    @assert size(points,1) > 1
    covmat = zeros(3,3)
    for i in eachindex(points)
        pt = points[i]-com

        covmat[2,2] += pt[2]*pt[2]
        covmat[2,3] += pt[2]*pt[3]
        covmat[3,3] += pt[3]*pt[3]

        covmat[1,1] += pt[1]*pt[1]
        covmat[1,2] += pt[1]*pt[2]
        covmat[1,3] += pt[1]*pt[3]
    end
    covmat[2,1] = covmat[1,2]
    covmat[3,1] = covmat[1,3]
    covmat[3,2] = covmat[2,3]
    return covmat
end

function covmat(points)
    c = centroid(points)
    return covmat(points, c)
end

"""
    normedcovmat(points, centr)

Compute the normed covariance matrix with the given centroid.
"""
function normedcovmat(points, c)
    m = covmat(points, c)
    return m/size(points,1)
end

"""
    normedcovmat(points)

Compute the normed covariance matrix of the points.
"""
function normedcovmat(points)
    c = centroid(points)
    m = covmat(points, c)
    return m/size(points,1)
end

"""
    vec2homvec(ps)

Convert 3D vectors to homogeneous vectors: append 1 to each vector.
Return a vector of SVectors.
"""
function vec2homvec(ps)
    return [SVector{4,Float64}(p..., 1) for p in ps]
end

"""
    homvec2vec(ps)

Convert 3D homogeneous vectors to "normal" vectors: drop the 1 from the end.
Return a vector of SVectors.
"""
function homvec2vec(ps)
    return [SVector{3,Float64}(p[1:3]) for p in ps]
end

"""
    fit3pointimplplane(points)

Fit an `ImplicitPlane` to 3 points. First is used as one point of the plane.
"""
function fit3pointimplplane(points)
    v1 = normalize(points[2]-points[1])
    v2 = normalize(points[3]-points[1])
    n = normalize(cross(v1, v2))
    return ImplicitPlane(points[1], n)
end

"""
    findOBB(points)

Compute the oriented bounding box of points (in 3D).
Return the cornerpoints and the 6 planes (as `ImplicitPlane`s).
"""
function findOBB(points)
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
    rmat[1:3,4] = -1 .* evs' * c
    trm = SMatrix{4,4,Float64}(rmat)

    p_transformed = [trm*p for p in vec2homvec(points)]
    aabb_tr = homvec2vec(findAABB(p_transformed))
    meanDiagonal = sum(aabb_tr)/2

    # size of oriented bounding box
    bbs = aabb_tr[2]-aabb_tr[1]
    nv = -bbs/2
    # box around origo
    bi = 0:1
    corners_ = [nv+bbs .*[i,j,k] for i in bi for j in bi for k in bi]
    corners = vec2homvec(corners_)

    # final transformation
    finalTR = zeros(4,4)
    finalTR[4,4] = 1
    finalTR[1:3,1:3] = evs
    finalTR[1:3,4] = evs*meanDiagonal+c
    ftr = SMatrix{4,4,Float64}(finalTR)

    obbcorners_ = [ftr*p for p in corners]
    obbcorners = homvec2vec(obbcorners_)

    # points are selected so that the normals point outside from the cube
    planetris = [[1,5,2], [1,2,3], [1,3,5],
                [8,4,6], [8,6,7], [8,7,4]]
    planes = [fit3pointimplplane(obbcorners[i]) for i in planetris]
    return obbcorners, planes
end
