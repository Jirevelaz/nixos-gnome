# NixOS Config — jirevelaz

Configuración declarativa de NixOS para un **IdeaPad Gaming 3 15ACH6** (AMD Ryzen 5 5600H + NVIDIA RTX 3050 Ti). Arquitectura de flake multicapa: base estable 26.05, herramientas de la rama unstable y browsers externos.

---

## Hardware

| Componente | Detalle |
|---|---|
| Modelo | Lenovo IdeaPad Gaming 3 15ACH6 |
| CPU | AMD Ryzen 5 5600H (12 hilos @ 4.28 GHz) |
| GPU primaria | AMD Radeon Vega (integrada) |
| GPU discreta | NVIDIA GeForce RTX 3050 Ti Mobile |
| RAM | 13.5 GB |
| Pantalla | 1920×1080 @ 120 Hz, 15" |
| WiFi | MediaTek MT7921 |

---

## Arquitectura del Flake

```
flake.nix
├── nixpkgs              → nixos-26.05 (base estable del sistema)
├── nixpkgs-unstable     → nixos-unstable (zed-editor, spotatui, opencode)
├── home-manager         → release-26.05 (sigue nixpkgs estable)
└── helium               → schembriaiden/helium-browser-nix-flake (sigue nixpkgs)
```

**Por qué dos ramas de nixpkgs:**
`nixpkgs` estable garantiza un sistema robusto y reproducible. `nixpkgs-unstable` se usa puntualmente para herramientas de desarrollo que se actualizan lentamente en stable (Zed, OpenCode).

**Por qué `helium` sigue `nixpkgs`:**
Helium Browser es un binario prelinkado. Hacerlo seguir la misma base que el sistema (`nixos-26.05`) minimiza el riesgo de incompatibilidad de ABI y evita duplicar bibliotecas pesadas como GTK y glibc en `/nix/store`.

---

## Estructura de archivos

```
/etc/nixos/
├── flake.nix                    # Punto de entrada, declaración de inputs
├── flake.lock                   # Hashes bloqueados de todos los inputs
├── configuration.nix            # Configuración principal del sistema
├── gnome.nix                    # Extensiones, tema visual y dconf de GNOME
├── home.nix                     # Configuración de Home Manager (paquetes de usuario)
└── hardware-configuration.nix   # Generado por nixos-generate-config (no editar)
```

---

## Paquetes

### Sistema (`configuration.nix` — `pkgs` nixos-26.05)

- `git`, `tree`, `btop`, `pciutils` — utilidades base
- `helium` — navegador principal (vía flake externo)
- `steam` — gaming (con soporte 32-bit habilitado)

### GNOME (`gnome.nix`)

- `gnome-extension-manager`, `gnome-tweaks` — personalización
- `whitesur-gtk-theme`, `whitesur-icon-theme` — tema visual

### Usuario (`home.nix` — via Home Manager)

**Estables (`pkgs`):**
- `discord`, `onlyoffice-desktopeditors`, `protonvpn-gui` — comunicación y ofimática
- `spotify`, `nicotine-plus` — música
- `obs-studio` — grabación/streaming
- `neovim`, `lazygit`, `lazydocker` — desarrollo en terminal
- `fastfetch`, `hyfetch`, `cmatrix` — utilidades de terminal
- `proton-pass` — gestor de contraseñas
- `protonup-qt` — gestión de versiones de Proton
- `kitty` — terminal
- `mediawriter` — creación de USBs bootables

**Inestables (`unstablePkgs`):**
- `zed-editor-fhs` — editor de código
- `spotatui` — cliente TUI de Spotify
- `opencode` — agente de IA para terminal

---

## GNOME y apariencia

**Tema:** WhiteSur GTK + WhiteSur Icons

**Extensiones activas:**
- `blur-my-shell` — desenfoque en panel y overview
- `burn-my-windows` — animaciones de cierre de ventanas
- `just-perfection` — personalización avanzada del shell
- `search-light` — búsqueda rápida con spotlight
- `dash2dock-lite` — dock estilo macOS
- `coverflow-alt-tab` — alt-tab con vista 3D
- `compiz-windows-effect` — efecto de gelatina en ventanas
- `compiz-alike-magic-lamp-effect` — animación de minimizado
- `media-controls` — controles de reproducción en panel
- `caffeine` — previene suspensión
- `clipboard-indicator` — historial del portapapeles
- `appindicator` — soporte de iconos de bandeja del sistema
- `system-monitor`, `top-bar-organizer`, `bluetooth-battery-meter`

**Terminal por defecto:** Kitty (`Ctrl+Alt+T`)

---

## Hardware: NVIDIA PRIME Offload

La GPU AMD integrada maneja el display; la NVIDIA se activa bajo demanda mediante PRIME Offload.

```bash
# Ejecutar cualquier aplicación con la GPU NVIDIA
nvidia-offload <comando>

# Ejemplo
nvidia-offload %command%   # en opciones de lanzamiento de Steam
```

Configuración en `configuration.nix`:
```nix
hardware.nvidia.prime = {
  offload.enable = true;
  offload.enableOffloadCmd = true;
  amdgpuBusId = "PCI:6:0:0";
  nvidiaBusId = "PCI:1:0:0";
};
```

> ⚠️ Si los Bus IDs cambian, verifícalos con `lspci | grep -E "VGA|3D"`.

---

## Red y optimizaciones TCP

**Stack TCP (BBR + Fair Queue):**
Configurado para anchos de banda superiores a 100 Mbps:
- `tcp_congestion_control = bbr`
- `default_qdisc = fq`
- Buffers de red ampliados a 16 MB

**Otras configuraciones:**
- DNS: `1.1.1.1` y `8.8.8.8`
- WiFi powersave desactivado
- Kernel latest (`linuxPackages_latest`)

---

## Flujo de actualizaciones

### Actualización completa (rutina normal)

```bash
cd /etc/nixos
nix flake update
sudo nixos-rebuild switch --flake .#nixos
git add flake.lock
git commit -m "chore: update flake inputs"
git push
```

> `nix flake update` solo modifica `flake.lock`. Tu `flake.nix` no cambia.

### Actualizar un input específico

```bash
# Solo Helium Browser
nix flake update helium
sudo nixos-rebuild switch --flake .#nixos

# Solo herramientas unstable
nix flake update nixpkgs-unstable
sudo nixos-rebuild switch --flake .#nixos
```

### Agregar un paquete

**Estable** → en `configuration.nix` o `home.nix`:
```nix
home.packages = with pkgs; [
  nombre-del-paquete
];
```

**Inestable** → con prefijo `unstablePkgs.`:
```nix
home.packages = with pkgs; [
  unstablePkgs.nombre-del-paquete
];
```

Buscar paquetes:
```bash
nix search nixpkgs nombre
# o: https://search.nixos.org/packages
```

### Revertir un cambio que rompe el sistema

```bash
# Rollback inmediato
sudo nixos-rebuild switch --rollback

# Desde el bootloader
# systemd-boot muestra las últimas generaciones al arrancar;
# selecciona una anterior con las flechas y Enter.
```

---

## Comandos de mantenimiento

```bash
# Reconstruir y activar
sudo nixos-rebuild switch --flake .#nixos

# Construir sin activar (prueba)
sudo nixos-rebuild build --flake .#nixos

# Activar en el próximo arranque sin afectar la sesión actual
sudo nixos-rebuild boot --flake .#nixos

# Verificar que el flake está bien formado
nix flake check

# Ver generaciones existentes
nix-env --profile /nix/var/nix/profiles/system --list-generations

# GC manual (respeta generaciones vivas)
nix-collect-garbage --delete-older-than 7d

# Verificar espacio libre
df -h /

# Subir cambios al repositorio
git add -A
git commit -m "chore: descripción"
git push
```

---

## Notas

- `hardware-configuration.nix` es generado automáticamente. No editar manualmente.
- `programs.firefox.enable = true` está declarado para habilitar integraciones del sistema (1Password, etc.), pero el navegador principal es Helium.
- Docker está habilitado; el usuario `jirevelaz` pertenece al grupo `docker`.
- `programs.nix-ld.enable = true` permite ejecutar binarios dinámicos no empaquetados en Nix.
- Variables de entorno `NIXOS_OZONE_WL=1` y `ELECTRON_OZONE_PLATFORM_HINT=auto` fuerzan Wayland en apps Electron.
