using PyCall
ex = pyimport("cocoex")
suite_name = "bbob" # cocoex.known_suite_names
suite_instance = "" # "year:2018"
suite_options = "dimensions:40" # "dimensions: 2,3,5,10,20 "  # if 40 is not desired

# Length is 360, ARGS range is 0-23, there are 15 instances of each function
functions = ex.Suite(suite_name, suite_instance, suite_options)

#using BlackBoxOptimizationBenchmarking

# Length is 20, ARGS range is 0-19
#functions = [fun for fun in enumerate(BBOBFunction)]

# Length 13, ARGS range is 0-12
method = [
    # Natural Evolution Strategies
    :separable_nes, :xnes, :dxnes,
    # Differential Evolution Optimizers
    :adaptive_de_rand_1_bin, :adaptive_de_rand_1_bin_radiuslimited, :de_rand_1_bin, :de_rand_1_bin_radiuslimited, :de_rand_2_bin, :de_rand_2_bin_radiuslimited,
    # Direct Search / Generating Set Search
    :generating_set_search, :probabilistic_descent,
    # Resampling Memetic Searchers
    #These 2 do not work :resampling_memetic_search, :resampling_inheritance_memetic_search,
    # Stochastic Approximation / Simultaneous Perturbation Stochastic Approximation
    :simultaneous_perturbation_stochastic_approximation,
    # Random Search
    :random_search
]

# Length is 12, ARGS range is 0-11
acc = [100, 99, 98, 97, 96, 95, 90, 85, 80, 75, 70, 50]


# Parse the input, all ranges start at zero, changing the seed (s_i) changes which instance of the function is used
function parse_input(args)
    if length(args) == 4
        s_i = parse(Int, args[1])
        f_i = parse(Int, args[2])
        m_i = parse(Int, args[3])+1
        d_i = parse(Int, args[4])+1
        return s_i, get(functions, f_i*15 + s_i%15), method[m_i], acc[d_i]
    elseif length(args) == 3
        s_i = parse(Int, args[1])
        f_i = parse(Int, args[2])
        m_i = parse(Int, args[3])+1
        return s_i, get(functions, f_i*15 + s_i%15), method[m_i], nothing
    else
        println("Incorrect nunmber of arguments")
        @show ARGS
        exit()
    end
end





