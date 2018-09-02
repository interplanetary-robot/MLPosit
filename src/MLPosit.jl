module MLPosit

  primitive type Posit8 <: AbstractFloat 8 end

  export Posit8

  include("constants.jl")
  include("conversions.jl")
  include("lazy_math.jl")
  include("sugar.jl")

end # module
