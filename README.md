
MLPosit is a fast library for investigating the properties of 8- and 16-bit,
no exponent posits for the purposes of building machine learning hardware.

### Supported Platforms

-  Julia 1.0
-  C/C++

### Coming Soon

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
0.000252s

### Comparison against old code

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

### Using the C/C++ library

The C/C++ library defines the following types.  The Posit8 class can be used in
C++ programs, the posit8_t type can be used in C programs; both have size 1 byte.

```C++
  class Posit8;
  typedef posit8_t;
```

  the following functions are defined for conversion:

```C++
  float p8_to_f(posit8_t);
  posit8_t f_to_p8(float);

  Posit8::Posit8(float);
  Posit8::Posit8(double);
  Posit8::Posit8(posit8_t);
  Posit8::operator float();
  Posit8::operator double();
  Posit8::operator posit8_t();
```  

the following functions, plus the standard math overload operations (in C++) are
defined:

```C
  posit8_t posit8_add(const posit8_t, const posit8_t);  // addition
  posit8_t posit8_mul(const posit8_t, const posit8_t);  // multiplication
  posit8_t posit8_div(const posit8_t, const posit8_t);  // division
  posit8_t posit8_sub(const posit8_t, const posit8_t);  // subtraction
  posit8_t posit8_addinv(const posit8_t);               // ==> -x
  posit8_t posit8_mulinv(const posit8_t);               // ==> 1/x

  bool posit8_lt(const posit8_t, const posit8_t);
  bool posit8_lte(const posit8_t, const posit8_t);
  bool posit8_gt(const posit8_t, const posit8_t);
  bool posit8_gte(const posit8_t, const posit8_t);
  bool posit8_eq(const posit8_t, const posit8_t);
```  

No vector or matrix operations are defined, but (in C++) you may use the STL
vectors and matrix operations, which will "do the right thing".
