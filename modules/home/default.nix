{ config, pkgs, unstablePkgs, inputs, ... }:

{
  imports = [
    ./caelestia.nix
    ./hyprland
  ];

  home.username = "jirevelaz";
  home.homeDirectory = "/home/jirevelaz";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    onlyoffice-desktopeditors
    proton-vpn
    lazygit
    lazydocker
    protonup-qt
    neovim
    fastfetch
    proton-pass
    hyfetch
    cmatrix
    kitty
    zed-editor
    opencode
    inputs.antigravity-nix.packages.${pkgs.system}.google-antigravity-cli
  ];

  programs.home-manager.enable = true;
}
