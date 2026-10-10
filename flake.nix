{
  description = "Compute Power Spectrum";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  outputs = { self, nixpkgs }: {
    devShells.x86_64-linux.default =
      let
        pkgs = import nixpkgs {
          system = "x86_64-linux";
        };
      in
      pkgs.mkShell {
        packages = [
          pkgs.julia
        ];

        shellHook = ''
          export JULIA_PROJECT="$PWD"
          export JULIA_LOAD_PATH="@:@stdlib"
        '';
      };
  };
}
