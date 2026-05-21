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

  outputs = {
    game = pkgs.mkElmDerivation {
      name = "stencillogici";
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
    python3 -m http.server -d ${config.outputs.game}
  '';
}
