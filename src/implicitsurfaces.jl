abstract type AbstractImplicitSurface end

struct ImplicitSphere{T<:Real} <: AbstractImplicitSurface
    center::SVector{3,T}
    radius::T
end

Base.show(io::IO, surface::ImplicitSphere) = print(io, "Sphere: R$(surface.radius)")

function evaluate(surface::ImplicitSphere, coords::SVector{3})
    return norm(coords-surface.center) - surface.radius
end
