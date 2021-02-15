## AbstractBinaryOp shadows the implementation of Distances.jl functions and types
## for types which are not metric by definition but benefit from all the 
## pairwise machinery

## pairwise functions for matrices
function Distances.pairwise(d::AbstractBinaryOp, a::AbstractMatrix, b::AbstractMatrix=a; dims=1)
    dims in (1, 2) || throw(ArgumentError("dims should be 1 or 2 (got $dims)"))
    m = size(a, dims)
    n = size(b, dims)
    P = Matrix{Distances.result_type(d, a, b)}(undef, m, n)
    return mul!(P, a, b')
    if dims == 1
        return _pairwise!(P, d, transpose(a), transpose(b))
    else
        return _pairwise!(P, d, a, b)
    end
end

function Distances.pairwise!(P::AbstractMatrix, ::DotProduct, a::AbstractMatrix, b::AbstractMatrix=a; dims=1)
    dims = deprecated_dims(dims)
    dims in (1, 2) || throw(ArgumentError("dims should be 1 or 2 (got $dims)"))
    if dims == 1
        na, ma = size(a)
        nb, mb = size(b)
        ma == mb || throw(DimensionMismatch("The numbers of columns in a and b " *
                                            "must match (got $ma and $mb)."))
    else
        ma, na = size(a)
        mb, nb = size(b)
        ma == mb || throw(DimensionMismatch("The numbers of rows in a and b " *
                                            "must match (got $ma and $mb)."))
    end
    size(P) == (na, nb) ||
        throw(DimensionMismatch("Incorrect size of P (got $(size(P)), expected $((na, nb)))."))
    if dims == 1
        _pairwise!(P, metric, transpose(a), transpose(b))
    else
        _pairwise!(P, metric, a, b)
    end
end

## pairwise function for vectors
function pairwise(d::AbstractBinaryOp, X::AbstractVector, Y::AbstractVector=X)
    return broadcast(d, X, permutedims(Y))
end

function pairwise!(
    out::AbstractMatrix,
    d::AbstractBinaryOp,
    X::AbstractVector,
    Y::AbstractVector=X,
)
    broadcast!(d, out, X, permutedims(Y))
end

# function pairwise(d::BinaryOp, x::AbstractVector{<:Real})
#     return Distances.pairwise(d, reshape(x, :, 1); dims = 1)
# end

# function pairwise(
#     d::BinaryOp,
#     x::AbstractVector{<:Real},
#     y::AbstractVector{<:Real},
# )
#     return Distances.pairwise(d, reshape(x, :, 1), reshape(y, :, 1); dims = 1)
# end

# function pairwise!(out::AbstractMatrix, d::BinaryOp, x::AbstractVector{<:Real})
#     return Distances.pairwise!(out, d, reshape(x, :, 1); dims = 1)
# end

# function pairwise!(
#     out::AbstractMatrix,
#     d::BinaryOp,
#     x::AbstractVector{<:Real},
#     y::AbstractVector{<:Real},
# )
#     return Distances.pairwise!(out, d, reshape(x, :, 1), reshape(y, :, 1); dims=1)
# end
