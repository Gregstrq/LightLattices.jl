struct Cluster{D, T, ET, PCT<:AbstractPhysicalCollection{D, T}} <: AbstractPhysicalCollection{D, T, ET}
    pcol::PCT
end
