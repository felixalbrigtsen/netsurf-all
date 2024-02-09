{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    nativeBuildInputs = with pkgs; [
      (lib.recurseIntoAttrs (callPackage ./netsurf-nix { })).browser
    ];
}
