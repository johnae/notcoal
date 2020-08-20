{ nixpkgs ? import <nixpkgs> { } }:

nixpkgs.mkShell {
  buildInputs = [
    nixpkgs.rustc
    nixpkgs.cargo
  ];
}
