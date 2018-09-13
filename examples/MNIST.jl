using Flux, Flux.Data.MNIST
using Flux: onehotbatch, argmax, crossentropy, throttle
using Base.Iterators: repeated
using MLPosit

# example taken from:
# https://github.com/FluxML/model-zoo/blob/master/vision/mnist/mlp.jl
# this is a simple multilayer perceptron example.

# fetch MNIST digits and convert them to MLPosits
imgs = MNIST.images()
# Stack images into one large batch
full_input = hcat(Posit8.(float.(reshape.(imgs, :)))...)

# fetch the labels for each of these digits.
labels = MNIST.labels()
# One-hot-encode the labels
full_truth = onehotbatch(labels, 0:9) |> gpu

# just use a simple fully connected neural net here.
model = Chain(
  Dense(28^2, 32, relu),
  Dense(32, 10),
  softmax)

# define a loss function over a data set:
loss(input, truth) = crossentropy(model(input), truth)
# and a means of testing the accuracy of our model.  Note that
# the model should output a 10-vector and the truth is a 10-vector too.
# argmax will simply find the index of the maximum element
accuracy(input, truth) = mean(argmax(model(input)) .== argmax(truth))

# set up parameters for flux training.  Flux training requires a loss function,
# a dataset iterator, and an optimizer
dataset_iterator = repeated((full_input, full_truth), 200)
opt = ADAM(params(model))
# we can set up a callback function that will report on how we're doing.
callback = () -> @show(loss(full_input, full_truth))

Flux.train!(loss, dataset_iterator, opt, cb = throttle(evalcb, 10))

# let's see how well we did.
final_accuracy = accuracy(X, Y)
println(final_accuracy)
