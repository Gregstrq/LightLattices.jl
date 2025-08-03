# Manual

## Type Hierarchy

All the types exported by the package are the subtypes of
```julia
abstract type AbstractNodeCollection{D,T} end
```
This type describes an arbitrary collection of nodes in `D`-dimensional space. The coordinates of the nodes are stored internally as instances of `SVector{D,T}`. Hence, parameter `T` describes the type used to store the coordinates.

All the basis-cell types are subtypes of abstract type `AbstractCell`.
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
RegularLattice(lattice_dims::NTuple{D,Int}[, primitive_vecs::SMatrix{D,D,T}, basis_cell::AbstractCell{D,T1}]; periodic = true, label::Union{Symbol,Nothing}=nothing).
```
General lattice consists of a basis cell which is translated in space by the primitive vectors of the Bravais Lattice. Thus, the meaning of the entries is the following:
- `lattice_dims` is the tuple specifying the size of the lattice along each of the primitive vectors.
- `primitive_vecs` is the matrix, which columns are the primitive vectors of the underlying Bravais lattice.
- `basis_cell` specifies the collection of nodes which is used as the basis cell of the lattice.
- `periodic` specifies the boundary conditions: `true` for periodic, `false` for free boundary conditions.
- `label` is either `nothing` or a `Symbol`; it is a label to refer to the lattice (may be useful to automatically generate the name for the computation which uses particular lattice).

!!! note
    The variables `primitive_vecs` and `basis_cell` can use different internal types to store coordinates.
    However, when the lattice is constructed, they are promoted to the single type.
    
    !!! warning
        You should not mix dimensionful and dimensionless types. The promotion would lead to an error in this case. This is made intentionally.

    

### Convenient constructors

If the variable `basis_cell` is omitted, it is assumed that basis cell is trivial, i.e. consisting of a single node.
If `primitive_vecs` is omitted as well, hypercubic lattice is constructed. Instead of basis, one can specify the lattice spacing in this case:
```julia
RegularLattice(lattice_dims::NTuple{D,Int}[, a::Number = 1]; label = :cubic, periodic = true)
```

## Basis Cells and Indexing

There are three types of basis cells: `HomogeneousCell`, `TrivialCell`, `InhomogeneousCell`.

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

 `TrivialCell` is used by default when no basis cell is specified. It corresponds to a basis cell with single node.

For consistency of interface, `TrivialCell` behaves like a `HomogeneousCell` with single node, which has zero coordinates.
One can even index into it:
```julia
getindex(::TrivialCell{D,T}, 1) = zero(SVector{D,T})
```

### `InhomogeneousCell`

This type is useful if one needs to distinguish between the several groups of nodes.

For example, one can consider a crystal consisting of several types of nuclei, let's say, "A" and "B". Then, if one needs to get the coordinate of the ``i``-th nuclei of type "B" inside the basis cell, one calls
```julia
cell[i, 2]
```
Generally, if one needs to access the coordinate of `ic`-th node inside `ig`-th group, it is done by
```julia
cell[ic, ig]
```
!!! note
	If one does not care about the groups, one can index into `InhomogeneousCell` as if it was a `HomogeneousCell`:
	```julia
	cell[ic]
	```
	This works with lattice indexing as well.
 
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
!!! note
	One can always index into lattice as if it has a `HomogeneousCell` basis cell, i.e., using the default style for lattices with `HomogeneousCell` basis cell.

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
!!! note
	With alternative indexing, one can again use the style for lattices with `HomogeneousCell` basis cell for lattices with other types of basis cell. 

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
The format of the indices `I1` and `I2` depends on particular type of the collection (they should correspond to the default style of index). You can find default style of indexing for basis cells in [Basis Cells and Indexing](@ref) section. The default styles for lattices are listed in subsection [Default style](@ref)


!!! note
    If the index in default style is multicomponent, it is passed into `relative_coordinate` as a Tuple. Single `Int` or single `CartesianIndex{D}` are considered single-component.

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

## Iteration

The package provides `eachindex` implementation for all exported cell and lattice types.
For cells, the iteration order is as follows: first nodes inside a group, then the groups themselves (if there are any groups).
For lattices, the iteration over the basis cell indices is preceded by th iteration over lattice indices.

In addition, to that, the package provides a function to compare the indices:
```julia
takes_precedence(I1, I2)
```
This function returns `true` if index `I1` occurs before index `I2` in the iteration order. Correspondingly, it returns `false` otherwise.
