using LightLattices: TrivialCell, HomogeneousCell, InhomogeneousCell

const tcell = TrivialCell{3, Float64}()
@testset "Trivial cell" begin
    @test is_homogeneous(tcell) == IsHomogeneous{true}()
    @test_throws BoundsError tcell[2]
    @test tcell[1] == SVector{3, Float64}(0.0,0.0,0.0)
    @test relative_position(tcell, 1, 1) == SVector{3, Float64}(0.0,0.0,0.0)
	@test num_of_groups(tcell) == 1
	@test group_size(tcell, 1) == 1
	@test_throws ErrorException group_size(tcell, 2)
end

const dcell = HomogeneousCell([[0,0,0],[0.25,0.25,0.25]], :diamond)
const dcell_tuples = HomogeneousCell([(0,0.0,0),(0.25,0.25,0.25)], :diamond)
const dcell_unlabeled = HomogeneousCell([[0,0,0],[0.25,0.25,0.25]])
@testset "Homogeneous unit cell of diamond" begin
    @test is_homogeneous(dcell) == IsHomogeneous{true}()
    @test_throws BoundsError dcell[3]
    @test dcell[2] == SVector{3,Float64}(0.25,0.25,0.25)
    @test relative_position(dcell, 2, 1) == SVector{3,Float64}(0.25,0.25,0.25)
	@test typeof(dcell_tuples) == typeof(dcell)
	@test dcell_tuples.cell_vectors == dcell.cell_vectors
	@test dcell_unlabeled.label === nothing
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
const fcell_vectors = ([fpvecs*vec for vec in cell_vectors_raw1], [fpvecs*vec for vec in cell_vectors_raw2])
const fcell = InhomogeneousCell([fpvecs*vec for vec in cell_vectors_raw1], [fpvecs*vec for vec in cell_vectors_raw2]; label = :fluorapatite_magnetic)
@testset "Inhomogeneous unit cell for magnetic sublattice of fluorapatite" begin
    @test is_homogeneous(fcell) == IsHomogeneous{false}()
    @test_throws BoundsError fcell[9]
    @test_throws BoundsError fcell[3,1]
    @test_throws BoundsError fcell[7, 2]
    @test fcell[2] == fcell_vectors[1][2]
    @test fcell[2, 1] == fcell_vectors[1][2]
    @test fcell[3] == fcell_vectors[2][1]
    @test fcell[1,2] == fcell_vectors[2][1]
    @test relative_position(fcell, 5, 2) == fcell_vectors[2][3] - fcell_vectors[1][2]
    @test relative_position(fcell, (3,2), 2) == fcell_vectors[2][3] - fcell_vectors[1][2]
    @test relative_position(fcell, 5, (2,1)) == fcell_vectors[2][3] - fcell_vectors[1][2]
    @test relative_position(fcell, (3,2), (2,1)) == fcell_vectors[2][3] - fcell_vectors[1][2]
	@test num_of_groups(fcell) == 2
	@test group_size(fcell, 1) == 2
	@test group_size(fcell, 2) == 6
	@test_throws ErrorException group_size(fcell, 3)
end

### Tests for switch_coord_type

const mock_h_cell = HomogeneousCell([[0,0,0], [1,1,1]])
const mock_ih_cell = InhomogeneousCell([[0,0,0]], [[1,1,1]])
const tcell_transformed = switch_coord_type(tcell, Int)
const mock_h_cell_transformed = switch_coord_type(mock_h_cell, Float64)
const mock_ih_cell_transformed = switch_coord_type(mock_ih_cell, Float64)
@testset "Switching of coordinate type" begin
    @test is_homogeneous(tcell_transformed) == IsHomogeneous{true}()
    @test is_homogeneous(mock_h_cell_transformed) == IsHomogeneous{true}()
    @test is_homogeneous(mock_ih_cell_transformed) == IsHomogeneous{false}()
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
