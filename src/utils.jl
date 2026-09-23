### Indexing utils

#   If we consider composite structures, it is better to be able to index the structures as (linear index, group index).
#   Unfortunately, this would clash with the alternative indexing for two dimensional `RegularLattice`s with Trivial cell or one-dimensional `RegularLattices` with homogeneous basis cell.
#
@propagate_inbounds rearrange(x::Tuple, val::Val{D}) where {D} = rearrange((), x, val)
@propagate_inbounds rearrange(x::Tuple, y::Tuple, val::Val{D}) where {D} = rearrange((x...,first(y)), Base.tail(y), Val{D-1}())
@propagate_inbounds rearrange(x::NTuple{N,Int}, y::Tuple, val::Val{0}) where {N} = CartesianIndex{N}(x),y...

@propagate_inbounds getindex(lattice::RegularLattice, i::Int, I...) = getindex(lattice::RegularLattice, (i, I...))
@propagate_inbounds getindex(lattice::RegularLattice{D,T,PB,CT,L}, I::NTuple{D′,Int}) where {D,T,PB,CT,L,D′} = getindex(lattice, rearrange(I, Val{D}())...)

#@propagate_inbounds getindex(lattice::RegularLattice, i::Tuple{CartesianIndex, Vararg{Int}}) = getindex(lattice, i...)

@propagate_inbounds relative_coordinate(lattice::RegularLattice{D}, i1::NTuple{D′, Int}, i2::NTuple{D′, Int}) where {D, D′} = relative_coordinate(lattice, rearrange(i1, Val{D}()), rearrange(i2, Val{D}()))

@propagate_inbounds getindex(lattice::RegularLattice{D}, i1::NTuple{D,Int}, I...) where {D} = getindex(lattice, CartesianIndex(i1), I...)
@propagate_inbounds relative_coordinate(lattice::RegularLattice{D}, i1::T, i2::T) where {D, T<:Tuple{NTuple{D,Int},Vararg{Int}}} = relative_coordinate(lattice, (CartesianIndex(first(i1)), Base.tail(i1)...), (CartesianIndex(first(i2)), Base.tail(i2)...))

@inline _lin2cart(il::Int, dims::Tuple{Int, Vararg{Int}}, nc::Int) = _lin2cart_recurse(il-1, (), dims, nc)
@inline function _lin2cart_recurse(f::Int, cart::Tuple, dims::Tuple{Int,Vararg{Int}}, nc::Int)
    d, r = divrem(f, first(dims))
    return _lin2cart_recurse(d, (cart..., r+1), Base.tail(dims), nc)
end

@inline _lin2cart_recurse(f::Int, cart::Tuple, dims::Tuple{}, nc::Int) = CartesianIndex(cart), (f % nc)+1

###

@inline delete_last(t::NTuple{N,T}) where {N,T} = ntuple(i -> t[i], Val(N-1))

### Sorting utils

"""
`takes_precedence(i1, i2)`

Returns `true` if the index `i1` occurs before `i2` while iterating over a node collection.
"""
@inline takes_precedence(i1::T, i2::T) where {T<:Union{Int, CartesianIndex}} = isless(i1, i2)
@inline takes_precedence(i1::T, i2::T) where {T<:NTuple{D,Int}} where D = takes_precedence(CartesianIndex(i1), CartesianIndex(i2))
@inline takes_precedence(i1::T, i2::T) where {T<:Tuple{CartesianIndex, Int, Vararg{Int}}} = takes_precedence(CartesianIndex(first(i1).I..., Base.tail(i1)...), CartesianIndex(first(i2).I..., Base.tail(i2)...))

### Iteration utils

eachindex(col::AbstractNodeCollection) = eachindex(is_homogeneous(col), col)
eachindex(::IsHomogeneous{true}, col::AbstractNodeCollection) = col |> length |> Base.OneTo
eachindex(htrait::IsHomogeneous{false}, col::AbstractNodeCollection) = Iterators.flatten(Iterators.map(x->(x...,ig), @inbounds group_iterator(col, ig)) for ig = Base.OneTo(num_of_groups(col)))

eachindex(lattice::RegularLattice) = Iterators.map(I->(first(I),last(I)...), Iterators.product(CartesianIndices(lattice.lattice_dims), eachindex(lattice.basis_cell)))


"""
    group_iterator(collection, ig)

Iterate over the indices within group `ig`, omitting the group index itself.
For inhomogeneous collections, append `ig` when indexing the collection.
"""
@propagate_inbounds function group_iterator(col::AbstractNodeCollection, ig::Int)
    @boundscheck check_groupbounds(col, ig)
    return group_iterator(is_homogeneous(col), col, ig)
end

@propagate_inbounds group_iterator(::IsHomogeneous, col::AbstractNodeCollection, ig::Int) = Base.OneTo(group_size(col, ig))
@propagate_inbounds group_iterator(::IsHomogeneous, lattice::RegularLattice, ig::Int) = Iterators.product(CartesianIndices(lattice.lattice_dims), Base.OneTo(@inbounds group_size(lattice.basis_cell, ig)))

macro CI(args...)
    if last(args).head==:tuple
        return quote
            CartesianIndices(($(esc.(args[1:end-1])...), $(esc(last(args).args[1])),)), $(esc.(last(args).args[2:end])...)
        end
    else
        return quote
            CartesianIndices(($(esc.(args)...),))
        end
    end
end
