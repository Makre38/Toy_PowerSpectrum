# なんちゃってPower Spectrum プロット

# usage
```
 nix develop && julia --project=.

 julia> include("./src/PowerSpectrum.jl")
 julia> P, k = main("path_to_hdf.5", N=128, PartType=1)
 julia> output_plot(P,k,"filename")
```

# files and dirs
## ./sample
A DM only datas at z=0.00 from IllustrisTNG project . [link](https://users.flatironinstitute.org/~camels/Sims/)

## ./src
julia code.

# state
おおむねそれっぽいPower Spectumが出力されるけど、小スケールであわない。
ショットノイズとかちゃんと扱ってない、など改善の余地は山ほどある。
