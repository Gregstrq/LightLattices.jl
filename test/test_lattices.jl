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
I2t = (1,1,1,2,1)
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
