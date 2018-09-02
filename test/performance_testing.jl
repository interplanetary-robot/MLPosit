
as_posit(i::UInt8) = reinterpret(Posit8, i)

#allocate an array of 10k inputs to add.
ivalues = rand(UInt8, 10000, 2)
pvalues = as_posit.(ivalues)

#addition test
println("addition test")
perf_add(idx) = pvalues[idx, 1] + pvalues[idx, 2]
perf_add(1)
@time for idx = 1:10000
    perf_add(idx)
end
