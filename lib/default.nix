{ pkgs }:

let
  lib = pkgs.lib;
in {
  mkDevShell = configuration:
    let
      modules = [
        ./commands
        ./options.nix
      ];

      pkgsModule = { ... }: {
        config = {
          _module.args.baseModules = modules;
          _module.args.pkgsPath = lib.mkDefault pkgs.path;
          _module.args.pkgs = lib.mkDefault pkgs;
        };
      };

      module = lib.evalModules {
        modules = [
          configuration
          pkgsModule
        ] ++ modules;
      };

      rest = builtins.removeAttrs module.config [
        "commands"
        "defaultCommandCategory"
      ];
    in pkgs.mkShell rest;
}
