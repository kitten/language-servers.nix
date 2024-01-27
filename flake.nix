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
        nodejs = pkgs.nodejs_20;
      in
      {
        packages.angular-language-server = pkgs.callPackage ./angular-language-server { inherit nodejs; };
        packages.jdt-language-server = pkgs.callPackage ./jdt-language-server { };
        packages.svelte-language-server = pkgs.callPackage ./svelte-language-server { };
        packages.typescript-language-server = pkgs.callPackage ./typescript-language-server { };
        packages.vscode-langservers-extracted = pkgs.callPackage ./vscode-langservers-extracted { };

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs_20
            yarn
          ];
        };
      });
}
