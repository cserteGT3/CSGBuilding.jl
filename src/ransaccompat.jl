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
    result = [toimplicit(scored.candidate.shape)]
    inp = @view pcr.vertices[scored.inpoints]
    _, plusplanes = findOBB(inp)
    append!(result, plusplanes)
    return result
end

function ransacresult2implicit(pcr::PointCloud, scored::ScoredShape)
    implshapes = AbstractImplicitSurface[]
    for i in eachindex(scored)
        append!(implshapes, scored2implicit(pcr, scored))
    end
    toremove = falses(size(implshapes,1))
    ϵ_burntin = 0.2
    α_burntin = cosd(5)
    for i in eachindex(implshapes)
        for j in i+1:last(implshapes)
            issame(implshapes[i], implshapes[j]) || continue
            toremove[j] = true
        end
    end
    deleteat!(implshapes, toremove)
    return implshapes
end
