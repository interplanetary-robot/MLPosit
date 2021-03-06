using Flux, Flux.Data.MNIST
using Flux: onehotbatch, onecold, throttle
using Base.Iterators: repeated
using Statistics
using MLPosit
using BSON: @load

# example taken from:
# https://github.com/FluxML/model-zoo/blob/master/vision/mnist/mlp.jl
# this is a simple multilayer perceptron example.

################################################################################
# performs inference using posits, on data trained using Floats.

# load the bson model.
@load "MNIST-float.bson" model

typeswitch(dense::Dense, T::Type) = Dense(T.(dense.W), T.(dense.b), dense.σ)
typeswitch(f::Function, T::Type) = f
typeswitch(model::Chain, T::Type) = Chain([typeswitch(l, T) for l in model.layers]...)

# convert the model to a posit model.
model_posit = typeswitch(model, Posit8)

# create an accuracy metric
accuracy(input, truth) = mean(onecold(model_posit(input)) .== onecold(truth))

################################################################################
# load the input data

# fetch MNIST digits and convert them to MLPosits
imgs = MNIST.images()
# Stack images into one large batch
full_input = hcat(Posit8.(float.(reshape.(imgs, :)))...)

# fetch the labels for each of these digits.
labels = MNIST.labels()
# One-hot-encode the labels
full_truth = onehotbatch(labels, 0:9)

final_accuracy = accuracy(full_input, full_truth)
println("inference accuracy with 8-bit posits: $final_accuracy")
