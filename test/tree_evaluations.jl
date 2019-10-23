function makeit()
    n1 = SVector(1,0,0.0);
    n2 = SVector(0,1,0.0);
    n3 = SVector(0,0,1.0);

    pl1 = ImplicitPlane(n1, n1)
    pl2 = ImplicitPlane(n2, n2)
    pl3 = ImplicitPlane(n3, n3)
    pl4 = ImplicitPlane(-n1, -n1)
    pl5 = ImplicitPlane(-n2, -n2)
    pl6= ImplicitPlane(-n3, -n3)
    mpl = ImplicitPlane([4,4,0.25], -n3)
    cyl = ImplicitCylinder([0,0,1], [0,0,0], .25)
    return [pl1, pl2, pl3, pl4, pl5, pl6, cyl, mpl]
end

surfac = makeit();
Random.seed!(1234);
pontok = [rand(3)*20*rand() for i in 1:100];
cnodes, cvals, cnorms = cachenodes(surfac, pontok)

Random.seed!(1234);
trc1 = randomcachedtree(cnodes, 12);
trc2 = randomcachedtree(cnodes, 1);
randomcachedtree(cnodes, 1);
trc3 = randomcachedtree(cnodes, 1);
trc4 = randomcachedtree(cnodes, 2);
randomcachedtree(cnodes, 4);
trc5 = randomcachedtree(cnodes, 4);
trc6 = CachedCSGNode(:complement, [cnodes[1]], gensym());
trc7 = cnodes[7];
trc8 = CachedCSGNode(:complement, [cnodes[7]], gensym());
trc9 = CachedCSGNode(:subtraction, [cnodes[1], cnodes[7]], gensym());
trc10 = randomcachedtree(cnodes, 4);
trc11 = CachedCSGNode(:subtraction, [cnodes[1], cnodes[1]], gensym());

tr1 = cached2normaltree(trc1, surfac);
tr2 = cached2normaltree(trc2, surfac);
tr3 = cached2normaltree(trc3, surfac);
tr4 = cached2normaltree(trc4, surfac);
tr5 = cached2normaltree(trc5, surfac);
tr6 = cached2normaltree(trc6, surfac);
tr7 = cached2normaltree(trc7, surfac);
tr8 = cached2normaltree(trc8, surfac);
tr9 = cached2normaltree(trc9, surfac);
tr10 = cached2normaltree(trc10, surfac);
tr11 = cached2normaltree(trc11, surfac);

f1 = tree2func(trc1)
f2 = tree2func(trc2)
f3 = tree2func(trc3)
f4 = tree2func(trc4)
f5 = tree2func(trc5)
f6 = tree2func(trc6)
f7 = tree2func(trc7)
f8 = tree2func(trc8)
f9 = tree2func(trc9)
f10 = tree2func(trc10)
f11 = tree2func(trc11)

@testset "t1" begin
    for i in eachindex(pontok)
        p = pontok[i]
        vc1, nc1 = valueandnormal(trc1, cvals, cnorms, i)
        v1, n1 = valueandnormal(tr1, p)

        fv1 = Base.invokelatest(f1, cvals, i)::CachedResult
        vf1 = value(fv1)
        nf1 = normal(fv1, cnorms, i)

        if vc1 != vf1
            @test fv1.index == 7
        end

        @test vc1 == v1 == vf1
        @test nc1 == n1 == nf1
    end
end

@testset "t2" begin
    for i in eachindex(pontok)
        p = pontok[i]
        vc1, nc1 = valueandnormal(trc2, cvals, cnorms, i)
        v1, n1 = valueandnormal(tr2, p)

        fv1 = Base.invokelatest(f2, cvals, i)::CachedResult
        vf1 = value(fv1)
        nf1 = normal(fv1, cnorms, i)

        @test vc1 == v1 == vf1
        @test nc1 == n1 == nf1
    end
end

@testset "t3" begin
    for i in eachindex(pontok)
        p = pontok[i]
        vc1, nc1 = valueandnormal(trc3, cvals, cnorms, i)
        v1, n1 = valueandnormal(tr3, p)

        fv1 = Base.invokelatest(f3, cvals, i)::CachedResult
        vf1 = value(fv1)
        nf1 = normal(fv1, cnorms, i)

        @test vc1 == v1 == vf1
        @test nc1 == n1 == nf1
    end
end

@testset "t4" begin
    for i in eachindex(pontok)
        p = pontok[i]
        vc1, nc1 = valueandnormal(trc4, cvals, cnorms, i)
        v1, n1 = valueandnormal(tr4, p)

        fv1 = Base.invokelatest(f4, cvals, i)::CachedResult
        vf1 = value(fv1)
        nf1 = normal(fv1, cnorms, i)

        @test vc1 == v1 == vf1
        @test nc1 == n1 == nf1
    end
end

@testset "t5" begin
    for i in eachindex(pontok)
        p = pontok[i]
        vc1, nc1 = valueandnormal(trc5, cvals, cnorms, i)
        v1, n1 = valueandnormal(tr5, p)

        fv1 = Base.invokelatest(f5, cvals, i)::CachedResult
        vf1 = value(fv1)
        nf1 = normal(fv1, cnorms, i)

        @test vc1 == v1 == vf1
        @test nc1 == n1 == nf1
    end
end

@testset "t6" begin
    for i in eachindex(pontok)
        p = pontok[i]
        vc1, nc1 = valueandnormal(trc6, cvals, cnorms, i)
        v1, n1 = valueandnormal(tr6, p)

        fv1 = Base.invokelatest(f6, cvals, i)::CachedResult
        vf1 = value(fv1)
        nf1 = normal(fv1, cnorms, i)

        @test vc1 == v1 == vf1
        @test nc1 == n1 == nf1
    end
end

@testset "t7" begin
    for i in eachindex(pontok)
        p = pontok[i]
        vc1, nc1 = valueandnormal(trc7, cvals, cnorms, i)
        v1, n1 = valueandnormal(tr7, p)

        fv1 = Base.invokelatest(f7, cvals, i)::CachedResult
        vf1 = value(fv1)
        nf1 = normal(fv1, cnorms, i)

        @test vc1 == v1 == vf1
        @test nc1 == n1 == nf1
    end
end

@testset "t8" begin
    for i in eachindex(pontok)
        p = pontok[i]
        vc1, nc1 = valueandnormal(trc8, cvals, cnorms, i)
        v1, n1 = valueandnormal(tr8, p)

        fv1 = Base.invokelatest(f8, cvals, i)::CachedResult
        vf1 = value(fv1)
        nf1 = normal(fv1, cnorms, i)

        @test vc1 == v1 == vf1
        @test nc1 == n1 == nf1
    end
end

@testset "t9" begin
    for i in eachindex(pontok)
        p = pontok[i]
        vc1, nc1 = valueandnormal(trc9, cvals, cnorms, i)
        v1, n1 = valueandnormal(tr9, p)

        fv1 = Base.invokelatest(f9, cvals, i)::CachedResult
        vf1 = value(fv1)
        nf1 = normal(fv1, cnorms, i)

        @test vc1 == v1 == vf1
        @test nc1 == n1 == nf1
    end
end

@testset "t10" begin
    for i in eachindex(pontok)
        p = pontok[i]
        vc1, nc1 = valueandnormal(trc10, cvals, cnorms, i)
        v1, n1 = valueandnormal(tr10, p)

        fv1 = Base.invokelatest(f10, cvals, i)::CachedResult
        vf1 = value(fv1)
        nf1 = normal(fv1, cnorms, i)

        @test vc1 == v1 == vf1
        @test nc1 == n1 == nf1
    end
end

@testset "t11" begin
    for i in eachindex(pontok)
        p = pontok[i]
        vc1, nc1 = valueandnormal(trc11, cvals, cnorms, i)
        v1, n1 = valueandnormal(tr11, p)

        fv1 = Base.invokelatest(f11, cvals, i)::CachedResult
        vf1 = value(fv1)
        nf1 = normal(fv1, cnorms, i)

        @test vc1 == v1 == vf1
        @test nc1 == n1 == nf1
    end
end
