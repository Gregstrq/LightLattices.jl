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
