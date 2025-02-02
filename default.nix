{
  pkgs ? import <nixpkgs> { },
  system ? pkgs.stdenv.system
}:

let
  inputs = { inherit (pkgs) bun; };
  vscode-langservers-extracted = pkgs.callPackage ./vscode-langservers-extracted inputs;
  typescript-language-server = pkgs.callPackage ./typescript-language-server inputs;
  vtsls = pkgs.callPackage ./vtsls inputs;
in {
  inherit typescript-language-server vtsls;
  inherit (vscode-langservers-extracted)
    vscode-css-language-server
    vscode-eslint-language-server
    vscode-html-language-server
    vscode-json-language-server
    vscode vscode-markdown-language-server;
}
