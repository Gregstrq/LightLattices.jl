"""
$(TYPEDEF)

Abstract unordered collection of nodes in `D`-dimensional space. Type `T` is used to represent coordinates.
"""
abstract type AbstractCell{D, T} <: AbstractNodeCollection{D, T} end

###
### HomogeneousCell type

"""
$(TYPEDEF)
$(TYPEDFIELDS)

Unodered homogeneous collection of nodes in `D`-dimensional space.
"""
struct HomogeneousCell{D, T, L<:Union{Symbol,Nothing}} <: AbstractCell{D, T}
    """
    Coordinates of nodes.
    """
    cell_vectors::Vector{SVector{D,T}}
    """
    Label of the cell.
    """
    label::L
end

### HomogeneousCell constructors

@inline HomogeneousCell(cell_vectors) = HomogeneousCell(cell_vectors, nothing)
HomogeneousCell(cell_vectors::Vector{NTuple{D,T}}, label::L = nothing) where {D,T, L<:Union{Symbol, Nothing}} = HomogeneousCell(map(SVector{D,T}, cell_vectors), label)
function HomogeneousCell(cell_vectors::Vector{Vector{T}}, label::Union{Symbol,Nothing}=nothing) where {T}
    v1 = first(cell_vectors)
    D = length(v1)
    for i = 2:length(cell_vectors)
        @assert length(cell_vectors[i])==D "All coordinates should have identical dimension."
    end
    return HomogeneousCell(map(SVector{D,T}, cell_vectors), label)
end

###
### InhomogeneousCell type

"""
$(TYPEDEF)
$(TYPEDFIELDS)

Unordered inhomogeneous collection of nodes in `D`-dimensional space. This type allows one to partition the nodes of the cell into several groups. Different groups of nodes may correspond to the different classes of physical objects occupying these nodes.
"""
struct InhomogeneousCell{D, T, N, L<:Union{Symbol,Nothing}, T′} <: AbstractCell{D, T}
    """
    Coordinates of nodes.
    """
    cell_vectors::ArrayPartition{T′, NTuple{N, Vector{SVector{D, T}}}}
    """
    Sizes of the homogeneous groups inside inhomogeneous cell.
    """
    group_sizes::NTuple{N, Int}
    """
    Label of the cell.
    """
    label::L
    InhomogeneousCell(cell_vectors::ArrayPartition{T′, NTuple{N, Vector{SVector{D, T}}}}, label::L) where {T′,T,N,D, L<:Union{Symbol,Nothing}} = new{D,T,N,L,T′}(cell_vectors, Tuple(length.(cell_vectors.x)), label)
end

### InhomogeneousCell constructors

@inline InhomogeneousCell(cell_vectors; label = nothing) = InhomogeneousCell(cell_vectors, label)
function InhomogeneousCell(cell_vectors::ArrayPartition{T′, NTuple{N, Vector{NTuple{D,T}}}}; label::Union{Symbol,Nothing} = nothing) where {T′,T,N,D}
    new_cell_vectors = similar(cell_vectors, SVector{D,T})
    new_cell_vectors .= cell_vectors
    return InhomogeneousCell(cell_vectors, label)
end
function InhomogeneousCell(cell_vectors::Vector{SVector{D, T}}, splitting::Tuple{Int, Vararg{Int}}; label::Union{Symbol,Nothing} = nothing) where {D,T}
    end_positions = cumsum((0, splitting...))
    new_cell_vectors = Tuple(cell_vectors[end_positions[i-1]:end_positions[i]] for i=2:length(end_positions))
    return InhomogeneousCell(new_cell_vectors, label)
end
@inline InhomogeneousCell(cell_vectors::Vector{NTuple{D, T}}, splitting::Tuple{Int, Vararg{Int}}, label::L=nothing) where {D,T, L<:Union{Symbol,Nothing}} =
    InhomogeneousCell(map(SVector{D,T}, cell_vectors), splitting, label)
function InhomogeneousCell(vecss::Tuple{Vector, Vector, Vararg{Vector}}, label::Union{Symbol,Nothing})
    T = promote_type(map(x -> promote_type(compute_type.(x)...), vecss)...)
    D = length(vecss |> first |> first)
    cell_vectors = ArrayPartition(map(x -> SVector{D,T}.(x), vecss))
    return InhomogeneousCell(cell_vectors, label)
end
@inline InhomogeneousCell(cell_vectors1::Vector, cell_vectors2::Vector, vecss...; label::Union{Symbol,Nothing} = nothing) = InhomogeneousCell((cell_vectors1, cell_vectors2, vecss...), label)

compute_type(x::T) where {T<:Number} = T
compute_type(x::Tuple) = promote_type(typeof.(x)...)
compute_type(x::AbstractVector) = eltype(x)


### Helper functions for InhomogeneousCell

"""
$(TYPEDSIGNATURES)

Return the number of separate groups in Inhomogeneous Cell.
"""
@inline num_of_groups(cell::InhomogeneousCell{D,T,N}) where {D,T,N} = N

"""
$(TYPEDSIGNATURES)

Returns the size of the `ig`-th homogeneous group inside inhomogeneous cell.
"""
@inline group_size(cell::InhomogeneousCell, ig::Int) = cell.group_sizes[ig]

###
### TrivialCell type

"""
$(TYPEDEF)

Trivial cell consisting of one node at the origin of `D`-dimensional coordinate system. The type `T` is used to represent coordinates.
"""
struct TrivialCell{D, T} <: AbstractCell{D, T} end


###
### length for AbstractCell

"""
`length(cell::AbstractCell)`

Returns the number of the nodes in the cell.
"""
@inline Base.length(cell::AbstractCell) = length(cell.cell_vectors)
@inline Base.length(cell::TrivialCell) = 1

"""
`get_index(cell::AbstractCell, i...)`

Returns the coordinate of the ``i``-th node of the cell. In the case of InhomogeneousCell we can use double index `i = i1, i2` to access ``i_1``-th node of ``i_2``-th group.
"""
Base.@propagate_inbounds function Base.getindex(cell::AbstractCell, i...) end
Base.@propagate_inbounds Base.getindex(cell::Union{HomogeneousCell,InhomogeneousCell}, i::Int) = getindex(cell.cell_vectors, i)
Base.@propagate_inbounds Base.getindex(cell::InhomogeneousCell, ic::Int, ig::Int) = getindex(cell.cell_vectors, ig, ic)
Base.@propagate_inbounds Base.getindex(cell::TrivialCell{D,T}, i::Int) where {D,T} = (@boundscheck i==1 || throw(BoundsError(cell, i)); zero(SVector{D,T}))

###
### Conversion utilities

"""
`switch_coord_type(cell::AbstractCell{D, T}, ::Type{T′})`

Converts the type used to represent coordinates from `T` to `T′`.
"""
function switch_coord_type(cell::AbstractCell{D, T}, ::Type{T′}) where {D, T, T′} end
switch_coord_type(cell::TrivialCell{D,T}, ::Type{T′}) where {D,T,T′} = TrivialCell{D,T′}()
switch_coord_type(cell::HomogeneousCell{D,T}, ::Type{T′}) where {D,T,T′} = HomogeneousCell(SVector{D,T′}.(cell.cell_vectors), cell.label)
function switch_coord_type(cell::InhomogeneousCell{D,T}, ::Type{T′}) where {D,T,T′}
    new_cell_vectors = similar(cell.cell_vectors, SVector{D,T′})
    new_cell_vectors .= cell.cell_vectors
    return InhomogeneousCell(new_cell_vectors, cell.label)
end
@inline switch_coord_type(cell::AbstractCell{D,T}, ::Type{T}) where {D,T} = cell

###
### Relative coordinate of two nodes in a cell


Base.@propagate_inbounds relative_coordinate(cell::AbstractCell, i1, i2) = cell[i1...] - cell[i2...]

###
### Helper function for Lattice indexing.

"""
effective_dim(cell::AbstractCell)

Returns the number of additional indices which you need to add to Lattice index to describe the position in the cell.
"""
effective_dim(cell::TrivialCell) = 0
effective_dim(cell::HomogeneousCell) = 1
effective_dim(cell::InhomogeneousCell) = 2
