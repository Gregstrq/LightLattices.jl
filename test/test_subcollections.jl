using LightLattices: position, species
using IsotopeTable: isotopes

const diagonal_indices = [(CartesianIndex(i,i,i), 1) for i in 1:11]
const diamond_cross_cells = sort([
    CartesianIndex(0,0,0),
    CartesianIndex(1,0,0), CartesianIndex(0,1,0), CartesianIndex(0,0,1),
    CartesianIndex(-1,0,0), CartesianIndex(0,-1,0), CartesianIndex(0,0,-1),
])
const diamond_cross_indices = [(I, ic) for ic in 1:2 for I in diamond_cross_cells]
const fluorapatite_column_cells = CartesianIndices((6:6, 6:6, 1:11))

const diagonal = Subcollection(phys_cubic_lattice_f, 1 => reverse(diagonal_indices))
@testset "F19 cubic lattice body diagonal subcollection" begin
    @test diagonal.pcol === phys_cubic_lattice_f
    @test is_homogeneous(diagonal) == IsHomogeneous{true}()
    @test num_of_groups(diagonal) == 1
    @test length(diagonal) == 11
    @test group_size(diagonal, 1) == 11
    @test group_species(diagonal, 1) == isotopes[:F19]
    @test_throws ErrorException group_species(diagonal, 2)
    @test_throws ErrorException group_size(diagonal, 2)
    @test position(diagonal, 1, 1) ≈ 2.725u"Å" * SVector(1,1,1)
    @test first(diagonal[1, 1]) ≈ 2.725u"Å" * SVector(1,1,1)
    @test last(diagonal[1, 1]) == isotopes[:F19]
    @test position(diagonal, 11, 1) == position(phys_cubic_lattice_f, CartesianIndex(11,11,11))
    # Subcollection indices 2 and 10 select the corresponding diagonal cells.
    @test relative_position(diagonal, (2, 1), (10, 1)) ≈
        relative_position(phys_cubic_lattice_f, diagonal_indices[2], diagonal_indices[10])
    @test relative_position(diagonal, (2, 1), phys_cubic_lattice_f, (CartesianIndex(3,4,5), 1)) ≈
        relative_position(phys_cubic_lattice_f, diagonal_indices[2], (CartesianIndex(3,4,5), 1))
    @test relative_position(phys_cubic_lattice_f, (CartesianIndex(3,4,5), 1), diagonal, (2, 1)) ≈
        relative_position(phys_cubic_lattice_f, (CartesianIndex(3,4,5), 1), diagonal_indices[2])
    @test_throws BoundsError diagonal[0, 1]
    @test_throws BoundsError diagonal[12, 1]
    @test_throws BoundsError Subcollection(phys_cubic_lattice_f, 1 => [(CartesianIndex(12,12,12), 1)])
end

const cross = Subcollection(phys_diamond_lattice_p, 1 => reverse(diamond_cross_indices))
@testset "C13 diamond seven-cell periodic subcollection" begin
    @test cross.pcol === phys_diamond_lattice_p
    @test is_homogeneous(cross) == IsHomogeneous{true}()
    @test num_of_groups(cross) == 1
    @test length(cross) == 14
    @test group_size(cross, 1) == 14
    @test group_species(cross, 1) == isotopes[:C13]
    @test_throws ErrorException group_species(cross, 2)
    @test_throws ErrorException group_size(cross, 2)
    @test position(cross, 1) == dpvecs * SVector(11,11,10) + dcell[1]
    @test cross[1] == (dpvecs * SVector(11,11,10) + dcell[1], isotopes[:C13])
    @test position(cross, 14) == position(phys_diamond_lattice_p, diamond_cross_indices[14]...)
    # Include both basis sites and cells across the periodic boundary.
    @test relative_position(cross, (1, 1), (14, 1)) ≈
        relative_position(phys_diamond_lattice_p, diamond_cross_indices[1], diamond_cross_indices[14])
    @test relative_position(cross, (1, 1), phys_diamond_lattice_p, (CartesianIndex(1,1,1), 2)) ≈
        relative_position(phys_diamond_lattice_p, diamond_cross_indices[1], (CartesianIndex(1,1,1), 2))
    @test relative_position(phys_diamond_lattice_p, (CartesianIndex(1,1,1), 2), cross, (1, 1)) ≈
        relative_position(phys_diamond_lattice_p, (CartesianIndex(1,1,1), 2), diamond_cross_indices[1])
    @test_throws BoundsError cross[0, 1]
    @test_throws BoundsError cross[15, 1]
    @test_throws BoundsError Subcollection(phys_diamond_lattice_p, 1 => [(CartesianIndex(0,0,0), 3)])
end

const column = Subcollection(phys_fluorapatite_lattice_p,
    2 => (fluorapatite_column_cells, 1:3),
    1 => (fluorapatite_column_cells, 1:1))
@testset "Fluorapatite column with one F19 and three P31 sites per cell" begin
    @test column.pcol === phys_fluorapatite_lattice_p
    @test is_homogeneous(column) == IsHomogeneous{false}()
    @test num_of_groups(column) == 2
    @test column.group_indices == (1, 2)
    @test length(column) == 44
    @test group_size(column, 1) == 11
    @test group_size(column, 2) == 33
    @test group_species(column, 1) == isotopes[:F19]
    @test group_species(column, 2) == isotopes[:P31]
    @test_throws ErrorException group_species(column, 3)
    @test_throws ErrorException group_size(column, 3)
    @test position(column, 1, 1) ≈ fpvecs * SVector(6,6,1) + fcell[1, 1]
    @test first(column[1, 1]) ≈ fpvecs * SVector(6,6,1) + fcell[1, 1]
    @test last(column[1, 1]) == isotopes[:F19]
    @test position(column, 11, 1) == position(phys_fluorapatite_lattice_p, CartesianIndex(6,6,11), 1, 1)
    @test position(column, 1, 2) ≈ fpvecs * SVector(6,6,1) + fcell[1, 2]
    @test first(column[1, 2]) ≈ fpvecs * SVector(6,6,1) + fcell[1, 2]
    @test last(column[1, 2]) == isotopes[:P31]
    @test position(column, 33, 2) == position(phys_fluorapatite_lattice_p, CartesianIndex(6,6,11), 3, 2)
    # Index 33 in the P group is its third basis site in the last column cell.
    @test relative_position(column, (33, 2), (1, 1)) ≈
        relative_position(phys_fluorapatite_lattice_p, (CartesianIndex(6,6,11), 3, 2), (CartesianIndex(6,6,1), 1, 1))
    @test relative_position(column, (33, 2), phys_fluorapatite_lattice_p, (CartesianIndex(5,6,1), 2, 1)) ≈
        relative_position(phys_fluorapatite_lattice_p, (CartesianIndex(6,6,11), 3, 2), (CartesianIndex(5,6,1), 2, 1))
    @test relative_position(phys_fluorapatite_lattice_p, (CartesianIndex(5,6,1), 2, 1), column, (33, 2)) ≈
        relative_position(phys_fluorapatite_lattice_p, (CartesianIndex(5,6,1), 2, 1), (CartesianIndex(6,6,11), 3, 2))
    @test_throws BoundsError column[0, 1]
    @test_throws BoundsError column[12, 1]
    @test_throws BoundsError column[34, 2]
    @test_throws BoundsError Subcollection(phys_fluorapatite_lattice_p,
        1 => (fluorapatite_column_cells, 1:3))
end
