{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnome-extension-manager
    gnome-tweaks
    
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
    gnomeExtensions.dash2dock-lite
    gnomeExtensions.system-monitor
    gnomeExtensions.top-bar-organizer
    gnomeExtensions.bluetooth-battery-meter
    gnomeExtensions.compiz-alike-magic-lamp-effect
  ];

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
          command = "kitty";
          binding = "<Control><Alt>t";
        };
      };
    }];
  };   
}
