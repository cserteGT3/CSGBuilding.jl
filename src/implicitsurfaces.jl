abstract type AbstractImplicitSurface end

struct ImplicitSphere{T<:Real} <: AbstractImplicitSurface
    center::SVector{3,T}
    radius::T
end

Base.show(io::IO, surface::ImplicitSphere) = print(io, "Sphere: R$(surface.radius)")

function evaluate(surface::ImplicitSphere, coords::SVector{3})
    difv = surface.center-coords
    return dot(difv, difv) - surface.radius^2
end
