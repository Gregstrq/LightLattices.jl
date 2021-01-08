Base.@propagate_inbounds rearrange(x::Tuple, val::Val{D}) where {D} = rearrange((), x, val)
Base.@propagate_inbounds rearrange(x::Tuple, y::Tuple, val::Val{D}) where {D} = rearrange((x...,first(y)), Base.tail(y), Val{D-1}())
Base.@propagate_inbounds rearrange(x::NTuple{N,Int}, y::Tuple, val::Val{0}) where {N} = CartesianIndex{N}(x),y...

Base.@propagate_inbounds Base.getindex(lattice::RegularLattice, i::Int, I...) = Base.getindex(lattice::RegularLattice, (i, I...))
Base.@propagate_inbounds Base.getindex(lattice::RegularLattice{D,T,PB,CT,L,D′}, I::NTuple{D′,Int}) where {D,T,PB,CT,L,D′} = Base.getindex(lattice, rearrange(I, Val{D}())...)

