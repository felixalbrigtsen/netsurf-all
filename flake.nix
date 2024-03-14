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

      pwndbgWrapped = pkgs.stdenvNoCC.mkDerivation {
        name = "pwndbgWrapped";
        phases = [ "installPhase" ];
        # ln is broken, see https://github.com/NixOS/nix/issues/9579
        installPhase = ''
          mkdir -p $out/bin
          cp ${pkgs.pwndbg}/bin/pwndbg $out/bin/gdb
        '';
      };

      default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          zsh

          aflplusplus
          flawfinder

          (lib.recurseIntoAttrs (callPackage ./netsurf-nix { })).browser
        ] ++ lib.optionals stdenv.isLinux [
          pwndbgWrapped
        ];

        shellHook = ''
          zsh
          exit
        '';
      };
    });
  };
}

