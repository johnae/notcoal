{
  description = "Notmuch initial tagging";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, flake-utils, ... }@inputs:
    let
      genAttrs' = values: f: builtins.listToAttrs (map f values);
      package = pkgs: {
        pname = "notcoal";
        version = "v0.3.0";
        src = self;
        cargoSha256 = "sha256-JjwW/9JlsGPfsInZlLiVCHLKkzVIorEUDV5RLLmE5hY=";
        doCheck = false;
        cargoBuildFlags = [ "--features standalone" ];
        nativeBuildInputs = [ pkgs.pkgconfig ];
        buildInputs = [ pkgs.notmuch ];
        meta = {
          license = pkgs.stdenv.lib.licenses.mit;
          maintainers = [
            {
              email = "john@insane.se";
              github = "johnae";
              name = "John Axel Eriksson";
            }
          ];
        };
      };
    in
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          nixpkgs = import inputs.nixpkgs {
            localSystem = { inherit system; };
            config = {
              allowUnfree = true;
            };
          };
        in
        {

          defaultPackage = nixpkgs.rustPlatform.buildRustPackage (package nixpkgs);
          devShell = import ./shell.nix { inherit nixpkgs; };

        }
      ) // {
      overlay = final: prev: {
        notcoal = prev.rustPlatform.buildRustPackage (package prev);
      };

    };
}
