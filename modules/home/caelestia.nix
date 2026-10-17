{ inputs, ... }:

{
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];

  programs.caelestia = {
    enable = true;
    cli.enable = true;
    # Aquí puedes agregar settings declarativos para shell.json si deseas:
    # settings = {
    #   bar.persistent = true;
    # };
  };
}
