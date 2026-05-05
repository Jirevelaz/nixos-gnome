{ config, pkgs, ... }:
{
  programs.bash = {
    enable = true;
    shellAliases = {
      nix-nuke = "sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations old && sudo nix-collect-garbage -d && sudo nixos-rebuild boot";
    };
    initExtra = ''
      fastfetch
    '';
  };
}
