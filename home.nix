{ config, pkgs, ... }:

{
  home.username = "jirevelaz";
  home.homeDirectory = "/home/jirevelaz";
  home.stateVersion = "25.11";

  imports = [
    ./modules/fastfetch.nix
    ./modules/shell.nix
  ];
}
