# syntactic sugar, etc.

function Base.show(io::IO, x::Posit8)
    print(io, "Posit8($(Float64(x)))")
end
