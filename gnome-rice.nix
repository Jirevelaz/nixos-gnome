{ pkgs, ... }:

{
  # 1. Paquetes: Corroborados y listos para descargar
  environment.systemPackages = with pkgs; [
    whitesur-gtk-theme
    whitesur-icon-theme
    gnomeExtensions.blur-my-shell
    gnomeExtensions.burn-my-windows
    gnomeExtensions.search-light
    gnomeExtensions.just-perfection
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.appindicator
    gnomeExtensions.coverflow-alt-tab
    gnomeExtensions.compiz-windows-effect
    gnomeExtensions.media-controls
    gnomeExtensions.caffeine
    pkgs.gnomeExtensions.dash2dock-lite
    pkgs.gnomeExtensions.system-monitor
    pkgs.gnomeExtensions.top-bar-organizer
    pkgs.gnomeExtensions.bluetooth-battery-meter
    gnomeExtensions.compiz-alike-magic-lamp-effect
  ];

  # 2. Forzar dconf para tu usuario
  # Nota: Esto aplica los valores a nivel de base de datos de dconf
  programs.dconf = {
    enable = true;
    profiles.user.databases = [{
      settings = {
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          name = "Terminal";
          command = "ptyxis";
          binding = "<Control><Alt>t";
        };
      };
    }];
  };   
}      
