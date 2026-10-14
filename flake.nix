{
  description = "Compute Power Spectrum";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }: 
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.julia
            #pkgs.mpich
            pkgs.gcc
            #pkgs.gccNGPackages_15.libquadmath
          ];
          
          shellHook = ''
          echo "let's feel Power Spectrum!"
          export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [ pkgs.gcc.cc.lib ]}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
          '';
        };
      }
    );
}
