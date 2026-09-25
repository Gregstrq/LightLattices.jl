### Indexing utils

#   If we consider composite structures, it is better to be able to index the structures as (linear index, group index).
#   Unfortunately, this would clash with the alternative indexing for two dimensional `RegularLattice`s with Trivial cell or one-dimensional `RegularLattices` with homogeneous basis cell.
#
@propagate_inbounds rearrange(x::Tuple, val::Val{D}) where {D} = rearrange((), x, val)
@propagate_inbounds rearrange(x::Tuple, y::Tuple, val::Val{D}) where {D} = rearrange((x...,first(y)), Base.tail(y), Val{D-1}())
@propagate_inbounds rearrange(x::NTuple{N,Int}, y::Tuple, val::Val{0}) where {N} = CartesianIndex{N}(x),y...

@propagate_inbounds position(lattice::RegularLattice, i::Int, I...) = position(lattice, (i, I...))
@propagate_inbounds position(lattice::RegularLattice{D,T,PB,CT,L}, I::NTuple{D′,Int}) where {D,T,PB,CT,L,D′} = position(lattice, rearrange(I, Val{D}())...)
@inline checkbounds(lattice::RegularLattice, i::Int, I...) = checkbounds(lattice, (i, I...))
@inline checkbounds(lattice::RegularLattice{D,T,PB,CT,L}, I::NTuple{D′,Int}) where {D,T,PB,CT,L,D′} = checkbounds(lattice, rearrange(I, Val{D}())...)

#@propagate_inbounds getindex(lattice::RegularLattice, i::Tuple{CartesianIndex, Vararg{Int}}) = getindex(lattice, i...)

@propagate_inbounds relative_position(lattice::RegularLattice{D}, i1::NTuple{D′, Int}, i2::NTuple{D′, Int}) where {D, D′} = relative_position(lattice, rearrange(i1, Val{D}()), rearrange(i2, Val{D}()))

@propagate_inbounds position(lattice::RegularLattice{D}, i1::NTuple{D,Int}, I...) where {D} = position(lattice, CartesianIndex(i1), I...)
@propagate_inbounds relative_position(lattice::RegularLattice{D}, i1::T, i2::T) where {D, T<:Tuple{NTuple{D,Int},Vararg{Int}}} = relative_position(lattice, (CartesianIndex(first(i1)), Base.tail(i1)...), (CartesianIndex(first(i2)), Base.tail(i2)...))

@inline _lin2cart(il::Int, dims::Tuple{Int, Vararg{Int}}, nc::Int) = _lin2cart_recurse(il-1, (), dims, nc)
@inline function _lin2cart_recurse(f::Int, cart::Tuple, dims::Tuple{Int,Vararg{Int}}, nc::Int)
    d, r = divrem(f, first(dims))
    return _lin2cart_recurse(d, (cart..., r+1), Base.tail(dims), nc)
end

@inline _lin2cart_recurse(f::Int, cart::Tuple, dims::Tuple{}, nc::Int) = CartesianIndex(cart), (f % nc)+1

@inline _translate_index(col::AbstractNodeCollection, I...) = I
@propagate_inbounds _translate_index(lattice::RegularLattice, il::Int, ig::Int) = (_lin2cart(il, lattice.lattice_dims, group_size(lattice.basis_cell, ig))..., ig)

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

eachindex(col::AbstractCollection) = eachindex(is_homogeneous(col), col)
eachindex(::IsHomogeneous{true}, col::AbstractCollection) = col |> length |> Base.OneTo
eachindex(htrait::IsHomogeneous{false}, col::AbstractCollection) = Iterators.flatten(@inbounds group_iterator(col, ig) for ig = Base.OneTo(num_of_groups(col)))

eachindex(lattice::RegularLattice) = Iterators.map(I->(first(I),last(I)...), Iterators.product(CartesianIndices(lattice.lattice_dims), eachindex(lattice.basis_cell)))


"""
    group_iterator(collection, ig)

Returns iterator over the group `ig`. For homogeneous collections, the index of the group is omitted.
"""
@propagate_inbounds function group_iterator(col::AbstractCollection, ig::Int)
    @boundscheck check_groupbounds(col, ig)
    htrait = is_homogeneous(col)
    return @inbounds _decorate_group(htrait, group_iterator(htrait, col, ig), ig)
end

@propagate_inbounds group_iterator(::IsHomogeneous, col::AbstractCollection, ig::Int) = Base.OneTo(group_size(col, ig))
@propagate_inbounds group_iterator(::IsHomogeneous, lattice::RegularLattice, ig::Int) = Iterators.product(CartesianIndices(lattice.lattice_dims), Base.OneTo(@inbounds group_size(lattice.basis_cell, ig)))

@propagate_inbounds _decorate_group(::IsHomogeneous{true}, iterator, ig::Int) = iterator
@propagate_inbounds _decorate_group(::IsHomogeneous{false}, iterator, ig::Int) = Iterators.map(x->(x...,ig), iterator)

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
