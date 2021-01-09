# Manual

## Type Hierarchy

All the types exported by the package are the subtypes of
```julia
abstract type AbstractNodeCollection{D,T} end
```
This type describes an arbitrary collection of nodes in `D`-dimensional space. The coordinates of the nodes are stored internally as instances of `SVector{D,T}`. Hence, parameter `T` describes the type used to store the coordinates.

All the unit-cell types are subtypes of abstract type `AbstractCell`.
```julia
abstract type AbstractCell{D,T} <: AbstractNodeCollection{D,T} end
```

Analogously, we define the supertype for lattices:
```julia
abstract type AbstractLattice{D,T,PB} <: AbstractNodeCollection{D,T} end
```
The additional parameter `PB` can be either `true` for periodic boundary conditions, or `false` for free boundary conditions.

At this point there is only one subtype of `AbstractLattice`, which is `RegularLattice`. In the future, I may add additional types do describe, for example, disordered lattices with vacancies.

## Lattice construction

The general constructor for a regular (without disorder) lattice looks like this:
```julia
RegularLattice(lattice_dims::NTuple{D,Int}[, basis::SMatrix{D,D,T}, unit_cell::AbstractCell{D,T1}]; periodic = true, label::Union{Symbol,Nothing}=nothing).
```
General lattice consists of a unit cell which is translated in space by the vectors of the Bravais Lattice. Thus, the meaning of the entries is the following:
- `lattice_dims` is the tuple specifying the size of the lattice along each of the basis directions.
- `basis` is the matrix, which columns are the basis vectors of the underlying Bravais lattice.
- `unit_cell` specifies the collection of nodes which is used as the unit cell of the lattice.
- `periodic` specifies the boundary conditions: `true` for periodic, `false` for free boundary conditions.
- `label` is either `nothing` or a `Symbol`; it is a label to refer to the lattice (may be useful to automatically generate the name for the computation which uses particular lattice).

!!! note
    The variables `basis` and `unit_cell` can use different internal types to store coordinates.
    However, when the lattice is constructed, they are promoted to the single type.
    
    !!! warning
        You should not mix dimensionful and dimensionless types. The promotion would lead to an error in this case. This is made intentionally.

    

### Convenient constructors

If the variable `unit_cell` is omitted, it is assumed that unit cell is trivial, i.e. consisting of a single node.
If `basis` is omitted as well, hypercubic lattice is constructed. Instead of basis, one can specify the lattice spacing in this case:
```julia
RegularLattice(lattice_dims::NTuple{D,Int}[, a::Number = 1]; label = :cubic, periodic = true)
```

## Unit Cells and Indexing

There are three types of unit cells: `HomogeneousCell`, `TrivialCell`, `InhomogeneousCell`.

### `HomogeneousCell`
This type is used when there is no distinction between the nodes of the cell. The general constructor looks like
```julia
HomogeneousCell(node_coordinates::Vector; label::Union{Symbol,Nothing}=nothing)
```
where `node_coordinates` specifies the coordinates of the nodes. The coordinates can be specified either as `SVector`s, `Vector`s or `NTuple`s of same element type and length. Under the hood, coordinates are converted to `SVector`s.

One can access the coordinate of the ``i``-th node as
```julia
cell[i]
```

### `TrivialCell`

 `TrivialCell` is used by default when no unit cell is specified. It corresponds to a unit cell with single node.

For consistency of interface, `TrivialCell` behaves like a `HomoegeneousCell` with single node, which has zero coordinates.
One can even index into it:
```julia
getindex(::TrivialCell{D,T}, 1) = zero(SVector{D,T})
```

### `InhomogeneousCell`

This type is useful if one needs to distinguish between the several groups of nodes.

For example, one can consider a crystal consisting of several types of nuclei, let's say, "A" and "B". Then, if one needs to get the coordinate of the ``i``-th nuclei of type "B" inside the unit cell, one calls
```julia
cell[i, 2]
```
Generally, if one needs to access the coordinate of `ic`-th node inside `ig`-th group, it is done by
```julia
cell[ic, ig]
```
 
The general constructor for the type is
```julia
InhomogeneousCell(group1_coordinates::Vector, group2_coordinates::Vector, other_group_coordinates...; label=nothing).
```

## Lattice Indexing

### Default style

For `D`-dimensional lattice, the default style of indexing is
```julia
lattice[I::CartesianIndex{D}, Ic...]
```
Here, `I` is the index of the cell, and `Ic...` specifies the position inside that cell.
To be precise,

- in the case of `TrivialCell`, the default indexing is
```julia
lattice[I::CartesianIndex{D}]
```
- in the case of `HomogeneousCell`, it is
```julia
lattice[I::CartesianIndex{D}, ic::Int]
```
- in the case of `InhomogeneousCell`, it is
```julia
lattice[I::CartesianIndex{D}, ic::Int, ig::Int]
```

### Alternative style

The alternative style of indexing is to splat `I` and `Ic` into single tuple. For example, we can index into ``3``-dimensional lattice
- with `TrivialCell` as
```julia
lattice[x::Int, y::Int, z::Int]
```
- with `HomogeneousCell` as
```julia
lattice[x::Int, y::Int, z::Int, ic::Int]
```
- with `InhomogeneousCell` as
```julia
lattice[x::Int, y::Int, z::Int, ic::Int, ig::Int]
```

### Boundary conditions

For the lattice with free boundary conditions, the boundschecking is performed both for index of the cell and the index inside the cell.

In the case of the lattice with periodic boundary conditions, the boundschecking is only applied to the index inside the cell. If the cell index is outside the boundaries, it is simply translated back inside the boundaries.

As an example, let us consider two cubic lattices of similar size, but with different boundary conditions:
```julia
cubic_free = RegularLattice((11,11,11); periodic = false)

cubic_periodic = RegularLattice((11,11,11); periodic = true)
```
For the former lattice, `cubic_free[12,12,12]` leads to `BoundsError`. For the latter lattice, `cubic_periodic[12,12,12]` is equivalent to `cubic_periodic[1,1,1]`.

## Relative coordinate

The package exports the function
```julia
relative_coordinate(collection::AbstractNodeCollection, I1, I2)
```
which returns the coordinate of node `I1` relative to node `I2`.
The format of the indices `I1` and `I2` depends on particular type of the collection (they should correspond to the default style of index). You can find default style of indexing for unit cells in [Unit Cells and Indexing](@ref) section. The default styles for lattices are listed in subsection [Default style](@ref)


!!! note
    If the index in default style is multicomponent, it is passed into `relative_coordinate` as a Tuple. Single `Int` or single `CartesianIndex{D}` are considered single-component.

!!! warning
    At this point, `relative_coordinate` does not support alternative style of indexing for lattices (see [Alternative style](@ref)). Typically, one needs to calculate some coupling constants for all pairs of nodes in the lattice. This can be achieved by computing relative coordinates and substituting them into some interaction function. The indexes for the whole lattice or for it large subset are going to be machine generated anyway.

### Lattices with periodic boundaries

In the case of the lattice with periodic boundary conditions, one is interested in the shortest connecting vector for two nodes. The meaning of the shortest here is the following.
One can translate the lattice periodically in all directions. If one specifies the node, the translation of the lattice produces the images of this specific node. The shortest connecting vector is determined by picking the first node or its image, so that the distance to the second node is minimal.
In the case of the lattice with non-trivial cell, it is possible that this procedure is ambiguous: there can be several connecting vectors with the same minimal length (these vectors are related by symmetry).

In this package, I resolve this ambiguity by using a specific heuristic.
Let me consider two nodes with indices `(I1, Ic1...)` and `(I2, Ic2...)`. Here, `I1` and `I2` are `CartesianIndice`s of cells, `Ic1` and `Ic2` are indices inside the cells.
In the case of a lattice with periodic boundary conditions `relative_coordinate` returns
```julia
lattice[Ic1 + central_cell - Ic2, Ic1...] - lattice[central_cell, Ic2...]
```
Here, `central_cell` is literally the index of the central cell of the lattice:
```julia
central_cell = CartesianIndex(div.(lattice_dims, 2) .+ 1)
```
In reality, it is central only if lattice dimensions are all odd.
In the case of even dimensions it gives the index of one of several central cells.

The idea is quite simple: both `Ic1` and `Ic2` are translated by the same amount so that `Ic2` points to the central cell. Then, `Ic1` is translated back inside the boundaries (it is performed implicitly while indexing into lattice). Finally, the resulting indices are used to compute the relative coordinate.

!!! note
    This heuristic satisfies the important property of reciprocity:
    ```julia
    relative_coordinate(lattice, I1, I2) == - relative_coordinate(lattice, I2, I1)
    ```
