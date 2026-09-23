using LightLattices: compose, element
using IsotopeTable: isotopes

# Insert two N15 sites between adjacent retained F sites near the column midpoint.
const nitrogen_cell = cell(:N15,
    [column[6, 1] + fraction * (column[7, 1] - column[6, 1]) for fraction in (1/3, 2/3)];
    label=:nitrogen_pair, decoder=isotopes)
const fluorapatite_nitrogen = CompositeCollection((column, nitrogen_cell))

@testset "Fluorapatite column with an interstitial N15 pair" begin
    @test fluorapatite_nitrogen.collections === (column, nitrogen_cell)
    @test is_homogeneous(fluorapatite_nitrogen) == IsHomogeneous{false}()
    @test num_of_groups(fluorapatite_nitrogen) == 3
    @test length(fluorapatite_nitrogen) == 46
    @test fluorapatite_nitrogen.group_numbers == (2, 1)
    @test group_size(fluorapatite_nitrogen, 1) == 11
    @test group_size(fluorapatite_nitrogen, 2) == 33
    @test group_size(fluorapatite_nitrogen, 3) == 2
    @test fluorapatite_nitrogen.elements == (isotopes[:F19], isotopes[:P31], isotopes[:N15])
    @test element(fluorapatite_nitrogen, 1) == isotopes[:F19]
    @test element(fluorapatite_nitrogen, 2) == isotopes[:P31]
    @test element(fluorapatite_nitrogen, 3) == isotopes[:N15]
    @test_throws ErrorException element(fluorapatite_nitrogen, 4)
    @test_throws ErrorException group_size(fluorapatite_nitrogen, 0)
    @test_throws ErrorException group_size(fluorapatite_nitrogen, 4)
    @test compose(column, nitrogen_cell).collections === fluorapatite_nitrogen.collections

    # Sample the first and last sites of each column group.
    for ig in 1:2, i in (1, group_size(column, ig))
        @test fluorapatite_nitrogen[i, ig] == column[i, ig]
    end
    for i in 1:2
        position = fluorapatite_nitrogen[i, 3]
        @test position == nitrogen_cell[i]
        @test position ≈ column[6, 1] + (i/3) * fpvecs[:, 3]
        @test column[6, 1][3] < position[3] < column[7, 1][3]
    end
    @test_throws BoundsError fluorapatite_nitrogen[0, 1]
    @test_throws BoundsError fluorapatite_nitrogen[12, 1]
    @test_throws BoundsError fluorapatite_nitrogen[34, 2]
    @test_throws BoundsError fluorapatite_nitrogen[3, 3]
    @test_throws ErrorException fluorapatite_nitrogen[1, 4]

    # Preserve periodic distances within the column, including across its ends.
    @test relative_coordinate(fluorapatite_nitrogen, (33, 2), (1, 1)) ≈
        relative_coordinate(column, (33, 2), (1, 1))
    @test relative_coordinate(fluorapatite_nitrogen, (2, 3), (1, 3)) ≈
        relative_coordinate(nitrogen_cell, 2, 1)
    @test relative_coordinate(fluorapatite_nitrogen, (1, 3), (6, 1)) ≈ fpvecs[:, 3] / 3
    @test relative_coordinate(fluorapatite_nitrogen, (6, 1), (1, 3)) ≈ -fpvecs[:, 3] / 3
    @test relative_coordinate(fluorapatite_nitrogen, (33, 2), phys_fluorapatite_lattice_p,
        (CartesianIndex(6,6,1), 1, 1)) ≈
        relative_coordinate(phys_fluorapatite_lattice_p,
            (CartesianIndex(6,6,11), 3, 2), (CartesianIndex(6,6,1), 1, 1))
    @test relative_coordinate(fluorapatite_nitrogen, (1, 3), nitrogen_cell, (2, 1)) ≈
        relative_coordinate(nitrogen_cell, 1, 2)
end
