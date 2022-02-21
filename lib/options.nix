{ lib, ... }:

with lib;

# Options for the module which get passed to mkShell.
# Defined this way to allow merging with evalModules.
{
  options = {
    name = mkOption {
      type = types.str;
    };

    packages = mkOption {
      type = types.listOf types.package;
      default = [];
    };

    shellHook = mkOption {
      type = types.str;
      default = "";
    };
  };
}
