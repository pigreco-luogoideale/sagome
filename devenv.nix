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

  outputs = {
    game = pkgs.mkElmDerivation {
      name = "stencillogici";
      src = ./.;

      nativeBuildInputs = [pkgs.elmPackages.elm];
      buildPhase = ''
        runHook preBuild

        elm make src/Main.elm --output=game.js

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        cp index.html $out/
        cp game.js $out/
        cp -r layers $out/

        runHook postInstall
      '';
    };
  };
}
