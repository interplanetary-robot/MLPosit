
as_posit(i::UInt8) = reinterpret(Posit8, i)

#allocate an array of 10k inputs to add.
const ivalues = rand(UInt8, 10000, 2)
const pvalues = as_posit.(ivalues)

#addition test
println("addition test")
perf_add(idx) = pvalues[idx, 1] + pvalues[idx, 2]
perf_add(1)

@time for idx = 1:10000
    perf_add(idx)
end

branch_perf_add(idx) = MLPosit.branch_add(pvalues[idx,1], pvalues[idx, 2])
branch_perf_add(1)

@time for idx = 1:10000
    branch_perf_add(idx)
end
