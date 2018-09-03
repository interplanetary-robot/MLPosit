
MLPosit is a fast library for investigating the properties of 8- and 16-bit,
no exponent posits for the purposes of building machine learning hardware.

### Supported Platforms

-  Julia 1.0

### Coming Soon

-  C/C++
-  Python
-  Javascript

### Running in Julia

- NB: to go into shell mode, type `;`, to go into pkg mode type `]`

```julia
shell> cd path/to/MLPosit
(v1.1) pkg> activate .
julia> using MLPosit

julia> x = Posit8(1.0)
Posit8(1.0)

julia> y = Posit8(2.0)
Posit8(2.0)

julia> x + y
Posit8(3.0)
```

#### Performance comparison:

Current code:

```julia
  # note: in julia 1.0
  as_posit(i::UInt8) = reinterpret(Posit8, i)

  # allocate an array of 10k inputs to add.
  const ivalues = rand(UInt8, 10000, 2)
  const pvalues = as_posit.(ivalues)

  #addition test
  perf_add(idx) = pvalues[idx, 1] + pvalues[idx, 2]
  perf_add(1)
  @time for idx = 1:10000
      perf_add(idx)
  end
```

result:
0.000348s

```julia
  # note: use julia 0.6.4
  using SigmoidNumbers

  # allocate an array of 10k inputs to add.
  const ivalues = rand(UInt8, 10000, 2)
  const pvalues = Posit{8,0}.(ivalues)

  # addition test
  perf_add(idx) = pvalues[idx, 1] + pvalues[idx, 2]
  perf_add(1)
  @time for idx = 1:10000
      perf_add(idx)
  end
```
result:
0.000609s
