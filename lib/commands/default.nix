{ config, lib, pkgs, ... }:

with lib;

let
  ansi = import ../ansi.nix;

  commandToPackage = name: cmd:
    assert lib.assertMsg (cmd.text != null && cmd.text != "")
      "${name} requires a definition via the 'text' attribute";
    pkgs.writeShellScriptBin name cmd.text;

  commandsToMenu = { commands, commandCategoryOrder, ... }:
    let
      commands' = mapAttrsToList (name: attrs: attrs // { inherit name; }) commands;

      commandCategories = lib.unique (
        (zipAttrsWithNames [ "category" ] (name: attr: attr) commands').category
      );

      # Map category name to index
      commandCategoryOrder' =
        (builtins.listToAttrs (
          map (c: { name = c; value = 0; }) commandCategories)
        )
        //
        (builtins.listToAttrs (
            imap0 (value: name: { inherit name value; }) commandCategoryOrder
        ));


      commandByCategoriesSorted = builtins.sort
        (a: b: commandCategoryOrder'.${a.name} < commandCategoryOrder'.${b.name or 0})
        # Sorted categories with the commands
        (builtins.attrValues (lib.genAttrs
          commandCategories
          # Sorted commands for this category
          (category: lib.nameValuePair category (builtins.sort
            (a: b: a.name < b.name)
            (builtins.filter (x: x.category == category) commands')
          ))
        ));

      commandLengths =
        map ({ name, ... }: builtins.stringLength name) commands';

      maxCommandLength =
        builtins.foldl'
          (max: v: if v > max then v else max)
          0
          commandLengths;

      pad = str: num:
        if num > 0 then
          pad "${str} " (num - 1)
        else
          str;

      fmtCategory = { name, value }:
        let
          category = name;
          cmd = value;
          fmtCommand = { name, help, ... }:
            let
              len = maxCommandLength - (builtins.stringLength name);
            in
              if help == null || help == "" then
                "  ${name}"
              else
                "  ${pad name len} - ${help}";
        in
          "\n${ansi.bold}[${category}]${ansi.reset}\n\n"
          + builtins.concatStringsSep "\n" (map fmtCommand cmd);
    in
      builtins.concatStringsSep "\n" (map fmtCategory commandByCategoriesSorted) + "\n";

  commandOptions = {
    name = mkOption {
      type = types.str;
    };

    category = mkOption {
      type = types.str;
      default = config.defaultCommandCategory;
      description = ''
        Set a free text category under which this command is grouped
        and shown in the help menu.
      '';
    };

    help = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Describes what the command does in one line of text.
      '';
    };

    text = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = ''
        #!/usr/bin/env python
        print("Hello")
      '';
    };
  };
in {
  options = {
    defaultCommandCategory = mkOption {
      type = types.str;
      default = "general";
    };

   commandCategoryOrder = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        A list of the categories in desired order.
      '';
    };

    commands = mkOption {
      type = types.attrsOf (types.submodule {
        options = commandOptions;
      });
      default = { };
    };
  };

  config = {
    commands = {
      menu = {
        help = "prints this menu";
        text = ''
          echo -e "\
          ${commandsToMenu config}"
        '';
      };
    };

    packages = mapAttrsToList commandToPackage config.commands;

    shellHook = ''
      echo -e "${ansi.bold}${ansi.magenta}🔨 Welcome to ${config.name}!${ansi.reset}"
      menu
    '';
  };
}
