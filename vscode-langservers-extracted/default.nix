{ bun, pkgs, ... }:

let
  node = pkgs.nodejs_22;
  version =
    let packageJson = with builtins; fromJSON (
      readFile ./package.json);
    in builtins.replaceStrings [ "^" "~" ] [ "" "" ] (packageJson.dependencies.vscode-langservers-extracted);
in
pkgs.stdenv.mkDerivation {
  pname = "vscode-langservers-extracted";
  inherit version;
  nativeBuildInputs = [ bun node pkgs.makeBinaryWrapper ];
  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  src = [
    ./vscode-css-language-server.js
    ./vscode-html-language-server.js
    ./vscode-json-language-server.js
    ./vscode-eslint-language-server.js
    ./vscode-markdown-language-server.js
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
    makeBinaryWrapper ${bun}/bin/bun $out/bin/vscode-css-language-server \
      --add-flags "run --bun --prefer-offline --no-install $out/vscode-css-language-server.js"
    makeBinaryWrapper ${bun}/bin/bun $out/bin/vscode-html-language-server \
      --add-flags "run --bun --prefer-offline --no-install $out/vscode-html-language-server.js"
    makeBinaryWrapper ${bun}/bin/bun $out/bin/vscode-json-language-server \
      --add-flags "run --bun --prefer-offline --no-install $out/vscode-json-language-server.js"
    makeBinaryWrapper ${node}/bin/node $out/bin/vscode-eslint-language-server \
      --add-flags "$out/vscode-eslint-language-server.js"
    makeBinaryWrapper ${bun}/bin/bun $out/bin/vscode-markdown-language-server \
      --add-flags "run --bun --prefer-offline --no-install $out/vscode-markdown-language-server.js"
  '';
}
