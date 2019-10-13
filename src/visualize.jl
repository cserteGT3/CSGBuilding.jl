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

function writeparaviewformat(surface, fname, ranget)
    f = ranget[1]
    t = ranget[2]
    res = ranget[3]

    voxels = Array{Float64}(undef, res, res, res)
    r = range(f, stop=t, length=res)
    for i in 1:res, j in 1:res, k in 1:res
        voxels[i,j,k] = value(evaluate(surface, SVector{3}([r[i], r[j], r[k]])))
    end
    write_volume(voxels, fname)
end
