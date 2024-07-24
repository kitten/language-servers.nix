{ bun, pkgs, ... }:

let
  packageJson = builtins.fromJSON (builtins.readFile ./package.json);
  version = builtins.replaceStrings [ "^" "~" ] [ "" "" ] (packageJson.dependencies.vscode-langservers-extracted);

  node-modules = pkgs.mkYarnPackage {
    name = "${packageJson.name}-node-modules";
    src = ./.;
  };
in
pkgs.stdenv.mkDerivation {
  pname = "vscode-langservers-extracted";
  inherit version;
  nativeBuildInputs = [ pkgs.makeBinaryWrapper ];
  buildInputs = [ bun node-modules ];
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

    makeBinaryWrapper ${bun}/bin/bun $out/bin/vscode-css-language-server \
      --add-flags "run --bun --prefer-offline --no-install $out/vscode-css-language-server.js"
    makeBinaryWrapper ${bun}/bin/bun $out/bin/vscode-html-language-server \
      --add-flags "run --bun --prefer-offline --no-install $out/vscode-html-language-server.js"
    makeBinaryWrapper ${bun}/bin/bun $out/bin/vscode-json-language-server \
      --add-flags "run --bun --prefer-offline --no-install $out/vscode-json-language-server.js"
    makeBinaryWrapper ${bun}/bin/bun $out/bin/vscode-eslint-language-server \
      --add-flags "run --bun --prefer-offline --no-install $out/vscode-eslint-language-server.js"
    makeBinaryWrapper ${bun}/bin/bun $out/bin/vscode-markdown-language-server \
      --add-flags "run --bun --prefer-offline --no-install $out/vscode-markdown-language-server.js"
  '';
}
