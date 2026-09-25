using LightLattices: cluster, lattice, position, species
using IsotopeTable: isotopes

const phys_dcell = cluster(:C13, dcell.cell_vectors; label=:diamond, decoder=isotopes)
const phys_dcell_tuples = cluster(:C13, [(0,0.0,0), (0.25,0.25,0.25)]; label=:diamond, decoder=isotopes)
const phys_dcell_unlabeled = cluster(:C13, dcell.cell_vectors; decoder=isotopes)
@testset "C13-enriched diamond unit cell" begin
    @test phys_dcell isa PhysicalCollection
    @test phys_dcell.species == (isotopes[:C13],)
    @test group_species(phys_dcell, 1) == isotopes[:C13]
    @test_throws ErrorException group_species(phys_dcell, 2)
    @test phys_dcell.nodes.label == :diamond
    @test is_homogeneous(phys_dcell) == IsHomogeneous{true}()
    @test length(phys_dcell) == 2
    @test_throws BoundsError phys_dcell[3]
    @test position(phys_dcell, 2) == SVector{3,Float64}(0.25,0.25,0.25)
    @test phys_dcell[2] == (SVector{3,Float64}(0.25,0.25,0.25), isotopes[:C13])
    @test relative_position(phys_dcell, 2, 1) == SVector{3,Float64}(0.25,0.25,0.25)
    @test typeof(phys_dcell_tuples) == typeof(phys_dcell)
    @test phys_dcell_tuples.nodes.cell_vectors == phys_dcell.nodes.cell_vectors
    @test phys_dcell_unlabeled.nodes.label === nothing
    @test num_of_groups(phys_dcell) == 1
    @test group_size(phys_dcell, 1) == 2
    @test_throws ErrorException group_size(phys_dcell, 2)
end

const phys_fcell = cluster(:F19 => fcell_vectors[1], :P31 => fcell_vectors[2]; label=:fluorapatite_magnetic, decoder=isotopes)
@testset "F19 and P31 fluorapatite unit cell" begin
    @test phys_fcell isa PhysicalCollection
    @test phys_fcell.species == (isotopes[:F19], isotopes[:P31])
    @test group_species(phys_fcell, 2) == isotopes[:P31]
    @test_throws ErrorException group_species(phys_fcell, 3)
    @test phys_fcell.nodes.label == :fluorapatite_magnetic
    @test is_homogeneous(phys_fcell) == IsHomogeneous{false}()
    @test length(phys_fcell) == 8
    @test_throws BoundsError phys_fcell[9]
    @test_throws BoundsError phys_fcell[3,1]
    @test_throws BoundsError phys_fcell[7, 2]
    @test position(phys_fcell, 2) == fcell_vectors[1][2]
    @test phys_fcell[2] == (fcell_vectors[1][2], isotopes[:F19])
    @test position(phys_fcell, 2, 1) == fcell_vectors[1][2]
    @test phys_fcell[2, 1] == (fcell_vectors[1][2], isotopes[:F19])
    @test position(phys_fcell, 3) == fcell_vectors[2][1]
    @test phys_fcell[3] == (fcell_vectors[2][1], isotopes[:P31])
    @test position(phys_fcell, 1, 2) == fcell_vectors[2][1]
    @test phys_fcell[1,2] == (fcell_vectors[2][1], isotopes[:P31])
    @test relative_position(phys_fcell, 5, 2) == fcell_vectors[2][3] - fcell_vectors[1][2]
    @test relative_position(phys_fcell, (3,2), 2) == fcell_vectors[2][3] - fcell_vectors[1][2]
    @test relative_position(phys_fcell, 5, (2,1)) == fcell_vectors[2][3] - fcell_vectors[1][2]
    @test relative_position(phys_fcell, (3,2), (2,1)) == fcell_vectors[2][3] - fcell_vectors[1][2]
    @test num_of_groups(phys_fcell) == 2
    @test group_size(phys_fcell, 1) == 2
    @test group_size(phys_fcell, 2) == 6
    @test_throws ErrorException group_size(phys_fcell, 3)
end

const phys_cubic_lattice_f = lattice((11,11,11), 2.725u"Å", :F19; periodic=false, decoder=isotopes)
const phys_cubic_lattice_p = lattice((11,11,11), 2.725u"Å", :F19; decoder=isotopes)
@testset "F19 cubic lattice" begin
    @test phys_cubic_lattice_f isa PhysicalCollection
    @test is_homogeneous(phys_cubic_lattice_f) == IsHomogeneous{true}()
    @test phys_cubic_lattice_p isa PhysicalCollection
    @test is_homogeneous(phys_cubic_lattice_p) == IsHomogeneous{true}()
    @test phys_cubic_lattice_f.species == (isotopes[:F19],)
    @test phys_cubic_lattice_p.species == (isotopes[:F19],)
    @test group_species(phys_cubic_lattice_p, 1) == isotopes[:F19]
    @test_throws ErrorException group_species(phys_cubic_lattice_p, 2)
    @test phys_cubic_lattice_f.nodes.central_cell == CartesianIndex(6,6,6)
    @test_throws BoundsError phys_cubic_lattice_f[11,11,12]
    @test_throws BoundsError phys_cubic_lattice_f[11,11,11,2]
    @test_throws BoundsError phys_cubic_lattice_f[CartesianIndex(11,11,11),2]
    @test position(phys_cubic_lattice_p, 13,24,182) ≈ 2.725u"Å"*SVector(2, 2, 6)
    @test first(phys_cubic_lattice_p[13,24,182]) ≈ 2.725u"Å"*SVector(2, 2, 6)
    @test last(phys_cubic_lattice_p[13,24,182]) == isotopes[:F19]
    @test position(phys_cubic_lattice_p, CartesianIndex(13,24,182)) ≈ 2.725u"Å"*SVector(2,2,6)
    @test position(phys_cubic_lattice_p, CartesianIndex(13,24,182), 1) ≈ 2.725u"Å"*SVector(2,2,6)
    @test relative_position(phys_cubic_lattice_f, CartesianIndex(2,2,6), CartesianIndex(1,1,1)) ≈ 2.725u"Å"*SVector(1,1,5)
    @test relative_position(phys_cubic_lattice_f, (CartesianIndex(2,2,6),1), (CartesianIndex(1,1,1),1)) ≈ 2.725u"Å"*SVector(1,1,5)
    @test relative_position(phys_cubic_lattice_f, (2,2,6,1), (1,1,1,1)) ≈ 2.725u"Å"*SVector(1,1,5)
    @test relative_position(phys_cubic_lattice_p, CartesianIndex(13,24,182), CartesianIndex(1,1,1)) ≈ 2.725u"Å"*SVector(1,1,5)
    @test relative_position(phys_cubic_lattice_p, (CartesianIndex(13,24,182),1), (CartesianIndex(1,1,1),1)) ≈ 2.725u"Å"*SVector(1,1,5)
    @test relative_position(phys_cubic_lattice_p, (13,24,182,1), (1,1,1,1)) ≈ 2.725u"Å"*SVector(1,1,5)
    @test num_of_groups(phys_cubic_lattice_p) == 1
    @test group_size(phys_cubic_lattice_p, 1) == 11^3
    @test_throws ErrorException group_size(phys_cubic_lattice_p, 2)
    @test length(phys_cubic_lattice_p) == 11^3
end

const phys_diamond_lattice_f = lattice((11,11,11), dpvecs, :C13 => dcell.cell_vectors; label=:fcc, periodic=false, decoder=isotopes)
const phys_diamond_lattice_p = lattice((11,11,11), dpvecs, :C13 => dcell.cell_vectors; label=:fcc, decoder=isotopes)
@testset "C13-enriched diamond lattice" begin
    @test phys_diamond_lattice_f isa PhysicalCollection
    @test is_homogeneous(phys_diamond_lattice_f) == IsHomogeneous{true}()
    @test phys_diamond_lattice_p isa PhysicalCollection
    @test is_homogeneous(phys_diamond_lattice_p) == IsHomogeneous{true}()
    @test phys_diamond_lattice_f.species == (isotopes[:C13],)
    @test phys_diamond_lattice_p.species == (isotopes[:C13],)
    @test group_species(phys_diamond_lattice_p, 1) == isotopes[:C13]
    @test_throws ErrorException group_species(phys_diamond_lattice_p, 2)
    @test_throws BoundsError phys_diamond_lattice_f[13,24,182,1]
    @test_throws BoundsError phys_diamond_lattice_p[13,24,182,3]
    @test_throws BoundsError phys_diamond_lattice_f[CartesianIndex(13,24,182),1]
    @test_throws BoundsError phys_diamond_lattice_p[CartesianIndex(13,24,182),3]
    @test position(phys_diamond_lattice_p, CartesianIndex(13,24,182), 1) == dpvecs*SVector(2,2,6)
    @test phys_diamond_lattice_p[CartesianIndex(13,24,182), 1] == (dpvecs*SVector(2,2,6), isotopes[:C13])
    @test position(phys_diamond_lattice_p, CartesianIndex(13,24,182), 2) == dpvecs*SVector(2,2,6) + SVector(0.25,0.25,0.25)
    @test position(phys_diamond_lattice_p, 13,24,182, 1) == dpvecs*SVector(2,2,6)
    @test position(phys_diamond_lattice_p, 13,24,182, 2) == dpvecs*SVector(2,2,6) + SVector(0.25,0.25,0.25)
    @test relative_position(phys_diamond_lattice_p, I1, I2) == dpvecs*SVector(1,1,5) - SVector(0.25,0.25,0.25)
    @test relative_position(phys_diamond_lattice_p, I1, I2) == -relative_position(phys_diamond_lattice_p, I2, I1)
    @test relative_position(phys_diamond_lattice_p, I1t, I2t) == dpvecs*SVector(1,1,5) - SVector(0.25,0.25,0.25)
    @test relative_position(phys_diamond_lattice_p, I1t, I2t) == -relative_position(phys_diamond_lattice_p, I2, I1)
    @test num_of_groups(phys_diamond_lattice_p) == 1
    @test group_size(phys_diamond_lattice_p, 1) == 11^3*2
    @test_throws ErrorException group_size(phys_diamond_lattice_p, 2)
    @test length(phys_diamond_lattice_p) == 11^3*2
end

const phys_fluorapatite_lattice_p = lattice((11,11,11), fpvecs,
    :F19 => fcell_vectors[1], :P31 => fcell_vectors[2]; label=:hexagonal, decoder=isotopes)
@testset "F19 and P31 fluorapatite lattice" begin
    @test phys_fluorapatite_lattice_p isa PhysicalCollection
    @test is_homogeneous(phys_fluorapatite_lattice_p) == IsHomogeneous{false}()
    @test phys_fluorapatite_lattice_p.species == (isotopes[:F19], isotopes[:P31])
    @test group_species(phys_fluorapatite_lattice_p, 2) == isotopes[:P31]
    @test_throws ErrorException group_species(phys_fluorapatite_lattice_p, 3)
    @test_throws BoundsError phys_fluorapatite_lattice_p[CartesianIndex(13,24,182), 3,1]
    @test_throws BoundsError phys_fluorapatite_lattice_p[13,24,182, 3,1]
    @test position(phys_fluorapatite_lattice_p, CartesianIndex(13,24,182), 5,2) == fpvecs*SVector(2,2,6) + fcell[5,2]
    @test phys_fluorapatite_lattice_p[CartesianIndex(13,24,182), 5,2] == (fpvecs*SVector(2,2,6) + fcell[5,2], isotopes[:P31])
    @test position(phys_fluorapatite_lattice_p, 13,24,182, 5,2) == fpvecs*SVector(2,2,6) + fcell[5,2]
    @test relative_position(phys_fluorapatite_lattice_p, I1_f, I2_f) ≈ fpvecs*SVector(1,1,5) + fcell[5,2] - fcell[2,1]
    @test relative_position(phys_fluorapatite_lattice_p, I1_f, I2_f) ≈ - relative_position(phys_fluorapatite_lattice_p, I2_f, I1_f)
    @test relative_position(phys_fluorapatite_lattice_p, I1t_f, I2t_f) ≈ fpvecs*SVector(1,1,5) + fcell[5,2] - fcell[2,1]
    @test relative_position(phys_fluorapatite_lattice_p, I1t_f, I2t_f) ≈ - relative_position(phys_fluorapatite_lattice_p, I2t_f, I1t_f)
    @test num_of_groups(phys_fluorapatite_lattice_p) == 2
    @test group_size(phys_fluorapatite_lattice_p, 1) == 11^3*2
    @test group_size(phys_fluorapatite_lattice_p, 2) == 11^3*6
    @test_throws ErrorException group_size(phys_fluorapatite_lattice_p, 3)
    @test length(phys_fluorapatite_lattice_p) == 11^3*8
end
