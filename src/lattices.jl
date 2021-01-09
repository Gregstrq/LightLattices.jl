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
struct RegularLattice{D, T, PB, CT, L<:Union{Symbol,Nothing}, D′} <: AbstractLattice{D, T, PB}
    """
    The number of basis cells along each of the basis directions.
    """
    lattice_dims::NTuple{D, Int}
    """
    Coordinates of the basis vectors of the underlying Bravais lattice. `basis[:, i]` gives the ``i``-th basis vector.
    """
    basis::SMatrix{D,D, T}
    """
    Unit cell of the lattice.
    """
    unit_cell::CT
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

    Constructs a Regular Lattice enforcing the condition that `typeof(unit_cell)<:AbstractCell{D,T}`.

    #Arguments
    - `lattice_dims::NTuple{D,Int}`: specifies the number of unit cells along each of the basis directions.
    - `basis::SMatrix{D,D,T}`: stores as columns the basis vectors of the underlying Bravais lattice.
    - `unit_cell::AbstractCell{D,T}`: specifies the unit cell of the lattice; if the unit cell does not have any special structure, an instance of `TrivialCell` should be used.
    - `label::Union{Symbol,Nothing}`: the label of the lattice.
    - `PB::Bool`: specifies if periodic or free boundary conditions are applied; default value is `true`.
    """
    function RegularLattice(lattice_dims::NTuple{D, Int}, basis::SMatrix{D,D,T}, unit_cell::AbstractCell{D,T}, label::Union{Symbol,Nothing}, PB::Bool) where {D,T}
        @assert D>=1
        num_of_cells = prod(lattice_dims)
        central_cell = CartesianIndex(div.(lattice_dims,2).+1)
        D′ = D + effective_dim(unit_cell)
        new{D, T, PB, typeof(unit_cell), typeof(label), D′}(lattice_dims, basis, unit_cell, label, num_of_cells, length(unit_cell)*num_of_cells, central_cell)
    end
end

### Outer constructors.

function RegularLattice(lattice_dims::NTuple{D, Int}, basis::SMatrix{D,D,T1}, unit_cell::AbstractCell{D,T2}, label, PB) where {D,T1,T2}
    T = promote_type(T1,T2)
    return RegularLattice(lattice_dims::NTuple{D, Int}, SMatrix{D,D,T}(basis), switch_coord_type(unit_cell, T), label, PB)
end

"""
`RegularLattice(lattice_dims::NTuple{D, Int}, a::T=1; label=:cubic, periodic=true)`

Constructs hypercubic lattice with lattice parameter `a` and trivial unit cell.
"""
function RegularLattice(lattice_dims::NTuple{D, Int}, a::T=1; periodic=true, label=:cubic) where {D, T<:Number}
    basis = one(SMatrix{D,D,Int})*a
    unit_cell = TrivialCell{D,T}()
    return RegularLattice(lattice_dims, basis, unit_cell, label, periodic)
end
function RegularLattice(lattice_dims::NTuple{D,Int}, basis::SMatrix{D,D,T}; label=:simple, periodic = true) where {D,T}
    unit_cell = TrivialCell{D,T}()
    return RegularLattice(lattice_dims, basis, unit_cell, label, periodic)
end
"""
`RegularLattice(lattice_dims::NTuple{D, Int}, basis::SMatrix{D,D}, unit_cell::AbstractCell{D}; label=nothing, periodic=true)`

Convenient constructor which allows to specify the label and boundary condition as keyword arguments.
"""
RegularLattice(lattice_dims::NTuple{D, Int}, basis::SMatrix{D,D}, unit_cell::AbstractCell{D}; label=nothing, periodic=true) where {D} =
    RegularLattice(lattice_dims, basis, unit_cell, label, periodic)

"""
$(TYPEDSIGNATURES)

Return the number of separate groups for lattice with inhomogeneous unit cell.
"""
@inline num_of_groups(lattice::RegularLattice{D,T,PB,<:InhomogeneousCell}) where {D,T,PB} = num_of_groups(lattice.unit_cell)

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

Base.@propagate_inbounds function Base.getindex(lattice::RegularLattice{D,T,false,<:TrivialCell}, I::CartesianIndex{D}) where {D,T}
    @boundscheck check_lattice_index(lattice, I)
    @inbounds lattice.basis*SVector{D}(I.I)
end
Base.@propagate_inbounds function Base.getindex(lattice::RegularLattice{D,T,false,<:Union{HomogeneousCell,InhomogeneousCell}}, I::CartesianIndex{D}, Ic...) where {D,T}
    @boundscheck check_lattice_index(lattice, I)
    @boundscheck check_cell_index(lattice, Ic...)
    @inbounds lattice.basis*SVector{D}(I.I) + lattice.unit_cell[Ic...]
end
Base.@propagate_inbounds function Base.getindex(lattice::RegularLattice{D,T,true,<:TrivialCell}, I::CartesianIndex{D}) where {D,T}
    @inbounds lattice.basis*SVector{D}(mod1.(I.I, lattice.lattice_dims))
end
Base.@propagate_inbounds function Base.getindex(lattice::RegularLattice{D,T,true,<:Union{HomogeneousCell,InhomogeneousCell}}, I::CartesianIndex{D}, Ic...) where {D,T}
    @boundscheck check_cell_index(lattice, Ic...)
    @inbounds lattice.basis*SVector{D}(mod1.(I.I, lattice.lattice_dims)) + lattice.unit_cell[Ic...]
end


@inline check_lattice_index(lattice::RegularLattice{D}, I::CartesianIndex{D}) where {D} = _check_cartesian_index(true, I.I, lattice.lattice_dims) || throw(BoundsError(lattice, I))
@inline _check_cartesian_index(b, i, stop) = _check_cartesian_index(b & (1 <= i[1] <= stop[1]), Base.tail(i), Base.tail(stop))
@inline _check_cartesian_index(b, i::Tuple, ::Tuple{}) = false
@inline _check_cartesian_index(b, i::Tuple{}, stop::Tuple) = false
@inline _check_cartesian_index(b, i::Tuple{}, stop::Tuple{}) = b

@inline check_cell_index(lattice::RegularLattice{D,T,PB,<:HomogeneousCell}, ic::Int) where {D,T,PB} = (1<=ic<=length(lattice.unit_cell)) || throw(BoundsError(lattice.unit_cell, ic))
@inline check_cell_index(lattice::RegularLattice{D,T,PB,<:InhomogeneousCell}, ic::Int, ig::Int) where {D,T,PB} =
    (1<=ig<=num_of_groups(lattice)) && (1<=ic<=group_size(lattice.unit_cell, ig)) || throw(BoundsError(lattice.unit_cell, (ic, ig)))


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

Base.@propagate_inbounds function translate_indices(lattice::RegularLattice{D,T,PB,<:TrivialCell}, Is) where {D,T,PB}
    @boundscheck map(x -> check_lattice_index(lattice, x), Is)
    return Is
end
Base.@propagate_inbounds function translate_indices(lattice::RegularLattice{D,T,PB,<:HomogeneousCell}, Is) where {D,T,PB}
    @boundscheck map(x -> check_lattice_index(lattice, x), Is)
    return Base.product(Is, Base.OneTo(length(lattice.unit_cell)))
end
Base.@propagate_inbounds function translate_indices(lattice::RegularLattice{D,T,PB,<:InhomogeneousCell}, Is, ig::Int) where {D,T,PB}
    @boundscheck map(x -> check_lattice_index(lattice, x), Is)
    return Base.product(Is, Base.OneTo(group_size(lattice.unit_cell, ig)), ig)
end

#@inline to_default(lattice::RegularLattice{D,T,PB,<:TrivialCell}, x::Int, y::Int, z::Int) = CartesianIndex
