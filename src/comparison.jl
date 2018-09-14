function Base.:<(a::T, b::T) where T <: Posit
  (isnan(a) || isnan(b)) && return nan(T)
  return s(a) < s(b)
end

function Base.:<=(a::T, b::T) where T <: Posit
  (isnan(a) || isnan(b)) && return nan(T)
  return s(a) <= s(b)
end

function Base.:>(a::T, b::T) where T <: Posit
  (isnan(a) || isnan(b)) && return nan(T)
  return s(a) > s(b)
end

function Base.:>=(a::T, b::T) where T <: Posit
  (isnan(a) || isnan(b)) && return nan(T)
  return s(a) >= s(b)
end

function Base.signbit(a::T) where T <: Posit
  isnan(a) && return false
  return s(a) < zero(Int8)
end
