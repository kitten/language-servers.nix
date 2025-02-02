{
  description = "Various Language Servers (lsp).";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        bun = pkgs.bun;
        inputs = { inherit bun; };
      in
      {
        packages = let
          vscode-langservers-extracted = pkgs.callPackage ./vscode-langservers-extracted inputs;
        in {
          typescript-language-server = pkgs.callPackage ./typescript-language-server inputs;
          vtsls = pkgs.callPackage ./vtsls inputs;
        } // vscode-langservers-extracted;

        devShell = pkgs.mkShell {
          buildInputs = [ bun ];
        };
      });
}
