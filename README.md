# nix-devshell

A flake-based utility for setting up developer environments.

This project uses ideas and code from [devshell](https://github.com/numtide/devshell), which is a much more sophisticated option. I was mostly interested in creating a simpler version without TOML and other features.

## Example

An example flake.nix file:

```nix
{
  description = "A flake for my-project";

  inputs.devshell.url = "github:matt-snider/nix-devshell";

  outputs = { self, devshell, ... }: {
    devShell.x86_64-linux = devshell.lib.x86_64-linux.mkDevShell {
      name = "my-project";
      commands = {
        build = {
          category = "build";
          help = "build the project";
          text = ''
            #!/bin/env bash
            echo "Building...";
          '';
        };
        clean = {
          category = "build";
          help = "clean the project";
          text = ''
            #!/bin/env bash
            echo "Cleaning...";
          '';
        };
        docs = {
          help = "serve the documents at port 9000";
          text = ''
            #!/bin/env bash
            echo "Starting the document server at localhost:9000...";
          '';
        };
      };
      commandCategoryOrder = [ "general" "build"];
    };
  };
}
```

Activating it will result in the following being output:

```
🔨 Welcome to my-project!

[general]

  docs  - serve the documents at port 9000
  menu  - prints this menu

[build]

  build - build the project
  clean - clean the project
```

## TODO

- Git Hooks
- user.nix override
- Multi Shell (via devShells.x86_64-linux.<other name>)
