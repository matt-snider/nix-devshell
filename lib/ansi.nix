let
  # Nix strings only support \t, \r and \n as escape codes, so actually store
  # the literal escape "ESC" code.
  esc = "\\\\u001B";
in builtins.mapAttrs (_name: value: "${esc}${value}") {
  reset = "[0m";
  bold = "[1m";

  black = "[30m";
  gray = "[90m";

  white = "[37m";
  bright_white = "[97m";

  red = "[31m";
  bright_red = "[91m";

  green = "[32m";
  bright_green = "[92m";

  yellow = "[33m";
  bright_yellow = "[93m";

  blue = "[34m";
  bright_blue = "[94m";

  magenta = "[35m";
  bright_magenta = "[95m";

  cyan = "[36m";
  bright_cyan = "[96m";
}
