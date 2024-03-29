"""
$(TYPEDEF)

The supertype for Lattices in `D`-dimensional space. Type `T` is used to represent coordinates. The boundary conditions can be either periodic (`PB=true`) or free (`PB=false`).
"""
abstract type AbstractLattice{D, T, PB} <: AbstractNodeCollection{D, T} end

"""
$(TYPEDEF)
$(TYPEDFIELDS)

This type describes a regular arrangment of nodes in `D`-dimensional space with boundary condition `PB` (`PB=true` for periodic boundary conditions, `PB=false` for free periodic boundary conditions). A general lattice consists of identicall cells (combinations of nodes) arranged as a Bravais lattice.
"""
struct RegularLattice{D, T, PB, CT, L<:Union{Symbol,Nothing}} <: AbstractLattice{D, T, PB}
    """
    The number of basis cells along each of the basis directions.
    """
    lattice_dims::NTuple{D, Int}
    """
    Coordinates of the primitive vectors of the underlying Bravais lattice. `primitive_vecs[:, i]` gives the ``i``-th primitive vector.
    """
    primitive_vecs::SMatrix{D,D, T}
    """
    Repeated basis cell of the lattice.
    """
    basis_cell::CT
    """
    Label of the Lattice.
    """
    label::L
    """
    Total number of cells.
    """
    num_of_cells::Int
    """
    Total number of nodes.
    """
    num_of_nodes::Int
    """
    Cartesian index of the central cell (in the case of even length among of dimensions it is an approximation).
    """
    central_cell::CartesianIndex{D}
    """    
    $(SIGNATURES)

    Constructs a Regular Lattice enforcing the condition that `typeof(basis_cell)<:AbstractCell{D,T}`.

    #Arguments
    - `lattice_dims::NTuple{D,Int}`: specifies the number of basis cells along each of the basis directions.
    - `primitive_vecs::SMatrix{D,D,T}`: stores as columns the primitive vectors of the underlying Bravais lattice.
    - `basis_cell::AbstractCell{D,T}`: specifies the repeated basis cell of the lattice; if the basis cell does not have any special structure, an instance of `TrivialCell` should be used.
    - `label::Union{Symbol,Nothing}`: the label of the lattice.
    - `PB::Bool`: specifies if periodic or free boundary conditions are applied; default value is `true`.
    """
	function RegularLattice(lattice_dims::NTuple{D, Int}, primitive_vecs::SMatrix{D,D,T}, basis_cell::AbstractCell{D,T}, label::Union{Symbol,Nothing}, PB::Bool) where {D,T}
        @assert D>=1
        num_of_cells = prod(lattice_dims)
        central_cell = CartesianIndex(div.(lattice_dims,2).+1)
        new{D, T, PB, typeof(basis_cell), typeof(label)}(lattice_dims, primitive_vecs, basis_cell, label, num_of_cells, length(basis_cell)*num_of_cells, central_cell)
    end
end

### Outer constructors.

function RegularLattice(lattice_dims::NTuple{D, Int}, primitive_vecs::SMatrix{D,D,T1}, basis_cell::AbstractCell{D,T2}, label, PB) where {D,T1,T2}
    T = promote_type(T1,T2)
    return RegularLattice(lattice_dims, SMatrix{D,D,T}(primitive_vecs), switch_coord_type(basis_cell, T), label, PB)
end

"""
`RegularLattice(lattice_dims::NTuple{D, Int}, a::T=1; label=:cubic, periodic=true)`

Constructs hypercubic lattice with lattice parameter `a` and trivial unit cell.
"""
function RegularLattice(lattice_dims::NTuple{D, Int}, a::T=1; periodic=true, label=:cubic) where {D, T<:Number}
    primitive_vecs = one(SMatrix{D,D,Int})*a
    basis_cell = TrivialCell{D,T}()
    return RegularLattice(lattice_dims, primitive_vecs, basis_cell, label, periodic)
end
function RegularLattice(lattice_dims::NTuple{D,Int}, primitive_vecs::SMatrix{D,D,T}; label=:simple, periodic = true) where {D,T}
    basis_cell = TrivialCell{D,T}()
    return RegularLattice(lattice_dims, primitive_vecs, basis_cell, label, periodic)
end
"""
`RegularLattice(lattice_dims::NTuple{D, Int}, primitive_vecs::SMatrix{D,D}, basis_cell::AbstractCell{D}; label=nothing, periodic=true)`

Convenient constructor which allows to specify the label and boundary condition as keyword arguments.
"""
RegularLattice(lattice_dims::NTuple{D, Int}, primitive_vecs::SMatrix{D,D}, basis_cell::AbstractCell{D}; label=nothing, periodic=true) where {D} =
    RegularLattice(lattice_dims, primitive_vecs, basis_cell, label, periodic)

"""
$(TYPEDSIGNATURES)

Return the number of lattice separate groups.
"""
@inline num_of_groups(lattice::RegularLattice) = num_of_groups(lattice.basis_cell)

Base.@propagate_inbounds group_size(lattice::RegularLattice, ig) = lattice.num_of_cells*group_size(lattice.basis_cell, ig)

Base.length(lattice::RegularLattice) = lattice.num_of_nodes

##
## Indexing interface.

"""
`getindex(lattice::RegularLattice{D}, Index...)`

Returns the coordinate of the node with index `Index`. The configurations of indices for different types of unit cell are the following:
- `TrivialCell`: `I::CartesianIndex{D}`.
- `HomogeneousCell`: `I::CartesianIndex{D}, ic::Int`.
- `InhomogeneousCell`: `I::CartesianIndex{D}, ic::Int, ig::Int`.
When iterating over lattice, the index at the left is iterated faster. For example, in the case of `InhomogeneousCell` I is iterated first, then `ic`, then `ig`.

In the case of periodic lattice, if `CartesianIndex` is outside of the lattice dims, it is simply translated back inside.
"""

Base.@propagate_inbounds function Base.getindex(lattice::RegularLattice{D,T}, I::CartesianIndex{D}, Ic...) where {D,T}
    @boundscheck check_lattice_index(lattice, I)
	@boundscheck check_cell_index(lattice.basis_cell, Ic...)
    @inbounds lattice.primitive_vecs*SVector{D}(I.I) + lattice.basis_cell[Ic...]
end
Base.@propagate_inbounds function Base.getindex(lattice::RegularLattice{D,T,false,<:TrivialCell}, I::CartesianIndex{D}) where {D,T}
    @boundscheck check_lattice_index(lattice, I)
    @inbounds lattice.primitive_vecs*SVector{D}(I.I)
end
Base.@propagate_inbounds function Base.getindex(lattice::RegularLattice{D,T,true}, I::CartesianIndex{D}, Ic...) where {D,T}
    @boundscheck check_cell_index(lattice.basis_cell, Ic...)
    @inbounds lattice.primitive_vecs*SVector{D}(mod1.(I.I, lattice.lattice_dims)) + lattice.basis_cell[Ic...]
end
Base.@propagate_inbounds function Base.getindex(lattice::RegularLattice{D,T,true,<:TrivialCell}, I::CartesianIndex{D}) where {D,T}
    @inbounds lattice.primitive_vecs*SVector{D}(mod1.(I.I, lattice.lattice_dims))
end


@inline check_lattice_index(lattice::RegularLattice{D}, I::CartesianIndex{D}) where {D} = _check_cartesian_index(true, I.I, lattice.lattice_dims) || throw(BoundsError(lattice, I))
@inline _check_cartesian_index(b, i, stop) = _check_cartesian_index(b & (1 <= i[1] <= stop[1]), Base.tail(i), Base.tail(stop))
@inline _check_cartesian_index(b, i::Tuple, ::Tuple{}) = false
@inline _check_cartesian_index(b, i::Tuple{}, stop::Tuple) = false
@inline _check_cartesian_index(b, i::Tuple{}, stop::Tuple{}) = b



## Relative coordinate

Base.@propagate_inbounds function relative_coordinate(lattice::RegularLattice{D,T,false}, I1::TI, I2::TI) where {D,T, TI<:Union{CartesianIndex{D}, Tuple{CartesianIndex{D},Vararg{Int}}}}
    return lattice[I1] - lattice[I2]
end
"""
$(TYPEDSIGNATURES)

For periodic lattice, the "shortest" relative coordinate is calculated instead.

For, that the following heuristic is used. Cartesian indices of the two nodes are shifted by the same amount, so that the cartesian index of the second node corresponds to the central cell of the lattice. Then, the cartesian index of the first node is translated back inside the lattice. The relative coordinate is computed using the resulting indices.

This heuristic guarantees that
`relative_coordinate(lattice, I1, I2) == -relative_coordinate(lattice, I2, I1)`.
"""
Base.@propagate_inbounds function relative_coordinate(lattice::RegularLattice{D,T,true,<:TrivialCell}, I1::TI, I2::TI) where {D,T, TI<:CartesianIndex{D}}
    return lattice[I1 + lattice.central_cell - I2] - lattice[lattice.central_cell]
end
Base.@propagate_inbounds function relative_coordinate(lattice::RegularLattice{D,T,true}, I1::TI, I2::TI) where {D,T, TI<:Tuple{CartesianIndex{D},Vararg{Int}}}
    return lattice[first(I1) + lattice.central_cell - first(I2), Base.tail(I1)...] - lattice[lattice.central_cell, Base.tail(I2)...]
end

#Base.@propagate_inbounds function translate_indices(lattice::RegularLattice{D,T,PB,<:TrivialCell}, Is) where {D,T,PB}
#    @boundscheck map(x -> check_lattice_index(lattice, x), Is)
#    return Is
#end
#Base.@propagate_inbounds function translate_indices(lattice::RegularLattice{D,T,PB,<:HomogeneousCell}, Is) where {D,T,PB}
#    @boundscheck map(x -> check_lattice_index(lattice, x), Is)
#    return Base.product(Is, Base.OneTo(length(lattice.unit_cell)))
#end
#Base.@propagate_inbounds function translate_indices(lattice::RegularLattice{D,T,PB,<:InhomogeneousCell}, Is, ig::Int) where {D,T,PB}
#    @boundscheck map(x -> check_lattice_index(lattice, x), Is)
#    return Base.product(Is, Base.OneTo(group_size(lattice.unit_cell, ig)), ig)
#end

#@inline to_default(lattice::RegularLattice{D,T,PB,<:TrivialCell}, x::Int, y::Int, z::Int) = CartesianIndex
