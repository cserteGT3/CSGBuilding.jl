# Source: http://salvi.chaosnet.org/snippets/i-patch.html
"""
write_volume(voxels, filename)

Writes the 3D matrix `voxels` into `filename.raw`
with the metaimage header `filename.mhd`.
"""
function write_volume(voxels, filename)
    n = size(voxels)
    open("$(filename).mhd", "w") do f
        println(f, "NDims = 3")
        println(f, "DimSize = $(n[1]) $(n[2]) $(n[3])")
        println(f, "ElementSize = 1.0 1.0 1.0")
        println(f, "ElementSpacing = 1.0 1.0 1.0")
        println(f, "ElementType = MET_DOUBLE")
        println(f, "ElementByteOrderMSB = False") # LittleEndian
        println(f, "ElementDataFile = $(filename).raw")
    end
    open("$(filename).raw", "w") do f
        for val in voxels
            write(f, val)
        end
    end
end

function writeparaviewformat(surface, fname, scaletuple)
    @unpack mincorner, maxcorner, edgelength = scaletuple
    voxels = Array{Float64}(undef, edgelength, edgelength, edgelength)
    r = range(mincorner, stop=maxcorner, length=edgelength)
    for i in 1:edgelength, j in 1:edgelength, k in 1:edgelength
        voxels[i,j,k] = value(evaluate(surface, SVector{3}([r[i], r[j], r[k]])))
    end
    write_volume(voxels, fname)
end

function readobj(fname, scaletuple)
    @unpack mincorner, maxcorner, edgelength = scaletuple
    m = load(fname)
    vs = vertices(m)./(edgelength-1)
    vs = vs.*(abs(mincorner)+abs(maxcorner))
    diffv = fill(mincorner, 3)
    vs = [v+diffv for v in vs]
    ns = -1 .* normalize.(normals(m))
    return vs, ns
end
