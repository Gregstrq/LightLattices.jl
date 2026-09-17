const _UnorderedIndexType = AbstractVector{Int}
const _OrderedIndexType{D} = Tuple{CartesianIndices{D}, AbstractVector{Int}}

"""
$(TYPEDEF)
$(TYPEDFIELDS)

A Collection that is obtained if we restrict a `PhysicalCollection` to a subset of nodes.
"""
struct Subcollection{D, T, ET, IT, PCT<:PhysicalCollection{D, T}, N} <: AbstractPhysicalCollection{D, T, ET}
    """
    Underlying PhysicalCollection
    """
    pcol::PCT
    """
    Indices of the nodes that belong to the subcollection$(TYPEDEF)
$(TYPEDFIELDS).
    """
    indices::IT
    """
    Indices of the groups that contain nodes belonging to the Subcollection.
    """
    group_indices::NTuple{N, Int}
    """
    `group_size[i]` is the number of nodes with group index `group_indices[i]` that belong to the Subcollection.
    """
    group_sizes::NTuple{N, Int}
    """
    Elements of the underlying PhysicalCollection that belong to the subcollection.
    """
    elements::ET
    function Subcollection(pcol::PhysicalCollection{D,T, ET}, group_indices_unsorted::NTuple{N,Int}, indices_unsorted::NTuple{N, AbstractVector}) where {D, T, ET, N}
        p = sortperm(group_indices)
        group_indices = group_indices_unsorted[p]
        indices = indices_unsorted[p]
        map(x->sort!(x; lt=takes_precedence), indices)
        _check_indices(pcol, indices, group_indices)
        group_sizes = length.(indices)
        elements = map(i->pcol.elements[i], group_indices)
        new{D, T, typeof(elements), typeof(indices), typeof(pcol), N}(pcol, indices, group_indices, group_sizes, elements)
    end
    function Subcollection(pcol::PhysicalCollection{D,T,ET,<:RegularLattice}, group_indices_unsorted::NTuple{N,Int}, indices_unsorted::NTuple{N, Union{CartesianIndices{D},Tuple{CartesianIndices{D}, Union{Colon, AbstractVector{D}}}}}) where {D,T, ET, N}
        p = sortperm(group_indices)
        group_indices = group_indices_unsorted[p]
        indices = _process_indices(pcol, group_indices, indices_unsorted[p])
        group_sizes = map(x->length(first(x))*length(last(x)), indices)
        elements = map(i->pcol.elements[i], group_indices)
        new{D, T, typeof(elements), typoef(indices), typeof(pcol), N}(pcol, indices, group_indices, group_sizes, elements)
    end
end
Subcollection(pcol::PhysicalCollection, indices::AbstractVector) = Subcollection(pcol, ntuple(i->i, num_of_groups(pcol)), ntuple(i->indices, num_of_groups(pcol)))
Subcollection(pcol::PhysicalCollection, indices::AbstractVector{<:Pair{Int}}) = Subcollection(pcol, Tuple(first(p) for p in indices), Tuple(last(p) for p in indices))
Subcollection(pcol::PhysicalCollection, indices::Dict{Int}) = Subcolleciton(pcol, Tuple(keys(indices)), Tuple(values(indices)))

Subcollection(pcol::PhysicalCollection{D,T,ET,<:RegularLattice}, lattice_indices::CartesianIndices{D}) where {D,T,ET} = Subcollection(pcol, lattice_indices, Colon(), ntuple(i->i, num_of_groups(pcol)))
Subcollection(pcol::PhysicalCollection{D,T,ET,<:RegularLattice}, lattice_indices::CartesianIndices{D}, cell_indices::Union{Colon, AbstractVector{Int}}, group_indices::NTuple{N, Int}) where {D,T,ET, N} = Subcollection(pcol, ntuple(i->(lattice_indices, cell_indices), Val(N)), group_indices)

Base.view(pcol::PhysicalCollection, I...) = Subcollection(pcol, I...)

function _check_indices(pcol::PhysicalCollection, indices::NTuple{N, AbstractVector}, group_indices::NTuple{N, Int}) where {N}
    for ig in group_indices
        for index in indices[ig]
            checkbounds(pcol, index..., ig)
        end
    end
end
_process_indices(pcol::PhysicalCollection{D,T,ET,<:RegularLattice}, group_indices::NTuple{N, Int}, indices::NTuple{N, Union{CartesianIndices{D}, Tuple{CartesianIndices{D}, Union{Colon,AbstractVector{Int}}}}}) where {D,T,ET,N} = map((ig, I)->_process_index(pcol, ig, I), group_indices, indices)
@inline _process_index(pcol::PhysicalCollection{D,T,ET,<:RegularLattice}, ig::Int, index::CartesianIndices{D}) where {D,T, ET} = _process_index(pcol, ig, (index, Colon())) 
@inline _process_index(pcol::PhysicalCollection{D,T,ET,<:RegularLattice}, ig::Int, index::Tuple{CartesianIndices{D}, Colon}) where {D,T,ET} = _process_index(pcol, ig, (first(index),Base.OneTo(group_size(pcol.nodes.basis_cell, ig))))
function _process_index(pcol::PhysicalCollection{D,T,ET,<:RegularLattice}, ig::Int, index::Tuple{CartesianIndices{D}, AbstractVector{Int}}) where {D,T,ET}
    rlattice = pcol.nodes
    cell = rlattice.basis_cell
    lattice_indices = first(index)
    cell_indices = sort(last(index))
    check_lattice_bounds(rlattice, lattice_indices|>first)
    check_lattice_bounds(rlattice, lattice_indices|>last)
    checkbounds(cell, first(cell_indices), ig)
    checkbounds(cell, last(cell_indices), ig)
    return (lattice_indices, cell_indices)
end

is_homogeneous(subcol::Subcollection) = IsHomogeneous{false}()
is_homogeneous(subcol::Subcollection{D,T, ET, IT, PCT, 1}) where {D, T, ET, IT, PCT} = IsHomogeneous{true}()

@inline num_of_groups(subcol::Subcollection{D,T, ET, PCT, N}) where {D, T, ET, PCT, N} = N

@propagate_inbounds group_size(subcol::Subcollection, ig::Int) = (@boundscheck check_groupbounds(subcol, ig); subcol.group_sizes[ig])

@propagate_inbounds function group_iterator(subcol::Subcollection{D,T,ET, <:NTuple{N, _OrderedIndexType{D}}}, ig::Int) where {D,T,ET,N}
    indices = subcol.indices[ig]
    return Iterators.product(CartesianIndices(indices|>first|>axes), Base.OneTo(indices[2]|>length))
end

#
#    If you think about it, we are never supposed to index into the subcollection ourselves.
#    We probably just want to iterate over it and that is it.
#    The parent collections is a different story: we might want to play with them to identify what nodes we
#    want to include in a subcollection
#
#


@propagate_inbounds getindex(subcol::Subcollection, I...) = subcol.pcol[_translate_index(subcol, I...)...]
@propagate_inbounds _translate_index(subcol::Subcollection{D,T,ET, <:NTuple{N, _UnorderedIndexType}}, ic::Int, ig::Int) where {D,T,ET,N} = (subcol.indices[ig][ic]..., subcol.group_indices[ig])
@propagate_inbounds _translate_index(subcol::Subcollection{D,T,ET, <:NTuple{N, _OrderedIndexType{D}}, <:RegularLattice}, I::CartesianIndex{D}, ic::Int, ig::Int) where {D,T,ET,N} = (index = subcol.indices[ig]; return (first(index)[I], last(index)[ic], subcol.group_indices[ig]))
@propagate_inbounds function _translate_index(subcol::Subcollection{D,T,ET, <:NTuple{N, _OrderedIndexType{D}}, <:PhysicalCollection{D,T,ET′, <:RegularLattice}}, il::Int, ig::Int) where {D,T,ET,N,ET′}
    index = subcol.indices[ig]
    return map((x,y)->getindex(x,y), (index..., subcol.group_indices), (_lin2cart(il, size(first(index)), length(last(index)))..., ig))
end

@inline _translate_index(col::AbstractNodeCollection, I...) = I
@propagate_inbounds _translate_index(col::PhysicalCollection, I...) = _translate_index(col.nodes, I...)
@propagate_inbounds _translate_index(lattice::RegularLattice, il::Int, ig::Int) = (_lin2cart(il, lattice.lattice_dims, group_size(lattice.basis_cell, ig))..., ig)


@inline _get_col(pcol::PhysicalCollection) = pcol
@inline _get_col(subcol::Subcollection) = subcol.pcol

@propagate_inbounds _get_col_index(col::AbstractPhysicalCollection, index) = _get_col(col), _translate_index(col, index)

@propagate_inbounds relative_coordinate(col1::AbstractPhysicalCollection{D,T}, I1, col2::AbstractPhysicalCollection{D,T}, I2) where {D,T} = relative_coordinate(_get_col_index(col, I1...)..., _get_col_index(col, I2...)...)

@propagate_inbounds relative_coordinate(pcol1::PhysicalCollection{D,T}, I1, pcol2::PhysicalCollection{D,T}, I2) where {D,T} = pcol1===pcol2 ? relative_coordinate(pcol1, I1, I2) : pcol1[I1...] - pcol2[I2...]
