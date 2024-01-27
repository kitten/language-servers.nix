{ lib, bun, pkgs, ... }:

let
  version =
    let packageJson = with builtins; fromJSON (
      readFile ./package.json);
    in builtins.replaceStrings [ "^" "~" ] [ "" "" ] (packageJson.dependencies."@astrojs/language-server");
in
pkgs.stdenv.mkDerivation rec {
  pname = "astro-language-server";
  inherit version;
  nativeBuildInputs = [ bun pkgs.makeBinaryWrapper ];
  dontBuild = true;
  dontConfigure = true;
  dontStrip = true;

  src = [
    ./astro-language-server.js
    ./package.json
    ./bun.lockb
  ];

  unpackPhase = ''
    mkdir -p $out/bin
    for srcFile in $src; do
      cp $srcFile "$out/$(stripHash $srcFile)"
    done
  '';

  installPhase = ''
    cd $out
    bun install --no-progress --no-cache --frozen-lockfile
    makeBinaryWrapper ${bun}/bin/bun $out/bin/${pname} \
      --add-flags "run --bun --prefer-offline --no-install $out/${pname}.js"
  '';
}
