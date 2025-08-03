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
function HomogeneousCell(cell_vectors::Vector, label::Union{Symbol,Nothing}=nothing)
    D = first(cell_vectors) |> length
    for i = 2:length(cell_vectors)
        @assert length(cell_vectors[i])==D "All coordinates should have identical dimension."
    end
	T = promote_type(compute_type.(cell_vectors)...)
    return HomogeneousCell(map(SVector{D,T}, cell_vectors), label)
end

###
### InhomogeneousCell type

"""
$(TYPEDEF)
$(TYPEDFIELDS)

Unordered inhomogeneous collection of nodes in `D`-dimensional space. This type allows one to partition the nodes of the cell into several groups. Different groups of nodes may correspond to the different classes of physical objects occupying these nodes.
"""
struct InhomogeneousCell{D, T, N, L<:Union{Symbol,Nothing}} <: AbstractCell{D, T}
    """
    Coordinates of nodes.
    """
    cell_vectors::NTuple{N, Vector{SVector{D, T}}}
    """
    Sizes of the homogeneous groups inside inhomogeneous cell.
    """
    group_sizes::NTuple{N, Int}
    """
    Label of the cell.
    """
    label::L
    InhomogeneousCell(cell_vectors::NTuple{N, Vector{SVector{D, T}}}, label::L) where {T,N,D, L<:Union{Symbol,Nothing}} = new{D,T,N,L}(cell_vectors, length.(cell_vectors), label)
end

### InhomogeneousCell constructors

@inline InhomogeneousCell(cell_vectors; label = nothing) = InhomogeneousCell(cell_vectors, label)
function InhomogeneousCell(cell_vectors::NTuple{N, Vector{NTuple{D,T}}}; label::Union{Symbol,Nothing} = nothing) where {T,N,D}
    new_cell_vectors = map(x->map(y->SVector{D,T}(y), x), cell_vectors)
    return InhomogeneousCell(new_cell_vectors, label)
end
function InhomogeneousCell(vecss::Tuple{Vector, Vector, Vararg{Vector}}, label::Union{Symbol,Nothing})
    T = promote_type(map(x -> promote_type(compute_type.(x)...), vecss)...)
    D = length(vecss |> first |> first)
    cell_vectors = map(x->map(y->SVector{D,T}(y), x), vecss)
    return InhomogeneousCell(cell_vectors, label)
end
@inline InhomogeneousCell(cell_vectors1::Vector, cell_vectors2::Vector, vecss...; label::Union{Symbol,Nothing} = nothing) = InhomogeneousCell((cell_vectors1, cell_vectors2, vecss...), label)

compute_type(x::T) where {T<:Number} = T
compute_type(x::Tuple) = promote_type(typeof.(x)...)
compute_type(x::AbstractVector) = eltype(x)


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
@inline Base.length(cell::InhomogeneousCell) = sum(cell.group_sizes)

###
### Helper functions to work with cell groups

"""
$(TYPEDSIGNATURES)

Return the number of separate groups in a cell.
"""
@inline num_of_groups(cell::Union{TrivialCell, HomogeneousCell}) = 1
@inline num_of_groups(cell::InhomogeneousCell{D,T,N}) where {D,T,N} = N

"""
$(TYPEDSIGNATURES)

Returns the size of the `ig`-th homogeneous group inside a cell.
"""
Base.@propagate_inbounds group_size(cell::Union{TrivialCell, HomogeneousCell}, ig::Int) = (@boundscheck ig==1 || throw(ErrorException("Group index is out of range.")); length(cell))
Base.@propagate_inbounds group_size(cell::InhomogeneousCell, ig::Int) = (@boundscheck 1<=ig<=num_of_groups(cell) || throw(ErrorException("Group index is out of range."));cell.group_sizes[ig])

###
### Indexing

"""
`getindex(cell::AbstractCell, i...)`

Returns the coordinate of the ``i``-th node of the cell. In the case of InhomogeneousCell we can use double index `i = i1, i2` to access ``i_1``-th node of ``i_2``-th group.
"""
Base.@propagate_inbounds function Base.getindex(cell::HomogeneousCell, ic::Int)
	@boundscheck check_cell_index(cell, ic)
	@inbounds getindex(cell.cell_vectors, ic)
end
Base.@propagate_inbounds function Base.getindex(cell::InhomogeneousCell, ic::Int)
	@boundscheck check_cell_index(cell, ic)
    gsizes = cell.group_sizes
    for j in 1:num_of_groups(cell)
        ic -= gsizes[j]
        if ic <= 0
            return cell.cell_vectors[j][ic + gsizes[j]]
        end
    end
end
Base.@propagate_inbounds function Base.getindex(cell::InhomogeneousCell, ic::Int, ig::Int)
	@boundscheck check_cell_index(cell, ic, ig)
    @inbounds cell.cell_vectors[ig][ic]
end
Base.@propagate_inbounds Base.getindex(cell::TrivialCell{D,T}, i::Int) where {D,T} = (@boundscheck check_cell_index(cell, i); zero(SVector{D,T}))


@inline check_cell_index(cell::TrivialCell, i::Int) = i==1 || throw(BoundsError(cell, i))
@inline check_cell_index(cell::Union{HomogeneousCell,InhomogeneousCell}, ic::Int) = (1<=ic<=length(cell)) || throw(BoundsError(cell, ic))
@inline check_cell_index(cell::InhomogeneousCell, ic::Int, ig::Int) =
    (1<=ig<=num_of_groups(cell)) && (1<=ic<=group_size(cell, ig)) || throw(BoundsError(cell, (ic, ig)))

###
### Conversion utilities

"""
`switch_coord_type(cell::AbstractCell{D, T}, ::Type{T′})`

Converts the type used to represent coordinates from `T` to `T′`.
"""
switch_coord_type(cell::TrivialCell{D,T}, ::Type{T′}) where {D,T,T′} = TrivialCell{D,T′}()
@inline switch_coord_type(cell::TrivialCell{D,T}, ::Type{T}) where {D,T} = cell
switch_coord_type(cell::HomogeneousCell{D,T}, ::Type{T′}) where {D,T,T′} = HomogeneousCell(SVector{D,T′}.(cell.cell_vectors), cell.label)
@inline switch_coord_type(cell::HomogeneousCell{D,T}, ::Type{T}) where {D,T} = cell
function switch_coord_type(cell::InhomogeneousCell{D,T}, ::Type{T′}) where {D,T,T′}
    new_cell_vectors = map(x->map(y->SVector{D,T′}(y),x), cell.cell_vectors)
    return InhomogeneousCell(new_cell_vectors, cell.label)
end
@inline switch_coord_type(cell::InhomogeneousCell{D,T}, ::Type{T}) where {D,T} = cell

###
### Relative coordinate of two nodes in a cell


Base.@propagate_inbounds relative_coordinate(cell::AbstractCell, i1, i2) = cell[i1...] - cell[i2...]

