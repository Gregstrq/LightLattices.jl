module LightLattices

using StaticArrays, DocStringExtensions

import Base: getindex, checkbounds, eachindex, length, @propagate_inbounds
import AtomsBase: position, species

export AbstractNodeCollection, AbstractPhysicalCollection, AbstractCollection

"""
$(TYPEDEF)

Abstract collection of nodes in `D`-dimensional space. Type `T` is used to represent coordinates.
"""
abstract type AbstractNodeCollection{D, T} end
"""
$(TYPEDEF)

Trait to distinguish homogeneous and inhomogeneous collections. Informally speaking, collection can have several groups of nodes, where each of the groups corresponds to its own type of physical object occupying the nodes of the group. Collections with a single group are called homogeneous, while in the case of multiple groups, they are called inhomogeneous.
"""
struct IsHomogeneous{BT} end
"""
```julia
is_homogeneous(nodes::AbstractNodeCollection)
```

Computes the `IsHomogeneous` trait for the given collection.
Returns `IsHomogeneous{true}()` for single-group collections and `IsHomogeneous{false}` otherwise.
"""
function is_homogeneous end

"""
$(TYPEDEF)

Abstract collection of nodes in `D`-dimensional space, occupied by the physical objects from a Tuple of species `ST`. The type `T` is used to represent coordinates.
"""
abstract type AbstractPhysicalCollection{D, T, ST} end

"""
$(TYPEDEF)

Union of node collections and physical collections in `D`-dimensional space.
Use this alias for interfaces that operate on both plain node collections and
physical collections.
"""
const AbstractCollection{D,T} = Union{AbstractNodeCollection{D,T}, AbstractPhysicalCollection{D,T}}
"""
```julia
group_species(pcol::AbstractPhysicalCollection, ig::Int)
```

Returns an object corresponding to the `ig`-th group of the collection.
"""
@propagate_inbounds group_species(pcol::AbstractPhysicalCollection, I...) = group_species(is_homogeneous(pcol), pcol, I...)
@propagate_inbounds group_species(::IsHomogeneous, pcol::AbstractPhysicalCollection, ig::Int) = (@boundscheck check_groupbounds(pcol, ig); get_species(pcol)[ig])
group_species(::IsHomogeneous{true}, pcol::AbstractPhysicalCollection) = first(get_species(pcol))

@inline get_species(pcol::AbstractPhysicalCollection) = pcol.species


"""
```julia
AtomsBase.position(collection::AbstractCollection, I...)
```

Returns the cartesian coordinates of the node with index `I`.
"""
function position end

@inline _species_index(collection::AbstractPhysicalCollection, I...) = _species_index(is_homogeneous(collection), collection, I...)
@inline _species_index(::IsHomogeneous{true}, collection::AbstractPhysicalCollection, I...) = 1
@inline _species_index(::IsHomogeneous{false}, collection::AbstractPhysicalCollection, I...) = last(I)
_species_index(htrait::IsHomogeneous{false}, collection::AbstractPhysicalCollection, i::Int) = _to_il_ig(htrait, collection, i)|>last

"""
```julia
AtomsBase.species(collection::AbstractPhysicalCollection, I...)
```

Return the species at index `I` of an `AbstractPhysicalCollection`.
"""
@propagate_inbounds species(collection::AbstractPhysicalCollection, I...) = (checkbounds(collection, I...); group_species(collection, _species_index(collection, I...)))


"""
```julia
getindex(collection::AbstractNodeCollection, I...)

Return the position of the node with index `I`.
```
"""
@propagate_inbounds getindex(collection::AbstractNodeCollection, I...) = position(collection, I...)
"""
```julia
getindex(collection::AbstractPhysicalCollection, I...)
```

Returns the position and the species at node with index `I`.
"""
@propagate_inbounds function getindex(collection::AbstractPhysicalCollection, I...)
    @boundscheck checkbounds(collection, I...)
    return @inbounds position(collection, I...), @inbounds species(collection, I...)
end

"""
```julia
relative_position(collection::AbstractNodeCollection, i1, i2)
```

Returns the coordinate of node with index `i1` relative to coordinate of the node with index `i2` for the collection `collection`.
"""
function relative_position end

"""
```julia
num_of_groups(collection::AbstractCollection)
```

Returns the number of different groups in the `collection`.
Since the groups are in one-to-one correspondence with the different species, it gives the number of the different kinds of species.
"""
function num_of_groups end

"""
```julia
group_size(collection::AbstractCollection, ig::Int)
```

Return the number of nodes corresponding to the group (species) with index `ig`.
"""
function group_size end

"""
```julia
(collection::AbstractCollection, ig::Int)
```

Return an iterator over the indices inside the `ig`-th group.
"""
function group_iterator end


@inline check_groupbounds(collection::AbstractCollection, ig::Int) = check_group_index(collection, ig) || throw(ErrorException("Group index $(ig) is out of range for collection $(collection)"))
@inline check_group_index(collection::AbstractCollection, ig::Int) = check_group_index(is_homogeneous(collection), collection, ig)
@inline check_group_index(::IsHomogeneous{true}, collection::AbstractCollection, ig::Int) = (ig==1)
@inline check_group_index(::IsHomogeneous{false}, collection::AbstractCollection, ig::Int) = (1≤ig≤num_of_groups(collection))

@inline checkbounds(collection::AbstractCollection, I...) = checkbounds(Bool, collection, I...) || throw(BoundsError(collection, I))
@inline checkbounds(::Type{Bool}, collection::AbstractCollection, I...) = check_linear_index(is_homogeneous(collection), collection, I...)

@inline check_linear_index(::IsHomogeneous, collection::AbstractCollection, ic::Int) = (1<=ic<=length(collection))
@inline check_linear_index(::IsHomogeneous, collection::AbstractCollection, ic::Int, ig::Int) =
    check_group_index(collection, ig) && (1<=ic<=group_size(collection, ig))

_to_il_ig(::IsHomogeneous{true}, collection::AbstractCollection, i::Int) = i, 1
function _to_il_ig(::IsHomogeneous{false}, collection::AbstractCollection, i::Int)
    @inbounds for ig = collection|>num_of_groups|>Base.OneTo
        gs = group_size(collection, ig)
        i -= gs
        i<=0 && return i+gs, ig
    end
end

function _translate_index end
@propagate_inbounds function position(collection::AbstractNodeCollection, i::Int)
    @boundscheck checkbounds(collection, i)
    @inbounds position(collection, _translate_index(collection, _to_il_ig(is_homogeneous(collection), collection, i)...))
end


include("cells.jl")
include("lattices.jl")
include("utils.jl")
#include("disordered_lattices.jl")
include("physical_collection.jl")
include("subcollection.jl")
include("composite_collection.jl")


export AbstractNodeCollection, AbstractPhysicalCollection, AbstractCollection
export AbstractCell, TrivialCell, HomogeneousCell, InhomogeneousCell
export AbstractLattice, RegularLattice
export PhysicalCollection, Subcollection, CompositeCollection
export cluster, lattice
#export DisorderedLattice 
export switch_coord_type
export position, relative_position
export num_of_groups, group_size, group_species
export IsHomogeneous, is_homogeneous, group_iterator
export species, get_species
export @CI

end
