{ pkgs, ... }:

let
  version =
    let packageJson = with builtins; fromJSON (
      readFile ./package.json);
    in builtins.replaceStrings [ "^" "~" ] [ "" "" ] (packageJson.dependencies.svelte-language-server);

  modules = pkgs.mkYarnModules {
    pname = "svelte-language-server-modules";
    inherit version;
    packageJSON = ./package.json;
    yarnLock = ./yarn.lock;
  };

in
pkgs.stdenv.mkDerivation rec {
  pname = "svelte-language-server";
  inherit version;

  buildInputs = with pkgs; [ rsync ];

  configurePhase = ''
    ln -sf ${modules}/node_modules node_modules
  '';

  installPhase = ''
    mkdir -p $out/bin $out/node_modules
    rsync -a --no-links ${modules}/node_modules $out
    chmod a+rwx $out/node_modules
    rsync -a --no-links ${modules}/deps/${pname}-modules/node_modules $out

    make_start_server () {
      target="$1"
      require="$2"
      echo '#!/usr/bin/env node' >"$1"
      echo "const { startServer } = require('$2');" >>"$1"
      echo "startServer();" >>"$1"
      chmod a+x "$1"
    }

    make_start_server "$out/bin/svelte-language-server" \
      "$out/node_modules/svelte-language-server/dist/src/server"
  '';

  dontUnpack = true;
  dontBuild = true;
}
