struct PhysicalCollection{D,T,ET<:Tuple, NCT<:AbstractNodeCollection{D,T}}<:AbstractPhysicalCollection{D,T,ET}
    """
    Underlying node collection.
    """
    collection::NCT
    """
    The tuple of the elements occupying the nodes. The elements are in one-to-one correspondence with the groups of the `collection`.
    """
    elements::ET

    function PhysicalCollection(collection::AbstractNodeCollection{D,T}, elements::ET) where {D,T,ET<:Tuple}
        @assert num_of_groups(collection)==length(elements) "The number of elements has to coincide with the number of the groups of the node collection."
        new{D,T, typeof{collection}, ET}(collection, elements)
    end
end

num_of_groups(pcol::PhysicalCollection) = num_of_groups(pcol.collection)
Base.@propagate_inbounds group_size(pcol::PhysicalCollection) = group_size(pcol.collection)

is_homogeneous(pcol::PhysicalCollection) = is_homogeneous(pcol.collection)

Base.@propagate_inbounds Base.getindex(pcol::PhysicalCollection, I...) = pcol.collection[I...]

Base.@propagate_inbounds function element(pcol::PhysicalCollection, I...)
    @boundscheck checkbounds(pcol, I...)
    pcol.elements[last(I)]
end

Base.checkindex(pcol::PhysicalCollection, I...) = checkindex(pcol.collection, I...)

Base.@propagate_inbounds relative_coordinate(pcol::PhysicalCollection, I1, I2) = relative_coordinate(pcol.collection, I1, I2)

Base.eachindex(pcol::PhysicalCollection) = eachindex(pcol.collection)
