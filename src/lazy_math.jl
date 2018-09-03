p2f(p::Posit8)::Float64 = convert(Float64, p)
f2p(x::Float64)::Posit8 = convert(Posit8, x)

lazyadd(a::Posit8, b::Posit8)::Posit8 = f2p(p2f(a) + p2f(b))
lazysub(a::Posit8, b::Posit8)::Posit8 = f2p(p2f(a) - p2f(b))
lazymul(a::Posit8, b::Posit8)::Posit8 = f2p(p2f(a) * p2f(b))
lazydiv(a::Posit8, b::Posit8)::Posit8 = f2p(p2f(a) / p2f(b))

Base.:+(a::Posit8, b::Posit8)::Posit8 = lazyadd(a,b)
Base.:-(a::Posit8, b::Posit8)::Posit8 = lazysub(a,b)
Base.:*(a::Posit8, b::Posit8)::Posit8 = lazymul(a,b)
Base.:/(a::Posit8, b::Posit8)::Posit8 = lazydiv(a,b)

# for performance testing analyses.
branch_add(a::Posit8, b::Posit8)::Posit8 = convert_with_branches(p2f(a) + p2f(b))
