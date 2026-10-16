using HDF5
using H5Zblosc
using FFTW
#using CairoMakie

function read_coord(path::String;PartType=1)
  fid = h5open(path, "r")
  @info keys(fid)
  BoxSize::Float32 = read_attribute(fid["Header"],"BoxSize")
  Coords_matrix = read(fid)["PartType"*string(PartType)]["Coordinates"]
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
  density_fluctuation::Array{Float32,3} = Density / mean_density .- 1

  return density_fluctuation
  
end

function PS(fluct,BoxSize)
  n = length(fluct[:,1,1])

  dx = BoxSize / n
  delta_k = fft(fluct)

  delta_k = abs2.(delta_k)
  
  k_x::Vector{Float32} = fftfreq(n, 1/dx) * (2*pi)
  k_y::Vector{Float32} = fftfreq(n, 1/dx) * (2*pi)
  k_z::Vector{Float32} = fftfreq(n, 1/dx) * (2*pi)

  k_array::Array{Float32} = zeros(n,n,n)

 for i = 1:n
   for j = 1:n
     for l = 1:n
       k = sqrt( k_x[i]^2 +k_y[j]^2 +k_z[l]^2 )
       k_array[i,j,l] = k
     end
   end
 end

 @info maximum(k_array)
 dk::Float32 = maximum(k_array)/n

 n_data::Vector{Float32} = zeros(n+1)
 delta_sum::Vector{Float32} = zeros(n+1)

 count::Int = 0
 for i = 1:n
   for j = 1:n
     for l = 1:n
       k_int = Int(floor(k_array[i,j,l]/dk))
       n_data[k_int+1] += 1
       delta_sum[k_int+1] += delta_k[i,j,l]
     end
   end
 end
 #@info maximum(n_data)
 #@info minimum(n_data)

 grid = [(i-1/2)*dk for i = 1:n+1] .* 10^3 # cMpc にするため10^3倍

 P = delta_sum ./ n_data * (25^3)/n^6

 return P, grid

end

function output_plot(P,k,fname)
  f = open(fname,"w")

  for i = 1:length(P)
    print(f, k[i])
    print(f, " ")
    println(f,P[i])
  end

  close(f)
end

function main(filepath::String; N=32, PartType=1)

  #filepath = "./sample/snapshot_090.hdf5"
  Coords, BoxSize = read_coord(filepath; PartType=PartType)
  density = Coords_to_density(Coords,BoxSize;n=N)
  fluct = density_to_fluctuation(density)
  P,k = PS(fluct,BoxSize)


 # fig = Figure()
 # axis = Axis(fig[1,1], xlabel = "k [/ckpc]", ylabel="Pk", yscale=log10, xscale=log10)
 # lines!(axis, k,P)
 # fig
end
