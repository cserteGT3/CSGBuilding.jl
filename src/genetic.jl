@with_kw struct CSGGeneticBuildParameters{R<:Real} @deftype R
    # scoring
    ϵ_d = 0.01
    α = deg2rad(10)
    # mutation and crossover
    χ = 0.3
    μ = 0.3
    μ_0 = 0.3
    # tree & genetic iteration parameters
    maxdepth::Int = 10
    itermax::Int = 3000
    populationsize::Int = 150
    keepbestn::Int = 2
    # tournament selection
    tournamentsize::Int = 30
    selectionprob = 0.5
    rungc::Bool = false
end

function crossover(creatures, params)
    @unpack χ, maxdepth = params
    if rand() >= χ
        #@debug "rand() >= χ"
        return creatures
    end
    creat_copy = deepcopy(creatures)
    podfs = PreOrderDFS.(creat_copy)
    nofnodes = numberofnodes.(podfs)
    #@debug "nofnodes: $nofnodes"
    (isempty(1:nofnodes[1]) || isempty(1:nofnodes[2])) && return creatures
    randnodes = map(x->rand(1:x), nofnodes)
    #@debug "randnodes: $randnodes"
    changenodes = reverse(deepcopy(selectfirstchildnode.(podfs, randnodes)))
    for i in 1:2
        n = 0
        for j in podfs[i]
            isempty(j.children) && continue
            n += 1
            if n == randnodes[i]
                j.children[1] = changenodes[i]
                break
            end
        end
    end
    for c in creat_copy
        if depth(c) > maxdepth
            #@debug "depth(c) > maxdepth"
            return creatures
        end
    end
    return creat_copy
end

function mutatecached(creature, nodes, params)
    @unpack μ, μ_0, maxdepth = params

    if rand() < μ
        # return mutated
        if rand() < μ_0
            # return new tree
            return randomcachedtree(nodes, maxdepth)
        else
            # mutate tree
            creat_copy = deepcopy(creature)
            podfs = PreOrderDFS(creat_copy)
            nofnodes = numberofnodes(podfs)
            isempty(1:nofnodes) && return creature
            randnode = rand(1:nofnodes)
            selected_node = selectfirstchildnode(podfs, randnode)
            nd = depth(selected_node)
            newdepth = nd > 0 ? nd : 1
            newnode = randomcachedtree(nodes, newdepth)
            n = 0
            for j in podfs
                isempty(j.children) && continue
                n += 1
                if n == randnode
                    j.children[1] = newnode
                    break
                end
            end
            if depth(creat_copy) > maxdepth
                return creature
            end
            return creat_copy
        end
    else
        # don't mutate tree
        return creature
    end
end

function tournament(params)
    # asserts that the population is sorted in descending order
    @unpack tournamentsize, selectionprob, populationsize = params
    tourn = [rand(1:populationsize) for _ in 1:tournamentsize]
    sort!(tourn)
    for ind in tourn
        rand() < selectionprob && return ind
    end
    return tourn[1]
end

function projectnormal(res::CachedResult, surfaces, n)
    pl = surfaces[res.index]
    cf = pl.coordframe
    n_ = SVector{2,Float64}(dot(cf[1],n), dot(cf[2],n))
    resn = res.signint*n_
    return resn
end

function rawscorefunc(tree, surfaces, cpoints, cnormals, normals, params)
    @unpack ϵ_d, α = params
    # λ should be unpacked?
    λ = log(size(cpoints, 1))
    score = 0.
    f = tree2func(tree)
    for i in eachindex(cpoints)
        res = Base.invokelatest(f, cpoints, i)::CachedResult
        v = value(res)
        n = normal(res, cnormals, i)
        d_i = v/ϵ_d
        #TODO: this is not really safe :D
        if size(n,1) == 2
            n_comp = projectnormal(res, surfaces, normals[i])
            ddot = dot(n, n_comp)
        else
            ddot = dot(n, normals[i])
        end
        ddot = clamp(ddot, -1, 1)
        θ_i = acos(ddot)/α
        score += exp(-d_i^2) + exp(-θ_i^2)
    end
    return score - λ*treesize(tree)
end

function rankcachedpopulationfunc(population, surfaces, cpoints, cnormals, normals, params)
    sum = 0.
    score = Array{Float64,1}(undef, size(population))
    normed = similar(score)

    #smphr = Semaphore(1)
    #@threads for i in eachindex(population)
    for i in eachindex(population)
        score[i] = rawscorefunc(population[i], surfaces, cpoints, cnormals, normals, params)
    end
    #=
    for i in eachindex(score)
        normed[i] = 1/(1+score[i])
        sum += normed[i]
    end
    for i in eachindex(score)
        score[i] = normed[i]/sum
    end
    # this is the rescaled score
    =#
    p = sortperm(score, rev=true)
    bestscore = score[p][1]
    return population[p], bestscore
end

function cachedfuncgeneticbuildtree(surfaces, points, normals, params)
    @unpack itermax, maxdepth, populationsize = params
    @unpack keepbestn, rungc = params
    notifit = itermax > 10 ? div(itermax,10) : 1
    cnodes, cvalues, cnormals = cachenodes(surfaces, points)
    population = [randomcachedtree(cnodes, maxdepth) for _ in 1:populationsize]
    npopulation = similar(population)
    start_time = time_ns()
    @info "Iteration in progress..."
    for i in 1:itermax
        population, nsc = rankcachedpopulationfunc(population, surfaces, cvalues, cnormals, normals, params)
        if i%notifit == 0
            @info "$i-th iteration - best score: $nsc"
            if rungc
                GC.gc()
            end
        end
        # save the best
        npopulation[1:keepbestn] = population[1:keepbestn]
        n = keepbestn+1
        while true
            # select 2 creatures by tournament
            t1 = deepcopy(population[tournament(params)])
            t2 = deepcopy(population[tournament(params)])
            # crossover them
            newc = crossover([t1, t2], params)
            # mutate first
            cv = mutatecached(newc[1], cnodes, params)
            npopulation[n] = cv
            n += 1
            # finish if we have enough
            n > populationsize && break
            # mutate second
            cv = mutatecached(newc[2], cnodes, params)
            npopulation[n] = cv
            n += 1
            n > populationsize && break
        end
        # npopulation is populated with a new set of creature
        population = npopulation
    end
    fint = trunc((time_ns() - start_time)/1_000_000_000, digits=2)
    @info "Finished: $itermax iteration in $fint seconds."
    return population, cached2normaltree(population[1], surfaces)
end
