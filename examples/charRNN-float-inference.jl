using Flux
using Flux: onehot, chunk, batchseq, throttle, crossentropy
using StatsBase: wsample
using Base.Iterators: partition
using BSON:@load

# relevant input text can be gotten at:
# https://cs.stanford.edu/people/karpathy/char-rnn/shakespeare_input.txt

text = collect(String(read("shakespeare_input.txt")))

# we do need to redefine the alphabet here.
alphabet = [unique(text)..., '_']

@load "charRNN-ckpt.bson" m

# Sampling

function sample(m, alphabet, len; temp = 1)
  Flux.reset!(m)
  buf = IOBuffer()
  c = rand(alphabet)
  for i = 1:len
    write(buf, c)
    c = wsample(alphabet, m(onehot(c, alphabet)).data)
  end
  return String(take!(buf))
end

sample(m, alphabet, 1000) |> println
