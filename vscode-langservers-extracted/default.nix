{ lib, bun, pkgs, ... }:

with builtins; with pkgs;
let
  inherit (fromJSON (readFile ./package.json)) version;
  src = ./.;
  yarnOfflineCache = fetchYarnDeps {
    yarnLock = ./yarn.lock;
    hash = "sha256-IBEYfVrgINScJB2Ro2cu50hP2ebQ3j7JUz6bq+uTXZQ=";
  };
  mkDerivationInputs = (name: yarnBuildScript: {
    inherit name src yarnOfflineCache yarnBuildScript;
    doDist = false;
    buildInputs = [ bun ];
    nativeBuildInputs = [
      makeBinaryWrapper
      yarnConfigHook
      yarnBuildHook
      nodejs
    ];
    postInstall = ''
      mkdir -p $out/build
      cp -r build/** $out/build
      makeBinaryWrapper ${bun}/bin/bun $out/bin/${name} \
        --add-flags "run --bun --prefer-offline --no-install $out/build/index.js"
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
