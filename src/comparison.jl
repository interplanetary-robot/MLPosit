function Base.:<(a::T, b::T) where T <: Posit
  isnan(a) || isnan(b) return nan(T)
  return s(a) < s(b)
end
