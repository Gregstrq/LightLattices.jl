"""
$(TYPEDEF)
$(TYPEDFIELDS)

Collection of nodes in `D`-dimensional space, occupied by the physical objects of types `ST`. The type `T` is used to represent coordinates.
"""
struct PhysicalCollection{D,T,ST<:Tuple, NCT<:AbstractNodeCollection{D,T}} <: AbstractPhysicalCollection{D,T,ST}
    """
    Underlying node collection.
    """
    nodes::NCT
    """
    The tuple of the species occupying the nodes. The species are in one-to-one correspondence with the groups of the `nodes` collection.
    """
    species::ST

    PhysicalCollection(nodes::AbstractNodeCollection, species) = PhysicalCollection(nodes, (species,))
    function PhysicalCollection(nodes::AbstractNodeCollection{D,T}, species::ST) where {D,T,ST<:Tuple}
        @assert num_of_groups(nodes)==length(species) "The number of species has to coincide with the number of the groups of the node collection."
        new{D,T, ST, typeof(nodes)}(nodes, species)
    end
end

num_of_groups(pcol::PhysicalCollection) = num_of_groups(pcol.nodes)
@propagate_inbounds group_size(pcol::PhysicalCollection, ig::Int) = group_size(pcol.nodes, ig)

length(pcol::PhysicalCollection) = length(pcol.nodes)

is_homogeneous(pcol::PhysicalCollection) = is_homogeneous(pcol.nodes)

@propagate_inbounds position(pcol::PhysicalCollection, I...) = position(pcol.nodes, I...)

@inline checkbounds(pcol::PhysicalCollection, I...) = checkbounds(pcol.nodes, I...)

@propagate_inbounds relative_position(pcol::PhysicalCollection, I1, I2) = relative_position(pcol.nodes, I1, I2)

@propagate_inbounds group_iterator(pcol::PhysicalCollection, ig::Int) = group_iterator(pcol.nodes, ig)

eachindex(pcol::PhysicalCollection) = eachindex(pcol.nodes)

@propagate_inbounds _translate_index(col::PhysicalCollection, I...) = _translate_index(col.nodes, I...)

#
#
#    Now we need some convenience constructors for the primitive collection types like cells and lattices,
#    that would allow to create the physical collections in one go.
#
#

cluster(sp, cell_vectors::Vector; label=nothing, decoder=identity) =
            PhysicalCollection(
                cluster(cell_vectors; label),
                decoder(sp)
            )
cluster(p::Pair{T,<:Vector}; label=nothing, decoder=identity) where T = cluster(first(p), last(p); label=label, decoder=decoder)
cluster(p1::Pair{T1,<:Vector}, p2::Pair{T2,<:Vector}, ps...; label=nothing, decoder=identity) where {T1,T2} = cluster((p1,p2,ps...); label, decoder)
cluster(ps::NTuple{N, Pair}; label=nothing, decoder=identity) where {N} =
            PhysicalCollection(
                cluster(map(last, ps); label),
                map(x->decoder(first(x)), ps)
            )

lattice(lattice_dims::NTuple{D,Int}, a::T, sp::ST; periodic=true, label=:cubic, decoder=identity) where {D, T<:Number, ST} =
            PhysicalCollection(
                lattice(lattice_dims, a; periodic, label),
                decoder(sp)
            )
lattice(lattice_dims::NTuple{D,Int}, primitive_vecs::SMatrix{D,D,T}, sp::ST; label=simple, periodic=true, decoder=identity) where {D,T<:Number, ST} =
            PhysicalCollection(
                lattice(lattice_dims, primitive_vecs; label, periodic),
                decoder(sp)
            )
lattice(lattice_dims::NTuple{D,Int}, primitive_vecs::SMatrix{D,D,T}, p1::Pair{ST, <:Vector}, ps::Vararg{Pair, N}; label=simple, periodic=true, cell_label=nothing, decoder=identity) where {D,T<:Number, ST, N} = lattice(lattice_dims, primitive_vecs, (p1, ps...); label, periodic, cell_label, decoder)
lattice(lattice_dims::NTuple{D,Int}, primitive_vecs::SMatrix{D,D,T}, ps::Vector{<:Pair}; label=:simple, periodic=true, cell_label=nothing, decoder=identity) where {D,T<:Number} = lattice(lattice_dims, primitive_vecs, Tuple(ps); label, periodic, cell_label, decoder)
lattice(lattice_dims::NTuple{D,Int}, primitive_vecs::SMatrix{D,D,T}, ps::NTuple{N,Pair}; label=simple, periodic=true, cell_label=nothing, decoder=identity) where {D,T<:Number, N} =
            PhysicalCollection(
                lattice(lattice_dims, primitive_vecs, cluster(map(last, ps)...; label=cell_label); label, periodic),
                map(p -> decoder(first(p)), ps)
            )
