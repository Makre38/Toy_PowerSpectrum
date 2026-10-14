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
  dx = BoxSize / n

  density::Array{Float32,3} = zeros(n,n,n) 

  for (x,y,z) in Coords
    (x,y,z) = Int.(floor.((x, y, z) ./dx))
    density[x+1,y+1,z+1] += 1
  end

  return density

end


function main()
end
