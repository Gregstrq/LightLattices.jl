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
        new{D,T, ET, typeof(nodes)}(nodes, elements)
    end
end

num_of_groups(pcol::PhysicalCollection) = num_of_groups(pcol.nodes)
@propagate_inbounds group_size(pcol::PhysicalCollection, ig::Int) = group_size(pcol.nodes, ig)

length(pcol::PhysicalCollection) = length(pcol.nodes)

is_homogeneous(pcol::PhysicalCollection) = is_homogeneous(pcol.nodes)

@propagate_inbounds getindex(pcol::PhysicalCollection, I...) = pcol.nodes[I...]

@inline checkbounds(pcol::PhysicalCollection, I...) = checkbounds(pcol.nodes, I...)

@propagate_inbounds relative_coordinate(pcol::PhysicalCollection, I1, I2) = relative_coordinate(pcol.nodes, I1, I2)

@propagate_inbounds group_iterator(pcol::PhysicalCollection, ig::Int) = group_iterator(pcol.nodes, ig)

eachindex(pcol::PhysicalCollection) = eachindex(pcol.nodes)

#
#
#    Now we need some convenience constructors for the primitive collection types like cells and lattices,
#    that would allow to create the physical collections in one go.
#
#

cell(et, cell_vectors::Vector; label=nothing, decoder=identity) =
            PhysicalCollection(
                cell(cell_vectors; label),
                decoder(et)
            )
cell(p::Pair{T,<:Vector}; label=nothing, decoder=identity) where T = cell(first(p1), last(p1); label=label, decoder=decoder)
cell(p1::Pair{T1,<:Vector}, p2::Pair{T2,<:Vector}, ps...; label=nothing, decoder=identity) where {T1,T2} = cell((p1,p2,ps...); label, decoder)
cell(ps::NTuple{N, Pair}; label=nothing, decoder=identity) where {N} =
            PhysicalCollection(
                cell(map(last, ps); label),
                map(x->decoder(first(x)), ps)
            )

lattice(lattice_dims::NTuple{D,Int}, a::T, et::ET; periodic=true, label=:cubic, decoder=identity) where {D, T<:Number, ET} =
            PhysicalCollection(
                lattice(lattice_dims, a; periodic, label),
                decoder(et)
            )
lattice(lattice_dims::NTuple{D,Int}, primitive_vecs::SMatrix{D,D,T}, et::ET; label=simple, periodic=true, decoder=identity) where {D,T<:Number, ET} =
            PhysicalCollection(
                lattice(lattice_dims, primitive_vecs; label, periodic),
                decoder(et)
            )
lattice(lattice_dims::NTuple{D,Int}, primitive_vecs::SMatrix{D,D,T}, p1::Pair{ET, <:Vector}, ps::Vararg{Pair, N}; label=simple, periodic=true, cell_label=nothing, decoder=identity) where {D,T<:Number, ET, N} = lattice(lattice_dims, primitive_vecs, (p1, ps...); label, periodic, cell_label, decoder)
lattice(lattice_dims::NTuple{D,Int}, primitive_vecs::SMatrix{D,D,T}, ps::Vector{<:Pair}; label=:simple, periodic=true, cell_label=nothing, decoder=identity) where {D,T<:Number} = lattice(lattice_dims, primitive_vecs, Tuple(ps); label, periodic, cell_label, decoder)
lattice(lattice_dims::NTuple{D,Int}, primitive_vecs::SMatrix{D,D,T}, ps::NTuple{N,Pair}; label=simple, periodic=true, cell_label=nothing, decoder=identity) where {D,T<:Number, N} =
            PhysicalCollection(
                lattice(lattice_dims, primitive_vecs, cell(map(last, ps)...; label=cell_label); label, periodic),
                map(p -> decoder(first(p)), ps)
            )
