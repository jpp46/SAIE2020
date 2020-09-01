using Base

function num_jobs()
	original_stdout = stdout;
	(rd, wr) = redirect_stdout();
	run(`qstat`);
	redirect_stdout(original_stdout);
	close(wr);
	lines = readlines(rd);
	if length(lines) == 0
		return 0
	end
	return (length(lines)-2)
end

function run_job(s, f, m)
	script = 
"
#PBS -l nodes=1:ppn=2,pmem=3gb,pvmem=8gb
#PBS -l walltime=05:00:00
#PBS -N SAIE_$(s)_$(f+1)_$(m+1)
#PBS -j oe
#PBS -o  \$HOME/SAIE.out

cd \$HOME/SAIE2020/
julia generate_data.jl $s $f $m
"
	open("job.script", "w") do f
		write(f, script)
	end
	run(`qsub job.script`)
	sleep(0.1)
	run(`rm job.script`)
end

function run_job(s, f, m, a)
		script = 
"
#PBS -l nodes=1:ppn=2,pmem=3gb,pvmem=8gb
#PBS -l walltime=05:00:00
#PBS -N SAIE_$(s)_$(f+1)_$(m+1)_$(a)
#PBS -j oe
#PBS -o  \$HOME/SAIE.out

cd \$HOME/SAIE2020/
julia generate_data.jl $s $f $m $a
"
	open("job.script", "w") do f
		write(f, script)
	end
	run(`qsub job.script`)
	sleep(0.1)
	run(`rm job.script`)
end

job_instances = []
acc = [100, 99, 98, 97, 96, 95, 90, 85, 80, 75, 70, 50]
for seed in 0:120
	for f_i in 0:23
		for m_i in 0:12
			if !(isfile("data/$(seed)_f$(f_i+1)_m$(m_i+1)_gt.csv") && isfile("data/$(seed)_f$(f_i+1)_m$(m_i+1)_rnd.csv"))
				push!(job_instances, (seed, f_i, m_i))
			end
			for a_i in 0:11
				if !isfile("data/$(seed)_f$(f_i+1)_m$(m_i+1)_$(acc[a_i+1]).csv")
					push!(job_instances, (seed, f_i, m_i, a_i))
				end
			end
		end
	end
end

while length(job_instances) > 0
	n = num_jobs()
	for _ in 1:(100-n)
		inst = pop!(job_instances)
		if length(inst) == 3
			run_job(inst[1], inst[2], inst[3])
		elseif length(inst) == 4
			run_job(inst[1], inst[2], inst[3], inst[4])
		else
			println(inst)
			println("We have a problem")
			exit()
		end
	end
	sleep(60)
end
