using Flux
using Flux: onehot, chunk, batchseq, throttle, crossentropy
using StatsBase: wsample
using Base.Iterators: partition
using BSON:@save

# shamelessly ganked from:
# https://github.com/FluxML/model-zoo/blob/master/text/char-rnn/char-rnn.jl

# relevant input text can be gotten at:
# https://cs.stanford.edu/people/karpathy/char-rnn/shakespeare_input.txt

text = collect(String(read("shakespeare_input.txt")))
alphabet = [unique(text)..., '_']
text = map(ch -> onehot(ch, alphabet), text)
stop = onehot('_', alphabet)

N = length(alphabet)
seqlen = 50
nbatch = 50

Xs = collect(partition(batchseq(chunk(text, nbatch), stop), seqlen))
Ys = collect(partition(batchseq(chunk(text[2:end], nbatch), stop), seqlen))

m = Chain(
  LSTM(N, 128),
  LSTM(128, 128),
  Dense(128, N),
  softmax)

# I don't have a GPU :''''''(
# m = gpu(m)

function loss(xs, ys)
  l = sum(crossentropy.(m.(xs), ys))
  Flux.truncate!(m)
  return l
end

opt = ADAM(params(m), 0.01)
#tx, ty = (gpu.(Xs[5]), gpu.(Ys[5]))
tx, ty = (Xs[5], Ys[5])
evalcb = () -> @show loss(tx, ty)


for idx=1:20
  Flux.train!(loss, zip(Xs, Ys), opt,
              cb = throttle(evalcb, 30))

  println("checkpointing $idx")

  model = cpu(m)

  @save "charRNN-ckpt-$idx.bson" model
end
