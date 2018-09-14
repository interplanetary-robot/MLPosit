#function crossentropy(ŷ::AbstractVecOrMat, y::AbstractVecOrMat; weight = 1)
#  -sum(y .* log.(ŷ) .* weight) / size(y, 2)
#end
#
#function softmax(xs::AbstractVecOrMat{P, N}) where P <: Posit where N
#    #temporarily, use a quire-like structure.
#    f2p.(exp.(p2f.(xs)) ./ sum(exp.(p2f.(xs)), dims=1), P)
#end
#
#function ∇softmax(xs::AbstractVecOrMat{P, N}, Δ::AbstractVecOrMat{P, N})
#  s = sum(exp, p2f.(xs), dims=1)
#  f2p.(exp.(xs)./s.*(Δ .- sum(Δ .* exp.(xs), dims=1)./s), P)
#end
