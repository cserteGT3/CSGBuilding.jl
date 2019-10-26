function rawscore(tree::CSGNode, points, normals, params)
    @unpack ϵ_d, α = params
    # λ should be unpacked?
    λ = log(size(points, 1))
    score = 0.

    for i in eachindex(points)
        v, n = valueandnormal(tree, points[i])
        d_i = v/ϵ_d
        θ_i = acos(dot(n, normals[i]))/α
        score += exp(-d_i^2) + exp(-θ_i^2)
    end
    return score - λ*treesize(tree)
end

function rankpopulation(population, points, normals, params)
    sum = 0.
    score = Array{Float64,1}(undef, size(population))
    normed = similar(score)

    @threads for i in eachindex(population)
    #for i in eachindex(population)
        score[i] = rawscore(population[i], points, normals, params)
    end
    for i in eachindex(score)
        normed[i] = 1/(1+score[i])
        sum += normed[i]
    end
    for i in eachindex(score)
        score[i] = normed[i]/sum
    end
    # this is the rescaled score

    p = sortperm(score)
    return population[p], score[p]
end

function mutate(creature, surfaces, params)
    @unpack μ, μ_0, maxdepth = params

    if rand() < μ
        # return mutated
        if rand() < μ_0
            # return new tree
            return randomtree(surfaces, maxdepth)
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
            newnode = randomtree(surfaces, newdepth)
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

function geneticbuildtree(surfaces, points, normals, params)
    @unpack itermax, maxdepth, populationsize = params
    @unpack keepbestn = params
    notifit = itermax > 10 ? div(itermax,10) : 1
    snodes = [CSGNode(s, []) for s in surfaces]
    population = [randomtree(snodes, maxdepth) for _ in 1:populationsize]
    npopulation = similar(population)
    start_time = time_ns()
    for i in 1:itermax
        if i%notifit == 0
            @info "$i-th iteration"
        end
        population, _ = rankpopulation(population, points, normals, params)
        @debug "ranked population"
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
            cv = mutate(newc[1], snodes, params)
            npopulation[n] = cv
            n += 1
            # finish if we have enough
            n > populationsize && break
            # mutate second
            cv = mutate(newc[2], snodes, params)
            npopulation[n] = cv
            n += 1
            n > populationsize && break
        end
        # npopulation is populated with a new set of creature
        population = npopulation
    end
    fint = trunc((time_ns() - start_time)/1_000_000_000, digits=2)
    @info "Finished: $itermax iteration in $fint seconds."
    return population
end
