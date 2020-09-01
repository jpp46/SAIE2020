using BSON: @load
using ColorSchemes
using Makie
using Plots
using DataFrames
using CSV
using Formatting
gr()

normalize(x, mn, mx) = (x - mn)/(mx - mn)

dir = "processed"
@load "$(dir)/missing.bson" missing_files
@assert(length(missing_files) == 0)

@load "$(dir)/mat_100.bson" mat_100
@load "$(dir)/mat_99.bson" mat_99
@load "$(dir)/mat_98.bson" mat_98
@load "$(dir)/mat_97.bson" mat_97
@load "$(dir)/mat_96.bson" mat_96
@load "$(dir)/mat_95.bson" mat_95
@load "$(dir)/mat_90.bson" mat_90
@load "$(dir)/mat_85.bson" mat_85
@load "$(dir)/mat_80.bson" mat_80
@load "$(dir)/mat_75.bson" mat_75
@load "$(dir)/mat_70.bson" mat_70
@load "$(dir)/mat_50.bson" mat_50
@load "$(dir)/mat_rnd.bson" mat_rnd
@load "$(dir)/min_best.bson" min_best
@load "$(dir)/max_worst.bson" max_worst
mats = [mat_100, mat_99, mat_98, mat_97, mat_96, mat_95, mat_90, mat_85, mat_80, mat_75, mat_70, mat_50, mat_rnd]
ms = ["\$m_{$i}\$" for i in 1:13]
cd("raw_graphs")

x_values = [100.0, 95.0, 90.0, 85.0, 80.0, 75.0, 70.0, 50.0]
y_values = Vector{Float64}()
for (mat, name) in zip(mats, [100, 99, 98, 97, 96, 95, 90, 85, 80, 75, 70, 50, :rnd])
    global z, z2
    z = zeros(13, 24)
    z2 = zeros(13, 24)
    idx = 1
    for i in 1:(13*24)
        z[i] = 
        if (2496*mat[i].p) < 0.05
            if mat[i].my <= mat[i].mx
                1
            else
                -1
            end
        else
            0
        end
        mn = min_best[idx]
        mx = max_worst[idx]
        z2[i] = normalize(mat[i].my, mn, mx)
        if i%13 == 0
            idx += 1
        end
    end
    @show maximum(z2), minimum(z2)
    scene = Makie.heatmap(transpose(z[end:-1:1, :]), show_axis=false, colormap=[:red, :blue, :green2])
    println("Number red in $name, ", length(findall(v -> v == -1, z)) )
    push!(y_values, 1 - (length(findall(v -> v == -1, z))/(13*24)))
    Makie.save("$name.png", scene)
    df = DataFrame()
    for i in reverse(1:24)
        insertcols!(df, 1, Symbol("\$f_{$i}\$")=>format.(z2[:, i], precision=2))
    end
    insertcols!(df, 1, Symbol("")=>ms)
    CSV.write("$(name)_values.csv", df)
end

Plots.plot(x_values, y_values[[1, 6, 7, 8, 9, 10, 11, 12]])
Plots.scatter!(x_values, y_values[[1, 6, 7, 8, 9, 10, 11, 12]])
Plots.plot!(
    title="Analysis of Human Accuracy and Performance",
    xlabel="Human Accuracy", ylabel="Percent of Cells Not Red",
    legend=false
)
Plots.plot!(
    xlims=(49.5, 100.5), ylims=(0.0, 1.01), xticks=50:10:100, yticks=0.0:0.2:1.0
)
Plots.savefig("t_trend.png")

println("\n\n")
gt = Nothing
y_values = Vector{Float64}()
for (mat, name) in zip([mat_rnd, mats...], [:gt, 100, 99, 98, 97, 96, 95, 90, 85, 80, 75, 70, 50, :rnd])
    global z, gt
    z = zeros(Int, 13, 24)
    temp_mat = map(t -> t.my, mat)
    if name == :gt
        temp_mat = map(t -> t.mx, mat)
    end
    for col in 1:24
        ranks = zeros(Int, 13)
        r = 1
        while 0 in ranks
            idx = argmin(temp_mat[:, col])
            t2 = temp_mat[:, col]
            t2[idx] = Inf
            temp_mat[:, col] = t2
            ranks[idx] = r
            r += 1
        end
        z[:, col] = ranks
    end
    if name == :gt
        gt = deepcopy(z)
    end
    scene = Makie.heatmap(transpose(z[end:-1:1, :]), show_axis=false, colormap=reverse(ColorSchemes.imola.colors))
    println("Number off in $name, ", length(findall(v -> v != 0, abs.(z .- gt))) )
    push!(y_values, 1 - length(findall(v -> v != 0, abs.(z .- gt)))/(13*24))
    Makie.save("rank_$name.png", scene)
end

Plots.plot(x_values, y_values[[2, 7, 8, 9, 10, 11, 12, 13]])
Plots.scatter!(x_values, y_values[[2, 7, 8, 9, 10, 11, 12, 13]])
Plots.plot!(
    title="Analysis of Human Accuracy and Rank",
    xlabel="Human Accuracy", ylabel="Percent of Rank Retained",
    legend=false
)
Plots.plot!(
    xlims=(49.5, 100.5), ylims=(0.0, 1.01), xticks=50:10:100, yticks=0.0:0.2:1.0
)
Plots.savefig("rank_trend.png")



#=m = zeros(Int, 13, 24)
for col in 1:24
    m[:, col] = collect(1:13)
end
scene = heatmap(transpose(m), show_axis=false, colormap=reverse(ColorSchemes.imola.colors))
Makie.save("test.png", scene)=#