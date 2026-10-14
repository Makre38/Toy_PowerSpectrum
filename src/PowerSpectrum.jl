using HDF5
using FFTW

function read_coord(path::String)
  fid = h5open(path, "r")
  @info keys(fid)
  BoxSize::Float32 = read_attribute(fid["Header"],"BoxSize")
  Coords_matrix = read(fid)["PartType1"]["Coordinates"]
  PartNum::Int = length(Coords_matrix[1,:])
  Coords_vector::Vector{Vector{Float32}} = [Coords_matrix[:,i] for i in 1:PartNum]
  close(fid)

  return Coords_vector, BoxSize
end

function Coords_to_density(Coords::Vector{Vector{Float32}}, BoxSize::Float32; n::Int = 64)
  #number per ckpc
  dx = BoxSize / n

  density::Array{Float32,3} = zeros(n,n,n) 

  for (x,y,z) in Coords
    (x,y,z) = Int.(floor.((x, y, z) ./dx))
    density[x+1,y+1,z+1] += 1
  end

  return density

end

function density_to_fluctuation(Density)
  n = length(Density[:,1,1])
  mean_density::Float32 = Float32(sum(Density)) / n^3
  density_fluctuation::Array{Float32,3} = - Density ./ mean_density .+ 1

  return density_fluctuation
  
end

function main()
end
