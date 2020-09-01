using Pkg

ENV["PYTHON"]="/users/j/p/jpowers4/anaconda3/bin/python"
#ENV["PYTHON"]="/usr/local/anaconda3/bin/python"
Pkg.build("PyCall", "DataStructures", "BlackBoxOptim", "BlackBoxOptimizationBenchmarking", "DataFrames", "CSV")