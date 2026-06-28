{ config, pkgs, unstablePkgs, inputs,... }:

{
  home.username = "jirevelaz";
  home.homeDirectory = "/home/jirevelaz";
  home.stateVersion = "26.05"; 
  
  
  home.packages = with pkgs; [
  
  discord
  onlyoffice-desktopeditors
  protonvpn-gui
  nicotine-plus
  obs-studio
  lazygit
  lazydocker
  protonup-qt
  neovim
  fastfetch
  proton-pass
  spotify
  hyfetch
  mediawriter
  cmatrix
  unstablePkgs.zed-editor-fhs
  kitty
  unstablePkgs.spotatui
  unstablePkgs.opencode
  ];

  programs.home-manager.enable = true;
}
