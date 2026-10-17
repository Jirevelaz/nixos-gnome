# NixOS Config — jirevelaz

Configuración declarativa y modular de NixOS para Lenovo IdeaPad Gaming 3 15ACH6 (AMD Ryzen 5 5600H + NVIDIA GeForce RTX 3050 Ti Mobile).

El sistema está estructurado mediante Nix Flakes y Home Manager sobre el canal `nixos-26.05`, implementando una arquitectura de escritorio dual (GNOME + Hyprland) con gestión estética unificada mediante Caelestia y Starship.

---

## Hardware

| Componente | Especificación |
| :--- | :--- |
| **Equipo** | Lenovo IdeaPad Gaming 3 15ACH6 |
| **CPU** | AMD Ryzen 5 5600H (6C/12T) |
| **iGPU** | AMD Radeon Graphics |
| **dGPU** | NVIDIA GeForce RTX 3050 Ti Mobile |

---

## Decisiones de Arquitectura y Diseño

### 1. Entorno Híbrido: GNOME + Hyprland
La convivencia de dos entornos gráficos responde a una necesidad funcional entre estabilidad y flujo de trabajo ágil:

* **Hyprland (Sesión Principal de Trabajo):** Compositor Wayland dinámico enfocado en productividad por teclado, bajo consumo de recursos en segundo plano y latencia reducida. El control granular de ventanas mediante `windowrules.nix` y atajos en `keybinds.nix` permite un espacio de trabajo libre de distracciones.
* **GNOME (Sesión de Contingencia / General):** Sirve como entorno completo de respaldo para tareas de consumo multimedia, calibración de múltiples pantallas o software dependiente de portales específicos de escritorio (XDG) donde la configuración manual de Wayland requiera depuración sin frenar el flujo diario.

### 2. Estética y Shell: Caelestia + Starship
* **Caelestia (`modules/home/caelestia.nix`):** Centraliza la coherencia visual, temas y assets compartidos entre los diferentes componentes del escritorio. En lugar de dispersar variables de estilo y colores en dotfiles individuales, Caelestia define una base visual uniforme para las interfaces y el compositor.
* **Starship Prompt:** Proporciona retroalimentación contextual inmediata en terminal (estado de Git, entorno activo de Nix Shell, runtime de lenguajes) con un tiempo de renderizado mínimo, integrándose sin fricción tanto en sesiones de terminal estándar como en emuladores embebidos en el tiling window manager.

### 3. Modularización: Desacoplamiento Sistema / Usuario
El repositorio adopta el patrón modular estándar de Flakes:
* **`hosts/nixos/`**: Define estrictamente la capa de máquina (kernel, parámetros de hardware, GPU offloading/PRIME para Ryzen + NVIDIA, usuarios y bootloader).
* **`modules/nixos/`**: Activa servicios a nivel raíz (`gnome.nix`, `hyprland.nix`), controlando qué subsistemas y display managers existen en el SO.
* **`modules/home/`**: Administra de forma aislada la experiencia de usuario con Home Manager. Separar Hyprland en `appearance.nix`, `keybinds.nix` y `windowrules.nix` permite modificar atajos o temas sin recompilar componentes del sistema base.

---

## Estructura del Repositorio

```text
.
├── flake.lock
├── flake.nix
├── hosts/
│   └── nixos/
│       ├── configuration.nix       # Base del sistema, servicios y cuentas
│       └── hardware-configuration.nix # Módulos de kernel, discos y drivers
└── modules/
    ├── home/
    │   ├── caelestia.nix           # Capa estética y variables de tema
    │   ├── default.nix             # Paquetes de usuario, shell y Starship
    │   └── hyprland/               # Configuración granular de Hyprland
    │       ├── appearance.nix      # Bordes, sombras, animaciones y paleta
    │       ├── default.nix         # Punto de entrada de Home Manager para Hyprland
    │       ├── keybinds.nix        # Mapeo de atajos de teclado y lanzadores
    │       └── windowrules.nix     # Comportamiento flotante, opacidades y capas
    └── nixos/
        ├── gnome.nix               # Integración del entorno de escritorio GNOME
        └── hyprland.nix            # Servicios y configuración global de Hyprland
```

---

## Mantenimiento y Despliegue

### Reconstruir y aplicar cambios
```bash
sudo nixos-rebuild switch --flake .#nixos
```

### Probar cambios sin registrar en el bootloader
```bash
sudo nixos-rebuild test --flake .#nixos
```

### Actualizar dependencias (inputs del flake)
```bash
nix flake update
sudo nixos-rebuild switch --flake .#nixos
```

### Limpieza de generaciones antiguas y optimización del Nix Store
```bash
nix-collect-garbage -d
nix store optimise
```