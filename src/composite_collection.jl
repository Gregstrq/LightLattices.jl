"""
$(TYPEDEF)
$(TYPEDFIELDS)

A composite type for a physical collection composed from other physical collections and subcollections.
The groups of the underlying collections are combined together and form the groups of the `CompositeCollection`.
"""
struct CompositeCollection{D,T, ET, N, CST<:NTuple{N, AbstractPhysicalCollection{D,T}}} <: AbstracPhysicalCollection{D,T, ET}
    """
    Tuple of underlying collections.
    """
    collections::CST
    """
    Tuple of the numbers of groups in each of the underlying collections.
    """
    group_numbers::NTuple{N,Int}
    """
    Total number of groups
    """
    num_of_groups::Int
    """
    The tuple of all the elements of the underlying collections combined together.
    """
    elements::ET
    function CompositeCollection(collections::NTuple{N, SimpleNodeCollection{D,T}}) where {N,D,T}
        elements = merge_tuples(map(get_elements, collections)...)
        group_numbers = map(num_of_groups, collections)
        new{D,T, typeof(elements), N, typeof(collections)}(collections, group_numbers, sum(group_numbers))
    end
end
"""
$(TYPEDSGINATURES)

Combine several `PhysicalCollection`-s or `Subcollection`-s into a single `CompositeCollection`.
"""
compose(col1::AbstractPhysicalCollection{D,T}, col2::AbstractPhysicalCollection{D,T}, col::Vararg{AbstractPhysicalCollection{D,T}, N}) where {D,T,N} = CompositeCollection((col1,col2, cols...))

merge_tuples(t1::Tuple, ts::Vararg{Tuple, N}) = merge_tuples((t1..., first(ts)...), Base.tail(ts)...)
merge_tuples(t::Tuple) = t

num_of_groups(ccol::CompositeCollection) = ccol.num_of_groups

@propagate_inbounds function _get_col_and_group(ccol::CompositeCollection, ig)
    @boundscheck check_groupbounds(ccol, ig)
    for ic = 1:length(ccol.group_numbers)
        ig -= ccol.group_numbers[ic]
        if ig <=0
            return ccol.collections[ic], ccol.group_numbers[ic]+ig
        end
    end
end

@propagate_inbounds function _get_col_index(ccol::CompositeCollection, il::Int, ig_raw::Int)
    pcol, ig = _get_col_and_group(ccol, ig_raw)
    return pcol, _translate_index(pcol, il, ig)
end

@propagate_inbounds group_size(ccol::CompositeCollection, ig) = group_size(_get_col_and_group(ccol, ig)...)

length(ccol::CompositeCollection) = sum(length, ccol.collections)

is_homogeneous(ccol::CompositeCollection) = IsHomogeneous{false}()

@propagate_inbounds getindex(ccol::CompositeCollection, il::Int, ig_raw::Int) = getindex(_get_col_index(ccol, il, ig)...)
