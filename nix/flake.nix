{
  description = "MacOS Zen Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = { self, nix-darwin, nix-homebrew, ... }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      nixpkgs.config.allowUnfree = true;
      environment.systemPackages =
        [
            # VSCODE Extentions
            pkgs.vscode-extensions.batisteo.vscode-django
            pkgs.vscode-extensions.catppuccin.catppuccin-vsc
            pkgs.vscode-extensions.catppuccin.catppuccin-vsc-icons
            pkgs.vscode-extensions.charliermarsh.ruff
            pkgs.vscode-extensions.ms-python.python
            pkgs.vscode-extensions.github.copilot
            pkgs.vscode-extensions.github.copilot-chat
            pkgs.vscode-extensions.redhat.vscode-yaml
            pkgs.vscode-extensions.pkief.material-icon-theme
            pkgs.vscode-extensions.wholroyd.jinja
            pkgs.vscode-extensions.visualstudioexptteam.vscodeintellicode
            pkgs.vscode-extensions.visualstudioexptteam.intellicode-api-usage-examples
            # FONTS
            pkgs.fira-code-nerdfont
            pkgs.nerdfonts
            pkgs.meslo-lgs-nf
            pkgs.source-code-pro
            pkgs.anonymousPro
            pkgs.hack-font
            # PACKAGES
            pkgs.nixd
            pkgs.ollama
            pkgs.neovim
            pkgs.asciinema-agg
            pkgs.asciinema
            pkgs.bat
            pkgs.direnv
            pkgs.docker
            pkgs.docker-compose
            pkgs.eza
            pkgs.fd
            pkgs.fzf
            pkgs.git
            pkgs.delta
            pkgs.go
            pkgs.terraform
            pkgs.ipcalc
            pkgs.jq
            pkgs.libffi
            pkgs.stow
            pkgs.poetry
            pkgs.pyenv
            pkgs.ruff
            pkgs.speedtest-cli
            pkgs.sshpass
            pkgs.starship
            pkgs.thefuck
            pkgs.tldr
            pkgs.tree
            pkgs.wget
            pkgs.zoxide
            pkgs.zsh
            pkgs.drawio
            pkgs.lazygit
        ];

      fonts.packages = with pkgs; [
        (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
      ];

      homebrew = {
        enable = true;
        taps = [
            "nikitabobko/tap"
            "FelixKratz/formulae"
        ];
        brews = [
            "mas"
            # "autoenv"
            "borders"
            # "switchaudio-osx"
            "tmux"
            "bash"
            "bitwarden-cli"
            "cdktf"
            #"zellij"
        ];
        casks = [
            "firefox"
            "aerospace"
            "appcleaner"
            "discord"
            "displaylink"
            "iterm2"
            "itsycal"
            "monitorcontrol"
            "onyx"
            "slack"
            "stats"
            "visual-studio-code"
            "zed"
            "wireshark"
            "whatsapp"
            "zoom"
            "raycast"
            "sf-symbols"
            "zen-browser"
        ];

        # execute `mas search <app name> to get the id`
        masApps = {
          "hiddenbar" = 1452453066;
          };

        # Makes it declaritive
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
        };

      system.defaults = {
            dock = {
                autohide = false;
                orientation = "left";
                show-recents = false;
                mineffect = "scale";
                tilesize = 42;
                "minimize-to-application" = true;
                "mru-spaces" = false;
            };
            trackpad = {
                Clicking = true;
            };
            CustomUserPreferences = {
                "com.apple.trackpad" = {
                    forceClick = true;
                    enableSecondaryClick = true;
                    momentumScroll = true;
                    pinchGesture = true;
                    rotateGesture = true;
                    twoFingerDoubleTapGesture = true;
                };
                "com.apple.desktopservices" = {
                    # Avoid creating .DS_Store files on network or USB volumes
                      DSDontWriteNetworkStores = true;
                      DSDontWriteUSBStores = true;
                    };
                "com.apple.screencapture" = {
                    location = "~/Desktop";
                    type = "png";
                    };
                "com.apple.SoftwareUpdate" = {
                    AutomaticCheckEnabled = true;
                    # Check for software updates daily, not just once per week
                    ScheduleFrequency = 1;
                    # Download newly available updates in background
                    AutomaticDownload = 1;
                    # Install System data files & security updates
                    CriticalUpdateInstall = 1;
                    };
            };
        };

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."macos" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
                {
                  nix-homebrew = {
                    # Install Homebrew under the default prefix
                    enable = true;

                    # Apple Silicon Only: Also install Homebrew under the
                    # default Intel prefix for Rosetta 2
                    enableRosetta = true;

                    # User owning the Homebrew prefix
                    user = "sudarshanv";

                    # Migrate existing homebrew
                    autoMigrate = true;
                  };
                }
        ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."macos".pkgs;
  };
}
