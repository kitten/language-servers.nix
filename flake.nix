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
      in
      {
        packages.astro-language-server = pkgs.callPackage ./astro-language-server { inherit bun; };
        packages.typescript-language-server = pkgs.callPackage ./typescript-language-server { inherit bun; };
        packages.vscode-langservers-extracted = pkgs.callPackage ./vscode-langservers-extracted { inherit bun; };

        devShell = pkgs.mkShell {
          buildInputs = [ bun ];
        };
      });
}
