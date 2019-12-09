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

function tree2tex(tree, outfile, preamble=true)
    js = JSON.parse(JSON.json(tree))
    open(outfile, "w") do io
        println(io, "% ", outfile)
        if preamble
            println(io, """
                        \\begin{figure}[h]""")
        end
        println(io, "   \\begin{forest}")
        println(io, "   ",dict2tex(js))
        println(io, "   \\end{forest}")
        if preamble
            println(io, """
                        \\caption{CSG tree}
                        \\label{fig:tree_}
                    \\end{figure}
                    """)
        end
    end
    nothing
end
