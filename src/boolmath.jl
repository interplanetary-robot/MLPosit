#consider generalizing these values.

Base.:*(a::Posit, b::Bool) = p(u(a) * b)
Base.:*(b::Bool, a::Posit) = p(u(a) * b)
