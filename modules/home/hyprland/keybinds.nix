{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    # Keybinds principales (Caelestia + Hyprland + Apps)
    bind = [
      # --- Caelestia Shell ---
      "$mod, Space, global, caelestia:launcher"
      "Ctrl+Alt, Delete, global, caelestia:session"
      "$mod, N, global, caelestia:sidebar"
      "$mod, K, global, caelestia:showall"
      "$mod, L, global, caelestia:lock"
      "Ctrl+Alt, C, global, caelestia:clearNotifs"
      "Ctrl+$mod+Alt, R, exec, qs -c caelestia kill; sleep .1; caelestia shell -d"

      # --- Capturas de pantalla (Caelestia) ---
      ", Print, exec, caelestia screenshot"
      "$mod+Shift, S, global, caelestia:screenshotFreeze"
      "$mod+Shift+Alt, S, global, caelestia:screenshot"

      # --- Portapapeles y Emojis (Caelestia) ---
      "$mod, V, exec, pkill fuzzel || caelestia clipboard"
      "$mod, Period, exec, pkill fuzzel || caelestia emoji -p"

      # --- Aplicaciones ---
      "$mod, T, exec, $terminal"
      "$mod, Return, exec, $terminal"
      "Ctrl+Alt, T, exec, $terminal"
      "$mod, W, exec, $browser"
      "$mod, C, exec, $editor"
      "$mod, E, exec, $fileManager"

      # --- Gestión de Ventanas ---
      "$mod, Q, killactive,"
      "$mod, F, fullscreen, 0"
      "$mod+Alt, F, fullscreen, 1"
      "$mod+Alt, Space, togglefloating,"
      "$mod, P, pin,"

      # --- Mover foco ---
      "$mod, left, movefocus, l"
      "$mod, right, movefocus, r"
      "$mod, up, movefocus, u"
      "$mod, down, movefocus, d"

      # --- Mover ventanas ---
      "$mod+Shift, left, movewindow, l"
      "$mod+Shift, right, movewindow, r"
      "$mod+Shift, up, movewindow, u"
      "$mod+Shift, down, movewindow, d"

      # --- Workspaces (1-10) ---
      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"
      "$mod, 6, workspace, 6"
      "$mod, 7, workspace, 7"
      "$mod, 8, workspace, 8"
      "$mod, 9, workspace, 9"
      "$mod, 0, workspace, 10"

      # --- Mover ventana a Workspace (1-10) ---
      "$mod+Shift, 1, movetoworkspace, 1"
      "$mod+Shift, 2, movetoworkspace, 2"
      "$mod+Shift, 3, movetoworkspace, 3"
      "$mod+Shift, 4, movetoworkspace, 4"
      "$mod+Shift, 5, movetoworkspace, 5"
      "$mod+Shift, 6, movetoworkspace, 6"
      "$mod+Shift, 7, movetoworkspace, 7"
      "$mod+Shift, 8, movetoworkspace, 8"
      "$mod+Shift, 9, movetoworkspace, 9"
      "$mod+Shift, 0, movetoworkspace, 10"

      # --- Scroll entre Workspaces ---
      "$mod, mouse_down, workspace, e+1"
      "$mod, mouse_up, workspace, e-1"
    ];

    # Keybinds que también funcionan con pantalla bloqueada (Audio / Brillo)
    bindl = [
      ", XF86MonBrightnessUp, global, caelestia:brightnessUp"
      ", XF86MonBrightnessDown, global, caelestia:brightnessDown"
      ", XF86AudioPlay, global, caelestia:mediaToggle"
      ", XF86AudioPause, global, caelestia:mediaToggle"
      ", XF86AudioNext, global, caelestia:mediaNext"
      ", XF86AudioPrev, global, caelestia:mediaPrev"
      ", XF86AudioStop, global, caelestia:mediaStop"
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
    ];

    # Keybinds con repetición al mantener presionado (Volumen)
    bindle = [
      ", XF86AudioRaiseVolume, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    ];

    # Keybinds del ratón (Mover y redimensionar ventanas con Super + Click)
    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];
  };
}
