{ config, pkgs, inputs,unstablePkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ./gnome-rice.nix
      #<home-manager/nixos>
    ];

  # ==============================
  # ARRANQUE Y SISTEMA
  # ==============================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];
  system.stateVersion = "25.11"; 
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  

  # Kernel más reciente (Vital para soporte de hardware moderno)
  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  # Desactivar ASPM: Previene la suspensión de la MediaTek MT7921 y latencia alta
  boot.extraModprobeConfig = ''
    options mt7921e disable_aspm=Y
  '';

  # ==============================
  # RED Y COMUNICACIONES
  # ==============================
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    
    # Optimizaciones para Telmex: Desactivar IPv6 y usar DNS rápidos
    enableIPv6 = false; 
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    
    # Evitar caída de velocidad por ahorro de batería en la antena
    networkmanager.wifi.powersave = false;
    
    # Cemu: Permitir telemetría UDP desde el servidor DSU (iPhone)
    firewall.allowedUDPPorts = [ 26760 ];
  };

  # Optimización TCP Stack para aprovechar anchos de banda >100Mbps
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_window_scaling" = 1;
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
  };

  time.timeZone = "America/Matamoros";
  i18n.defaultLocale = "es_MX.UTF-8";

  # ==============================
  # ENTORNO GRÁFICO Y AUDIO
  # ==============================
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.xkb = { layout = "us"; variant = ""; };
  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

# ==============================
  # TIPOGRAFÍAS (Nerd Fonts 3.0+)
  # ==============================
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.droid-sans-mono
  ];

# ==============================
  # CAPA DE COMPATIBILIDAD (NIX-LD)
  # ==============================
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc  # Crítico: Librería estándar de C++ (requerido por esbuild y node-gyp)
    zlib          # Compresión básica, omnipresente en herramientas web
    openssl       # Dependencia común para criptografía y redes
    icu           # Internacionalización (vital para .NET y Node.js)
    vips          # Procesamiento de imágenes (necesario si usas Astro Image con Sharp)
    curl
    util-linux    # Provee dependencias subyacentes como libuuid
  ];
  

  # ==============================
  # USUARIOS Y PAQUETES
  # ==============================
  users.users.jirevelaz = {
    isNormalUser = true;
    description = "Jire Israel Gonzalez Diaz";
    extraGroups = [ "networkmanager" "wheel" ];
  };

programs.firefox.enable = true;
  programs.steam.enable = true;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
  
  # ---------------------------------------------
    # 1. PAQUETES ESTABLES (Cargados desde pkgs)
    # ---------------------------------------------
    # --- Utilidades y Sistema ---
    ptyxis
    gnome-extension-manager
    gnome-tweaks
    fastfetch
    ntfs3g
    cmatrix
    git
    btop
    mediawriter

    # --- Productividad y Comunicación ---
    onlyoffice-desktopeditors
    discord
    teams-for-linux
    figma-linux
    whatsapp-electron
    proton-pass
    protonvpn-gui

    # --- Multimedia y Gaming ---
    spotify
    sayonara
    transmission_4
    heroic
    cemu
    nicotine-plus

  # --- Desarrollo (SDKs Globales) ---
    
    
# .NET SDK 8
    dotnetCorePackages.sdk_8_0
    
    # Node.js y Rust
    nodejs_22
    pnpm
    rustc
    cargo
    gcc            
    pkg-config    
    
    
    # ---------------------------------------------
    # 2. PAQUETES INESTABLES (Llamado explícito)
    # ---------------------------------------------
    
    unstablePkgs.vscode
    unstablePkgs.obsidian
    unstablePkgs.jetbrains.rider
    unstablePkgs.google-chrome
    
    # ---------------------------------------------
    # 3. OVERLAYS Y PERSONALIZADOS
    # ---------------------------------------------
    google-antigravity-no-fhs
  ];

  # Variables de entorno
  environment.variables = {
    DOTNET_ROOT = "${pkgs.dotnetCorePackages.sdk_8_0}";
  };
  
  environment.gnome.excludePackages = (with pkgs; [
    gnome-console
    gnome-terminal
  ]);

  # ==============================
  # CONFIGURACIONES PERSONALIZADAS
  # ==============================
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
  
  # 1. Variable de entorno estándar para scripts y aplicaciones CLI
  environment.variables.TERMINAL = "ptyxis";

  # 2. Sobrescritura de GSettings para la integración con GNOME
  services.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.desktop.default-applications.terminal]
    exec='ptyxis'
    exec-arg='--'
  [org.gnome.desktop.wm.preferences]
    button-layout='close,minimize,maximize:'
  '';
  
  nixpkgs.overlays = [
  
   inputs.antigravity-nix.overlays.default
  
    (final: prev: {
      proton-pass = prev.proton-pass.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ prev.makeWrapper ];
        postFixup = (old.postFixup or "") + ''
          wrapProgram $out/bin/proton-pass \
            --add-flags "--ozone-platform-hint=auto" \
            --add-flags "--app-id=proton-pass" \
            --add-flags "--wm-class=proton-pass"
        '';
        postInstall = (old.postInstall or "") + ''
          if [ -f $out/share/applications/proton-pass.desktop ]; then
            sed -i '/StartupWMClass/d' $out/share/applications/proton-pass.desktop
            echo "StartupWMClass=electron" >> $out/share/applications/proton-pass.desktop
          fi
        '';
      });
    })
  ];
  
  # Montaje automático de SSD 2 con bypass de seguridad
fileSystems."/mnt/ssd2" = {
    device = "/dev/disk/by-label/ssd2";
    fsType = "ext4";
    options = [ 
      "defaults" 
      "nofail" 
      "x-gvfs-show"
    ];
  };
  
  # ==============================
  # REGLAS DE DISPOSITIVOS (UDEV)
  # ==============================
  services.udev.extraRules = ''
    # Regla para permitir a SDL2 leer el Wiimote (Vendor 057e, Product 0306)
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0306", MODE="0666"
  '';
  
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
    package = config.boot.kernelPackages.nvidiaPackages.stable;

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
