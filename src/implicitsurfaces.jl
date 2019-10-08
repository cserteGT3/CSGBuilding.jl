abstract type AbstractImplicitSurface end

mutable struct ImplicitResult{T<:CSGBuilding.AbstractImplicitSurface, F<:Real}
    surface::T
    value::F
    signint::Int
end

value(result::ImplicitResult) = result.value

function normal(result::ImplicitResult, coords::SVector{3})
    return result.signint * normal(result.surface, coords)
end

Base.show(io::IO, result::ImplicitResult) =
    print(io, "ImplicitResult: $(result.surface), $(result.value)")

Base.min(x::ImplicitResult, y::ImplicitResult) = ifelse(isless(x.value, y.value), x, y)

Base.max(x::ImplicitResult, y::ImplicitResult) = ifelse(isless(y.value, x.value), x, y)

struct ImplicitSphere{T<:Real} <: AbstractImplicitSurface
    center::SVector{3,T}
    radius::T
end

Base.show(io::IO, surface::ImplicitSphere) = print(io, "Sphere: R$(surface.radius)")

function evaluate(surface::ImplicitSphere, coords::SVector{3})
    val = norm(coords-surface.center) - surface.radius
    return ImplicitResult(surface, val, 1)
end

function normal(surface::ImplicitSphere, coords::SVector{3})
    val = evaluate(surface, coords)
    dist = coords-surface.center
    if ! isapprox(norm(dist), 0)
        return normalize(coords-surface.center)
    else
        return convert(typeof(coords), [0,0,0])
    end
end

struct ImplicitPlane{T<:Real} <: AbstractImplicitSurface
    point::SVector{3,T}
    normal::SVector{3,T}
end

Base.show(io::IO, surface::ImplicitPlane) = print(io, "Plane: n$(surface.normal)")

function evaluate(surface::ImplicitPlane, coords::SVector{3})
    val = dot(coords-surface.point, surface.normal)
    return ImplicitResult(surface, val, 1)
end

normal(surface::ImplicitPlane, coords::SVector{3}) = surface.normal
