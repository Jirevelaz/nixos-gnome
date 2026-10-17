{ ... }:

{
  imports = [
    ./appearance.nix
    ./keybinds.nix
    ./windowrules.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false; # Ya usamos UWSM en modules/nixos/hyprland.nix

    settings = {
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$browser" = "helium";
      "$editor" = "zeditor";
      "$fileManager" = "nautilus";

      monitor = [ ",preferred,auto,1" ];

      exec-once = [
        "caelestia shell -d"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad.natural_scroll = true;
      };
    };
  };
}
