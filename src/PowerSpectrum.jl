using HDF5
using H5Zblosc
using FFTW
using CairoMakie

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

function PS(fluct)
  n = length(fluct[:,1,1])
  delta_k = fft(fluct)

  delta_k = abs.(delta_k)

  #PowerSpectrum::Matrix{Float32} = zeros(n,2)

  k_n = []

 for i = 1:n
   for j = 1:n
     for l = 1:n
       k = Int(floor(sqrt(i^2 + j^2 + l^2)))
       push!(k_n,k)
     end
   end
 end

 dk = floor(maximum(k_n)) / n

 n_data::Vector{Float32} = zeros(n)
 delta_sum::Vector{Float32} = zeros(n)

 for i = 1:n
   for j = 1:n
     for l = 1:n
       k = Int( floor(sqrt(i^2 + j^2 + l^2) / dk) )
       n_data[k] += 1
       delta_sum[k] += delta_k[i,j,l]
     end
   end
 end

 @info maximum(n_data)
 @info minimum(n_data)

 grid = [i*dk for i = 1:n]

 return delta_sum ./ n_data, grid

end

function main(filepath::String; N=64)

  #filepath = "./sample/snapshot_090.hdf5"
  Coords, BoxSize = read_coord(filepath)
  density = Coords_to_density(Coords,BoxSize;n=N)
  fluct = density_to_fluctuation(density)
  P,k = PS(fluct)

  fig = Figure()
  axis = Axis(fig[1,1], xlabel = "k [/ckpc]", ylabel="Pk", yscale=log10, xscale=log10)
  lines!(axis, k,P)
  fig
end
