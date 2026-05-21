{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  overlays = [
    (inputs.mkElmDerivation.overlays.mkElmDerivation)
  ];
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = [
    pkgs.git
    pkgs.fontconfig
    pkgs.pkg-config
    # Slint runtime dependencies
    pkgs.libxkbcommon
    pkgs.wayland
    pkgs.mesa
    pkgs.libx11
    pkgs.libxcursor
    pkgs.libxrandr
    pkgs.libxi
    pkgs.libGL
  ];

  env.LD_LIBRARY_PATH = lib.makeLibraryPath [
    pkgs.libxkbcommon
    pkgs.wayland
    pkgs.mesa
    pkgs.libx11
    pkgs.libxcursor
    pkgs.libxrandr
    pkgs.libxi
    pkgs.libGL
  ];

  # https://devenv.sh/languages/
  languages.rust.enable = true;
  languages.elm.enable = true;

  # https://devenv.sh/processes/
  # processes.dev.exec = "${lib.getExe pkgs.watchexec} -n -- ls -la";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/scripts/
  scripts.hello.exec = ''
    echo hello from $GREET
  '';

  # https://devenv.sh/basics/
  enterShell = ''
    hello         # Run scripts directly
    git --version # Use packages
  '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

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

  # https://devenv.sh/git-hooks/
  # git-hooks.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
