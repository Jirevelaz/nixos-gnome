{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    # Ejecución automática al abrir la terminal [cite: 53]
    initExtra = ''
      fastfetch
    '';
  };
}
