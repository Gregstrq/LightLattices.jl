const _UnorderedIndexType = AbstractVector
const _OrderedIndexType{D} = Tuple{CartesianIndices{D}, AbstractVector{Int}}

"""
$(TYPEDEF)
$(TYPEDFIELDS)

A Collection that is obtained if we restrict a `PhysicalCollection` to a subset of nodes.
"""
struct Subcollection{D, T, ST, IT, PCT<:PhysicalCollection{D, T}, N} <: AbstractPhysicalCollection{D, T, ST}
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
    Species of the underlying PhysicalCollection that belong to the subcollection.
    """
    species::ST
    function Subcollection(pcol::PhysicalCollection{D,T, ST}, group_indices_unsorted::NTuple{N,Int}, indices_unsorted::NTuple{N, AbstractVector}) where {D, T, ST, N}
        p = sortperm(collect(group_indices_unsorted))
        group_indices = ntuple(i -> group_indices_unsorted[p[i]], N)
        indices = ntuple(i -> copy(indices_unsorted[p[i]]), N)
        map(x->sort!(x; lt=takes_precedence), indices)
        _check_indices(pcol, indices, group_indices)
        group_sizes = length.(indices)
        species = map(i->pcol.species[i], group_indices)
        new{D, T, typeof(species), typeof(indices), typeof(pcol), N}(pcol, indices, group_indices, group_sizes, species)
    end
    function Subcollection(pcol::PhysicalCollection{D,T,ST,<:RegularLattice}, group_indices_unsorted::NTuple{N,Int}, indices_unsorted::NTuple{N, Union{CartesianIndices{D},Tuple{CartesianIndices{D}, Union{Colon, AbstractVector{Int}}}}}) where {D,T, ST, N}
        p = sortperm(collect(group_indices_unsorted))
        group_indices = ntuple(i -> group_indices_unsorted[p[i]], N)
        indices = _process_indices(pcol, group_indices, ntuple(i -> indices_unsorted[p[i]], N))
        group_sizes = map(x->length(first(x))*length(last(x)), indices)
        species = map(i->pcol.species[i], group_indices)
        new{D, T, typeof(species), typeof(indices), typeof(pcol), N}(pcol, indices, group_indices, group_sizes, species)
    end
end
Subcollection(pcol::PhysicalCollection, indices::AbstractVector) = Subcollection(pcol, ntuple(i->i, num_of_groups(pcol)), ntuple(i->indices, num_of_groups(pcol)))
Subcollection(pcol::PhysicalCollection, indices::Dict{Int}) = Subcolleciton(pcol, Tuple(keys(indices)), Tuple(values(indices)))
Subcollection(pcol::PhysicalCollection, indices::AbstractVector{<:Pair{Int}}) = Subcollection(pcol, Tuple(first(p) for p in indices), Tuple(last(p) for p in indices))
Subcollection(pcol::PhysicalCollection, indices::NTuple{N,Pair{Int}}) where {N} = Subcollection(pcol, Tuple(first(p) for p in indices), Tuple(last(p) for p in indices))
Subcollection(pcol::PhysicalCollection, p1::Pair{Int}, ps::Vararg{Pair{Int},N}) where N = Subcollection(pcol, (p1, ps...))

Subcollection(pcol::PhysicalCollection{D,T,ST,<:RegularLattice}, lattice_indices::CartesianIndices{D}) where {D,T,ST} = Subcollection(pcol, lattice_indices, Colon(), ntuple(i->i, num_of_groups(pcol)))
Subcollection(pcol::PhysicalCollection{D,T,ST,<:RegularLattice}, lattice_indices::CartesianIndices{D}, cell_indices::Union{Colon, AbstractVector{Int}}, group_indices::NTuple{N, Int}) where {D,T,ST, N} = Subcollection(pcol, ntuple(i->(lattice_indices, cell_indices), Val(N)), group_indices)

Base.view(pcol::PhysicalCollection, I...) = Subcollection(pcol, I...)

function _check_indices(pcol::PhysicalCollection, indices::NTuple{N, AbstractVector}, group_indices::NTuple{N, Int}) where {N}
    for (ig, group) in zip(group_indices, indices)
        check_groupbounds(pcol, ig)
        for index in group
            checkbounds(pcol, _parent_index(pcol, index, ig)...)
        end
    end
end
_process_indices(pcol::PhysicalCollection{D,T,ST,<:RegularLattice}, group_indices::NTuple{N, Int}, indices::NTuple{N, Union{CartesianIndices{D}, Tuple{CartesianIndices{D}, Union{Colon,AbstractVector{Int}}}}}) where {D,T,ST,N} = map((ig, I)->_process_index(pcol, ig, I), group_indices, indices)
@inline _process_index(pcol::PhysicalCollection{D,T,ST,<:RegularLattice}, ig::Int, index::CartesianIndices{D}) where {D,T, ST} = _process_index(pcol, ig, (index, Colon())) 
@inline _process_index(pcol::PhysicalCollection{D,T,ST,<:RegularLattice}, ig::Int, index::Tuple{CartesianIndices{D}, Colon}) where {D,T,ST} = _process_index(pcol, ig, (first(index),Base.OneTo(group_size(pcol.nodes.basis_cell, ig))))
function _process_index(pcol::PhysicalCollection{D,T,ST,<:RegularLattice}, ig::Int, index::Tuple{CartesianIndices{D}, AbstractVector{Int}}) where {D,T,ST}
    check_groupbounds(pcol, ig)
    rlattice = pcol.nodes
    cell = rlattice.basis_cell
    lattice_indices = first(index)
    cell_indices = sort(last(index))
    check_lattice_bounds(rlattice, lattice_indices|>first)
    check_lattice_bounds(rlattice, lattice_indices|>last)
    checkbounds(pcol, _parent_index(pcol, (first(lattice_indices), first(cell_indices)), ig)...)
    checkbounds(pcol, _parent_index(pcol, (last(lattice_indices), last(cell_indices)), ig)...)
    return (lattice_indices, cell_indices)
end

is_homogeneous(subcol::Subcollection) = IsHomogeneous{false}()
is_homogeneous(subcol::Subcollection{D,T, ST, IT, PCT, 1}) where {D, T, ST, IT, PCT} = IsHomogeneous{true}()

@inline num_of_groups(subcol::Subcollection{D,T, ST, IT, PCT, N}) where {D, T, ST, IT, PCT, N} = N

@propagate_inbounds group_size(subcol::Subcollection, ig::Int) = (@boundscheck check_groupbounds(subcol, ig); subcol.group_sizes[ig])

@inline function checkbounds(::Type{Bool}, subcol::Subcollection{D,T,ST,<:NTuple{N,_OrderedIndexType{D}}}, I::CartesianIndex{D}, ic::Int, ig::Int) where {D,T,ST,N}
    check_group_index(subcol, ig) || return false
    lattice_indices, cell_indices = subcol.indices[ig]
    return checkbounds(Bool, lattice_indices, I) && checkbounds(Bool, cell_indices, ic)
end

@propagate_inbounds function group_iterator(subcol::Subcollection{D,T,ST, <:NTuple{N, _OrderedIndexType{D}}}, ig::Int) where {D,T,ST,N}
    @boundscheck check_groupbounds(subcol, ig)
    indices = subcol.indices[ig]
    return Iterators.product(CartesianIndices(size(first(indices))), Base.OneTo(indices[2]|>length))
end

#
#    If you think about it, we are never supposed to index into the subcollection ourselves.
#    We probably just want to iterate over it and that is it.
#    The parent collections is a different story: we might want to play with them to identify what nodes we
#    want to include in a subcollection
#
#


length(subcol::Subcollection) = sum(subcol.group_sizes)

@inline _parent_index(pcol::PhysicalCollection, index, ig) = _parent_index(is_homogeneous(pcol), index, ig)
@inline _parent_index(::IsHomogeneous{true}, index, ig) = (index...,)
@inline _parent_index(::IsHomogeneous{false}, index, ig) = (index..., ig)

@propagate_inbounds function position(subcol::Subcollection, il::Int, ig::Int)
    @boundscheck begin
        check_groupbounds(subcol, ig)
        1 <= il <= group_size(subcol, ig) || throw(BoundsError(subcol, (il, ig)))
    end
    position(subcol.pcol, _translate_index(subcol, il, ig)...)
end

@propagate_inbounds position(subcol::Subcollection{D,T,ST,IT,PCT,1}, il::Int) where {D,T,ST,IT,PCT} = position(subcol, il, 1)
@propagate_inbounds position(subcol::Subcollection{D,T,ST,IT,PCT,1}, I::CartesianIndex{D}, ic::Int) where {D,T,ST,IT,PCT} = position(subcol, I, ic, 1)

@propagate_inbounds position(subcol::Subcollection, I...) = position(subcol.pcol, _translate_index(subcol, I...)...)
@propagate_inbounds _translate_index(subcol::Subcollection{D,T,ST, <:NTuple{N, _UnorderedIndexType}}, ic::Int, ig::Int) where {D,T,ST,N} = _parent_index(subcol.pcol, subcol.indices[ig][ic], subcol.group_indices[ig])
@propagate_inbounds function _translate_index(subcol::Subcollection{D,T,ST, <:NTuple{N, _OrderedIndexType{D}}}, I::CartesianIndex{D}, ic::Int, ig::Int) where {D,T,ST,N}
    @boundscheck check_groupbounds(subcol, ig)
    index = subcol.indices[ig]
    return _parent_index(subcol.pcol, (first(index)[I], last(index)[ic]), subcol.group_indices[ig])
end
@propagate_inbounds function _translate_index(subcol::Subcollection{D,T,ST, <:NTuple{N, _OrderedIndexType{D}}, <:PhysicalCollection{D,T,ST′, <:RegularLattice}}, il::Int, ig::Int) where {D,T,ST,N,ST′}
    index = subcol.indices[ig]
    lattice_indices, cell_indices = index
    ncells = length(lattice_indices)
    parent_index = (lattice_indices[mod1(il, ncells)], cell_indices[div(il - 1, ncells) + 1])
    return _parent_index(subcol.pcol, parent_index, subcol.group_indices[ig])
end



@inline _get_col(pcol::PhysicalCollection) = pcol
@inline _get_col(subcol::Subcollection) = subcol.pcol

@propagate_inbounds _get_col_index(col::AbstractPhysicalCollection, index...) = _get_col(col), _translate_index(col, index...)

@propagate_inbounds relative_position(subcol::Subcollection, I1, I2) = relative_position(_get_col(subcol), _translate_index(subcol, I1...), _translate_index(subcol, I2...))

@propagate_inbounds relative_position(col1::AbstractPhysicalCollection{D,T}, I1, col2::AbstractPhysicalCollection{D,T}, I2) where {D,T} =
    relative_position(_get_col_index(col1, I1...)..., _get_col_index(col2, I2...)...)

@propagate_inbounds relative_position(pcol1::PhysicalCollection{D,T}, I1, pcol2::PhysicalCollection{D,T}, I2) where {D,T} =
    pcol1===pcol2 ? relative_position(pcol1, I1, I2) : position(pcol1, I1...) - position(pcol2, I2...)
