using HDF5

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


function main()
end
