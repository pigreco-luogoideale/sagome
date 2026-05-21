{
  pkgs,
  lib,
  inputs,
  ...
}: {
  overlays = [
    (inputs.mkElmDerivation.overlays.mkElmDerivation)
  ];

  # https://devenv.sh/languages/
  languages.elm.enable = true;

  scripts.do-build.exec = ''
    elm make src/Main.elm --output=dist/game.js
    cp -r layers dist/
  '';

  outputs = {
    game = pkgs.mkElmDerivation {
      name = "stencillogici";
      src = ./.;

      nativeBuildInputs = [pkgs.elmPackages.elm];
      buildPhase = ''
        runHook preBuild

        elm make src/Main.elm --output=dist/game.js

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        cp dist/index.html $out/
        cp dist/game.js $out/
        cp -r layers $out/

        runHook postInstall
      '';
    };
  };
}
