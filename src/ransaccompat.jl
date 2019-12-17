# compatibility constructors for RANSAC.jl

function toimplicit(fitted::FittedSphere)
    return ImplicitSphere(fitted.center, fitted.radius)
end

function toimplicit(fitted::FittedPlane)
    return ImplicitPlane(fitted.point, fitted.normal)
end

function toimplicit(fitted::FittedCylinder)
    return ImplicitCylinder(fitted.axis, fitted.center, fitted.radius)
end

function toimplicit(fitted::FittedCone)
    return ImplicitCone(fitted.apex, fitted.axis, fitted.opang)
end

function toimplicit(fitted::ExtractedTranslational)
    cf = fitted.coordframe
    segs = fitted.contour
    c = fitted.center
    outw = fitted.outwards
    flipn = fitted.flipnormal
    return ImplicitTranslational(cf, segs, c, outw, flipn)
end

function scored2implicit(pcr::PointCloud, scored::ScoredShape)
    scored.candidate.shape isa FittedPlane && return [toimplicit(scored.candidate.shape)]
    result = AbstractImplicitSurface[]
    append!(result, [toimplicit(scored.candidate.shape)])
    inp = @view pcr.vertices[scored.inpoints]
    _, plusplanes = findOBB(inp)
    append!(result, plusplanes)
    return result
end

"""
    ransacresult2implicit(pcr::PointCloud, scored::Array{ScoredShape,1}, param)

Process ransac result shapes to implicit surfaces.
"""
function ransacresult2implicit(pcr, scored, params)
    implshapes = AbstractImplicitSurface[]
    for i in eachindex(scored)
        append!(implshapes, scored2implicit(pcr, scored[i]))
    end
    toremove = falses(size(implshapes,1))
    for i in eachindex(implshapes)
        for j in i+1:lastindex(implshapes)
            issame(implshapes[i], implshapes[j], params) || continue
            toremove[j] = true
        end
    end
    deleteat!(implshapes, toremove)
    return implshapes, toremove
end

function scored2implicit_ordered(pcr::PointCloud, scored::ScoredShape)
    inp = @view pcr.vertices[scored.inpoints]
    _, plusplanes = findOBB(inp)
    return plusplanes
end

function ransacresult2implicit_ordered(pcr, scored, params)
    implshapes = AbstractImplicitSurface[]
    append!(implshapes, [toimplicit(s.candidate.shape) for s in scored])
    for i in eachindex(scored)
        scored[i].candidate.shape isa FittedPlane && continue
        append!(implshapes, scored2implicit_ordered(pcr, scored[i]))
    end
    toremove = falses(size(implshapes,1))
    for i in eachindex(implshapes)
        for j in i+1:lastindex(implshapes)
            issame(implshapes[i], implshapes[j], params) || continue
            toremove[j] = true
        end
    end
    deleteat!(implshapes, toremove)
    return implshapes, toremove
end

function pairthem(a, b, p)
    pairing = []
    for i in 1:size(a,1)
        for j in 1:size(b,1)
            if a[i] == b[j]
                push!(pairing, [i, j])
            elseif CSGBuilding.issame(a[i], b[j], p)
                push!(pairing, [i, j])
            end
        end
    end
    na = CSGBuilding._name.(a)
    nb = CSGBuilding._name.(b)
    pname = [na[p[1]]*"$(p[1])"=>nb[p[2]]*"$(p[2])" for p in pairing]
    pairing, pname
end
