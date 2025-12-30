{ lib, pkgs, ... }:

let
  left = "j";
  down = "l";
  up = "k";
  right = "oslash";
  mod = "Mod1";
  super = "Super";

  rofiRepo = builtins.fetchTarball {
    url = "https://github.com/johron/adi1090x-rofi/archive/refs/heads/master.tar.gz";
    sha256 = "182fbvilfj4qvzjdxrkbayiazqw31blb4hzkn583fkxaz4zf2378";
  };

  notwaitaBlackSrc = pkgs.fetchurl {
    url = "https://github.com/ful1e5/notwaita-cursor/releases/download/v1.0.0-alpha1/Notwaita-Black.tar.xz";
    sha256 = "sha256-P/F4NRBqz/6Ws9//qEKMYdqtfG5LdZa6jihqueZnx88==";
  };

  notwaitaBlackCursor = pkgs.runCommand "notwaita-black-cursor" {
    nativeBuildInputs = [ pkgs.xz pkgs.gnutar ];
  } ''
    mkdir -p $out/share/icons
    tar -xJf ${notwaitaBlackSrc} -C $out/share/icons
  '';
in
{
  nixpkgs.config.allowUnfree = true;

  programs.alacritty = {
    enable = true;
    settings = {
      cursor = {
        style = {
          shape = "Beam";
          blinking = "Off";
        };
      };
      font = {
        size = 10.0;
        normal = {
          family = "JetBrains Mono";
          style = "Regular";
        };

        bold = {
          family = "JetBrains Mono";
          style = "Bold";
        };

        italic = {
          family = "JetBrains Mono";
          style = "Italic";
        };

        bold_italic = {
          family = "JetBrains Mono";
          style = "Bold Italic";
        };
      };
      colors = { # Enfocado Dark colorscheme
        primary = {
          background =  "#181818";
          foreground =  "#b9b9b9";
        };

        normal = {
          black   = "#3b3b3b";
          red     = "#ed4a46";
          green   = "#70b433";
          yellow  = "#dbb32d";
          blue    = "#368aeb";
          magenta = "#eb6eb7";
          cyan    = "#3fc5b7";
          white   = "#b9b9b9";
        };

        bright = {
          black   = "#777777";
          red     = "#ff5e56";
          green   = "#83c746";
          yellow  = "#efc541";
          blue    = "#4f9cfe";
          magenta = "#ff81ca";
          cyan    = "#56d8c9";
          white   = "#dedede";
        };
      };
    };
  };

  home = {
    packages = with pkgs; [
      vscode
      rofi
      nemo
      spotify
      playerctl
      gh
      discord
      fastfetch
      swaybg
      onefetch
      nomacs
      mpvpaper
      kdePackages.kdenlive
      feishin
      google-cloud-sdk
      flameshot
      hyprpicker
      jetbrains.rust-rover
     ];

    pointerCursor = {
      package = notwaitaBlackCursor;
      name = "Notwaita-Black";
      size = 20; # adjust size you want
      gtk.enable = true;
      x11.enable = true;
    };

    # This needs to actually be set to your username
    username = "johron";
    homeDirectory = "/home/johron";

    stateVersion = "25.11";

    file = {
      bashrc = {
        target = ".bashrc";
        text = ''
          alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
          home() {
            cd "$HOME/home-manager"
            "$EDITOR" "$HOME/home-manager/home.nix"
          }
          flake() {
            cd "$HOME/home-manager"
            "$EDITOR" "$HOME/home-manager/flake.nix"
          }
          config() {
            "sudo" "$EDITOR" "/etc/nixos/configuration.nix"
          }
          nix-update() {
            set -e

            ORIG_CWD="$(pwd)"

            sudo nix-channel --update
            cd "$HOME/home-manager"
            make
            sudo nixos-rebuild switch
            flatpak update -y
            sudo flatpak update -y
            cd "$ORIG_CWD"
          }
        '';
      };
      flameshot = {
        target = ".config/flameshot/flameshot.ini";
        text = ''
          [General]
          contrastOpacity=188
          showAbortNotification=false
          showDesktopNotification=false
          showStartupLaunchMessage=false
          savePath=/home/johron/Pictures/Screenshots
          savePathFixed=true
        '';
      };
      "/.config/rofi/launchers".source = "${rofiRepo}/files/launchers";
      "/.config/rofi/applets".source   = "${rofiRepo}/files/applets";
      "/.config/rofi/colors".source    = "${rofiRepo}/files/colors";
      "/.config/rofi/images".source    = "${rofiRepo}/files/images";
      "/.config/rofi/powermenu".source = "${rofiRepo}/files/powermenu";
      "/.config/rofi/scripts".source   = "${rofiRepo}/files/scripts";
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Breeze-Dark";
      package = pkgs.kdePackages.breeze-gtk;
    };
    iconTheme = {
      name = "breeze-dark";
      package = pkgs.kdePackages.breeze-icons;
    };
  };

  wayland.windowManager.sway = {
      enable = true;
      checkConfig = true;
      config = {
        bars = [
          {
            command = "swaybar_command waybar";
          }
        ];
        modes = {
          resize = {
            # Letters
            "j" = "resize shrink width 10 px or 10 ppt";
            "k" = "resize grow height 10 px or 10 ppt";
            "l" = "resize shrink height 10 px or 10 ppt";
            "oslash" = "resize grow width 10 px or 10 ppt";

            # Arrow keys
            "Left"  = "resize shrink width 10 px or 10 ppt";
            "Down"  = "resize grow height 10 px or 10 ppt";
            "Up"    = "resize shrink height 10 px or 10 ppt";
            "Right" = "resize grow width 10 px or 10 ppt";

            # Exit mode
            "Escape" = "mode default";
            "Return" = "mode default";
          };
        };
        keybindings = {
          "${mod}+Shift+r" = "reload";
          "${mod}+Shift+q" = "kill";
          "${mod}+d" = "exec rofi -show drun";
          "${mod}+Return" = "exec alacritty";
          "${super}+l" = "exec swaylock";
          "${mod}+r" = "mode \"resize\"";

          "${mod}+h" = "split h";
          "${mod}+v" = "split v";
          "${mod}+f" = "fullscreen toggle";
          "${mod}+s" = "layout stacking";
          "${mod}+t" = "layout tabbed";
          "${mod}+e" = "layout toggle split";

          "${mod}+Shift+space" = "floating toggle";
          "${mod}+space" = "focus mode_toggle";
          "${mod}+a" = "focus parent";

          # Focus movement
          "${mod}+${left}" = "focus left";
          "${mod}+${down}" = "focus down";
          "${mod}+${up}" = "focus up";
          "${mod}+${right}" = "focus right";

          # Focus movement (arrow keys)
          "${mod}+Left" = "focus left";
          "${mod}+Down" = "focus down";
          "${mod}+Up" = "focus up";
          "${mod}+Right" = "focus right";

          # Move windows
          "${mod}+Shift+${left}" = "move left";
          "${mod}+Shift+${down}" = "move down";
          "${mod}+Shift+${up}" = "move up";
          "${mod}+Shift+${right}" = "move right";

          # Move windows (arrow keys)
          "${mod}+Shift+Left" = "move left";
          "${mod}+Shift+Down" = "move down";
          "${mod}+Shift+Up" = "move up";
          "${mod}+Shift+Right" = "move right";

          # Switch to workspace
          "${mod}+1" = "workspace number 1";
          "${mod}+2" = "workspace number 2";
          "${mod}+3" = "workspace number 3";
          "${mod}+4" = "workspace number 4";
          "${mod}+5" = "workspace number 5";
          "${mod}+6" = "workspace number 6";
          "${mod}+7" = "workspace number 7";
          "${mod}+8" = "workspace number 8";
          "${mod}+9" = "workspace number 9";
          "${mod}+0" = "workspace number 10";

          ## Switch to secondary workspace
          "${super}+1" = "workspace number 11";
          "${super}+2" = "workspace number 12";
          "${super}+3" = "workspace number 13";
          "${super}+4" = "workspace number 14";
          "${super}+5" = "workspace number 15";
          "${super}+6" = "workspace number 16";
          "${super}+7" = "workspace number 17";
          "${super}+8" = "workspace number 18";
          "${super}+9" = "workspace number 19";
          "${super}+0" = "workspace number 20";

          # Move to workspace
          "${mod}+Shift+1" = "move container to workspace number 1";
          "${mod}+Shift+2" = "move container to workspace number 2";
          "${mod}+Shift+3" = "move container to workspace number 3";
          "${mod}+Shift+4" = "move container to workspace number 4";
          "${mod}+Shift+5" = "move container to workspace number 5";
          "${mod}+Shift+6" = "move container to workspace number 6";
          "${mod}+Shift+7" = "move container to workspace number 7";
          "${mod}+Shift+8" = "move container to workspace number 8";
          "${mod}+Shift+9" = "move container to workspace number 9";
          "${mod}+Shift+0" = "move container to workspace number 10";

          ## Move to secondary workspace
          "${super}+Shift+1" = "move container to workspace number 11";
          "${super}+Shift+2" = "move container to workspace number 12";
          "${super}+Shift+3" = "move container to workspace number 13";
          "${super}+Shift+4" = "move container to workspace number 14";
          "${super}+Shift+5" = "move container to workspace number 15";
          "${super}+Shift+6" = "move container to workspace number 16";
          "${super}+Shift+7" = "move container to workspace number 17";
          "${super}+Shift+8" = "move container to workspace number 18";
          "${super}+Shift+9" = "move container to workspace number 19";
          "${super}+Shift+0" = "move container to workspace number 20";

          ## Resize windows with letters
          #"${mod}+Shift+j" = "resize shrink width 10 px or 10 ppt";
          #"${mod}+Shift+k" = "resize grow height 10 px or 10 ppt";
          #"${mod}+Shift+l" = "resize shrink height 10 px or 10 ppt";
          #"${mod}+Shift+oslash" = "resize grow width 10 px or 10 ppt";
#
          ## Resize windows with arrow keys (same actions)
          #"${mod}+Shift+Left"  = "resize shrink width 10 px or 10 ppt";
          #"${mod}+Shift+Down"  = "resize grow height 10 px or 10 ppt";
          #"${mod}+Shift+Up"    = "resize shrink height 10 px or 10 ppt";
          #"${mod}+Shift+Right" = "resize grow width 10 px or 10 ppt";

          # Multimedia
          XF86AudioMute = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
          XF86AudioPlay = "exec playerctl play-pause";
          XF86AudioPause = "exec playerctl pause";
          XF86AudioNext = "exec playerctl next";
          XF86AudioPrev = "exec playerctl previous";
          XF86AudioRaiseVolume = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
          XF86AudioLowerVolume = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";

          ## Applications
          "${super}+q" = "exec firefox";
          "${super}+e" = "exec nemo";
          "${super}+s" = "exec spotify";
          "${super}+d" = "exec discord";

          "${super}+v" = "exec cliphist list | rofi -dmenu | cliphist decode | wl-copy";
          "${super}+Shift+s" = "exec flameshot gui";
          "${super}+Shift+c" = "exec hyprpicker --autocopy";
        };

        window.commands = [
          { command = "floating enable"; criteria.instance = "spotify"; }
          #{ command = "floating enable"; criteria.class = "steam"; }
        ];

        input = {
          "*" = {
           xkb_layout = "no";
           #xkb_variant = "cole";
        };
      };
    };
    extraConfig = ''
      output * mode 1920x1080@143.981Hz

      workspace 1 output DP-2
      workspace 2 output DP-2
      workspace 3 output DP-2

      workspace 11 output HDMI-A-1
      workspace 12 output HDMI-A-1
      workspace 13 output HDMI-A-1

     exec wl-paste --watch cliphist store

     seat seat0 xcursor_theme Notwaita-Black 20

     # Bind Alt+Shift+e to show a Swaynag exit confirmation
     bindsym Mod1+Shift+e exec swaynag -t warning \
       -m "Are you sure you want to exit Sway?" \
       -b "Exit" "swaymsg exit" \
       -b "Reboot" "reboot"

     exec mpvpaper -o "--loop=inf" ALL /home/johron/Videos/cubebg.mp4

     exec_always {
       systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK
       lxqt-policykit-agent
     }
    '';
  };

  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    theme = "launchers/type-4/style-5.rasi";
  };

  programs.waybar = {
    enable = true;
    settings = {
      main = {
        position = "bottom";
        layer = "top";
        height = 24;
        spacing = 5;
        modules-left = [ "sway/workspaces" "sway/mode" "mpris" ];
        modules-center = [ "clock" ];
        modules-right = [ "memory" "wireplumber" "sway/language" "idle_inhibitor" "network" "bluetooth" "tray" ];

        #"mpris" = {
        #  format = "{player_icon} {title} - {artist}";
        #  format-paused = "   ";
        #  max-length = 40;
        #  player-icons = {
        #    default = "󰐎";
        #    spotify = "󰓇";
        #    #firefox = "󰈹";
        #    mpv = "󰐎";
        #  };
        #};

        "mpris" = {
          player = "spotify";
          format = "󰓇 {artist} - {title}";
          format-paused = "󰓇 {artist}";
          max-length = 60;
        };

        "sway/workspaces" = {
          format = "{icon}";
          on-click = "activate";
          icon-size = 10;
          sort-by-number = "true";
        };

        "clock" = {
          format = "{:%d.%m.%Y | %H:%M}";
        };

        "battery" = {
          bat = "BAT1";
          interval = 60;
          format = "{icon} {capacity}%";
          format-icons = ["\uf244" "\uf243" "\uf242" "\uf241" "\uf240"];
        };

        "wireplumber" = {
          format = "󰕾  {volume}%";
          max-volume = "100";
          scroll-step = 5;
        };

        "memory" = {
          interval = 30;
          format = "󰍛  {used:0.1f}G/{total:0.1f}G";
        };

        "temperature" = {
          format = "{temperatureC}°C";
        };

        "network" = {
          format = "";
          format-ethernet = "󰈀";
          format-wifi = "{icon}";
          format-disconnected = "󰈂";
          format-icons = ["󰤟" "󰤢" "󰤥" "󰤨"];
          tooltip-format-wifi = "{essid} ({signalStrength}%)";
          tooltip-format-ethernet = "{ifname}";
          tooltip-format-disconnected = "Disconnected";
        };

        "bluetooth" = {
          format = "󰂯";
          format-disabled = "󰂲";
          format-connected = "󰂱";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
        };

        "sway/language" = {
          format = "{short}";
        };

        "tray" = {
          icon-size = 16;
          spacing = 16;
        };

        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = "󰅶";
            deactivated = "󰾪";
          };
        };
      };
    };
    style = ''
      @define-color foreground #eeeeee;
      @define-color foreground-inactive #aaaaaa;
      @define-color background #000000;

      * {
        font-family: JetBrainsMono Nerd Font;
        font-size: 12px;
      }

      #waybar {
        color: @foreground;
        background-color: @background;
      }

      #workspaces {
        background: transparent;
      }

      #workspaces button {
        padding: 0 0.6em;
        margin: 0 0.2em;
        color: @foreground-inactive;
        background: transparent;
        border: none;
        border-bottom: 2px solid transparent;
        border-radius: 0;
      }

      #workspaces button.active,
      #workspaces button.focused {
        color: @foreground;
        border-bottom: 2px solid @foreground;
      }

      #workspaces button.empty {
        color: @foreground-inactive;
      }

      #workspaces button.urgent {
        color: #c94444;
      }

      #workspaces button:hover {
        color: @foreground;
      }

      #memory,
      #wireplumber,
      #battery,
      #idle_inhibitor,
      #language,
      #network,
      #bluetooth,
      #tray {
        padding-right: 1em
      }
    '';
  };
}
