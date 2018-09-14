p2f(p::Posit{8}) = convert(Float64, p)
f2p(x::Float64, ::Type{P}) where P <: Posit = convert(P, x)

lazyadd(a::P, b::P) where P <: Posit = f2p(p2f(a) + p2f(b), P)
lazysub(a::P, b::P) where P <: Posit = f2p(p2f(a) - p2f(b), P)
lazymul(a::P, b::P) where P <: Posit = f2p(p2f(a) * p2f(b), P)
lazydiv(a::P, b::P) where P <: Posit = f2p(p2f(a) / p2f(b), P)

Base.:+(a::P, b::P) where P <: Posit = lazyadd(a,b)
Base.:-(a::P, b::P) where P <: Posit = lazysub(a,b)
Base.:*(a::P, b::P) where P <: Posit = lazymul(a,b)
Base.:/(a::P, b::P) where P <: Posit = lazydiv(a,b)

# unary subtraction.
Base.:-(a::P) where P <: Posit = p(-u(a), P)

# for performance testing analyses.
branch_add(a::Posit8, b::Posit8)::Posit8 = convert_with_branches(p2f(a) + p2f(b), Posit8)

Base.log(a::P) where P <: Posit = f2p(log(p2f(a)), P)
Base.exp(a::P) where P <: Posit = f2p(exp(p2f(a)), P)

# a lazy converter because sometimes our functions use integers.
# TODO: amend crossentropy function instead.
Base.:*(a::P, b::Int64) where P <: Posit = f2p(p2f(a) * b, P)
Base.:/(a::P, b::Int64) where P <: Posit = f2p(p2f(a) / b, P)
