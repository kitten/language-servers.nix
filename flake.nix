{
  description = "Various Language Servers (lsp).";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      default = pkgs: import ./default.nix { inherit pkgs; };
    in
    {
      overlays.default = final: prev: default prev;
    }
    //
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = default pkgs;
        devShell = with pkgs; pkgs.mkShell {
          buildInputs = [ bun ];
        };
      });
}
