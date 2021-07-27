### Indexing utils

Base.@propagate_inbounds rearrange(x::Tuple, val::Val{D}) where {D} = rearrange((), x, val)
Base.@propagate_inbounds rearrange(x::Tuple, y::Tuple, val::Val{D}) where {D} = rearrange((x...,first(y)), Base.tail(y), Val{D-1}())
Base.@propagate_inbounds rearrange(x::NTuple{N,Int}, y::Tuple, val::Val{0}) where {N} = CartesianIndex{N}(x),y...

Base.@propagate_inbounds Base.getindex(lattice::RegularLattice, i::Int, I...) = Base.getindex(lattice::RegularLattice, (i, I...))
Base.@propagate_inbounds Base.getindex(lattice::RegularLattice{D,T,PB,CT,L}, I::NTuple{D′,Int}) where {D,T,PB,CT,L,D′} = Base.getindex(lattice, rearrange(I, Val{D}())...)

Base.@propagate_inbounds Base.getindex(lattice::RegularLattice, i::Tuple{CartesianIndex, Vararg{Int}}) = Base.getindex(lattice, i...)

Base.@propagate_inbounds relative_coordinate(lattice::RegularLattice{D}, i1::NTuple{D′, Int}, i2::NTuple{D′, Int}) where {D, D′} = relative_coordinate(lattice, rearrange(i1, Val{D}()), rearrange(i2, Val{D}()))

### Sorting utils

"""
`takes_precedence(i1, i2)`

Returns `true` if the index `i1` occurs before `i2` while iterating over a node collection.
"""
@inline takes_precedence(i1::T, i2::T) where {T<:Union{Int, CartesianIndex}} = isless(i1, i2)
@inline takes_precedence(i1::T, i2::T) where {T<:NTuple{D,Int}} where D = takes_precedence(CartesianIndex(i1), CartesianIndex(i2))
@inline takes_precedence(i1::T, i2::T) where {T<:Tuple{CartesianIndex, Int, Vararg{Int}}} = takes_precedence(CartesianIndex(first(i1).I..., Base.tail(i1)...), CartesianIndex(first(i2).I..., Base.tail(i2)...))
