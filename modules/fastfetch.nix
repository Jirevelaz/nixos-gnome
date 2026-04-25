{ config, pkgs, ... }:

{
  # Vinculación del logo ASCII [cite: 47]
  xdg.configFile."fastfetch/logo_custom.txt".source = ../logo_custom.txt;

  # Configuración estética del JSONC [cite: 48-51]
  xdg.configFile."fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "logo": {
        "type": "file",
        "source": "${config.xdg.configHome}/fastfetch/logo_custom.txt",
        "color": { "1": "bright_cyan" },
        "padding": { "top": 0, "right": 2 }
      },
      "display": {
        "separator": " ⟫ ",
        "color": {
          "keys": "cyan",
          "title": "bright_white"
        }
      },
      "modules": [
        { "type": "title", "color": { "user": "bright_white", "at": "cyan", "host": "bright_white" } },
        "separator",
        { "type": "os", "outputColor": "bright_white" },
        { "type": "host", "outputColor": "bright_white" },
        { "type": "kernel", "outputColor": "bright_white" },
        { "type": "uptime", "outputColor": "bright_white" },
        { "type": "packages", "outputColor": "bright_white" },
        { "type": "shell", "outputColor": "bright_white" },
        { "type": "display", "outputColor": "bright_white" },
        { "type": "de", "outputColor": "bright_white" },
        { "type": "wm", "outputColor": "bright_white" },
        { "type": "terminal", "outputColor": "bright_white" },
        { "type": "cpu", "outputColor": "bright_white" },
        { "type": "gpu", "outputColor": "bright_white" },
        { "type": "memory", "outputColor": "bright_white" },
        "break",
        { "type": "colors", "symbol": "circle" }
      ]
    }
  '';
}
