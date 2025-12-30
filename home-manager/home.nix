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
    sha256 = "14rh0argbl1xdsy8xbs9kdxcl1nbpgxfpi72g6h5ccjgkbqkp9qy";
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

  news.display = "silent";

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
      htop
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
          current_git_branch() {
            git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
          }
          PS1='(\[\033[01;94m\]\u\[\033[00;00m\]@\[\033[01;94m\]\h\[\033[00;00m\]:\[\033[01;34m\]\w\[\033[00m\])\[\033[01;32m\]$(current_git_branch)\[\033[00m\]$ '
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
      mako = {
        target = ".config/mako/config";
        text = ''
          default-timeout=5000
        '';
      };
      clock = {
        target = ".config/waybar/clock.sh";
        text = ''
        # Generate the formatted date string
        formatted_date=$(LC_TIME=nb_NO.UTF-8 date +"%H:%M %A, %b %d" | tr '[:upper:]' '[:lower:]' | sed 's/\.//g')

        # Output as JSON for Waybar
        printf '{"text": "%s"}\n' "$formatted_date"
        '';
        executable = true;
      };
      memory = {
        target = ".config/waybar/memory.sh";
        text = ''
          free -m | awk '
          /^Mem:/ {
              current_gb = $3 / 1024;
              total_gb = $2 / 1024;
              printf "{\"text\": \"%.1fG/%.1fG\"}\n", current_gb, total_gb
          }'
        '';
        executable = true;
      };
      volume = {
        target = ".config/waybar/volume.sh";
        text = ''
          VOLUME_INFO=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
          VOL_NUM=$(echo "$VOLUME_INFO" | awk '{print $2}')
          VOL_PERC=$(awk -v n="$VOL_NUM" 'BEGIN {print int(n * 100)}')

          if [[ "$VOLUME_INFO" == *"[MUTED]"* ]]; then
              RESULT="Muted ($VOL_PERC%)"
          else
              RESULT="$VOL_PERC%"
          fi

          echo "{\"text\": \"$RESULT\"}"
        '';
        executable = true;
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

          # Multimedia
          XF86AudioMute = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
          XF86AudioPlay = "exec playerctl play-pause";
          XF86AudioPause = "exec playerctl pause";
          XF86AudioNext = "exec playerctl next";
          XF86AudioPrev = "exec playerctl previous";
          XF86AudioRaiseVolume = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
          XF86AudioLowerVolume = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";

          # Applications
          "${super}+q" = "exec firefox";
          "${super}+e" = "exec nemo";
          "${super}+s" = "exec spotify";
          "${super}+d" = "exec discord";

          "${super}+v" = "exec cliphist list | rofi -dmenu | cliphist decode | wl-copy";
          "${super}+Shift+s" = "exec flameshot gui";
          "${super}+Shift+c" = "exec hyprpicker --autocopy";

          # Scripts
          "${mod}+dead_diaeresis" = "exec /storage/Scripts/rofi-audio";
          "${mod}+Control+a" = "exec /storage/Scripts/toggle-mic-mute";
          "${mod}+Control+s" = "exec /storage/Scripts/toggle-output-mute";
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

      #exec mpvpaper -o "--loop=inf" ALL /home/johron/Videos/cubebg.mp4

      exec_always {
        systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK
        lxqt-policykit-agent
        swayidle \
          timeout 300 'swaylock -f' \
          timeout 600 'systemctl suspend' \
          before-sleep 'swaylock -f'
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
        height = 30;
        spacing = 5;
        modules-left = [ "custom/block_start" "sway/workspaces" "mpris" "custom/block_stop" "sway/mode" ];
        modules-center = [ "custom/block_start" "custom/clock" "custom/block_stop" ];
        modules-right = [ "custom/block_start" "custom/memory" "custom/slash" "custom/volume" "custom/block_stop" "tray" ];

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
          format = "<span color=\"#272727\">/</span> <span color=\"#ACA69E\">mus:</span> {artist} - {title}";
          format-paused = "<span color=\"#272727\">/</span> <span color=\"#ACA69E\">mus:</span> {artist}";
          max-length = 200;
        };

        "sway/workspaces" = {
          format = "{icon}{name}";
          on-click = "activate";
          icon-size = 10;
          sort-by-number = "true";
          justify = "right";
          "format-icons" = {
            focused = "*";
            urgent = "!";
            default = "";
          };
        };

        #"clock" = {
        #  #format = "{:%d.%m.%Y | %H:%M}";
        #  format = "{:%H:%M tirsdag, %b %d}";
        #};

        "custom/space" = {
          format = " ";
        };

        "custom/slash" = {
          format = "/ ";
        };

        "custom/block_start" = {
          format = " [";
        };

        "custom/block_stop" = {
          format = "] ";
        };

        "custom/clock" = {
          format = "{}";
          exec = "~/.config/waybar/clock.sh";
          return-type = "json";
          restart-interval = 1;
        };

        "battery" = {
          bat = "BAT1";
          interval = 60;
          format = "{icon} {capacity}%";
          format-icons = ["\uf244" "\uf243" "\uf242" "\uf241" "\uf240"];
        };

        #"wireplumber" = {
        #  format = "<span color=\"#ACA69E\">vol:</span> {volume}%";
        #  max-volume = "100";
        #  scroll-step = 5;
        #};

        "custom/volume" = {
          format = "<span color=\"#ACA69E\">vol:</span> {} ";
          exec = "~/.config/waybar/volume.sh";
          return-type = "json";
          restart-interval = 0;
        };

        "custom/memory" = {
          format = "<span color=\"#ACA69E\">mem:</span> {} ";
          exec = "~/.config/waybar/memory.sh";
          return-type = "json";
          restart-interval = 1;
        };

        "custom/lang" = {
          format = "<span color=\"#ACA69E\">key:</span> no";
        };

        "tray" = {
          icon-size = 16;
          spacing = 16;
        };
      };
    };
    style = ''
      @define-color foreground #ACA69E;
      @define-color foreground-inactive #ffffff;
      @define-color background #101010;

      * {
        font-family: JetBrainsMono Nerd Font;
        font-size: 12px;
      }

      #waybar {
        color: #ffffff;
        background-color: @background;
      }

      #workspaces {
        background: transparent;
      }

      #custom-slash,
      #custom-block_start,
      #custom-block_stop {
        color: #272727;
      }

      #workspaces button {
        min-width: 20px;
        padding: 0 0.6em;
        margin: 0 0.2em;
        color: @foreground-inactive;

        background: transparent;
        border: none;
        border-bottom: 2px solid transparent;
        border-radius: 0;
        padding: 0px;
        margin: 0 5px;
      }

      #workspaces button.active,
      #workspaces button.focused {
        color: #ACA69E;
        /*border-bottom: 2px solid @foreground;*/
      }

      #workspaces button.empty {
        color: #ACA69E;
      }

      #workspaces button.urgent {
        color: #A64443;
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

  systemd.user.services.mpvpaper = {
    Unit = {
      Description = "Video wallpaper with mpvpaper";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.mpvpaper}/bin/mpvpaper -o '--loop=inf' ALL /home/johron/Videos/cubebg.mp4";
      Restart = "always";
    };
    Install = {
      WantedBy = [ "sway-session.target" ];
    };
  };
}
