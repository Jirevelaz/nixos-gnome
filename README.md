# NixOS Config — jirevelaz

Configuración declarativa completa de NixOS para un **IdeaPad Gaming 3 15ACH6** (AMD Ryzen 5 5600H + NVIDIA RTX 3050 Ti). Arquitectura de flake multicapa: base estable, herramientas inestables, overlays personalizados y browsers externos.

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
| Almacenamiento | 256 GB (sistema) + SSD2 ext4 montado en `/mnt/ssd2` |
| WiFi | MediaTek MT7921 |

---

## Arquitectura del Flake

```
flake.nix
├── nixpkgs              → nixos-25.11 (rama estable, base del sistema)
├── nixpkgs-unstable     → nixos-unstable (VSCode, Obsidian, Rider, Chrome)
├── home-manager         → release-25.11 (sigue nixpkgs estable)
├── antigravity-nix      → IDE Antigravity (sigue nixpkgs-unstable)
└── zen-browser          → youwen5/zen-browser-flake (sigue nixpkgs-unstable)
```

### Decisiones arquitectónicas clave

**Por qué dos ramas de nixpkgs:**
`nixpkgs` estable garantiza un sistema operativo robusto. `nixpkgs-unstable` proporciona versiones recientes de herramientas de desarrollo y aplicaciones de escritorio que se actualizan lentamente en stable.

**Por qué `zen-browser` sigue `nixpkgs-unstable` y no `nixpkgs`:**
Zen Browser es un binario precompilado enlazado contra bibliotecas de sistema modernas (GTK, Wayland, glibc). Forzarlo a seguir `nixpkgs-unstable` — la misma base que usa el flake origen — minimiza el riesgo de incompatibilidad de ABI. Beneficios adicionales:
- Las actualizaciones de seguridad de `nss`, `glibc` y componentes de Wayland quedan bajo tu control con `nix flake update`
- Evita duplicar bibliotecas pesadas (GTK, LLVM, Qt) en `/nix/store`, crítico en disco de 256 GB

**Plan de contingencia si Zen rompe tras un update:**
```bash
# 1. Revertir el sistema al estado anterior
sudo nixos-rebuild switch --rollback

# 2. Comentar la línea follows en flake.nix:
#   inputs.nixpkgs.follows = "nixpkgs-unstable";

# 3. Actualizar solo el input de Zen
nix flake update zen-browser

# 4. Reconstruir (Zen usará su nixpkgs propio)
sudo nixos-rebuild switch --flake .#nixos
```

---

## Estructura de archivos

```
/etc/nixos/
├── flake.nix                    # Punto de entrada, declaración de inputs
├── flake.lock                   # Hashes bloqueados de todos los inputs
├── configuration.nix            # Configuración principal del sistema
├── hardware-configuration.nix   # Generado por nixos-generate-config (no editar)
├── gnome-rice.nix               # Extensiones y tema visual de GNOME
├── home.nix                     # Punto de entrada de Home Manager
├── logo_custom.txt              # Logo ASCII personalizado para fastfetch
└── modules/
    ├── fastfetch.nix            # Configuración de fastfetch (JSONC)
    └── shell.nix                # Configuración de Bash y alias del sistema
```

---

## Paquetes instalados

### Estables (`pkgs` — nixos-25.11)

**Sistema y utilidades**
- `ptyxis` — terminal moderna con soporte Wayland nativo
- `gnome-extension-manager`, `gnome-tweaks` — personalización de GNOME
- `fastfetch` — info del sistema al abrir terminal
- `ntfs3g` — soporte lectura/escritura NTFS (para SSD2 durante migración)
- `cmatrix`, `btop` — utilidades de terminal
- `git`, `mediawriter`

**Productividad y comunicación**
- `onlyoffice-desktopeditors` — suite ofimática
- `discord`, `teams-for-linux`, `whatsapp-electron`
- `figma-linux`
- `proton-pass` — gestor de contraseñas (con overlay Wayland)
- `protonvpn-gui`

**Multimedia y gaming**
- `spotify`, `sayonara` — reproductores de música
- `transmission_4` — cliente BitTorrent
- `heroic` — launcher de Epic Games / GOG
- `cemu` — emulador de Wii U
- `nicotine-plus` — cliente Soulseek

**Desarrollo**
- `dotnetCorePackages.sdk_8_0` — .NET 8 SDK
- `nodejs_22`, `pnpm` — Node.js y gestor de paquetes
- `rustc`, `cargo` — toolchain de Rust
- `gcc`, `pkg-config` — compilador C y utilidades de build

### Inestables (`unstablePkgs` — nixos-unstable)
- `vscode` — editor de código
- `obsidian` — notas en Markdown
- `jetbrains.rider` — IDE para .NET / C#
- `google-chrome`

### Externos (flakes)
- `zen-browser` — navegador basado en Firefox con foco en privacidad
- `google-antigravity-no-fhs` — IDE Antigravity sin FHS wrapper

---

## Hardware: NVIDIA PRIME Offload

El sistema usa **PRIME Offload** para manejar la GPU dual. La GPU AMD integrada maneja el display, la NVIDIA se activa bajo demanda.

```bash
# Ejecutar cualquier aplicación con la GPU NVIDIA
nvidia-offload <comando>

# Ejemplo: iniciar un juego de Steam con GPU dedicada
nvidia-offload heroic
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

> ⚠️ Si cambias los Bus IDs, verifícalos con `lspci | grep -E "VGA|3D"`.

---

## Red y optimizaciones TCP

**WiFi MediaTek MT7921:**
```nix
boot.extraModprobeConfig = "options mt7921e disable_aspm=Y";
```
Deshabilita ASPM para prevenir suspensiones erráticas de la antena y picos de latencia.

**Stack TCP (BBR + Fair Queue):**
Configurado para aprovechar anchos de banda superiores a 100 Mbps (Telmex fibra):
- `tcp_congestion_control = bbr`
- `default_qdisc = fq`
- Buffers de red ampliados a 16 MB

**Otras optimizaciones:**
- IPv6 desactivado (compatibilidad Telmex)
- DNS: `1.1.1.1` y `8.8.8.8`
- WiFi powersave desactivado
- Puerto UDP 26760 abierto (DSU Server para giroscopio iPhone en Cemu)

---

## Gestión de almacenamiento en `/nix/store`

Con disco de 256 GB y rama unstable activa, el store puede saturarse silenciosamente.

```nix
nix = {
  gc = {
    automatic = true;
    dates = "Mon *-*-* 04:00:00";  # Lunes 4AM, fuera de sesiones de juego
    options = "--delete-older-than 7d";
  };
  settings = {
    auto-optimise-store = true;   # Deduplicación mediante hardlinks en tiempo real
    min-free = 10737418240;       # 10 GB — umbral mínimo antes de activar GC
    max-free = 21474836480;       # 20 GB — objetivo de espacio libre tras GC
  };
};

boot.loader.systemd-boot.configurationLimit = 5;  # Máximo 5 generaciones en bootloader
```

**Cómo funciona cada capa:**

| Mecanismo | Cuándo actúa | Qué hace |
|---|---|---|
| `auto-optimise-store` | En cada escritura al store | Deduplica archivos idénticos con hardlinks |
| `min-free` / `max-free` | Durante builds/descargas | GC de emergencia si el disco baja de 10 GB libres |
| `gc.automatic` | Lunes 4AM | Elimina generaciones mayores a 7 días |
| `configurationLimit = 5` | En cada `nixos-rebuild` | Limita entradas en el bootloader a 5 generaciones |

### Alias de emergencia: `nix-nuke`

Disponible en cualquier terminal. Úsalo cuando el disco esté al límite y el GC automático no sea suficiente:

```bash
nix-nuke
```

Ejecuta en secuencia:
1. `nix-env --profile /nix/var/nix/profiles/system --delete-generations old` — rompe el anclaje de todas las generaciones anteriores a la activa
2. `nix-collect-garbage -d` — purga todo lo no anclado
3. `nixos-rebuild boot` — reconstruye el bootloader limpio

> ⚠️ Este alias destruye el historial de rollback. Úsalo solo cuando el disco esté en asfixia real.

---

## Dispositivos y UDEV

**Control Wiimote (Nintendo Wii Remote):**
```nix
services.udev.extraRules = ''
  KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0306", MODE="0666"
'';
```
Permite que SDL2 lea el Wiimote sin permisos de root (necesario para Cemu).

---

## Overlays

### Proton Pass — fix Wayland
Proton Pass no declara correctamente su clase de ventana en Wayland. El overlay fuerza los flags de Ozone y corrige el `StartupWMClass` en el `.desktop`:

```nix
(final: prev: {
  proton-pass = prev.proton-pass.overrideAttrs (old: {
    # Agrega --ozone-platform-hint=auto y corrige WMClass
  });
})
```

---

## GNOME y apariencia

**Tema:** WhiteSur GTK + WhiteSur Icons

**Extensiones activas:**
- `blur-my-shell` — desenfoque en panel y overview
- `burn-my-windows` — animaciones de cierre de ventanas
- `just-perfection` — personalización avanzada del shell
- `dash2dock-lite` — dock estilo macOS
- `compiz-windows-effect` — efecto de gelatina en ventanas
- `compiz-alike-magic-lamp-effect` — animación de minimizado
- `coverflow-alt-tab` — alt-tab con vista 3D
- `media-controls` — controles de reproducción en panel
- `caffeine` — previene suspensión
- `clipboard-indicator` — historial del portapapeles
- `appindicator` — soporte de iconos de bandeja
- `system-monitor`, `top-bar-organizer`, `bluetooth-battery-meter`

**Terminal:** Ptyxis (configurada como terminal por defecto en GNOME y GSettings)

**Fastfetch:** Logo NixOS clásico (`nixos_old`), separador `⟫`, colores cyan/white

---

## Capa de compatibilidad NIX-LD

Permite ejecutar binarios dinámicos no empaquetados en Nix (por ejemplo, scripts de Node.js con binarios nativos, herramientas de .NET, esbuild):

```nix
programs.nix-ld.enable = true;
programs.nix-ld.libraries = [ stdenv.cc.cc, zlib, openssl, icu, vips, curl, util-linux ];
```

**Variable de entorno necesaria para .NET:**
```bash
echo $DOTNET_ROOT  # → /nix/store/.../dotnet-sdk-8.0
```

---

## Flujo de actualizaciones

### Actualización completa del sistema (rutina normal)

Esto actualiza todos los inputs del flake: nixpkgs estable, unstable, home-manager, zen-browser y antigravity-nix. Es el comando que debes correr periódicamente para recibir actualizaciones de seguridad y nuevas versiones de paquetes.

```bash
cd /etc/nixos

# 1. Actualizar todos los inputs (modifica flake.lock)
nix flake update

# 2. Reconstruir y activar
sudo nixos-rebuild switch --flake .#nixos

# 3. Commitear el nuevo lockfile
git add flake.lock
git commit -m "chore: update flake inputs"
git push
```

> ℹ️ `nix flake update` solo modifica `flake.lock`. Tu `flake.nix` no cambia. Los hashes nuevos quedan bloqueados hasta el próximo update.

---

### Actualizar solo un input específico

Útil cuando quieres traer una versión nueva de un paquete concreto sin mover todo el árbol. Por ejemplo, si Zen Browser lanzó una nueva versión:

```bash
nix flake update zen-browser
sudo nixos-rebuild switch --flake .#nixos
git add flake.lock
git commit -m "chore: update zen-browser input"
git push
```

Lo mismo aplica para cualquier otro input:
```bash
nix flake update nixpkgs-unstable   # solo herramientas inestables
nix flake update home-manager       # solo home-manager
nix flake update antigravity-nix    # solo el IDE Antigravity
```

---

### Agregar un paquete estable nuevo

Los paquetes estables viven en `configuration.nix` bajo `environment.systemPackages`. Para agregar uno:

```nix
# En configuration.nix, dentro del bloque environment.systemPackages:
environment.systemPackages = with pkgs; [
  # ... paquetes existentes ...
  nombre-del-paquete   # ← agregar aquí
];
```

Luego:
```bash
sudo nixos-rebuild switch --flake .#nixos
git add configuration.nix
git commit -m "feat: add nombre-del-paquete"
git push
```

Para buscar el nombre correcto del paquete:
```bash
nix search nixpkgs nombre
# o en el navegador: https://search.nixos.org/packages
```

---

### Agregar un paquete inestable nuevo

Los paquetes inestables usan el prefijo `unstablePkgs.` en `configuration.nix`:

```nix
environment.systemPackages = with pkgs; [
  # ...
  unstablePkgs.nombre-del-paquete   # ← prefijo unstablePkgs
];
```

Para buscar en la rama unstable específicamente:
```bash
nix search nixpkgs#nixos-unstable nombre
```

---

### Agregar una extensión de GNOME nueva

Las extensiones de GNOME están declaradas en `gnome-rice.nix`:

```nix
environment.systemPackages = with pkgs; [
  # ...
  gnomeExtensions.nombre-de-extension   # ← formato estándar
];
```

Para buscar extensiones disponibles:
```bash
nix search nixpkgs gnomeExtensions
# o: https://search.nixos.org/packages?query=gnomeExtensions
```

---

### Modificar la configuración y aplicar

Cualquier cambio en archivos `.nix` requiere reconstruir el sistema para activarse:

```bash
# Después de editar cualquier archivo .nix:
sudo nixos-rebuild switch --flake .#nixos

# Si solo quieres probar sin activar (construye pero no cambia la generación activa):
sudo nixos-rebuild build --flake .#nixos

# Si quieres que el cambio aplique en el próximo arranque (sin afectar la sesión actual):
sudo nixos-rebuild boot --flake .#nixos
```

---

### Revertir un cambio que rompe el sistema

NixOS mantiene generaciones anteriores. Si algo deja de funcionar tras un rebuild:

```bash
# Opción 1: Rollback inmediato (vuelve a la generación anterior)
sudo nixos-rebuild switch --rollback

# Opción 2: Elegir una generación específica
nix-env --profile /nix/var/nix/profiles/system --list-generations
sudo nixos-rebuild switch --flake .#nixos  # después de revertir flake.lock

# Opción 3: Desde el bootloader
# Al arrancar, systemd-boot muestra las últimas 5 generaciones.
# Selecciona una anterior con las flechas y Enter.
```

---

### Agregar un nuevo flake externo (como se hizo con Zen Browser)

```nix
# 1. Declarar el input en flake.nix
inputs = {
  nuevo-flake = {
    url = "github:owner/repo";
    inputs.nixpkgs.follows = "nixpkgs-unstable";  # si usa unstable como base
  };
};

# 2. Declararlo en outputs
outputs = { self, nixpkgs, ..., nuevo-flake, ... }@inputs:

# 3. Consumirlo en configuration.nix
environment.systemPackages = with pkgs; [
  inputs.nuevo-flake.packages.${pkgs.stdenv.hostPlatform.system}.default
];
```

Luego:
```bash
sudo nixos-rebuild switch --flake .#nixos
git add flake.nix flake.lock configuration.nix
git commit -m "feat: add nuevo-flake"
git push
```

---

## Comandos de mantenimiento y diagnóstico

```bash
# Reconstruir y activar la configuración actual
sudo nixos-rebuild switch --flake .#nixos

# Ver qué generaciones existen
nix-env --profile /nix/var/nix/profiles/system --list-generations

# Verificar espacio libre en el store
df -h /nix/store

# Ver cuánto ocupa el store en total
du -sh /nix/store

# Forzar GC manual (respeta los GC roots / generaciones vivas)
nix-collect-garbage --delete-older-than 7d

# Purga de emergencia — destruye historial de rollback (usar solo en asfixia)
nix-nuke

# Verificar que el flake está bien formado antes de reconstruir
nix flake check

# Ver el árbol de dependencias de un paquete
nix-store --query --references $(which zen)

# Revertir a la generación anterior
sudo nixos-rebuild switch --rollback

# Subir cambios al repositorio
git add -A
git commit -m "chore: descripción del cambio"
git push
```

---

## Variables de entorno relevantes

| Variable | Valor | Propósito |
|---|---|---|
| `DOTNET_ROOT` | ruta del SDK en store | Requerido por herramientas .NET |
| `NIXOS_OZONE_WL` | `1` | Fuerza Ozone/Wayland en apps Electron |
| `TERMINAL` | `ptyxis` | Terminal por defecto en CLI |

---

## Notas adicionales

- `hardware-configuration.nix` es generado automáticamente por `nixos-generate-config`. No editar manualmente salvo para ajustes de UUIDs.
- El SSD2 está montado con `nofail` — el sistema arranca aunque el disco no esté presente.
- `programs.firefox.enable = true` está declarado pero Firefox no está en `systemPackages` — solo habilita las integraciones del sistema (como 1Password). El navegador principal es Zen Browser.
- Steam tiene soporte para bibliotecas 32-bit activado a través de `hardware.graphics.enable32Bit = true`.
