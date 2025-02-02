{ lib, bun, pkgs, ... }:

with builtins; with pkgs;
let
  inherit (fromJSON (readFile ./package.json)) version;
in
stdenv.mkDerivation rec {
  name = "typescript-language-server";
  inherit version;
  src = ./.;
  doDist = false;
  yarnOfflineCache = fetchYarnDeps {
    yarnLock = ./yarn.lock;
    hash = "sha256-cHZ55bYBJxTeDMOvdULugF7Oy+jXLDIDaX6hB3jL+GM=";
  };
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
}
