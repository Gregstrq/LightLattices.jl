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

# Compare indices without dereferencing collection nodes.
function test_iteration_format(collection)
    indices = vec(collect(eachindex(collection)))
    @test length(indices) == length(collection)
    combined_indices = []
    homogeneous = is_homogeneous(collection) == IsHomogeneous{true}()

    for ig in 1:num_of_groups(collection)
        group_indices = collect(group_iterator(collection, ig))
        @test length(group_indices) == group_size(collection, ig)
        @test all(i -> checkbounds(collection, i..., ig), group_indices)

        if homogeneous && eltype(indices) <: Integer && eltype(group_indices) <: Tuple
            # Ordered homogeneous subcollections use linear eachindex indices.
            linear_indices = LinearIndices(group_indices)
            append!(combined_indices,
                (linear_indices[Tuple(I)..., ic] for (I, ic) in vec(group_indices)))
        elseif homogeneous
            append!(combined_indices, vec(group_indices))
        else
            append!(combined_indices, ((i..., ig) for i in vec(group_indices)))
        end
    end
    @test combined_indices == indices
    @test_throws ErrorException group_iterator(collection, 0)
    @test_throws ErrorException group_iterator(collection, num_of_groups(collection) + 1)
end

@testset "Cell iteration" begin
    for (name, collection) in (
        ("trivial", tcell),
        ("diamond", dcell),
        ("fluorapatite", fcell),
        ("physical diamond", phys_dcell),
        ("physical fluorapatite", phys_fcell),
    )
        @testset "$name" begin
            test_iteration_format(collection)
        end
    end
    @test_throws BoundsError checkbounds(dcell, 3, 1)
    @test_throws BoundsError checkbounds(dcell, 1, 2)
end

@testset "Lattice iteration" begin
    for (name, collection) in (
        ("free cubic", cubic_lattice_f),
        ("periodic cubic", cubic_lattice_p),
        ("free diamond", diamond_lattice_f),
        ("periodic diamond", diamond_lattice_p),
        ("fluorapatite", fluorapatite_lattice_p),
        ("physical free cubic", phys_cubic_lattice_f),
        ("physical periodic cubic", phys_cubic_lattice_p),
        ("physical free diamond", phys_diamond_lattice_f),
        ("physical periodic diamond", phys_diamond_lattice_p),
        ("physical fluorapatite", phys_fluorapatite_lattice_p),
    )
        @testset "$name" begin
            test_iteration_format(collection)
        end
    end
end

const phosphorus_iteration_column = Subcollection(phys_fluorapatite_lattice_p,
    2 => (fluorapatite_column_cells, [1, 3]))

@testset "Subcollection iteration" begin
    @testset "diagonal" begin
        test_iteration_format(diagonal)
    end
    @testset "diamond cross" begin
        test_iteration_format(cross)
    end
    @testset "single-group ordered column" begin
        test_iteration_format(phosphorus_iteration_column)
    end
    @testset "fluorapatite column" begin
        test_iteration_format(column)
        @test_throws BoundsError checkbounds(column, CartesianIndex(2,1,1), 1, 1)
        @test_throws BoundsError checkbounds(column, CartesianIndex(1,1,1), 2, 1)
        @test_throws BoundsError checkbounds(column, CartesianIndex(1,1,1), 1, 3)
    end
end

@testset "Composite collection iteration" begin
    test_iteration_format(fluorapatite_nitrogen)
end
