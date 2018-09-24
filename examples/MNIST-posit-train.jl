using Flux.Data.MNIST
using Flux: onehotbatch, onecold
using Statistics
using MLPosit
using GenML
using Random: randperm

function glorotrand(F, dims...)
    F.(randn(dims...) .* sqrt(2.0/sum(dims)))
end

function mnisttrain()
    # fetch MNIST digits and convert them to MLPosits
    imgs = MNIST.images()
    # Stack images into one large batch
    full_input = Posit8.(hcat(float.(reshape.(imgs, :))...))

    # fetch the labels for each of these digits.
    labels = MNIST.labels()
    setsize = length(MNIST.labels())
    # One-hot-encode the labels
    full_truth = onehotbatch(labels, 0:9)
  
    model = GenML.MLP.MultilayerPerceptron{Posit8,(28^2,32,10)}(glorotrand, [GenML.TF.relu, GenML.TF.softmax])

    # and a means of testing the accuracy of our model.  Note that
    # the model should output a 10-vector and the truth is a 10-vector too.
    # argmax will simply find the index of the maximum element
    accuracy(input, truth) = mean(onecold(model(input)) .== onecold(truth))

    for rounds = 1:25
        for idx = 1:setsize
            input_column = full_input[:, idx]
            truth_column = full_truth[:, idx]

            GenML.Optimizers.backpropagationoptimize(model, input_column, truth_column, GenML.CF.crossentropy)

        end
        println("completed round $rounds")

        test_array = randperm(setsize)[1:100]
        #test_acc = mean(accuracy(full_input, full_truth[:, idx]) for idx in test_array)
        test_acc = accuracy(full_input[:, test_array], full_truth[:, test_array])

        println("current accuracy:", test_acc)
    end
end

mnisttrain()