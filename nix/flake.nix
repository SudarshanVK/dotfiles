{
  description = "MacOS Zen Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";™
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      nixpkgs.config.allowUnfree = true;
      environment.systemPackages =
        [
            pkgs.neovim
            pkgs.asciinema-agg
            pkgs.asciinema
            pkgs.bat
            pkgs.direnv
            pkgs.docker
            pkgs.docker-compose
            pkgs.eza
            pkgs.fd
            pkgs.jankyborders
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
        ];
      homebrew = {
        enable = true;
        taps = [
            "nikitabobko/tap"
        ];
        brews = [
            "autoenv"
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
            "alfred"
            "slack"
            "stats"
            "visual-studio-code"
            "zed"
            "wireshark"
            "whatsapp"
            "zoom"
            "vanilla"
        ];
        # Makes it declaritive
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;

              };

      system.defaults = {
            dock = {
                autohide = false;
                orientation = "right";
                show-recents = false;
                mineffect = "scale";
                tilesize = 42;
                "minimize-to-application" = true;
                "mru-spaces" = false;
                "persistent-apps" = [
                    "/Applications/Firefox.app"
                ];
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