{
  pkgs,
  inputs,
  config,
  ...
}: {
  overlays = [
    (inputs.mkElmDerivation.overlays.mkElmDerivation)
  ];

  # https://devenv.sh/languages/
  languages.elm.enable = true;

  packages = [
    pkgs.elmPackages.elm-live
  ];

  outputs = {
    game = pkgs.mkElmDerivation {
      name = "sagome";
      src = ./.;

      nativeBuildInputs = [pkgs.elmPackages.elm];
      buildPhase = ''
        runHook preBuild

        elm make src/Main.elm --output=static/game.js

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        cp static/index.html $out/
        cp static/game.js $out/
        cp -r static/layers $out/

        runHook postInstall
      '';
    };
  };

  processes.server.exec = ''
    elm-live src/Main.elm --dir=./static --start-page=index.html -- --output=./static/game.js
  '';
}
