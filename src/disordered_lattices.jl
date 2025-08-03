"""
$(TYPEDEF)
$(TYPEDFIELDS)

This types describes an arrangements of nodes in a `RegularLattice`, where some of the nodes are randomly absent. Such a node collection models random vacancies in a regular lattice.
"""
mutable struct DisorderedLattice{D, T, PB, RLT<:RegularLattice{D, T, PB}, AT, RT} <: AbstractLattice{D, T, PB}
    """
    The underlying regular lattice.
    """
    rlattice::RLT
    """
    The indices of the occupied nodes. The indices are in relation to the underlying regular lattice.
    """
    indices::AT
    """
    The occupation ratio. For ρ=1.0 there is no disorder. One can set up different level of disorder for different groups of nodes. In this case, ρ is a `Tuple`.
    """
    ρ::RT

    function DisorderedLattice(rlattice::RegularLattice{D,T,PB}, ρ::RT, rng=Base.GLOBAL_RNG) where {D,T,PB,RT}
        @assert 0.0≤ρ≤1.0
        indices = _initialize_indices(rlattice, ρ, rng)
        new{D,T,PB, typeof(lattice), typeof(indices), RT}(rlattice, indices, ρ)
    end
end

_initialize_indices(rlattice::RegularLattice, ρ, rng) = _initialize_indices(is_homogeneous(rlattice), rlattice, ρ, rng)
_initialize_indices(::IsHomogeneous{true}, rlattice::RegularLattice, ρ, rng) = rundsubseq(rng, eachindex(rlattice)|>collect)
_initialize_indices(htrait::IsHomogeneous{false}, rlattice::RegularLattice, ρ::Int, rng) = Tuple((@inbounds group_iterator(htrait, rlattice, ig))|>collect|>x->randsubseq(x,ρ) for ig=1:num_of_groups(rlattice))
_initialize_indices(htrait::IsHomogeneous{false}, rlattice::RegularLattice{D,T,PB,<:InhomogeneousCell{D,T,N}}, ρ::NTuple{N,Int}, rng) where {D,T,PB,N} = Tuple((@inbounds group_iterator(htrait, rlattice, ig))|>collect|>x->randsubseq(x,ρ[ig]) for ig=1:num_of_groups(rlattice))


## Groups and homogeneity trait.

@inline num_of_groups(dlattice::DisorderedLattice) = num_of_groups(dlattice.rlattice)
Base.@propagate_inbounds function group_size(dlattice::DisorderedLattice, ig::Int)
    @boundscheck check_groupbounds(dlattice, ig)
    @inbounds length(dlattice.indices)
end

Base.length(dlattice::DisorderedLattice) = sum(@inbounds group_size(dlattice, ig) for ig = 1:num_of_groups(dlattice))

is_homogeneous(dlattice::DisorderedLattice) = is_homogeneous(dlattice.rlattice)

## Indexing and relative_coordinate

@inline _translate_d_index(dlattice::DisorderedLattice, I...) = _translate_d_index(is_homogeneous(dlattice), dlattice, I...)
@inline _translate_d_index(htrait::IsHomogeneous, dlattice::DisorderedLattice, I::Tuple) = _tranlsate_d_index(htrait, dlattice, I...)
@inline _translate_d_index(::IsHomogeneous{true}, dlattice::DisorderedLattice, i::Int) = dlattice.indices[i]
@inline _translate_d_index(::IsHomogeneous{false}, dlattice::DisorderedLattice, i::Int, ig::Int) = (dlattice.indices[ig][i]..., ig)

@inline Base.checkindex(dlattice::DisorderedLattice, I...) = checkindex(is_homogeneous(dlattice), dlattice, I...) || throw(BoundsError(lattice, I))
@inline Base.checkindex(::IsHomogeneous{true}, dlattice::DisorderedLattice, i::Int) = 1≤i≤length(dlattice.indices)
@inline Base.checkindex(htrait::IsHomogeneous{false}, dlattice::DisorderedLattice, i::Int, ig::Int) = check_group_index(htrait, dlattice, ig) && (1≤i≤length(dlattice.indices[ig]))

Base.@propagate_inbounds function get_index(dlattice::DisorderedLattice, I...)
    @boundscheck checkbounds(dlattice, I...)
    @inbounds dlattice.lattice[_translate_d_index(dlattice, I...)...]
end

Base.@propagate_inbounds relative_coordinate(dlattice::DisorderedLattice, I1::T, I2::T) where {T} = relative_coordinate(dlattice.rlattice, _translate_d_index(I1), _translate_d_index(I2))

## Iteration over all indices.


Base.eachindex(dlattice::DisorderedLattice) = eachindex(is_homogeneous(dlattice), dlattice)
Base.eachindex(::IsHomogeneous{true}, dlattice::DisorderedLattice) = Base.OneTo(length(dlattice))
Base.eachindex(::IsHomogeneous{false}, dlattice::DisorderedLattice) = Iterators.flatten(Iterators.map(x->(x...,ig), Base.OneTo(@inbounds group_size(dlattice, ig))) for ig=1:num_of_groups(dlattice))



Base.@propagate_inbounds function group_iterator(::IsHomogeneous{false}, lattice::DisorderedLattice, ig::Int)
    @boundscheck check_group_index(lattice, ig)
    return lattice.indices
end
