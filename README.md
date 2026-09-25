# LightLattices.jl

The package provides a convenient interface to describe a set of physical objects occupying a fixed set of points in a `D`-dimensional space.
Main focus are the Lattices with arbitrary reapeated basis cells, but one can also define a cluster of objects without a regular structure.


 For the supported types of clusters and lattices, the package partially realizes the interface of [AtomsBase.jl](https://github.com/JuliaMolSim/AtomsBase.jl): The cartesian coordinates of a node and the kind of species occupying it can be accessed using the `position` and `species` functions respectively. At the same time, `getindex` returns the `Tuple` of both position and species. Finally, 

In addition to that, the shortest vector connecting the two nodes can be obtained using the `relative_position` function.
There are also convenience functions that allow to iterate over the group of nodes occupied by the same species and index into this group.

[![Build status (Github Actions)](https://github.com/Gregstrq/LightLattices.jl/workflows/CI/badge.svg)](https://github.com/Gregstrq/LightLattices.jl/actions)
[![codecov.io](http://codecov.io/github/Gregstrq/LightLattices.jl/coverage.svg?branch=main)](http://codecov.io/github/Gregstrq/LightLattices.jl?branch=main)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://Gregstrq.github.io/LightLattices.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://Gregstrq.github.io/LightLattices.jl/dev)

## Table of contents

- [Constructing physical collections](#constructing-physical-collections)
  - [Methane molecule](#methane-molecule)
  - [Cubic lattice with a trivial basis cell](#cubic-lattice-with-a-trivial-basis-cell)
  - [Diamond lattice with homogeneous basis cell](#diamond-lattice-with-homogeneous-basis-cell)
  - [Magnetic sublattice of fluorapatite with inhomogeneous basis cell](#magnetic-sublattice-of-fluorapatite-with-inhomogeneous-basis-cell)
  - [Spin chain or spin Square Lattice](#spin-chain-or-spin-square-lattice)
- [Indexing and iteration](#indexing-and-iteration)
  - [Indexing](#indexing)
  - [Iteration utils](#iteration-utils)

## Constructing physical collections

### Methane molecule.
Four Hydrogen atoms of Methane form the vertices of a regular tetrahedron, whose center is occupied by a single Carbon atom.
We can create it using a `cluster` convenience constructor.
```julia
using LightLattices, UnitfulGauss, IsotopeTable

a = 1.09ug"Å"
h_vecs = [[1,1,1],[1,-1,-1],[-1,1,-1],[-1,-1,1]].|>x->x*a/sqrt(3)

meth_mol = cluster(:C12=>zeros(3)ug"Å", :H1=>h_vecs; decoder=isotopes, label=:methane)
```
We can pass different groups of species as `species_label=>set_of_positions`.
Then, the labels are decoded into species by applying the `decoder` function: ``species = decoder(species_label)``.
In this example, we supplement `isotopes` function from [IsotopeTable.jl](https://github.com/Gregstrq/IsotopeTable.jl), so species would be an `Isotope` struct containing all the isotope information.

In principle, species and their labels can be anything the user wants.
The behavior can be changed in a very flexible manner by supplementing a custom `decoder` function.

By default, `decoder=identity`, so, in this example, we could have passed the species directly:
```julia
using LightLattices, UnitfulGauss, IsotopeTable

a = 1.09ug"Å"
C12, H1 = isotopes(:C12), isotopes(:H1)
h_vecs = [[1,1,1],[1,-1,-1],[-1,1,-1],[-1,-1,1]].|>x->x*a/sqrt(3)

meth_mol = cluster(C12=>zeros(3)ug"Å", H1=>h_vecs; label=:methane)
```


### Cubic lattice with a trivial basis cell.

The Fluorine nuclei in ``CaF2`` consitute a cubic lattice with lattice parameter ``a=2.725 Å``.
Let us construct fluorine sublattice of size ``11x11x11`` with free boundary conditions:
```julia
using LightLattices, UnitfulGauss, IsotopeTable

fluorine_sublattice = lattice((11,11,11), 2.725u"Å", isotopes(:F19); label=:cubic, periodic=false)
```

### Diamond lattice with homogeneous basis cell.

The lattice of carbon diamond is face-centered cubic with a lattice parameter `a=1.54ug"Å"` and a basis cell consisting of two nodes.
The following creates diamond lattice with ``11x11x11`` basis cells with periodic boundary conditions:
```julia
using LightLattices

a = 1.54ug"Å"
fcc_pvecs = 0.5a*hcat([0,1,1],[1,1,0],[1,0,1]) |> SMatrix{3,3}
cell_vecs = [zeros(3), ones(3)/4].*a

diamond_lattice = lattice((11,11,11), fcc_pvecs, isotopes(:C12)=>cell_vecs; label=:fcc)
```

### Magnetic sublattice of fluorapatite with inhomogeneous basis cell.

Fluorapatite has the hexagonal structure with the space group ``P6_3/m``. The three lattice parameters are ``a=b=9.462 Å`` and ``c=6.849 Å``.
The **c**-axis is orthogonal to (**a**, **b**) plane and the angle between **a** and **b** is ``120°``.
Thus, we can construct the matrix of primitive vectors as
```julia
using LightLattices, UnitfulGauss

a = 9.462ug"Å"
c = 6.849ug"Å"

fpvecs = hcat(a*[0.5, 0.5*sqrt(3), 0.0],
              a*[0.5, -0.5*sqrt(3), 0.0],
              c*[0.0, 0.0, 1.0]
             ) |> SMatrix{3,3}
```
The basis cell for magnetically active sublattice of fluorapatite contains two F nuceli at positions
```math
[0.0,0.0,0.25],    [0.0,0.0,0.75]
```
and six P nuclei at positions
```math
[x,y,0.25],        [1-y,x-y,0.25],    [y-x,1-x,0.25],
[1-x,1-y,0.75],    [y, y-x,0.75],     [x-y, x, 0.75],
```
where ``x=0.369`` and ``y=0.3985``. All the coordinates here are relative to the set of  primitive vectors `fpvecs`.
```julia
x = 0.369
y = 0.3985

cell_vectors1 = [[0.0, 0.0, 0.25], [0.0, 0.0, 0.75]] .|> x->fpvecs*x
cell_vectors2 = [[x, y, 0.25], [-y, x-y, 0.25], [y-x, -x, 0.25],
                  [-x, -y, 0.75], [y, y-x, 0.75], [x-y, x, 0.75]] .|> x->fpvecs*x
cell_vectorss = [cell_vectors1, cell_vectors2]
```
Finally, we can construct the lattice. Let us choose the size of ``11x11x11`` basis cells and periodic boundary conditions.
```julia
import IsotopeTable: isotopes

fluor_magn_sublattice = lattice((11,11,11), fpvecs, :F19=>cell_vectorss[1], :P31=>cell_vectorss[2]; label = :hexagonal, decoder=isotopes)
```

### Spin chain or spin Square Lattice
Let's say we want to create a spin lattice.
We can describe a spin-`S` with gyromagnetic ratio `γ' by the type
```julia
struct Spin{S, T}
    γ::T
    function Spin(S::Int, γ::T=1) where T<:Number
        @assert S>0
        new{S,T}(γ)
    end
    function Spin(S::Rational, γ::T=1) where T<:Number
        @assert S>0
        @assert S.den==2 || S.den==1
        new{S,T}(γ)
    end
end
```
We can create a chain of 12 spins-1/2 with lattice constant `1` and periodic boundary conditions by calling:
```julia
using LightLattices

chain = lattice((12,), 1, Spin(1//2); label=chain, periodic=true)
```
The following constructs a square lattice 12×12 of spins-1 with lattice constant `2` and free boundary conditions:
```julia
using LightLattices

square = lattice((12,12), 2, 1; decoder=Spin, periodic=false)
```

## Indexing and iteration

### Indexing

To maintain compatibility with [AtomsBase.jl](https://github.com/JuliaMolSim/AtomsBase.jl), linear indexing is supported, however, it is not the default indexing style.

Default indexing into collections exposes the groups corresponding to the different kinds of species, as well as the internal structure of the collections.
For concretness, let us look at the example of [Magnetic sublattice of fluorapatite](#magnetic-sublattice-of-fluorapatite-with-inhomogeneous-basis-cell).
Let's say, we want to focus on a Phosphorus atom with label `4` in the unit cell `(2,5,1)`. This can be done by
```julia
position(fluor_magn_sublattice, CartesianIndex(2,5,1), 4, 2) ≈ fpvecs*SVector(2,5,1) + cell_vectorss[2][4]
species(fluor_magn_sublattice, CartesianIndex(2,5,1), 4, 2) == isotopes(:P31)
fluor_magn_sublattice[CartesianIndex(2,5,1), 4, 2] ==
        (position(fluor_magn_sublattice, CartesianIndex(2,5,1), 4, 2), isotopes(:P31))
```
The index looks like `I, ic, ig`, where `ig` is the index of the group (species), `ic` is the index within the basis cell of the lattice and `I` is the index of the basis cell within the lattice.

For clusters, there is no lattice structure, and the index looks like `ic, ig`.

### Iteration utils

In some situations, it might be convenient to focus on a single kind of species. In this case, the following functions could be useful.
- `group_iterator(collection, ig)` returns an iterator over indices of a group `ig`;
- `group_size(collection, ig)` returns the total number of nodes in the group;
- `group_species(collection, ig)` gets the species by the group index `ig`;
- `num_of_groups(collection)` gives the total number of different groups (species).
