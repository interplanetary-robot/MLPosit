#consider generalizing these values.
macro u(e)
    :(reinterpret(UInt8, $e))
end

macro p(e)
    :(reinterpret(Posit8, $e))
end

Base.:*(a::Posit8, b::Bool) = @p(@u(a) * b)
Base.:*(b::Bool, a::Posit8) = @p(@u(a) * b)
