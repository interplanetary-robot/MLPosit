p2f(p::Posit{8}) = convert(Float64, p)
f2p(x::Float64, ::Type{P}) where P <: Posit{8} = convert(P, x)

lazyadd(a::P, b::P) where P <: Posit{8} = f2p(p2f(a) + p2f(b), P)
lazysub(a::P, b::P) where P <: Posit{8} = f2p(p2f(a) - p2f(b), P)
lazymul(a::P, b::P) where P <: Posit{8} = f2p(p2f(a) * p2f(b), P)
lazydiv(a::P, b::P) where P <: Posit{8} = f2p(p2f(a) / p2f(b), P)

Base.:+(a::P, b::P) where P <: Posit = lazyadd(a,b)
Base.:-(a::P, b::P) where P <: Posit = lazysub(a,b)
Base.:*(a::P, b::P) where P <: Posit = lazymul(a,b)
Base.:/(a::P, b::P) where P <: Posit = lazydiv(a,b)

# for performance testing analyses.
branch_add(a::Posit8, b::Posit8)::Posit8 = convert_with_branches(p2f(a) + p2f(b), Posit8)
