# LightLattices.jl

The package provides a convenient interface to work with Lattices with arbitrary unit cells.


 For the exported types of unit cells and lattices, it defines the array interface which allows to access the coordinate of specific node by its index. In addition to that, it provides a function `relative_coordinate` whih allows to calculate the shortest vector connecting the two nodes.

[![Build status (Github Actions)](https://github.com/Gregstrq/LightLattices.jl/workflows/CI/badge.svg)](https://github.com/Gregstrq/LightLattices.jl/actions)
[![codecov.io](http://codecov.io/github/Gregstrq/LightLattices.jl/coverage.svg?branch=main)](http://codecov.io/github/Gregstrq/LightLattices.jl?branch=main)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://Gregstrq.github.io/LightLattices.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://Gregstrq.github.io/LightLattices.jl/dev)

## Overview

The package exports the type `RegularLattice{D,T}` and several types used to describe the unit cell of the lattice. All the exported types are subtypes of the abstract type `AbstractNodeCollection{D,T}`. Here, `D` refers to the dimensionality of space (number of coordinates), `T` refers to the type used to store the coordinates. For all the exported subtypes, the package defines the array interface
```julia
node_collection[I]
```
which allows to access the coordinate of the `I`-th node of the collection.
In addition to that, the package provides the function `relative_coordinate`:
```julia
relative_coordinate(node_collection::AbstractNodeCollection, I1, I2)
```
which returns the vector connecting the `I2`-th node with the `I1`-th node.
In the case of `RegularLattice`-s with periodic boundary conditions, `relative_coordinate` returns the shortest connecting vector.
(Actually, in the case of complex unit cell, there can be several "shortest" vectors. The problem is resolved by a simple heuristic, described in the docs).

There are three available types to describe the unit cell: `HomogeneousCell`, `TrivialCell` and `InhomogeneousCell`.
`HomogeneousCell` refers to a homogeneous collection of nodes. `TrivialCell` behaves like `HomogeneousCell` with single node at the origin (zero coordinates). Finally, `InhomogeneousCell` is useful in the situation where one need to distinguish between several groups of nodes in the unit cell. For example, we can have several groupes of nodes corresponding to the different types of nuclei which occupy these nodes.



## Examples

### Chain
Here we construct a periodic chain with ``11`` nodes. The separation between nodes is ``1`` by default.
```
using LightLattices

chain = RegularLattice((11,); label=:chain)
```

### Square Lattice
Now, let us construct a square ``11\times11`` lattice with the size of the square equal to ``2``.
```
using LightLattices

square_lattice = RegularLattice((11,11), 2; label = :square)
```

### Cubic Lattice
For the cubic lattice example, let us draw inspiration from the real world.
The Fluorine nuclei in ``CaF_2`` consitute a cubic lattice with lattice parameter ``a=2.725\AA``.
Let us construct fluorine sublattice of size ``11\times11\times11`` with free boundary conditions:
```
using LightLattices, Unitful

fluorine_sublattice = RegularLattice((11,11,11), 2.725u"Å"; label=:cubic, periodic=false)
```

### Diamond lattice with homogeneous unit cell.
The lattice of diamond is face-centered cubic with a unit cell consisting of two nodes.
Let us take the size of cube equal to `1`. The following creates diamond lattice with ``11x11x11`` unit cells with periodic boundary conditions:
```
using LightLattice

fcc_basis = 0.5*hcat([0,1,1],[1,1,0],[1,0,1]) |> SMatrix{3,3}

diamond_cell = HomogeneousCell([[0.0,0.0,0.0], [0.25,0.25,0.25]]; label = :diamond)
dimond_lattice = RegularLattice((11,11,11), diamond_basis, diamond_cell; label=:fcc)
```
Here, `HomogeneousCell` constructor takes the vector of coordinates of the nodes.
Coordinates can be expressed as `Vector`-s, `SVector`-s or `NTuple`-s. Under the hood, all coordinates are converted to `SVector`-s.

### Magnetic sublattice of fluorapatite with inhomogeneous unit cell.
This example is going to be quite elaborated, but it illustrates the application of additional type of unit cell: `InhomogeneousCell`.
Fluorapatite has the hexagonal structure with the space group ``P6_3/m``. The three lattice parameters are ``a=b=9.462\AA`` and ``c=6.849\AA``.
The ``\bf{c}``-axis is orthogonal to ``(\bf{a}, \bf[b})`` plane and the angle between ``\bf{a}`` and ``\bf{b}`` is ``120\circ``.
Thus, we can construct the basis as
```
using Unitful

const a = 9.462u"Å"
const c = 6.849u"Å"

fbasis = hcat(a*[0.5, 0.5*sqrt(3), 0.0],
              a*[0.5, -0.5*sqrt(3), 0.0],
              c*[0.0, 0.0, 1.0]
             ) |> SMatrix{3,3}
```
The unit cell for magnetically active sublattice of fluorapatite contains two F nuceli at positions
```math
[0.0,0.0,0.25],\quad [0.0,0.0,0.75]
```
and six P nuclei at positions
```math
\begin{array}{lll}
[x,y,0.25], & [1-y,x-y,0.25], & [y-x,1-x,0.25]\\
[1-x,1-y,0.75], & [y, y-x,0.75], & [x-y, x, 0.75],
\end{array}
```
where ``x=0.369`` and ``y=0.3985``. All the coordinates here are relative to the basis `fbasis`.

Since we have two different types of nuclei, it is a good idea somehow to separate two groups of nuclei in the unit cell. In this case, one should use `InhomogeneousCell`.
```
const x = 0.369
const y = 0.3985

cell_vectors_raw1 = [[0.0, 0.0, 0.25], [0.0, 0.0, 0.75]]
cell_vectors_raw2 = [[x, y, 0.25], [-y, x-y, 0.25], [y-x, -x, 0.25],
                  [-x, -y, 0.75], [y, y-x, 0.75], [x-y, x, 0.75]]

fcell = InhomogeneousCell([fbasis*vec for vec in cell_vectors_raw1], [fbasis*vec for vec in cell_vectors_raw2]; label = :fluorapatite_magnetic)
```
Finally, we can construct the lattice. Let us choose the size of ``11\times11\times11`` unit cells and periodic boundary conditions.
```
fluorapatite_magnetic_sublattice = RegularLattice((11,11,11), fbasis, fcell; label = :hexagonal)
```
