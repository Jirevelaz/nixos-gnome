{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    # Reglas de ventanas (opacidad específica, ventanas flotantes, etc.)
    windowrulev2 = [
      "suppressevent maximize, class:.*"
      "float, class:^(org\\.pulseaudio\\.pavucontrol)$"
      "float, title:^(Picture-in-Picture)$"
      "pin, title:^(Picture-in-Picture)$"
    ];
  };
}
