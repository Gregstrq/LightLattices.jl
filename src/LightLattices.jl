module LightLattices

using StaticArrays, DocStringExtensions

import Base: getindex, checkbounds, eachindex, length, @propagate_inbounds

export AbstractNodeCollection

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
$(TYPEDSIGNATURES)

Computes the `IsHomogeneous` trait for the given collection.
Returns `IsHomogeneous{true}()` for single-group collections and `IsHomogeneous{false}` otherwise.
"""
function is_homogeneous(nodes::AbstractNodeCollection) end

"""
$(TYPEDEF)

Abstract collection of nodes in `D`-dimensional space, occupied by the physical objects of types `ET`. The type `T` is used to represent coordinates.
"""
abstract type AbstractPhysicalCollection{D, T, ET} <: AbstractNodeCollection{D,T} end
"""
```julia
element(pcol::AbstractPhysicalCollection, ig::Int)
```

Returns an object corresponding to the `ig`-th group of the collection.
"""
element(col::AbstractNodeCollection, I...) = throw(ErrorException("The function is defined only for the subtypes of `AbstractPhysicalCollection`."))
@propagate_inbounds element(pcol::AbstractPhysicalCollection, I...) = element(is_homogeneous(col), col, I...)
@propagate_inbounds element(::IsHomogeneous, pcol::AbstractPhysicalCollection, ig::Int) = (@boundscheck check_groupbounds(pcol, ig); get_elements(pcol)[ig])
element(::IsHomogeneous{true}, pcol::AbstractPhysicalCollection) = first(get_elements(pcol))

@inline get_elements(pcol::AbstractPhysicalCollection) = pcol.elements
"""
$(TYPEDSIGNATURES)

Returns the coordinate of node with index `i1` relative to coordinate of the node with index `i2`.
"""
@propagate_inbounds function relative_coordinate(collection::AbstractNodeCollection, i1, i2) end


include("cells.jl")
include("lattices.jl")
include("utils.jl")
#include("disordered_lattices.jl")
include("physical_collection.jl")
include("subcollection.jl")
include("composite_collection.jl")


export AbstractNodeCollection
export AbstractCell, TrivialCell, HomogeneousCell, InhomogeneousCell
export AbstractLattice, RegularLattice
export PhysicalCollection, Subcollection, CompositeCollection
#export DisorderedLattice 
export switch_coord_type
export relative_coordinate
export num_of_groups, group_size
export IsHomogeneous, is_homogeneous, group_iterator
export @CI

end
