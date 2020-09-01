using HypothesisTests
using StatsBase
using CSV
using BSON: @save

function welch_t_test(base, experiment)
    x = base
    y = experiment
    nx, ny = length(x), length(y)
    mx, my = StatsBase.mean(x), StatsBase.mean(y)
    varx, vary = StatsBase.var(x), StatsBase.var(y)
    xbar = mx-my
    stderr = sqrt(varx/nx + vary/ny)
    t = (xbar-0)/stderr
    df = (varx / nx + vary / ny)^2 / ((varx / nx)^2 / (nx - 1) + (vary / ny)^2 / (ny - 1))
    test = UnequalVarianceTTest(nx, ny, xbar, df, stderr, t, 0)
    return pvalue(test), mx, my
end


# Basline values
matrices = [[],[],[],[],[],[],[],[],[],[],[],[],[]]
min_best = ones(24).*Inf
max_worst = ones(24).*-Inf
missing_files = []
for f_i in 1:24
    for m_i in 1:13
        println("Running: F($(f_i)), M($(m_i))")
        baseline = []
        rnd = []
        for seed in 0:120
            if isfile("data/$(seed)_f$(f_i)_m$(m_i)_gt.csv")
                push!(baseline, CSV.read("data/$(seed)_f$(f_i)_m$(m_i)_gt.csv")[!, 2][end])
            else
                push!(missing_files, "data/$(seed)_f$(f_i)_m$(m_i)_gt.csv")
            end
            if isfile("data/$(seed)_f$(f_i)_m$(m_i)_rnd.csv")
                push!(rnd, CSV.read("data/$(seed)_f$(f_i)_m$(m_i)_rnd.csv")[!, 2][end])
            else
                push!(missing_files, "data/$(seed)_f$(f_i)_m$(m_i)_rnd.csv")
            end
        end
        p, mx, my = welch_t_test(baseline, rnd)
        push!(matrices[13], (p=p, mx=mx, my=my))
        mn = minimum(vcat(baseline, rnd))
        mx = maximum(vcat(baseline, rnd))
        if mn < min_best[f_i]
            min_best[f_i] = mn
        end
        if mx > max_worst[f_i]
            max_worst[f_i] = mx
        end

        for (i, a_i) in zip(1:12, [100, 99, 98, 97, 96, 95, 90, 85, 80, 75, 70, 50])
            srg = []
            for seed in 0:120
                if isfile("data/$(seed)_f$(f_i)_m$(m_i)_$(a_i).csv")
                    push!(srg, CSV.read("data/$(seed)_f$(f_i)_m$(m_i)_$(a_i).csv")[!, 2][end])
                else
                    push!(missing_files, "data/$(seed)_f$(f_i)_m$(m_i)_$(a_i).csv")
                end
            end
            p, mx, my = welch_t_test(baseline, srg)
            push!(matrices[i], (p=p, mx=mx, my=my))
            mn = minimum(vcat(baseline, srg))
            mx = maximum(vcat(baseline, srg))
            if mn < min_best[f_i]
                min_best[f_i] = mn
            end
            if mx > max_worst[f_i]
                max_worst[f_i] = mx
            end
        end
    end
end

mat_100 = reshape(matrices[1], (13, 24))
mat_99 = reshape(matrices[2], (13, 24))
mat_98 = reshape(matrices[3], (13, 24))
mat_97 = reshape(matrices[4], (13, 24))
mat_96 = reshape(matrices[5], (13, 24))
mat_95 = reshape(matrices[6], (13, 24))
mat_90 = reshape(matrices[7], (13, 24))
mat_85 = reshape(matrices[8], (13, 24))
mat_80 = reshape(matrices[9], (13, 24))
mat_75 = reshape(matrices[10], (13, 24))
mat_70 = reshape(matrices[11], (13, 24))
mat_50 = reshape(matrices[12], (13, 24))
mat_rnd = reshape(matrices[13], (13, 24))

@save "processed/missing.bson" missing_files
@save "processed/mat_100.bson" mat_100
@save "processed/mat_99.bson" mat_99
@save "processed/mat_98.bson" mat_98
@save "processed/mat_97.bson" mat_97
@save "processed/mat_96.bson" mat_96
@save "processed/mat_95.bson" mat_95
@save "processed/mat_90.bson" mat_90
@save "processed/mat_85.bson" mat_85
@save "processed/mat_80.bson" mat_80
@save "processed/mat_75.bson" mat_75
@save "processed/mat_70.bson" mat_70
@save "processed/mat_50.bson" mat_50
@save "processed/mat_rnd.bson" mat_rnd
@save "processed/min_best.bson" min_best
@save "processed/max_worst.bson" max_worst
