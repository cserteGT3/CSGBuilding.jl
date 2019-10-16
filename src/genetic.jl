@with_kw struct CSGGeneticBuildParameters{R<:Real} @deftype R
    ϵ_d = 0.01
    α = deg2rad(10)
    χ = 0.3
    μ = 0.3
    maxdepth::Int = 10
    μ_0 = 0.3
    itermax::Int = 3000
    populationsize::Int = 150
    keepbestn::Int = 2
end

function rawscore(tree, points, normals, params)
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
    return score - λ*size(tree)
end

function rankpopulation(population, points, normals, params)
    sum = 0.
    score = Array{Float64,1}(undef, size(points))
    normed = similar(score)
    for i in eachindex(population)
        score[i] = rawscore(population[i], points, normals, params)
        normed[i] = 1/(1+score[i])
        sum += normed[i]
    end
    for i in eachindex(score)
        score[i] = normed[i]/sum
    end
    p = sortperm(score)
    return population[p]
end

function crossover(creatures, params)
    @unpack χ, maxdepth = params
    if rand() >= χ
        @debug "rand() >= χ"
        return creatures
    end
    creat_copy = deepcopy(creatures)
    podfs = PreOrderDFS.(creat_copy)
    nofnodes = numberofnodes.(podfs)
    @debug "nofnodes: $nofnodes"

    randnodes = map(x->rand(1:x), nofnodes)
    @debug "randnodes: $randnodes"
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
            @debug "depth(c) > maxdepth"
            return creatures
        end
    end
    return creat_copy
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
    population = [randomtree(surfaces, maxdepth) for _ in 1:populationsize]
    npopulation = similar(population)
    for i in 1:itermax
        population = rankpopulation(population, points, normals, params)
        n = 3
        while true
            newc = crossover(population[1:2], params)
            cv = mutate(newc[1], surfaces, params)
            p[n] = c1v
            n += 1
            n > populationsize && break
            cv = mutate(newc[2], surfaces, params)
            p[n] = cv
            n += 1
            n > populationsize && break
        end
    end
    return population
end
