{ lib, bun, pkgs, ... }:

let
  packageJson = builtins.fromJSON (builtins.readFile ./package.json);
  version = builtins.replaceStrings [ "^" "~" ] [ "" "" ] (packageJson.dependencies."@astrojs/language-server");

  node-modules = pkgs.mkYarnPackage {
    name = "${packageJson.name}-node-modules";
    src = ./.;
  };
in
pkgs.stdenv.mkDerivation rec {
  pname = "astro-language-server";
  inherit version;
  nativeBuildInputs = [ pkgs.makeBinaryWrapper ];
  buildInputs = [ bun node-modules ];
  dontBuild = true;
  dontConfigure = true;
  dontStrip = true;

  src = [
    ./astro-language-server.js
    ./package.json
  ];

  unpackPhase = ''
    mkdir -p $out/bin
    for srcFile in $src; do
      cp $srcFile "$out/$(stripHash $srcFile)"
    done
  '';

  installPhase = ''
    cd $out
    ln -s ${node-modules}/libexec/${packageJson.name}/node_modules node_modules

    makeBinaryWrapper ${bun}/bin/bun $out/bin/${pname} \
      --add-flags "run --bun --prefer-offline --no-install $out/${pname}.js"
  '';
}
