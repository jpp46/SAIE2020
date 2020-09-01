using DataStructures
using StatsBase

mutable struct Human
    f::Function
    a::Int
    min_fitness::Union{Float64, Nothing}
    dict::SortedDict{Float64, Any}
end
Human(f::Function, a::Int) = Human(f, a, nothing, SortedDict{Float64, Any}())

function comparison(this, c, that, a)
	r = rand(1:100)
	if r > a
		return !c(this, that)
	else
		return c(this, that)
	end
end

function (this::Human)(_x)
	x = deepcopy(_x)
	true_fit = this.f(x)
	this.min_fitness = ((this.min_fitness===nothing) || (true_fit < this.min_fitness)) ? true_fit : this.min_fitness
	if isempty(this.dict)
		this.dict[0] = x
		return 0.0
	elseif length(this.dict) == 1
		if comparison(true_fit, <, this.f(this.dict[0.0]), this.a)
			this.dict[-1] = x
			return -1.0
		elseif comparison(true_fit, >, this.f(this.dict[0.0]), this.a)
			this.dict[1] = x
			return 1.0
		else
			return 0.0
		end
	else
		kys = collect(keys(this.dict))
		upper_bound = kys[end]
		lower_bound = kys[1]
		if comparison(true_fit, ==, this.f(this.dict[lower_bound]), this.a)
			return lower_bound
		elseif comparison(true_fit, ==, this.f(this.dict[upper_bound]), this.a)
			return upper_bound
		elseif comparison(true_fit, <, this.f(this.dict[lower_bound]), this.a)
			key = lower_bound-1
		elseif comparison(true_fit, >, this.f(this.dict[upper_bound]), this.a)
			key = upper_bound+1
		else
			while length(kys) > 2
				idx = Int.(ceil(length(kys)/2))
				key = kys[idx]
				if true_fit < this.f(this.dict[key])
					upper_bound = key
					kys = kys[1:idx]
				elseif true_fit > this.f(this.dict[key])
					lower_bound = key
					kys = kys[idx:end]
				else
					return key
				end
			end
			key = (upper_bound + lower_bound)/2
			this.dict[key] = x
			return key
		end
		this.dict[key] = x
		return key
	end
end




mutable struct rndSample
    f::Function
    min_fitness::Union{Float64, Nothing}
    dict::SortedDict{Float64, Any}
end
rndSample(f::Function) = rndSample(f, nothing, SortedDict{Float64, Any}())

function (this::rndSample)(_x)
	x = deepcopy(_x)
	true_fit = this.f(x)
	this.min_fitness = ((this.min_fitness===nothing) || (true_fit < this.min_fitness)) ? true_fit : this.min_fitness
	if isempty(this.dict)
		this.dict[0.0] = x
		return 0.0
	else
		sample_num = Int(floor(log2(length(this.dict))))+1
		k = zeros(sample_num)
		sample!(collect(keys(this.dict)), k; replace=false)
		df = []
		for idx in k
			if true_fit < this.f(this.dict[idx])
				push!(df, idx-1.0)
			elseif true_fit > this.f(this.dict[idx])
				push!(df, idx+1.0)
			else
				return idx
			end
		end
		m_df = mean(df)
		this.dict[m_df] = x
		return m_df
	end
end















