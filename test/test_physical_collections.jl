using LightLattices: cell, lattice

struct Spin{T, S}
    """
    Spin's gyromagnetic ratio
    """
    γ::T

    function Spin(S::Int, γ::T=1) where {T<:Number}
        DT = dimension(T)
        @assert (DT == NoDims) || (DT == dimension(1ug"rad/s/Gauss"))
        return new{T, S}(γ)
    end

    function Spin(S::Rational{Int}, γ::T=1) where {T<:Number}
        DT = dimension(T)
        @assert (DT == NoDims) || (DT == dimension(1ug"rad/s/Gauss"))
        m = 2S + 1
        @assert m.num == m
        return new{T, S}(γ)
    end
end

const C13 = Spin(1//2, 6728.28ug"rad/s/Gauss")

const F19 = Spin(1//2, 25181.5ug"rad/s/Gauss")

const P31 = Spin(1//2, 10829.1ug"rad/s/Gauss")

@testset "C13-enriched diamond unit cell" begin
    dcell = cell(C13, [[0,0,0], [0.25,0.25,0.25]]; label=:diamond)
    dcell_tuples = cell(C13, [(0,0.0,0), (0.25,0.25,0.25)]; label=:diamond)
    dcell_unlabeled = cell(C13, [[0,0,0], [0.25,0.25,0.25]])
    @test dcell isa PhysicalCollection
    @test dcell.elements == (C13,)
    @test dcell.nodes.label == :diamond
    @test is_homogeneous(dcell) == IsHomogeneous{true}()
    @test length(dcell) == 2
    @test_throws BoundsError dcell[3]
    @test dcell[2] == SVector{3,Float64}(0.25,0.25,0.25)
    @test relative_coordinate(dcell, 2, 1) == SVector{3,Float64}(0.25,0.25,0.25)
    @test typeof(dcell_tuples) == typeof(dcell)
    @test dcell_tuples.nodes.cell_vectors == dcell.nodes.cell_vectors
    @test dcell_unlabeled.nodes.label == nothing
    @test num_of_groups(dcell) == 1
    @test group_size(dcell, 1) == 2
    @test_throws ErrorException group_size(dcell, 2)
end

@testset "F19 and P31 fluorapatite unit cell" begin
    fcell = cell(F19 => fcell_vectors[1], P31 => fcell_vectors[2]; label=:fluorapatite_magnetic)
    @test fcell isa PhysicalCollection
    @test fcell.elements == (F19, P31)
    @test fcell.nodes.label == :fluorapatite_magnetic
    @test is_homogeneous(fcell) == IsHomogeneous{false}()
    @test length(fcell) == 8
    @test_throws BoundsError fcell[9]
    @test_throws BoundsError fcell[3,1]
    @test_throws BoundsError fcell[7, 2]
    @test fcell[2] == fcell_vectors[1][2]
    @test fcell[2, 1] == fcell_vectors[1][2]
    @test fcell[3] == fcell_vectors[2][1]
    @test fcell[1,2] == fcell_vectors[2][1]
    @test relative_coordinate(fcell, 5, 2) == fcell_vectors[2][3] - fcell_vectors[1][2]
    @test relative_coordinate(fcell, (3,2), 2) == fcell_vectors[2][3] - fcell_vectors[1][2]
    @test relative_coordinate(fcell, 5, (2,1)) == fcell_vectors[2][3] - fcell_vectors[1][2]
    @test relative_coordinate(fcell, (3,2), (2,1)) == fcell_vectors[2][3] - fcell_vectors[1][2]
    @test num_of_groups(fcell) == 2
    @test group_size(fcell, 1) == 2
    @test group_size(fcell, 2) == 6
    @test_throws ErrorException group_size(fcell, 3)
end

@testset "F19 cubic lattice" begin
    cubic_lattice_f = lattice((11,11,11), 2.725u"Å", F19; periodic=false)
    cubic_lattice_p = lattice((11,11,11), 2.725u"Å", F19)
    @test cubic_lattice_f isa PhysicalCollection
    @test cubic_lattice_p isa PhysicalCollection
    @test cubic_lattice_f.elements == (F19,)
    @test cubic_lattice_p.elements == (F19,)
    @test cubic_lattice_f.nodes.central_cell == CartesianIndex(6,6,6)
    @test_throws BoundsError cubic_lattice_f[11,11,12]
    @test_throws BoundsError cubic_lattice_f[11,11,11,2]
    @test_throws BoundsError cubic_lattice_f[CartesianIndex(11,11,11),2]
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

@testset "C13-enriched diamond lattice" begin
    diamond_vectors = [[0,0,0], [0.25,0.25,0.25]]
    diamond_lattice_f = lattice((11,11,11), dpvecs, C13 => diamond_vectors; label=:fcc, periodic=false)
    diamond_lattice_p = lattice((11,11,11), dpvecs, C13 => diamond_vectors; label=:fcc)
    @test diamond_lattice_f isa PhysicalCollection
    @test diamond_lattice_p isa PhysicalCollection
    @test diamond_lattice_f.elements == (C13,)
    @test diamond_lattice_p.elements == (C13,)
    I1 = (CartesianIndex(13,24,182),1)
    I2 = (CartesianIndex(1,1,1),2)
    I1t = (13,24,182,1)
    I2t = (1,1,1,2)
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

@testset "F19 and P31 fluorapatite lattice" begin
    fluorapatite_lattice_p = lattice((11,11,11), fpvecs,
        F19 => fcell_vectors[1], P31 => fcell_vectors[2]; label=:hexagonal)
    @test fluorapatite_lattice_p isa PhysicalCollection
    @test fluorapatite_lattice_p.elements == (F19, P31)
    I1 = (CartesianIndex(13,24,182),5,2)
    I2 = (CartesianIndex(1,1,1),2,1)
    I1t = (13,24,182,5,2)
    I2t = (1,1,1,2,1)
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
