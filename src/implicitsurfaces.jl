abstract type AbstractImplicitSurface end

struct ImplicitSphere{T<:Real} <: AbstractImplicitSurface
    center::SVector{3,T}
    radius::T
end

Base.show(io::IO, surface::ImplicitSphere) = print(io, "Sphere: R$(surface.radius)")

function evaluate(surface::ImplicitSphere, coords::SVector{3})
    return norm(coords-surface.center) - surface.radius
end

struct ImplicitPlane{T<:Real} <: AbstractImplicitSurface
    point::SVector{3,T}
    normal::SVector{3,T}
end

Base.show(io::IO, surface::ImplicitPlane) = print(io, "Plane: n$(surface.normal)")

function evaluate(surface::ImplicitPlane, coords::SVector{3})
    return dot(coords-surface.point, surface.normal)
end
