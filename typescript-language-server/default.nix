{ pkgs, ... }:

let
  version =
    let packageJson = with builtins; fromJSON (
      readFile ./package.json);
    in builtins.replaceStrings [ "^" "~" ] [ "" "" ] (packageJson.dependencies.typescript-language-server);

  modules = pkgs.mkYarnModules {
    pname = "typescript-language-server-modules";
    inherit version;
    packageJSON = ./package.json;
    yarnLock = ./yarn.lock;
  };

in
pkgs.stdenv.mkDerivation rec {
  pname = "typescript-language-server";
  inherit version;

  nativeBuildInputs = with pkgs; [ makeWrapper ];
  buildInputs = with pkgs; [ rsync ];

  configurePhase = ''
    ln -sf ${modules}/node_modules node_modules
  '';

  installPhase = ''
    mkdir -p $out/bin
    rsync -a --no-links ${modules}/node_modules $out
    chmod a+rwx $out/node_modules
    cp -a ${modules}/deps/typescript-language-server-modules/node_modules/typescript-language-server \
      $out/node_modules
    makeWrapper $out/node_modules/typescript-language-server/lib/cli.js $out/bin/${pname}
  '';

  dontUnpack = true;
  dontBuild = true;
}
