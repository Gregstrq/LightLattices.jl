# [Physical Collections](@id manual-physical-collections)

Physical collections associate species with positions. `PhysicalCollection`,
`Subcollection`, and `CompositeCollection` are all subtypes of `AbstractPhysicalCollection`.
Species can be isotopes, spin objects, symbols, or other user-defined values.

## [PhysicalCollection: geometry and species](@id physical-collection-wrapper)

A `PhysicalCollection` stores an underlying node collection in `nodes` and a tuple
of species in `species`. Each node group has one corresponding species entry.
The [Node Collections](@ref manual-node-collections) section describes the cells,
lattices, indexing conventions, and boundary conditions of this underlying object.

You can construct the geometry first and attach species afterwards:

```julia
using LightLattices, StaticArrays, UnitfulGauss, IsotopeTable

nodes = HomogeneousCell([[0.0, 0.0, 0.0], [0.25, 0.25, 0.25]], :diamond_unit_cell)
carbon_pair = PhysicalCollection(nodes, isotopes(:C13))

position(carbon_pair, 2) == nodes[2]                  # true
species(carbon_pair, 2) == isotopes(:C13)             # true
carbon_pair[2] == (nodes[2], isotopes(:C13))           # true
carbon_pair.nodes === nodes                         # true
```

For several groups, pass a tuple of species in the same order as the node groups.
The number of species entries must match `num_of_groups(nodes)`.
The `cluster` and `lattice` helpers illustrated in [Examples](@ref manual-examples)
construct the node collection and its physical wrapper together.

`position`, `eachindex`, `group_iterator`, and `relative_position` delegate to the
underlying geometry. Indexing a node collection returns coordinates; indexing a
physical collection returns `(position, species)`.

## [Subcollection](@id physical-subcollections)

A `Subcollection` functions as a view into a `PhysicalCollection`.
The sites to keep can be specified by pairs `parent_group => indices`, where `indices` are the indices to keep from group `parent_group`. The groups that are not specified are dropped from the `Subcollection`
!!! note
    Each separate index from `indices` should not include the group index.
Alternatively, one can just specify single `indices` set without the group index, and it will work like `ig=>indices for ig=1:num_of_groups`.

### Explicit indices: main diagonal of a cube

```julia
using LightLattices, UnitfulGauss, IsotopeTable

fluorine = lattice((11,11,11), 2.725u"Å", :F19;
    periodic=false, decoder=isotopes)
diagonal_indices = [(CartesianIndex(i,i,i), 1) for i in 1:11]
diagonal = view(fluorine, 1 => diagonal_indices)

length(diagonal) == 11                              # true
position(diagonal, 2) == position(fluorine, CartesianIndex(2,2,2)) # true
group_species(diagonal, 1) == isotopes(:F19)          # true
```
Here, each index contains the basis cell index within Bravais lattice
and the cell-site index within that basis cell, following [Default style](@ref).
The subcollection itself always supports `(site, group)` indexing; for a homogeneous
subcollection such as `diagonal`, the group may be omitted.

### Structured selection: a fluorapatite column

For a lattice parent, a selection may instead contain
`(CartesianIndices, cell_indices)`. This selects the given cell sites in every
specified lattice cell without explicitly listing every site.
!!! note
    If all cell indices for a given group are to be retained, one can replace by `:`, or just specify `CartesianIndices` not wrapped in a tuple.

Run the fluorapatite construction in [Examples](@ref manual-examples) first to define
`fluor_magn_sublattice` and `fpvecs`. Now, to select a column parallel to its third primitive
vector, retaining all $^{19}F$ site and the first three $^{31}P$ sites per cell, one can run
```julia
column_cells = CartesianIndices((6:6, 6:6, 1:11))
column = view(fluor_magn_sublattice,
    1 => column_cells,
    2 => (column_cells, 1:3))

group_size(column, 1) == 22                         # true
group_size(column, 2) == 33                         # true
position(column, 33, 2) ==
    position(column, CartesianIndex(1,1,11), 3, 2) == 
    position(fluor_magn_sublattice, CartesianIndex(6,6,11), 3, 2) # true
```
Within a group, lattice cells vary before cell-site indices. Thus $^{31}P$ site 33
is the third retained basis site in the last cell. This site can alternatively be accessed as
`position(column, CartesianIndex(1,1,11), 3, 2)`. Here, the index is structured as `I, ic, ig`;
`I` is the index into `column_cells`, `ic` is the cell-site index and `ig` is the group index.

The parent determines relative positions, including its periodic-boundary rule:
```julia
relative_position(column, (33, 2), (1, 1)) ≈
    relative_position(fluor_magn_sublattice,
        (CartesianIndex(6,6,11), 3, 2), (CartesianIndex(6,6,1), 1, 1)) # true

relative_position(column, (33, 2), fluor_magn_sublattice,
    (CartesianIndex(6,6,1), 1, 1)) ≈
    relative_position(column, (33, 2), (1, 1))        # true
```

See [Lattices with periodic boundaries](@ref) for the underlying rule. Selecting
a column does not give it an independent periodic box.

## [CompositeCollection: combining collections](@id physical-composites)

A `CompositeCollection` combines physical collections and subcollections. Its
groups follow the component order, preserving each component's group order.
Groups with equal species are not automatically merged. Components must have
the same spatial dimension and coordinate type and use a common coordinate frame.
By default, a `CompositeCollection` is indexed by `linear_index_within_group, group_index`.

Continuing the column example, place two $^{15}N$ sites between the two $^{19}F$ sites
in the central cell (cell 6):

```julia
lower_f = position(column, CartesianIndex(1,1,6), 1, 1)
upper_f = position(column, CartesianIndex(1,1,6), 2, 1)
nitrogen_pair = cluster(:N15,
    [lower_f + fraction * (upper_f - lower_f) for fraction in (1/3, 2/3)];
    label=:nitrogen_pair, decoder=isotopes)

combined = compose(column, nitrogen_pair)
# Equivalently: combined = LightLattices.compose(column, nitrogen_pair)

num_of_groups(combined) == 3                        # true
length(combined) == 57                             # true
group_species(combined, 3) == isotopes(:N15)         # true
combined[1, 3] == nitrogen_pair[1]                   # true
relative_position(combined, (1, 3), (6, 1)) ≈
    (upper_f - lower_f) / 3                         # true
```
The combined groups are $^{19}F$, $^{31}P$, and $^{15}N$, with 22, 33, and 2 sites respectively.
The two $^{19}F$ sites used above have within-group linear indices 6 and 17, because
all 11 cells of the first basis site precede those of the second basis site.
Relative positions that
resolve to the same parent physical collection retain that parent's boundary
rule; positions from different parents are subtracted directly. A composite
collection does not introduce a shared periodic box.


See [Group access and Iteration](@ref basics-iteration) for the shared iteration interface.
