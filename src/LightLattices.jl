module LightLattices

using StaticArrays, RecursiveArrayTools, DocStringExtensions

export AbstractNodeCollection

"""
$(TYPEDEF)

Abstract collection of nodes in `D`-dimensional space. Type `T` is used to represent coordinates.
"""
abstract type AbstractNodeCollection{D, T} end


"""
$(TYPEDSIGNATURES)

Returns the coordinate of node with index `i1` relative to coordinate of the node with index `i2`.
"""
Base.@propagate_inbounds function relative_coordinate(collection::AbstractNodeCollection, i1, i2) end

include("cells.jl")
include("lattices.jl")
include("utils.jl")

export AbstractNodeCollection
export AbstractCell, TrivialCell, HomogeneousCell, InhomogeneousCell
export AbstractLattice, RegularLattice
export switch_coord_type
export relative_coordinate
export num_of_groups, group_size

end
