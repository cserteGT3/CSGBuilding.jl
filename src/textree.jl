function convert_notation(s)
    s == "intersection" && return "\$\\cap\$"
    s == "union" && return "\$\\cup\$"
    s == "subtraction" && return "\$-\$"
    s == "complement" && return "\$\\sim\$"
    s
end

function dict2tex(tree)
    !haskey(tree, "data") && return ""
    isempty(tree["children"]) && return " [" * tree["data"] * " ]"
    mapreduce(dict2tex, *, tree["children"], init = " [" * convert_notation(tree["data"])) * "]"
end

function json2tex(infile, outfile; preamble=false)
    tree = JSON.parse(read(infile, String))
    open(outfile, "w") do f
        println(f, "% ", outfile)
        if preamble
            println(f, """
                       \\documentclass{article}
                       \\usepackage{Forest}
                       \\begin{document}
                       """)
        end
        println(f, "\\begin{forest}")
        println(f, dict2tex(tree))
        println(f, "\\end{forest}")
        if preamble
            println(f, "\\end{document}")
        end
    end
end

function tree2tex(tree, outfile::String; preamble=true)
    js = JSON.parse(JSON.json(tree))
    treestr = tree2tex(tree, preamble)
    open(outfile, "w") do io
        println(io, treestr)
    end
    nothing
end

"""
    tree2tex_orderfix(tree, outfile, pc, extr, convp; preamble=true)

Fix order.
"""
function tree2tex_orderfix(tree::CachedCSGNode, outfile, pc, extr, convp; preamble=true)
    js = JSON.parse(JSON.json(toNiceTree(tree)))
    treestr = tree2tex(js, preamble)
    #order fix
    impls2, _ = ransacresult2implicit(pc, extr, convp)
    impls2o, _ = ransacresult2implicit_ordered(pc, extr, convp)
    _, pairn = pairthem(impls2, impls2o, convp)
    for p in pairn
        treestr = replace(treestr, p)
    end
    open(outfile, "w") do io
        println(io, treestr)
    end
    nothing
end

function tree2tex(tree, preamble::Bool)
    js = JSON.parse(JSON.json(tree))
    io = IOBuffer()
    #println(io, "% ", outfile)
    if preamble
        println(io, """
        \\begin{figure}[h]""")
    end
    println(io, """    \\centering
    \\begin{forest}""")
    println(io, "   ",dict2tex(js))
    println(io, "   \\end{forest}")
    if preamble
        println(io, """
        \\caption{CSG tree}
        \\label{fig:tree_}
        \\end{figure}
        """)
    end
    return String(take!(io))
end
