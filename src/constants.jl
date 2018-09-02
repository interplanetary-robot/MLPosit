
# define one, zero, and NaN constants for MLPosit

const POSIT8_ONE    = 0b0100_0000
const POSIT8_NAN    = 0b1000_0000
const POSIT8_MAXPOS = 0b0111_1111
const POSIT8_MINPOS = 0b0000_0001

Base.one(::Type{Posit8}) = reinterpret(Posit8, POSIT8_ONE)
Base.zero(::Type{Posit8}) = reinterpret(Posit8, zero(UInt8))
Base.one(::Posit8) = one(Posit8)
Base.zero(::Posit8) = zero(Posit8)

nan(::Type{Posit8}) = reinterpret(Posit8, POSIT8_NAN)
nan(::Posit8) = nan(Posit8)

Base.isnan(x::Posit8) = reinterpret(UInt8, x) == POSIT8_NAN
Base.isone(x::Posit8) = reinterpret(UInt8, x) == POSIT8_ONE
Base.iszero(x::Posit8) = reinterpret(UInt8, x) == zero(UInt8)

#some internal constants
maxpos(::Type{Posit8}) = reinterpret(UInt8, POSIT8_MAXPOS)
minpos(::Type{Posit8}) = reinterpret(UInt8, POSIT8_MINPOS)

#other constants
Base.maxintfloat(::Type{Posit8}) = reinterpret(UInt8, 0b0111_1000)
