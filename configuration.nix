{ config, pkgs, inputs, unstablePkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./gnome.nix
    ];

  # ==============================
  # BOOTLOADER & SYSTEM
  # ==============================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  system.stateVersion = "26.05";
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
  #boot.kernelPackages = pkgs.linuxPackages_latest;

  # ==============================
  # NETWORKING
  # ==============================
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    networkmanager.wifi.powersave = false;
    firewall.enable = true;
  };

  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_window_scaling" = 1;
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
  };

  # ==============================
  # LOCALIZATION
  # ==============================
  time.timeZone = "America/Matamoros";
  i18n.defaultLocale = "en_US.UTF-8";

  # ==============================
  # DESKTOP ENVIRONMENT & X11
  # ==============================
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.xkb = { layout = "us"; variant = ""; };
  services.printing.enable = true;

  # ==============================
  # AUDIO (Pipewire)
  # ==============================
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ==============================
  # TYPOGRAPHY
  # ==============================
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.droid-sans-mono
  ];

  # ==============================
  # USER ACCOUNT
  # ==============================
  users.users."jirevelaz" = {
    isNormalUser = true;
    description = "Jire Israel Gonzalez Diaz";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.fish;
  };

  # ==============================
  # PROGRAMS & PACKAGES
  # ==============================
  nixpkgs.config.allowUnfree = true;
  programs.firefox.enable = true;
  programs.fish.enable = true;
  programs.steam.enable = true;
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    ptyxis
    git
    tree
    btop
    pciutils
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.spotifast.packages."${pkgs.stdenv.hostPlatform.system}".default
  ];

  # ==============================
  # VIRTUALISATION
  # ==============================
  virtualisation.docker.enable = true;

  # ==============================
  # WAYLAND VARIABLES
  # ==============================
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  # ==============================
  # HARDWARE: NVIDIA PRIME OFF-LOAD
  # ==============================
  hardware.enableAllFirmware = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      amdgpuBusId = "PCI:6:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
