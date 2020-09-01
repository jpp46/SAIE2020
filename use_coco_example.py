import cocoex as ex
import numpy as np
print(ex.known_suite_names)

suite_name = "bbob" # cocoex.known_suite_names
suite_instance = "" # "year:2016"
suite_options = "dimensions:40" # "dimensions: 2,3,5,10,20 "  # if 40 is not desired

suite = ex.Suite(suite_name, suite_instance, suite_options)
fun = suite[0]
range_ = fun.upper_bounds - fun.lower_bounds
center = fun.lower_bounds + range_ / 2
dim = fun.dimension
evals = fun.evaluations
evalc = fun.evaluations_constraints
fin_target = fun.final_target_hit
x0 = fun.initial_solution
xf = fun.best_observed_fvalue1
Id = fun.id
name = fun.name
fun(np.random.rand(40))

for problem_index, problem in enumerate(suite):
	print(problem.name)
	print(problem.dimension)
	print(probelm(np.random.rand(40)))
	print()

#In Julia
'''
using PyCall
ex = pyimport("cocoex")
suite_name = "bbob" # cocoex.known_suite_names
suite_instance = "" # "year:2016"
suite_options = "dimensions:40" # "dimensions: 2,3,5,10,20 "  # if 40 is not desired

suite = ex.Suite(suite_name, suite_instance, suite_options)
functions = []
for i in 1:15:length(suite)
	fun = get(suite, i-1)
	push!(functions, fun)
	println( fun.name )
	println( fun(rand(40)) )
	println()
end
'''