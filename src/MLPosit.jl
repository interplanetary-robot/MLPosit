module MLPosit

  abstract type Posit{N} <: AbstractFloat end

  primitive type Posit16 <: Posit{16} 16 end
  primitive type Posit8 <: Posit{8} 8 end
  primitive type PositN8 <: Posit{8} 8 end  #posit with no quire

  u(pval::Posit{8}) = reinterpret(UInt8, pval)
  s(pval::Posit{8}) = reinterpret(Int8, pval)
  p(ival::Union{Int8, UInt8}, ::Type{T}) where T <: Posit{8} = reinterpret(T, ival)

  export Posit8

  include("constants.jl")
  include("conversions8.jl")
  include("comparison.jl")
  include("lazy_math.jl")
  include("sugar.jl")

end # module
