# complement = -1*
function cmpl(x::CachedResult)
    return CachedResult(-1*x.value, -1*x.signint, x.index)
end

# union = min
# Base.min(x::CachedResult, y::CachedResult) = ifelse(isless(x.value, y.value), x, y)
uni(x::CachedResult, y::CachedResult) = ifelse(isless(x.value, y.value), x, y)

# intersection = max
# Base.max(x::CachedResult, y::CachedResult) = ifelse(isless(y.value, x.value), x, y)
inters(x::CachedResult, y::CachedResult) = ifelse(isless(y.value, x.value), x, y)

# subtraction f,g = f union complement(g)
subtr(x::CachedResult, y::CachedResult) = intersection(x, complement(y))

const opDictCode = Dict(:complement=>cmpl,
                :intersection=>inters,
                :subtraction=>subtr,
                :union=>uni)

function evalf(surface::CachedSurface, cachedvalues, ind)
    val = cachedvalues[ind][surface.index]
    return CachedResult(val, 1, surface.index)
end

function leaf2code(l::CachedCSGNode, _cvals, _ind)
    ex = Expr(Symbol("="), l.sym, Expr(:call, evalf, l.data, _cvals, _ind))
    return ex
end

function node2code(l::CachedCSGNode)
    arg1 = l.children[1].sym
    op = l.data
    if op === :complement
        ex = Expr(Symbol("="), l.sym, Expr(:call, opDictCode[:complement], arg1))
        return ex
    else
        arg2 = l.children[2].sym
        ex = Expr(Symbol("="), l.sym, Expr(:call, opDictCode[op], arg1, arg2))
        return ex
    end
end

function tree2code(tree::CachedCSGNode)
    _cachedv = gensym()
    _inds = gensym()
    exprs = Array{Expr,1}(undef,0)
    for l in Set{CachedCSGNode}(Leaves(tree))
        push!(exprs, leaf2code(l, _cachedv, _inds))
    end
    for n in PostOrderDFS(tree)
        isempty(n.children) && continue
        push!(exprs, node2code(n))
    end
    return CodeWrap(exprs, [_cachedv, _inds])
end

struct CodeWrap
    Core::Array{Expr,1}
    Params::Array{Symbol,1}
end

function code2func(cwrap)
    expr = Expr(:function,
        Expr(:tuple,
        cwrap.Params[1],
        cwrap.Params[2]),
        Expr(:block,cwrap.Core...))
    return eval(expr)
end

tree2func(tree::CachedCSGNode) = code2func(tree2code(tree))
