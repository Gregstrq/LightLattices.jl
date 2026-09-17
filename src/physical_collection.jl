"""
$(TYPEDEF)
$(TYPEDFIELDS)

Collection of nodes in `D`-dimensional space, occupied by the physical objects of types `ET`. The type `T` is used to represent coordinates.
"""
struct PhysicalCollection{D,T,ET<:Tuple, NCT<:AbstractNodeCollection{D,T}} <: AbstractPhysicalCollection{D,T,ET}
    """
    Underlying node collection.
    """
    nodes::NCT
    """
    The tuple of the elements occupying the nodes. The elements are in one-to-one correspondence with the groups of the `nodes` collection.
    """
    elements::ET

    PhysicalCollection(nodes::AbstractNodeCollection, element) = PhysicalCollection(nodes, (element,))
    function PhysicalCollection(nodes::AbstractNodeCollection{D,T}, elements::ET) where {D,T,ET<:Tuple}
        @assert num_of_groups(nodes)==length(elements) "The number of elements has to coincide with the number of the groups of the node collection."
        new{D,T, typeof{nodes}, ET}(nodes, elements)
    end
end

num_of_groups(pcol::PhysicalCollection) = num_of_groups(pcol.nodes)
@propagate_inbounds group_size(pcol::PhysicalCollection, ig::Int) = group_size(pcol.nodes, ig)

is_homogeneous(pcol::PhysicalCollection) = is_homogeneous(pcol.nodes)

@propagate_inbounds getindex(pcol::PhysicalCollection, I...) = pcol.nodes[I...]

@inline checkbounds(pcol::PhysicalCollection, I...) = checkbounds(pcol.nodes, I...)

@propagate_inbounds relative_coordinate(pcol::PhysicalCollection, I1, I2) = relative_coordinate(pcol.nodes, I1, I2)

@propagate_inbounds group_iterator(pcol::PhysicalCollection, ig::Int) = group_iterator(pcol, ig)

eachindex(pcol::PhysicalCollection) = eachindex(pcol.nodes)


