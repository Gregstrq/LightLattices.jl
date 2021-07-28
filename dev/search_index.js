var documenterSearchIndex = {"docs":
[{"location":"examples/#Examples","page":"Examples","title":"Examples","text":"","category":"section"},{"location":"examples/#Chain","page":"Examples","title":"Chain","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"Here we construct a periodic chain with 11 nodes. The separation between nodes is 1 by default.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"using LightLattices\n\nchain = RegularLattice((11,); label=:chain)","category":"page"},{"location":"examples/#Square-Lattice","page":"Examples","title":"Square Lattice","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"Now, let us construct a square 11times11 lattice with the size of the square equal to 2.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"using LightLattices\n\nsquare_lattice = RegularLattice((11,11), 2; label = :square)","category":"page"},{"location":"examples/#Cubic-Lattice","page":"Examples","title":"Cubic Lattice","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"For the cubic lattice example, let us draw inspiration from the real world. The Fluorine nuclei in CaF_2 consitute a cubic lattice with lattice parameter a=2725mathring A. Let us construct fluorine sublattice of size 11times11times11 with free boundary conditions:","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"using LightLattices, Unitful\n\nfluorine_sublattice = RegularLattice((11,11,11), 2.725u\"Å\"; label=:cubic, periodic=false)","category":"page"},{"location":"examples/#Diamond-lattice-with-homogeneous-unit-cell.","page":"Examples","title":"Diamond lattice with homogeneous unit cell.","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"The lattice of diamond is face-centered cubic with a unit cell consisting of two nodes. Let us take the size of cube equal to 1. The following creates diamond lattice with 11times11times11 unit cells with periodic boundary conditions:","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"using LightLattice\n\nfcc_basis = 0.5*hcat([0,1,1],[1,1,0],[1,0,1]) |> SMatrix{3,3}\n\ndiamond_cell = HomogeneousCell([[0.0,0.0,0.0], [0.25,0.25,0.25]]; label = :diamond)\ndimond_lattice = RegularLattice((11,11,11), fcc_basis, diamond_cell; label=:fcc)","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"Here, HomogeneousCell constructor takes the vector of coordinates of the nodes. Coordinates can be expressed as Vector-s, SVector-s or NTuple-s. Under the hood, all coordinates are converted to SVector-s.","category":"page"},{"location":"examples/#Magnetic-sublattice-of-fluorapatite-with-inhomogeneous-unit-cell.","page":"Examples","title":"Magnetic sublattice of fluorapatite with inhomogeneous unit cell.","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"This example is going to be quite elaborated, but it illustrates the application of additional type of unit cell: InhomogeneousCell. Fluorapatite has the hexagonal structure with the space group P6_3m. The three lattice parameters are a=b=9462mathring A and c=6849mathring A. The bfc-axis is orthogonal to (bfa bfb) plane and the angle between bfa and bfb is 120^circ. Thus, we can construct the basis as","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"using Unitful\n\nconst a = 9.462u\"Å\"\nconst c = 6.849u\"Å\"\n\nfbasis = hcat(a*[0.5, 0.5*sqrt(3), 0.0],\n              a*[0.5, -0.5*sqrt(3), 0.0],\n              c*[0.0, 0.0, 1.0]\n             ) |> SMatrix{3,3}","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"The unit cell for magnetically active sublattice of fluorapatite contains two F nuclei at positions","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"0000025quad 0000075","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"and six P nuclei at positions","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"beginarraylll\nxy025  1-yx-y025  y-x1-x025\n1-x1-y075  y y-x075  x-y x 075\nendarray","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"where x=0369 and y=03985. All the coordinates here are relative to the basis fbasis.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"Since we have two different types of nuclei, it is a good idea somehow to separate these two groups in the unit cell. In this case, one should use InhomogeneousCell.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"const x = 0.369\nconst y = 0.3985\n\ncell_vectors_raw1 = [[0.0, 0.0, 0.25], [0.0, 0.0, 0.75]]\ncell_vectors_raw2 = [[x, y, 0.25], [-y, x-y, 0.25], [y-x, -x, 0.25],\n                  [-x, -y, 0.75], [y, y-x, 0.75], [x-y, x, 0.75]]\n\nfcell = InhomogeneousCell([fbasis*vec for vec in cell_vectors_raw1], [fbasis*vec for vec in cell_vectors_raw2]; label = :fluorapatite_magnetic)","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"Finally, we can construct the lattice. Let us choose the size of 11times11times11 unit cells and periodic boundary conditions.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"fluorapatite_magnetic_sublattice = RegularLattice((11,11,11), fbasis, fcell; label = :hexagonal)","category":"page"},{"location":"list/#Index","page":"Index","title":"Index","text":"","category":"section"},{"location":"list/","page":"Index","title":"Index","text":"Modules = [LightLattices]","category":"page"},{"location":"list/#LightLattices.AbstractCell","page":"Index","title":"LightLattices.AbstractCell","text":"abstract type AbstractCell{D, T} <: AbstractNodeCollection{D, T}\n\nAbstract unordered collection of nodes in D-dimensional space. Type T is used to represent coordinates.\n\n\n\n\n\n","category":"type"},{"location":"list/#LightLattices.AbstractLattice","page":"Index","title":"LightLattices.AbstractLattice","text":"abstract type AbstractLattice{D, T, PB} <: AbstractNodeCollection{D, T}\n\nThe supertype for Lattices in D-dimensional space. Type T is used to represent coordinates. The boundary conditions can be either periodic (PB=true) or free (PB=false).\n\n\n\n\n\n","category":"type"},{"location":"list/#LightLattices.AbstractNodeCollection","page":"Index","title":"LightLattices.AbstractNodeCollection","text":"abstract type AbstractNodeCollection{D, T}\n\nAbstract collection of nodes in D-dimensional space. Type T is used to represent coordinates.\n\n\n\n\n\n","category":"type"},{"location":"list/#LightLattices.HomogeneousCell","page":"Index","title":"LightLattices.HomogeneousCell","text":"struct HomogeneousCell{D, T, L<:Union{Nothing, Symbol}} <: AbstractCell{D, T}\n\ncell_vectors::Array{StaticArrays.SVector{D, T}, 1} where {D, T}\nCoordinates of nodes.\n\nlabel::Union{Nothing, Symbol}\nLabel of the cell.\n\nUnodered homogeneous collection of nodes in D-dimensional space.\n\n\n\n\n\n","category":"type"},{"location":"list/#LightLattices.InhomogeneousCell","page":"Index","title":"LightLattices.InhomogeneousCell","text":"struct InhomogeneousCell{D, T, N, L<:Union{Nothing, Symbol}, T′} <: AbstractCell{D, T}\n\ncell_vectors::RecursiveArrayTools.ArrayPartition{T′, Tuple{Vararg{Array{StaticArrays.SVector{D, T}, 1}, N}}} where {D, T, N, T′}\nCoordinates of nodes.\n\ngroup_sizes::Tuple{Vararg{Int64, N}} where N\nSizes of the homogeneous groups inside inhomogeneous cell.\n\nlabel::Union{Nothing, Symbol}\nLabel of the cell.\n\nUnordered inhomogeneous collection of nodes in D-dimensional space. This type allows one to partition the nodes of the cell into several groups. Different groups of nodes may correspond to the different classes of physical objects occupying these nodes.\n\n\n\n\n\n","category":"type"},{"location":"list/#LightLattices.RegularLattice","page":"Index","title":"LightLattices.RegularLattice","text":"struct RegularLattice{D, T, PB, CT, L<:Union{Nothing, Symbol}} <: AbstractLattice{D, T, PB}\n\nlattice_dims::Tuple{Vararg{Int64, D}} where D\nThe number of basis cells along each of the basis directions.\n\nbasis::StaticArrays.SMatrix{D, D, T, L} where {D, T, L}\nCoordinates of the basis vectors of the underlying Bravais lattice. basis[:, i] gives the i-th basis vector.\n\nunit_cell::Any\nUnit cell of the lattice.\n\nlabel::Union{Nothing, Symbol}\nLabel of the Lattice.\n\nnum_of_cells::Int64\nTotal number of cells.\n\nnum_of_nodes::Int64\nTotal number of nodes.\n\ncentral_cell::CartesianIndex{D} where D\nCartesian index of the central cell (in the case of even length among of dimensions it is an approximation).\n\nThis type describes a regular arrangment of nodes in D-dimensional space with boundary condition PB (PB=true for periodic boundary conditions, PB=false for free periodic boundary conditions). A general lattice consists of identicall cells (combinations of nodes) arranged as a Bravais lattice.\n\n\n\n\n\n","category":"type"},{"location":"list/#LightLattices.RegularLattice-Union{Tuple{D}, Tuple{Tuple{Vararg{Int64, D}}, StaticArrays.SMatrix{D, D, T, L} where {T, L}, AbstractCell{D, T} where T}} where D","page":"Index","title":"LightLattices.RegularLattice","text":"RegularLattice(lattice_dims::NTuple{D, Int}, basis::SMatrix{D,D}, unit_cell::AbstractCell{D}; label=nothing, periodic=true)\n\nConvenient constructor which allows to specify the label and boundary condition as keyword arguments.\n\n\n\n\n\n","category":"method"},{"location":"list/#LightLattices.RegularLattice-Union{Tuple{Tuple{Vararg{Int64, D}}}, Tuple{T}, Tuple{D}, Tuple{Tuple{Vararg{Int64, D}}, T}} where {D, T<:Number}","page":"Index","title":"LightLattices.RegularLattice","text":"RegularLattice(lattice_dims::NTuple{D, Int}, a::T=1; label=:cubic, periodic=true)\n\nConstructs hypercubic lattice with lattice parameter a and trivial unit cell.\n\n\n\n\n\n","category":"method"},{"location":"list/#LightLattices.TrivialCell","page":"Index","title":"LightLattices.TrivialCell","text":"struct TrivialCell{D, T} <: AbstractCell{D, T}\n\nTrivial cell consisting of one node at the origin of D-dimensional coordinate system. The type T is used to represent coordinates.\n\n\n\n\n\n","category":"type"},{"location":"list/#Base.getindex-Tuple{Union{HomogeneousCell, InhomogeneousCell}, Int64}","page":"Index","title":"Base.getindex","text":"getindex(cell::AbstractCell, i...)\n\nReturns the coordinate of the i-th node of the cell. In the case of InhomogeneousCell we can use double index i = i1, i2 to access i_1-th node of i_2-th group.\n\n\n\n\n\n","category":"method"},{"location":"list/#Base.length-Tuple{AbstractCell}","page":"Index","title":"Base.length","text":"length(cell::AbstractCell)\n\nReturns the number of the nodes in the cell.\n\n\n\n\n\n","category":"method"},{"location":"list/#LightLattices.group_size-Tuple{Union{HomogeneousCell, TrivialCell}, Int64}","page":"Index","title":"LightLattices.group_size","text":"group_size(cell::Union{HomogeneousCell, TrivialCell}, ig::Int64) -> Int64\n\n\nReturns the size of the ig-th homogeneous group inside a cell.\n\n\n\n\n\n","category":"method"},{"location":"list/#LightLattices.num_of_groups-Tuple{RegularLattice}","page":"Index","title":"LightLattices.num_of_groups","text":"num_of_groups(lattice::RegularLattice) -> Any\n\n\nReturn the number of lattice separate groups.\n\n\n\n\n\n","category":"method"},{"location":"list/#LightLattices.num_of_groups-Tuple{Union{HomogeneousCell, TrivialCell}}","page":"Index","title":"LightLattices.num_of_groups","text":"num_of_groups(cell::Union{HomogeneousCell, TrivialCell}) -> Int64\n\n\nReturn the number of separate groups in a cell.\n\n\n\n\n\n","category":"method"},{"location":"list/#LightLattices.relative_coordinate-Tuple{AbstractNodeCollection, Any, Any}","page":"Index","title":"LightLattices.relative_coordinate","text":"relative_coordinate(collection::AbstractNodeCollection, i1, i2) -> Any\n\n\nReturns the coordinate of node with index i1 relative to coordinate of the node with index i2.\n\n\n\n\n\n","category":"method"},{"location":"list/#LightLattices.relative_coordinate-Union{Tuple{TI}, Tuple{T}, Tuple{D}, Tuple{RegularLattice{D, T, true, var\"#s10\", L} where {var\"#s10\"<:TrivialCell, L<:Union{Nothing, Symbol}}, TI, TI}} where {D, T, TI<:CartesianIndex{D}}","page":"Index","title":"LightLattices.relative_coordinate","text":"relative_coordinate(lattice::RegularLattice{D, T, true, var\"#s10\", L} where {var\"#s10\"<:TrivialCell, L<:Union{Nothing, Symbol}}, I1::TI<:CartesianIndex{D}, I2::TI<:CartesianIndex{D}) -> Any\n\n\nFor periodic lattice, the \"shortest\" relative coordinate is calculated instead.\n\nFor, that the following heuristic is used. Cartesian indices of the two nodes are shifted by the same amount, so that the cartesian index of the second node corresponds to the central cell of the lattice. Then, the cartesian index of the first node is translated back inside the lattice. The relative coordinate is computed using the resulting indices.\n\nThis heuristic guarantees that relative_coordinate(lattice, I1, I2) == -relative_coordinate(lattice, I2, I1).\n\n\n\n\n\n","category":"method"},{"location":"list/#LightLattices.switch_coord_type-Union{Tuple{T′}, Tuple{T}, Tuple{D}, Tuple{AbstractCell{D, T}, Type{T′}}} where {D, T, T′}","page":"Index","title":"LightLattices.switch_coord_type","text":"switch_coord_type(cell::AbstractCell{D, T}, ::Type{T′})\n\nConverts the type used to represent coordinates from T to T′.\n\n\n\n\n\n","category":"method"},{"location":"list/#LightLattices.takes_precedence-Union{Tuple{T}, Tuple{T, T}} where T<:Union{Int64, CartesianIndex}","page":"Index","title":"LightLattices.takes_precedence","text":"takes_precedence(i1, i2)\n\nReturns true if the index i1 occurs before i2 while iterating over a node collection.\n\n\n\n\n\n","category":"method"},{"location":"manual/#Manual","page":"Manual","title":"Manual","text":"","category":"section"},{"location":"manual/#Type-Hierarchy","page":"Manual","title":"Type Hierarchy","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"All the types exported by the package are the subtypes of","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"abstract type AbstractNodeCollection{D,T} end","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"This type describes an arbitrary collection of nodes in D-dimensional space. The coordinates of the nodes are stored internally as instances of SVector{D,T}. Hence, parameter T describes the type used to store the coordinates.","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"All the unit-cell types are subtypes of abstract type AbstractCell.","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"abstract type AbstractCell{D,T} <: AbstractNodeCollection{D,T} end","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"Analogously, we define the supertype for lattices:","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"abstract type AbstractLattice{D,T,PB} <: AbstractNodeCollection{D,T} end","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"The additional parameter PB can be either true for periodic boundary conditions, or false for free boundary conditions.","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"At this point there is only one subtype of AbstractLattice, which is RegularLattice. In the future, I may add additional types do describe, for example, disordered lattices with vacancies.","category":"page"},{"location":"manual/#Lattice-construction","page":"Manual","title":"Lattice construction","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"The general constructor for a regular (without disorder) lattice looks like this:","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"RegularLattice(lattice_dims::NTuple{D,Int}[, basis::SMatrix{D,D,T}, unit_cell::AbstractCell{D,T1}]; periodic = true, label::Union{Symbol,Nothing}=nothing).","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"General lattice consists of a unit cell which is translated in space by the vectors of the Bravais Lattice. Thus, the meaning of the entries is the following:","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"lattice_dims is the tuple specifying the size of the lattice along each of the basis directions.\nbasis is the matrix, which columns are the basis vectors of the underlying Bravais lattice.\nunit_cell specifies the collection of nodes which is used as the unit cell of the lattice.\nperiodic specifies the boundary conditions: true for periodic, false for free boundary conditions.\nlabel is either nothing or a Symbol; it is a label to refer to the lattice (may be useful to automatically generate the name for the computation which uses particular lattice).","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"note: Note\nThe variables basis and unit_cell can use different internal types to store coordinates. However, when the lattice is constructed, they are promoted to the single type.warning: Warning\nYou should not mix dimensionful and dimensionless types. The promotion would lead to an error in this case. This is made intentionally.","category":"page"},{"location":"manual/#Convenient-constructors","page":"Manual","title":"Convenient constructors","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"If the variable unit_cell is omitted, it is assumed that unit cell is trivial, i.e. consisting of a single node. If basis is omitted as well, hypercubic lattice is constructed. Instead of basis, one can specify the lattice spacing in this case:","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"RegularLattice(lattice_dims::NTuple{D,Int}[, a::Number = 1]; label = :cubic, periodic = true)","category":"page"},{"location":"manual/#Unit-Cells-and-Indexing","page":"Manual","title":"Unit Cells and Indexing","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"There are three types of unit cells: HomogeneousCell, TrivialCell, InhomogeneousCell.","category":"page"},{"location":"manual/#HomogeneousCell","page":"Manual","title":"HomogeneousCell","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"This type is used when there is no distinction between the nodes of the cell. The general constructor looks like","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"HomogeneousCell(node_coordinates::Vector; label::Union{Symbol,Nothing}=nothing)","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"where node_coordinates specifies the coordinates of the nodes. The coordinates can be specified either as SVectors, Vectors or NTuples of same element type and length. Under the hood, coordinates are converted to SVectors.","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"One can access the coordinate of the i-th node as","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"cell[i]","category":"page"},{"location":"manual/#TrivialCell","page":"Manual","title":"TrivialCell","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"TrivialCell is used by default when no unit cell is specified. It corresponds to a unit cell with single node.","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"For consistency of interface, TrivialCell behaves like a HomogeneousCell with single node, which has zero coordinates. One can even index into it:","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"getindex(::TrivialCell{D,T}, 1) = zero(SVector{D,T})","category":"page"},{"location":"manual/#InhomogeneousCell","page":"Manual","title":"InhomogeneousCell","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"This type is useful if one needs to distinguish between the several groups of nodes.","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"For example, one can consider a crystal consisting of several types of nuclei, let's say, \"A\" and \"B\". Then, if one needs to get the coordinate of the i-th nuclei of type \"B\" inside the unit cell, one calls","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"cell[i, 2]","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"Generally, if one needs to access the coordinate of ic-th node inside ig-th group, it is done by","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"cell[ic, ig]","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"The general constructor for the type is","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"InhomogeneousCell(group1_coordinates::Vector, group2_coordinates::Vector, other_group_coordinates...; label=nothing).","category":"page"},{"location":"manual/#Lattice-Indexing","page":"Manual","title":"Lattice Indexing","text":"","category":"section"},{"location":"manual/#Default-style","page":"Manual","title":"Default style","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"For D-dimensional lattice, the default style of indexing is","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"lattice[I::CartesianIndex{D}, Ic...]","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"Here, I is the index of the cell, and Ic... specifies the position inside that cell. To be precise,","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"in the case of TrivialCell, the default indexing is","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"lattice[I::CartesianIndex{D}]","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"in the case of HomogeneousCell, it is","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"lattice[I::CartesianIndex{D}, ic::Int]","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"in the case of InhomogeneousCell, it is","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"lattice[I::CartesianIndex{D}, ic::Int, ig::Int]","category":"page"},{"location":"manual/#Alternative-style","page":"Manual","title":"Alternative style","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"The alternative style of indexing is to splat I and Ic into single tuple. For example, we can index into 3-dimensional lattice","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"with TrivialCell as","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"lattice[x::Int, y::Int, z::Int]","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"with HomogeneousCell as","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"lattice[x::Int, y::Int, z::Int, ic::Int]","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"with InhomogeneousCell as","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"lattice[x::Int, y::Int, z::Int, ic::Int, ig::Int]","category":"page"},{"location":"manual/#Boundary-conditions","page":"Manual","title":"Boundary conditions","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"For the lattice with free boundary conditions, the boundschecking is performed both for index of the cell and the index inside the cell.","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"In the case of the lattice with periodic boundary conditions, the boundschecking is only applied to the index inside the cell. If the cell index is outside the boundaries, it is simply translated back inside the boundaries.","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"As an example, let us consider two cubic lattices of similar size, but with different boundary conditions:","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"cubic_free = RegularLattice((11,11,11); periodic = false)\n\ncubic_periodic = RegularLattice((11,11,11); periodic = true)","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"For the former lattice, cubic_free[12,12,12] leads to BoundsError. For the latter lattice, cubic_periodic[12,12,12] is equivalent to cubic_periodic[1,1,1].","category":"page"},{"location":"manual/#Relative-coordinate","page":"Manual","title":"Relative coordinate","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"The package exports the function","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"relative_coordinate(collection::AbstractNodeCollection, I1, I2)","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"which returns the coordinate of node I1 relative to node I2. The format of the indices I1 and I2 depends on particular type of the collection (they should correspond to the default style of index). You can find default style of indexing for unit cells in Unit Cells and Indexing section. The default styles for lattices are listed in subsection Default style","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"note: Note\nIf the index in default style is multicomponent, it is passed into relative_coordinate as a Tuple. Single Int or single CartesianIndex{D} are considered single-component.","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"warning: Warning\nAt this point, relative_coordinate does not support alternative style of indexing for lattices (see Alternative style). Typically, one needs to calculate some coupling constants for all pairs of nodes in the lattice. This can be achieved by computing relative coordinates and substituting them into some interaction function. The indexes for the whole lattice or for it large subset are going to be machine generated anyway.","category":"page"},{"location":"manual/#Lattices-with-periodic-boundaries","page":"Manual","title":"Lattices with periodic boundaries","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"In the case of the lattice with periodic boundary conditions, one is interested in the shortest connecting vector for two nodes. The meaning of the shortest here is the following. One can translate the lattice periodically in all directions. If one specifies the node, the translation of the lattice produces the images of this specific node. The shortest connecting vector is determined by picking the first node or its image, so that the distance to the second node is minimal. In the case of the lattice with non-trivial cell, it is possible that this procedure is ambiguous: there can be several connecting vectors with the same minimal length (these vectors are related by symmetry).","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"In this package, I resolve this ambiguity by using a specific heuristic. Let me consider two nodes with indices (I1, Ic1...) and (I2, Ic2...). Here, I1 and I2 are CartesianIndices of cells, Ic1 and Ic2 are indices inside the cells. In the case of a lattice with periodic boundary conditions relative_coordinate returns","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"lattice[Ic1 + central_cell - Ic2, Ic1...] - lattice[central_cell, Ic2...]","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"Here, central_cell is literally the index of the central cell of the lattice:","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"central_cell = CartesianIndex(div.(lattice_dims, 2) .+ 1)","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"In reality, it is central only if lattice dimensions are all odd. In the case of even dimensions it gives the index of one of several central cells.","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"The idea is quite simple: both Ic1 and Ic2 are translated by the same amount so that Ic2 points to the central cell. Then, Ic1 is translated back inside the boundaries (it is performed implicitly while indexing into lattice). Finally, the resulting indices are used to compute the relative coordinate.","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"note: Note\nThis heuristic satisfies the important property of reciprocity:relative_coordinate(lattice, I1, I2) == - relative_coordinate(lattice, I2, I1)","category":"page"},{"location":"#LightLattices.jl","page":"Contents","title":"LightLattices.jl","text":"","category":"section"},{"location":"","page":"Contents","title":"Contents","text":"The package provides a convenient interface to work with Lattices with arbitrary unit cells.","category":"page"},{"location":"#Manual","page":"Contents","title":"Manual","text":"","category":"section"},{"location":"","page":"Contents","title":"Contents","text":"Pages = [\"manual.md\"]","category":"page"},{"location":"#Examples","page":"Contents","title":"Examples","text":"","category":"section"},{"location":"","page":"Contents","title":"Contents","text":"Pages = [\"examples.md\"]","category":"page"},{"location":"#List-of-autogenerated-docs","page":"Contents","title":"List of autogenerated docs","text":"","category":"section"},{"location":"","page":"Contents","title":"Contents","text":"Pages = [\"list.md\"]\nDepth = 1","category":"page"}]
}
