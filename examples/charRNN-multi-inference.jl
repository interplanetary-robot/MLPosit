using Flux
using Flux: onehot, chunk, batchseq, throttle, crossentropy
using StatsBase: wsample
using Base.Iterators: partition
using BSON:@load
using MLPosit

# relevant input text can be gotten at:
# https://cs.stanford.edu/people/karpathy/char-rnn/shakespeare_input.txt

text = collect(String(read("shakespeare_input.txt")))

# we do need to redefine the alphabet here.
alphabet = [unique(text)..., '_']

@load "charRNN-ckpt.bson" m

typeswitch(rnn::Flux.Recur, T::Type) = Flux.Recur(typeswitch(rnn.cell, T))
typeswitch(lstmc::Flux.LSTMCell, T::Type) = Flux.LSTMCell(T.(lstmc.Wi),T.(lstmc.Wh),T.(lstmc.b),T.(lstmc.h),T.(lstmc.c))
typeswitch(dense::Dense, T::Type) = Dense(T.(dense.W), T.(dense.b), dense.σ)
typeswitch(f::Function, T::Type) = f
typeswitch(model::Chain, T::Type) = Chain([typeswitch(l, T) for l in model.layers]...)

#Flux.NNlib.σ(x::Posit) = MLPosit.lazy_sigmoid(x)

# convert the model to a posit model.
m_float = typeswitch(m, Float64)
m_float32 = typeswitch(m, Float32)
m_float16 = typeswitch(m, Float16)
m_posit = typeswitch(m, Posit8)

# this is a hack, because sometimes we get a NaN value for the posit.
cleanup(p::T) where T <: MLPosit.Posit = isnan(p) ? zero(T) : p

# Sampling
function sample(m, alphabet, len, c; temp = 1)
  Flux.reset!(m)
  buf = IOBuffer()
  for i = 1:len
    write(buf, c)
    # get the character probabilities by evaluating the NN.
    onehot_char = onehot(c, alphabet)
    char_probs = Float64.(m(onehot_char).data)
    # push it onto the state
    c = wsample(alphabet, char_probs)
  end
  return String(take!(buf))
end

c = rand(alphabet)
println("Float64 ===========================")
sample(m_float, alphabet, 1000, c) |> println
println("Float32 ===========================")
sample(m_float32, alphabet, 1000, c) |> println
println("Float16 ===========================")
sample(m_float16, alphabet, 1000, c) |> println
println("Posit   ===========================")
sample(m_posit, alphabet, 1000, c) |> println
