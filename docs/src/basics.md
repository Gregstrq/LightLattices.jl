# [Basics](@id manual-basics)

LightLattices separates the geometry of a collection from the physical objects
occupying its sites. It defines two families of collections:

- **Node collections**, subtypes of `AbstractNodeCollection{D,T}`, describe positions
  and their geometric structure. These include clusters of points and regular
  lattices with a repeated basis cell. See [Node Collections](@ref manual-node-collections).
- **Physical collections**, subtypes of `AbstractPhysicalCollection{D,T,ST}`, build
  on this geometry by associating species with the sites. `PhysicalCollection`
  wraps a node collection; `Subcollection` selects sites from a physical collection,
  and `CompositeCollection` combines physical collections. See
  [Physical Collections](@ref manual-physical-collections).

Here `D` is the spatial dimension, `T` is the coordinate element type, and `ST`
represents the tuple type of species in a physical collection. Species may be
isotopes, spin objects, symbols, or other user-defined values. The alias
`AbstractCollection{D,T}` covers both node and physical collections.

The `cluster` and `lattice` convenience constructors can create geometry alone or
attach species when supplied with species arguments. A `decoder` keyword converts
species labels to the desired objects; its default is `identity`.
The [Examples](@ref manual-examples) section demonstrates these constructors.

## Positions and relative positions

All collections provide `position(collection, I...)`, which returns the Cartesian
coordinates of a site. They also provide `relative_position(collection, i1, i2)`,
which returns the position of the first site relative to the second.

The index format reflects the underlying structure. A cluster can use a site
index and a group index; a lattice can additionally use a `CartesianIndex` to
identify a basis cell. For `relative_position`, each multicomponent index is
passed as a tuple. See [Basis Cells and Indexing](@ref) and [Lattice Indexing](@ref)
for the node-index conventions inherited by physical wrappers.

For free boundaries, relative positions are coordinate differences. For periodic
lattices, `relative_position` applies the underlying lattice's periodic-boundary
rule. See [Lattices with periodic boundaries](@ref) for its definition, and
[Physical Collections](@ref manual-physical-collections) for how subcollections
and composites use their parents' geometry.

## Species and indexing

Physical collections additionally provide `species(collection, I...)`, returning
the species at the indexed site. `position` and `species` extend the corresponding
functions from AtomsBase.

The meaning of `getindex`, written as `collection[I...]`, depends on the collection:

| Collection | Result of `collection[I...]` |
|:-----------|:----------------------------|
| Node collection | `position(collection, I...)` |
| Physical collection | `(position(collection, I...), species(collection, I...))` |

Use `position` when code should work with either family and needs only geometry.
Use `species` when it also needs the physical object associated with a site.

## [Group access and iteration](@id basics-iteration)

Collections organize their sites into groups. In a physical collection, each group
corresponds to a separate species entry; a node collection retains the grouping without storing species.

Collections consisting of a single group are referred to as homogeneous, while collections with multiple groups are referred to as inhomogeneous. By default, indexing into inhomogeneous collections requires a group index, while for homogeneous ones it may be omitted.

For the ease of dispatch, collections can be distinguished by a trait
```julia
struct IsHomogeneous{B} end
```
where `B` is either `true` or `false`.
To compute the trait, use
```julia
is_homogeneous(col::AbstractCollection)
```
!!! note
    Groups are supposed to be in one-to-one correspondence with the species types.
    However, in principle, one can have several groups with the same type of species.

Both families provide:

- `length(collection)`: the total number of sites.
- `num_of_groups(collection)`: the number of groups.
- `group_species(collection, ig)`: species corresponding to the group `ig`.
- `group_size(collection, ig)`: the number of sites in group `ig`.
- `eachindex(collection)`: an iterator over indices for the entire collection.
- `group_iterator(collection, ig)`: an iterator over indices for group `ig`.

Physical collections also provide `group_species(collection, ig)`, which returns
the species for a group. Unlike `species`, it takes a group index rather than a site index.

Use the indices returned by an iterator directly with `position`, `species`, or
`getindex`. For example, given a physical collection `collection` and group `ig`:

```julia
for i in group_iterator(collection, ig)
    pos = position(collection, i...)
    sp = group_species(collection, ig)

    ...do_some_stuff...
end
```
