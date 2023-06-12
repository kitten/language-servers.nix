{ pkgs, ... }:

let
  version =
    let packageJson = with builtins; fromJSON (
      readFile ./package.json);
    in builtins.replaceStrings [ "^" "~" ] [ "" "" ] (packageJson.dependencies.vscode-langservers-extracted);

  modules = pkgs.mkYarnModules {
    pname = "vscode-langservers-extracted-modules";
    inherit version;
    packageJSON = ./package.json;
    yarnLock = ./yarn.lock;
  };

in
pkgs.stdenv.mkDerivation {
  pname = "vscode-langservers-extracted";
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
    cp -a ${modules}/deps/vscode-langservers-extracted-modules/node_modules/vscode-langservers-extracted \
      $out/node_modules

    make_start () {
      target="$1"
      require="$2"
      echo '#!/usr/bin/env node' >"$1"
      echo "require('$2');" >>"$1"
      chmod a+x "$1"
    }

    make_start "$out/bin/vscode-css-language-server" \
      "$out/node_modules/vscode-langservers-extracted/lib/css-language-server/node/cssServerMain.js"

    make_start "$out/bin/vscode-html-language-server" \
      "$out/node_modules/vscode-langservers-extracted/lib/html-language-server/node/htmlServerMain.js"

    make_start "$out/bin/vscode-json-language-server" \
      "$out/node_modules/vscode-langservers-extracted/lib/json-language-server/node/jsonServerMain.js"

    make_start "$out/bin/vscode-eslint-language-server" \
      "$out/node_modules/vscode-langservers-extracted/lib/eslint-language-server/eslintServer.js"
  '';

  dontUnpack = true;
  dontBuild = true;
}
