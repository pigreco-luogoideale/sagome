{
  inputs = {
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    devenv.url = "github:cachix/devenv";
  };

  outputs = {
    self,
    nixpkgs,
    devenv,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    shell = devenv.lib.mkShell {
      inherit inputs pkgs;
      modules = [
        ./devenv.nix
        {devenv.root = toString ./.;}
      ];
    };
  in {
    devShells.${system}.default = shell;
    packages.${system} = {
      inherit (shell.config.outputs) game;
    };
  };
}
