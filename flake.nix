{
  description = "NetSurf flake for bachelor pentesting";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable-small";
  };

  outputs = { self, nixpkgs, unstable, ... }@inputs:
  let
    systems = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
  in {
    devShells = forAllSystems (system: rec {
      pkgs = import nixpkgs { inherit system; };
      pkgs-unstable = import unstable { inherit system; };

      default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          zsh

          aflplusplus
          flawfinder

          (lib.recurseIntoAttrs (callPackage ./netsurf-nix { })).browser
        ] ++ lib.optionals stdenv.isLinux [
          pwndbg
        ];

        shellHook = ''
          zsh
          exit
        '';
      };
    });
  };
}

