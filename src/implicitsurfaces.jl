abstract type AbstractImplicitSurface end

mutable struct ImplicitResult{T<:CSGBuilding.AbstractImplicitSurface, F<:Real}
    surface::T
    value::F
    signint::Int
end

value(result::ImplicitResult) = result.value

function normal(result::ImplicitResult, coords)
    return result.signint * normal(result.surface, coords)
end

Base.show(io::IO, result::ImplicitResult) =
    print(io, "ImplicitResult: $(result.surface), $(result.value)")

Base.min(x::ImplicitResult, y::ImplicitResult) = ifelse(isless(x.value, y.value), x, y)

Base.max(x::ImplicitResult, y::ImplicitResult) = ifelse(isless(y.value, x.value), x, y)

## sphere

struct ImplicitSphere{T<:Real} <: AbstractImplicitSurface
    center::SVector{3,T}
    radius::T
end

function ImplicitSphere(center::AbstractArray, radius)
    T = promote_type(eltype(center), typeof(radius))
    nc = convert(SVector{3, T}, center)
    return ImplicitSphere(nc, convert(T, radius))
end

Base.show(io::IO, surface::ImplicitSphere) = print(io, "ImplSphere: R$(surface.radius)")
_name(surface::ImplicitSphere) = "Sphere"

function evaluate(surface::ImplicitSphere, coords)
    val = norm(coords-surface.center) - surface.radius
    return ImplicitResult(surface, val, 1)
end

function normal(surface::ImplicitSphere, coords)
    dist = coords-surface.center
    if ! isapprox(norm(dist), 0)
        return normalize(dist)
    else
        return convert(typeof(coords), [0,0,0])
    end
end

## plane

struct ImplicitPlane{T<:Real} <: AbstractImplicitSurface
    point::SVector{3,T}
    normal::SVector{3,T}
end

function ImplicitPlane(point::AbstractArray, normal::AbstractArray)
    T = promote_type(eltype(point), eltype(normal))
    np = convert(SVector{3, T}, point)
    nn = convert(SVector{3, T}, normal)
    return ImplicitPlane(np, nn)
end

Base.show(io::IO, surface::ImplicitPlane) = print(io, "ImplPlane: n$(surface.normal)")
_name(surface::ImplicitPlane) = "Plane"

function evaluate(surface::ImplicitPlane, coords)
    val = dot(coords-surface.point, surface.normal)
    return ImplicitResult(surface, val, 1)
end

normal(surface::ImplicitPlane, coords) = surface.normal


"""
    issame(x::AbstractImplicitSurface, y::AbstractImplicitSurface, α, ϵ)

For any non-`ImplicitPlane` return false.
"""
issame(x::AbstractImplicitSurface, y::AbstractImplicitSurface, α, ϵ) = false

"""
    issame(pl1::ImplicitPlane, pl2::ImplicitPlane, α, ϵ)

Are the two planes the same? Parameters: α=cosd(5), ϵ=0.3
"""
function issame(pl1::ImplicitPlane, pl2::ImplicitPlane, α, ϵ)
    abs(dot(pl1.normal, pl2.normal)) < α && return false
    d = pl1.point-pl2.point
    abs(dot(d, pl1.normal)) > ϵ && return false
    return true
end

## cylinder

struct ImplicitCylinder{T<:Real} <: AbstractImplicitSurface
    axis::SVector{3,T}
    center::SVector{3,T}
    radius::T
end

function ImplicitCylinder(axis::AbstractArray, center::AbstractArray, radius)
    T = promote_type(eltype(axis), eltype(center), typeof(radius))
    na = convert(SVector{3, T}, axis)
    nc = convert(SVector{3, T}, center)
    return ImplicitCylinder(na, nc, convert(T, radius))
end

"""
    vectorfromline(p, d, q)

Compute the vector directing from a line to `q` point.
The line is defined by one point `p` and it's direction vector `d`.
"""
vectorfromline(p, d, q) = q-p-d*dot(q-p, d)

function evaluate(surface::ImplicitCylinder, coords)
    c = surface.center
    a = surface.axis
    val = norm(vectorfromline(c, a, coords)) - surface.radius
    return ImplicitResult(surface, val, 1)
end

function normal(surface::ImplicitCylinder, coords)
    c = surface.center
    a = surface.axis
    tnorm = vectorfromline(c, a, coords)
    if ! isapprox(norm(tnorm), 0)
        return normalize(tnorm)
    else
        return convert(typeof(coords), [0,0,0])
    end
end

function Base.show(io::IO, surface::ImplicitCylinder)
    return print(io, "ImplCylinder: R$(surface.radius)")
end
_name(surface::ImplicitCylinder) = "Cylinder"

## cone

struct ImplicitCone{T<:Real} <: AbstractImplicitSurface
    apex::SVector{3,T}
    axis::SVector{3,T}
    opang::T
end

function ImplicitCone(apex::AbstractArray, axis::AbstractArray, opang)
    T = promote_type(eltype(apex), eltype(axis), typeof(opang))
    nap = convert(SVector{3, T}, apex)
    nax = convert(SVector{3, T}, axis)
    return ImplicitCone(nap, nax, convert(T, radius))
end

function evaluate(surface::ImplicitCone, coords)
    d, _ = project2cone(surface, coords)
    return ImplicitResult(surface, d, 1)
end

function normal(surface::ImplicitCone, coords)
    _, n = project2cone(surface, coords)
    return n
end

function Base.show(io::IO, surface::ImplicitCone)
    return print(io, "ImplCone: op:$(rad2deg(surface.opang)°)")
end
_name(surface::ImplicitCone) = "Cone"

## translational

struct ImplicitTranslational <: AbstractImplicitSurface
    coordframe
    contour
    # center of gravity
    center
    # normal of the contour is parallel to the direction
    # towards the center of the contour?
    # == should flip the computed normals to direct outwards?
    # this is used in e.g. CSGBuilding
    # true means, that the computed normals must be turned to direct outside
    outwards::Int
    # should the computed normal be flipped to match the measured points
    # this is used in this package to ensure that in/outwards is correct
    # true means that computed normals must be turned to match the measured points
    flipnormal::Int
end

function evaluate(surface::ImplicitTranslational, coords)
    proj = project2sketchplane(coords, surface.coordframe)
    d, i = impldistance2segment(proj, surface)
    return ImplicitResult(surface, d, 1)
end

function normal(surface::ImplicitTranslational, coords)
    proj = project2sketchplane(coords, surface.coordframe)
    _, i = impldistance2segment(proj, surface)
    return outwardsnormal(surface, i)
end

function Base.show(io::IO, surface::ImplicitTranslational)
    return print(io, "ImplTransl")
end
_name(surface::ImplicitTranslational) = "Transl"
