
# define one, zero, and NaN constants for MLPosit

const POSIT8_ONE    = 0b0100_0000
const POSIT8_NAN    = 0b1000_0000
const POSIT8_MAXPOS = 0b0111_1111
const POSIT8_MINPOS = 0b0000_0001

Base.one(::Type{P})  where P <: Posit{8} = p(POSIT8_ONE, P)
Base.zero(::Type{P}) where P <: Posit{8} = p(zero(UInt8), P)
Base.one(::P)        where P <: Posit{8} = one(P)
Base.zero(::P)       where P <: Posit{8} = zero(P)

nan(::Type{P})       where P <: Posit{8} = p(POSIT8_NAN, P)
nan(::P)             where P <: Posit{8} = nan(P)

Base.isnan(x::Posit{8})  = u(x) == POSIT8_NAN
Base.isone(x::Posit{8})  = u(x) == POSIT8_ONE
Base.iszero(x::Posit{8}) = u(x) == zero(UInt8)

#there are no infinites in posits.
Base.isinf(x::Posit)     = false

#some internal constants
maxpos(::Type{P})    where P <: Posit{8} = p(POSIT8_MAXPOS, P)
minpos(::Type{P})    where P <: Posit{8} = p(POSIT8_MINPOS, P)

#other constants
Base.maxintfloat(::Type{P}) where P <: Posit{8} = p(0b0111_1000, P)
