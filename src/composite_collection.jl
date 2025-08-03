const SimpleNodeCollection{D,T} = Union{AbstractCell{D,T},AbstractLattice{D,T}}

"""
$(TYPEDEF)
$TYPEDFIELDS

A composite type for a collection of nodes composed from other simpler collections.
"""
struct CompositeCollection{D,T, N, CST<:NTuple{N, SimpleNodeCollection{D,T}}} <: AbstractNodeCollection{D,T}
    """
    Tuple of underlying collections.
    """
    collections::CST
    group_sizes::NTuple{N,Int}
    total_group_length::Int
    CompositeCollection(collections::NTuple{N, SimpleNodeCollection{D,T}}) where {N,D,T} = new{D,T,N, typeof(collecitons)}(collections, num_of_groups.(collections), sum(num_of_groups, collections))
end

CompositeCollection(collection1::SimpleNodeCollection{D,T}, collection2::SimpleNodeCollection{D,T}, collections...) where {D,T} = CompositeCollection((collection1, collection2, collections...))

Base.@propagate_inbounds function _get_col_and_group(cnodes::CompositeCollection, ig)
    @boundscheck 1≤ig≤cnodes.total_group_length
    @inbounds for ic = 1:length(cnodes.group_sizes)
        ig -= cnodes.group_sizes[ic]
        if ig <=0
            return cnodes.collections[ic], cnodes.group_sizes[ic]+ig
        end
    end
end

num_of_groups(cnodes::CompositeCollection) = cnodes.total_group_length
Base.@propagate_inbounds group_size(cnodes::CompositeCollection, ig) = group_size(_get_col_and_group(cnodes, ig)...)

Base.length(cnodes::CompositeCollection) = sum(length, cnodes.collections)

is_homogeneous(cnodes::CompositeCollection) = IsHomogeneous(false)

Base.@propagate_inbounds _transform_col_index(collection::AbstractNodeCollection, i, ig::Int) = _transform_col_index(is_homogeneous(collection), collection, i, ig)
Base.@propagate_inbounds _transform_col_index(::IsHomogeneous{true}, collection::AbstractNodeCollection, i::Tuple, ig::Int) = i
Base.@propagate_inbounds _transform_col_index(::IsHomogeneous{false}, collection::AbstractNodeCollection, i::Tuple, ig::Int) = (i, ig)

Base.@propagate_inbounds function Base.getindex(cnodes::CompositeCollection, I::Tuple{Any,Any,Vararg{Any}})
    @inbounds i = I[1:end-1]
    @inbounds ig_raw = last(I)
    col, ig = _get_col_and_group(cnodes, ig_raw)
    col[_transform_col_index(col, i, ig)]
end
Base.@propagate_inbounds Base.getindex(cnodes::CompositeCollection, i1, i2, is...) = getindex(cnodes, (i1,i2,is...))

"""
$(TYPEDEF)

For the composite collection, all the underlying lattices are treated as if they have non-periodic boundary conditions.
"""
Base.@propagate_inbounds relative_coordinate(cnodes::CompositeCollection, I1::Tuple{Any,Any,Vararg{Any}}, I2::Tuple{Any,Any,Vararg{Any}}) = cnodes[I1]-cnodes[I2]

_get_col_iter(collection::AbstractNodeCollection, offset::Int) = _get_col_iter(is_homogeneous(collection), collection, offset)
_get_col_iter(htrait::IsHomogeneous{true}, collection::AbstractNodeCollection, offset::Int) = Iterators.map(x->(x...,offset+1), eachindex(collection))
_get_col_iter(htrait::IsHomogeneous{false}, collection::AbstractNodeCollection, offset::Int) = Iterators.flatten(Iterators.map(x->(x..., ig+offset), @inbounds group_iterator(htrait, collection, ig)) for ig=1:num_of_groups(collection)) 

Base.eachindex(cnodes::CompositeCollection) = flatten(_get_col_iter(col) for col in cnodes.collections)
