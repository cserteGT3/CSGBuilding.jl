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

function scored2implicit(scored::ScoredShape, pcr::PointCloud)
    scored.candidate.shape isa FittedPlane && return [toimplicit(scored.candidate.shape)]
    #TODO: OOBB -> planes
    return [toimplicit(scored.candidate.shape)]
end
