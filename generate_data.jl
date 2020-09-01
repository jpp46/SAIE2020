include("build.jl")
include("surrogate.jl")
include("fitness_functions.jl")

using BlackBoxOptim
using BlackBoxOptim: num_func_evals
using DataFrames
using Random
using CSV

const S, F, M, A = parse_input(ARGS)
const MaxFuncEvals = 5000

Random.seed!(S)

# Optimize in the standard fashion as the ground truth
function optimize_gt(f, m)
    fitness_history = Array{Tuple{Int, Float64},1}()
    function callback(oc)
        push!(fitness_history, (num_func_evals(oc), best_fitness(oc))) # (evals, true_fit)
        history = hcat(collect.(fitness_history)...)
        evals, true_fits = (history[1, :], history[2, :])
        df = DataFrame(EVALS=evals, TrueFitness=true_fits)
        CSV.write("data/$(S)_f$(parse(Int, ARGS[2])+1)_m$(parse(Int, ARGS[3])+1)_gt.csv", df)
    end
    bboptimize(x -> f(x);
                SearchRange=(-5.0, 5.0), NumDimensions=40,
                Method=m, MaxFuncEvals=MaxFuncEvals, TraceMode=:silent,
                CallbackFunction=callback, CallbackInterval=0.0)
    history = hcat(collect.(fitness_history)...)
    return history[1, :], history[2, :]
end

# Optimize with a nlogn randomly smapled surrogate 100% accurate human
function optimize_rnd(f, m)
    fitness_history = Array{Tuple{Int, Float64, Float64},1}()
    function callback(oc)
        push!(fitness_history, (num_func_evals(oc), surrogate.min_fitness, best_fitness(oc))) # (evals, true_fit, derived_fit)
        history = hcat(collect.(fitness_history)...)
        evals, true_fits, der_fits = (history[1, :], history[2, :], history[3, :])
        df = DataFrame(EVALS=evals, TrueFitness=true_fits, DerivedFitness=der_fits)
        CSV.write("data/$(S)_f$(parse(Int, ARGS[2])+1)_m$(parse(Int, ARGS[3])+1)_rnd.csv", df)
    end
    surrogate = rndSample(x -> f(x))
    bboptimize(x -> surrogate(x);
                SearchRange=(-5.0, 5.0), NumDimensions=40,
                Method=m, MaxFuncEvals=MaxFuncEvals, TraceMode=:silent,
                CallbackFunction=callback, CallbackInterval=0.0)
    history = hcat(collect.(fitness_history)...)
    return history[1, :], history[2, :], history[3, :]
end

# Optimize using our simulated human surragate as the function evaluator
function optimize_hs(f, m, a)
    fitness_history = Array{Tuple{Int, Float64, Float64},1}()
    function callback(oc)
        push!(fitness_history, (num_func_evals(oc), surrogate.min_fitness, best_fitness(oc))) # (evals, true_fit, derived_fit)
        history = hcat(collect.(fitness_history)...)
        evals, true_fits, der_fits = (history[1, :], history[2, :], history[3, :])
        df = DataFrame(EVALS=evals, TrueFitness=true_fits, DerivedFitness=der_fits)
        CSV.write("data/$(S)_f$(parse(Int, ARGS[2])+1)_m$(parse(Int, ARGS[3])+1)_$(a).csv", df)
    end
    surrogate = Human(x -> f(x), a)
    bboptimize(x -> surrogate(x);
                SearchRange=(-5.0, 5.0), NumDimensions=40,
                Method=m, MaxFuncEvals=MaxFuncEvals, TraceMode=:silent,
                CallbackFunction=callback, CallbackInterval=0.0)
    history = hcat(collect.(fitness_history)...)
    return history[1, :], history[2, :], history[3, :]
end

if A == nothing
    res = optimize_gt(F, M)
    res = optimize_rnd(F, M)
else
    res = optimize_hs(F, M, A)
end






