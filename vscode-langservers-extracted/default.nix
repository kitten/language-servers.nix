{ lib, pkgs, ... }:

with builtins; with pkgs;
let
  inherit (fromJSON (readFile ./package.json)) version;
  src = ./.;
  yarnOfflineCache = fetchYarnDeps {
    yarnLock = ./yarn.lock;
    hash = "sha256-TXgnrF8FiNid6r7geXFzGxRmO2PtDmxQsr/IdAvPdUk=";
  };
  mkDerivationInputs = (name: yarnBuildScript: {
    inherit name src yarnOfflineCache yarnBuildScript;
    doDist = false;
    buildInputs = [ nodejs ];
    nativeBuildInputs = [
      makeBinaryWrapper
      yarnConfigHook
      yarnBuildHook
    ];
    postInstall = ''
      mkdir -p $out/build
      cp -r build/** $out/build
      makeBinaryWrapper ${nodejs}/bin/node $out/bin/${name} --add-flags "$out/build/index.js"
    '';
  });
in {
  vscode-css-language-server =
    stdenv.mkDerivation (mkDerivationInputs "vscode-css-language-server" "build:css");
  vscode-eslint-language-server =
    stdenv.mkDerivation (mkDerivationInputs "vscode-eslint-language-server" "build:eslint");
  vscode-html-language-server =
    stdenv.mkDerivation (mkDerivationInputs "vscode-html-language-server" "build:html");
  vscode-json-language-server =
    stdenv.mkDerivation (mkDerivationInputs "vscode-json-language-server" "build:json");
  vscode-markdown-language-server =
    stdenv.mkDerivation (mkDerivationInputs "vscode-markdown-language-server" "build:markdown");
}
