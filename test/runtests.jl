using Unitful, StaticArrays, RecursiveArrayTools, LightLattices, Test

###############################################################
#
#   Cell tests
#
#


tcell = TrivialCell{3, Float64}()
@testset "Trivial cell" begin
    @test_throws BoundsError tcell[2]
    @test tcell[1] == SVector{3, Float64}(0.0,0.0,0.0)
    @test relative_coordinate(tcell, 1, 1) == SVector{3, Float64}(0.0,0.0,0.0)
	@test num_of_groups(tcell) == 1
	@test group_size(tcell, 1) == 1
	@test_throws ErrorException group_size(tcell, 2)
end

dcell = HomogeneousCell([[0,0,0],[0.25,0.25,0.25]], :diamond)
dcell_tuples = HomogeneousCell([(0,0.0,0),(0.25,0.25,0.25)], :diamond)
dcell_unlabeled = HomogeneousCell([[0,0,0],[0.25,0.25,0.25]])
@testset "Homogeneous unit cell of diamond" begin
    @test_throws BoundsError dcell[3]
    @test dcell[2] == SVector{3,Float64}(0.25,0.25,0.25)
    @test relative_coordinate(dcell, 2, 1) == SVector{3,Float64}(0.25,0.25,0.25)
	@test typeof(dcell_tuples) == typeof(dcell)
	@test dcell_tuples.cell_vectors == dcell.cell_vectors
	@test dcell_unlabeled.label == nothing
	@test num_of_groups(dcell) == 1
	@test group_size(dcell, 1) == 2
	@test_throws ErrorException group_size(dcell, 2)
end

### Fluorapatite basis_cell requires introduction of primitive vectors.

const af = 9.462u"Å"
const cf = 6.849u"Å"

const x = 0.369
const y = 0.389

fpvecs = hcat(af*[0.5, 0.5*sqrt(3), 0.0],
              af*[0.5, -0.5*sqrt(3), 0.0],
              cf*[0.0, 0.0, 1.0]
             ) |> SMatrix{3,3}
cell_vectors_raw1 = [[0.0, 0.0, 0.25], [0.0, 0.0, 0.75]]
cell_vectors_raw2 = [[x, y, 0.25], [-y, x-y, 0.25], [y-x, -x, 0.25],
                  [-x, -y, 0.75], [y, y-x, 0.75], [x-y, x, 0.75]]
fcell_vectors = ArrayPartition([fpvecs*vec for vec in cell_vectors_raw1], [fpvecs*vec for vec in cell_vectors_raw2])
fcell = InhomogeneousCell([fpvecs*vec for vec in cell_vectors_raw1], [fpvecs*vec for vec in cell_vectors_raw2]; label = :fluorapatite_magnetic)
@testset "Inhomogeneous unit cell for magnetic sublattice of fluorapatite" begin
    @test_throws BoundsError fcell[9]
    @test_throws BoundsError fcell[3,1]
    @test_throws BoundsError fcell[7, 2]
    @test fcell[2] == fcell_vectors[2]
    @test fcell[2, 1] == fcell_vectors[2]
    @test fcell[3] == fcell_vectors[2,1]
    @test fcell[1,2] == fcell_vectors[2,1]
    @test relative_coordinate(fcell, 5, 2) == fcell_vectors[2,3] - fcell_vectors[1,2]
    @test relative_coordinate(fcell, (3,2), 2) == fcell_vectors[2,3] - fcell_vectors[1,2]
    @test relative_coordinate(fcell, 5, (2,1)) == fcell_vectors[2,3] - fcell_vectors[1,2]
    @test relative_coordinate(fcell, (3,2), (2,1)) == fcell_vectors[2,3] - fcell_vectors[1,2]
	@test num_of_groups(fcell) == 2
	@test group_size(fcell, 1) == 2
	@test group_size(fcell, 2) == 6
	@test_throws ErrorException group_size(fcell, 3)
end

### Tests for switch_coord_type

mock_h_cell = HomogeneousCell([[0,0,0], [1,1,1]])
mock_ih_cell = InhomogeneousCell([[0,0,0]], [[1,1,1]])
tcell_transformed = switch_coord_type(tcell, Int)
mock_h_cell_transformed = switch_coord_type(mock_h_cell, Float64)
mock_ih_cell_transformed = switch_coord_type(mock_ih_cell, Float64)
@testset "Switching of coordinate type" begin
	@test switch_coord_type(tcell, Float64) == tcell
	@test switch_coord_type(mock_h_cell, Int) === mock_h_cell
	@test switch_coord_type(mock_ih_cell, Int) === mock_ih_cell
    @test typeof(tcell_transformed) == TrivialCell{3,Int}
    @test typeof(mock_h_cell_transformed) == HomogeneousCell{3, Float64, Nothing}
    @test typeof(mock_ih_cell_transformed) <: InhomogeneousCell{3,Float64, 2, Nothing}
    @test tcell_transformed[1] == SVector(0,0,0)
    @test mock_h_cell_transformed[2] == SVector(1.0,1.0,1.0)
    @test mock_ih_cell_transformed[1,2] == SVector(1.0,1.0,1.0)
end

###############################################################
#
#   Lattice tests
#
#

### Fluorine sublattice of CaF2 is a cubic lattice.

cubic_lattice_f = RegularLattice((11,11,11), 2.725u"Å"; periodic=false)
cubic_lattice_p = RegularLattice((11,11,11), 2.725u"Å")
@testset "Fluorine sublattice of CaF2 as an example of cubic lattice" begin
    @test cubic_lattice_f.central_cell == CartesianIndex(6,6,6)
    @test_throws BoundsError cubic_lattice_f[11,11,12]
    @test_throws BoundsError cubic_lattice_f[11,11,11,2]
    @test_throws BoundsError cubic_lattice_f[CartesianIndex(11,11,11),2]
    @test cubic_lattice_p[13,24,182] ≈ 2.725u"Å"*SVector(2, 2, 6)
    @test cubic_lattice_p[13,24,182] ≈ 2.725u"Å"*SVector(2, 2, 6)
    @test cubic_lattice_p[CartesianIndex(13,24,182)] ≈ 2.725u"Å"*SVector(2,2,6)
    @test cubic_lattice_p[CartesianIndex(13,24,182), 1] ≈ 2.725u"Å"*SVector(2,2,6)
    @test relative_coordinate(cubic_lattice_f, CartesianIndex(2,2,6), CartesianIndex(1,1,1)) ≈ 2.725u"Å"*SVector(1,1,5)
    @test relative_coordinate(cubic_lattice_f, (CartesianIndex(2,2,6),1), (CartesianIndex(1,1,1),1)) ≈ 2.725u"Å"*SVector(1,1,5)
    @test relative_coordinate(cubic_lattice_f, (2,2,6,1), (1,1,1,1)) ≈ 2.725u"Å"*SVector(1,1,5)
    @test relative_coordinate(cubic_lattice_p, CartesianIndex(13,24,182), CartesianIndex(1,1,1)) ≈ 2.725u"Å"*SVector(1,1,5)
    @test relative_coordinate(cubic_lattice_p, (CartesianIndex(13,24,182),1), (CartesianIndex(1,1,1),1)) ≈ 2.725u"Å"*SVector(1,1,5)
    @test relative_coordinate(cubic_lattice_p, (13,24,182,1), (1,1,1,1)) ≈ 2.725u"Å"*SVector(1,1,5)
	@test num_of_groups(cubic_lattice_p) == 1
	@test group_size(cubic_lattice_p, 1) == 11^3
	@test_throws ErrorException group_size(cubic_lattice_p, 2)
	@test length(cubic_lattice_p) == 11^3
end

### We consider dimensionless diamond lattice here.

dpvecs = 0.5*hcat([0,1,1],[1,1,0],[1,0,1]) |> SMatrix{3,3}
diamond_lattice_f = RegularLattice((11,11,11), dpvecs, dcell; label = :fcc, periodic = false)
diamond_lattice_p = RegularLattice((11,11,11), dpvecs, dcell; label = :fcc)
I1 = (CartesianIndex(13,24,182),1)
I2 = (CartesianIndex(1,1,1),2)
I1t = (13,24,182,1)
I2t = (1,1,1,2)
@testset "Dimensionless diamond lattice as an example of lattice with homogeneous cell" begin
    @test_throws BoundsError diamond_lattice_f[13,24,182,1]
    @test_throws BoundsError diamond_lattice_p[13,24,182,3]
    @test_throws BoundsError diamond_lattice_f[CartesianIndex(13,24,182),1]
    @test_throws BoundsError diamond_lattice_p[CartesianIndex(13,24,182),3]
    @test diamond_lattice_p[CartesianIndex(13,24,182), 1] == dpvecs*SVector(2,2,6)
    @test diamond_lattice_p[CartesianIndex(13,24,182), 2] == dpvecs*SVector(2,2,6) + SVector(0.25,0.25,0.25)
    @test diamond_lattice_p[13,24,182, 1] == dpvecs*SVector(2,2,6)
    @test diamond_lattice_p[13,24,182, 2] == dpvecs*SVector(2,2,6) + SVector(0.25,0.25,0.25)
    @test relative_coordinate(diamond_lattice_p, I1, I2) == dpvecs*SVector(1,1,5) - SVector(0.25,0.25,0.25)
    @test relative_coordinate(diamond_lattice_p, I1, I2) == -relative_coordinate(diamond_lattice_p, I2, I1)
    @test relative_coordinate(diamond_lattice_p, I1t, I2t) == dpvecs*SVector(1,1,5) - SVector(0.25,0.25,0.25)
    @test relative_coordinate(diamond_lattice_p, I1t, I2t) == -relative_coordinate(diamond_lattice_p, I2, I1)
	@test num_of_groups(diamond_lattice_p) == 1
	@test group_size(diamond_lattice_p, 1) == 11^3*2
	@test_throws ErrorException group_size(diamond_lattice_p, 2)
	@test length(diamond_lattice_p) == 11^3*2
end

### Fluorapatite lattice

fluorapatite_lattice_p = RegularLattice((11,11,11), fpvecs, fcell; label = :hexagonal)
I1 = (CartesianIndex(13,24,182), 5,2)
I2 = (CartesianIndex(1,1,1), 2,1)
I1t = (13,24,182, 5,2)
I2t = (1,1,1, 2,1)
@testset "Fluorapatite magnetic sublattice as an example of lattice with inhomogeneous cell." begin
    @test_throws BoundsError fluorapatite_lattice_p[CartesianIndex(13,24,182), 3,1]
    @test_throws BoundsError fluorapatite_lattice_p[13,24,182, 3,1]
    @test fluorapatite_lattice_p[CartesianIndex(13,24,182), 5,2] == fpvecs*SVector(2,2,6) + fcell[5,2]
    @test fluorapatite_lattice_p[13,24,182, 5,2] == fpvecs*SVector(2,2,6) + fcell[5,2]
    @test relative_coordinate(fluorapatite_lattice_p, I1, I2) ≈ fpvecs*SVector(1,1,5) + fcell[5,2] - fcell[2,1]
    @test relative_coordinate(fluorapatite_lattice_p, I1, I2) ≈ - relative_coordinate(fluorapatite_lattice_p, I2, I1)
    @test relative_coordinate(fluorapatite_lattice_p, I1t, I2t) ≈ fpvecs*SVector(1,1,5) + fcell[5,2] - fcell[2,1]
    @test relative_coordinate(fluorapatite_lattice_p, I1t, I2t) ≈ - relative_coordinate(fluorapatite_lattice_p, I2t, I1t)
	@test num_of_groups(fluorapatite_lattice_p) == 2
	@test group_size(fluorapatite_lattice_p, 1) == 11^3*2
	@test group_size(fluorapatite_lattice_p, 2) == 11^3*6
	@test_throws ErrorException group_size(fluorapatite_lattice_p, 3)
	@test length(fluorapatite_lattice_p) == 11^3*8
end

### Sorting utilities

using LightLattices: takes_precedence

@testset "Comparing of the indices" begin
	@test takes_precedence(1,2) == true
	@test takes_precedence(2,1) == false

	@test takes_precedence(CartesianIndex(1), CartesianIndex(2)) == true
	@test takes_precedence(CartesianIndex(2), CartesianIndex(1)) == false

	@test takes_precedence(CartesianIndex(2,3,1), CartesianIndex(1,1,2)) == true
	@test takes_precedence(CartesianIndex(1,1,2), CartesianIndex(2,3,1)) == false

	@test takes_precedence((CartesianIndex(1,1,2), 3), (CartesianIndex(2,3,1),4)) == true
	@test takes_precedence((CartesianIndex(2,3,1),4), (CartesianIndex(1,1,2), 3)) == false

	@test takes_precedence((1,1,2, 3), (2,3,1,4)) == true
	@test takes_precedence((2,3,1,4), (1,1,2, 3)) == false

	@test takes_precedence((CartesianIndex(2,3,1),4,1), (CartesianIndex(1,1,2), 3, 2)) == true
	@test takes_precedence((CartesianIndex(1,1,2), 3, 2), (CartesianIndex(2,3,1),4,1)) == false

	@test takes_precedence((2,3,1,4,1), (1,1,2, 3, 2)) == true
	@test takes_precedence((1,1,2, 3, 2), (2,3,1,4,1)) == false
end

