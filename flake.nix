{
  description = "Notmuch initial tagging";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, flake-utils, ... }@inputs:
    let
      genAttrs' = values: f: builtins.listToAttrs (map f values);
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

          devShell = import ./shell.nix { inherit nixpkgs; };

        }
      ) // {
      overlay = final: prev: {
        notcoal = prev.rustPlatform.buildRustPackage {
          pname = "notcoal";
          version = "v0.3.0";
          src = self;
          cargoSha256 = "sha256-OhVg5r24Zfjr2bY3dkRg6rztFQB9oPlp6LB04ETbElw=";
          doCheck = false;
          meta = {
            license = prev.stdenv.lib.licenses.mit;
            maintainers = [
              {
                email = "john@insane.se";
                github = "johnae";
                name = "John Axel Eriksson";
              }
            ];
          };
        };
      };

    };
}
