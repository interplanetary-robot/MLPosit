using Flux, Flux.Data.MNIST
using Flux: onehotbatch, onecold, throttle
using Base.Iterators: repeated
using Statistics
using BSON: @save

# example taken from:
# https://github.com/FluxML/model-zoo/blob/master/vision/mnist/mlp.jl
# this is a simple multilayer perceptron example.

# include patched machine learning functions
include("mlfunctions.jl")

# fetch MNIST digits and convert them to MLPosits
imgs = MNIST.images()
# Stack first 100 images into one large batch
full_input = hcat(float.(reshape.(imgs, :))...)

# fetch the labels for each of these digits.
labels = MNIST.labels()
# One-hot-encode the labels
full_truth = onehotbatch(labels, 0:9)

#create a custom zero initializer.
p8_zi(args...) = zeros(args...)
#create a custom glorot initializer.
gl_in(dims...) = (rand(dims...) .- 0.5) .* sqrt(24.0/(sum(dims)))

# just use a simple fully connected neural net here.
model = Chain(
  Dense(28^2, 32, relu, initW = gl_in, initb = p8_zi),
  Dense(32, 10, initW = gl_in, initb = p8_zi),
  softmax_a)

# define a loss function over a data set:
#loss(input, truth) = crossentropy_a(model(input), truth)

function loss(input, truth) 
  crossentropy_a(model(input), truth)
end

# and a means of testing the accuracy of our model.  Note that
# the model should output a 10-vector and the truth is a 10-vector too.
# argmax will simply find the index of the maximum element
accuracy(input, truth) = mean(onecold(model(input)) .== onecold(truth))

# set up parameters for flux training.  Flux training requires a loss function,
# a dataset iterator, and an optimizer
dataset_iterator = repeated((full_input, full_truth), 200)
opt = ADAM(params(model))
# we can set up a callback function that will report on how we're doing.
callback = () -> @show(loss(full_input, full_truth))

Flux.train!(loss, dataset_iterator, opt, cb = throttle(callback, 10))

# let's see how well we did.
final_accuracy = accuracy(full_input, full_truth)
println(final_accuracy)

@save "MNIST-float.bson" model
