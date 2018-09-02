module MLPosit

  primitive type Posit8 <: AbstractFloat 8 end

  include("constants.jl")
  include("conversions.jl")
  include("lazy_math.jl")

end # module
