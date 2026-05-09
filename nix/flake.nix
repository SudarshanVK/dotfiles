{
  description = "MacOS Zen Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # Pin homebrew-core and homebrew-cask as flake inputs so that
    # brew reads local Ruby DSL files instead of the online API JSON.
    # This avoids the brew-5.1.7 `depends_on` nil-key parsing bug.
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    # Third-party taps — with mutableTaps = false every tap must be a
    # flake input. Convention: `brew tap owner/name` -> github:owner/homebrew-name
    nikitabobko-tap = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };
    felixkratz-formulae = {
      url = "github:FelixKratz/homebrew-formulae";
      flake = false;
    };
    zkondor-dist = {
      url = "github:zkondor/homebrew-dist";
      flake = false;
    };
    pulumi-tap = {
      url = "github:pulumi/homebrew-tap";
      flake = false;
    };
    boring-notch-tap = {
      url = "github:theboredteam/homebrew-boring-notch";
      flake = false;
    };
  };

  outputs = { self, nix-darwin, nix-homebrew, homebrew-core, homebrew-cask,
              nikitabobko-tap, felixkratz-formulae, zkondor-dist, pulumi-tap,
              boring-notch-tap, ... }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      nixpkgs.config.allowUnfree = true;
      # nixpkgs sets direnv CGO_ENABLED=0 for static binaries; Darwin's Makefile
      # still uses -linkmode=external, which requires CGO (see direnv GNUmakefile).
      nixpkgs.overlays = [
        (final: prev: {
          direnv =
            if prev.stdenv.hostPlatform.isDarwin then
              prev.direnv.overrideAttrs (oldAttrs: {
                env = (oldAttrs.env or { }) // { CGO_ENABLED = 1; };
                doCheck = false;
              })
            else
              prev.direnv;
        })
      ];
      environment.systemPackages =
        [
     	      pkgs.bashInteractive
    	      pkgs.ncurses
            pkgs.meslo-lgs-nf
            pkgs.source-code-pro
            pkgs.anonymousPro
            pkgs.hack-font
            # PACKAGES
            pkgs.nixd
            pkgs.nil
            pkgs.nixfmt
            pkgs.neovim
            pkgs.asciinema-agg
            pkgs.asciinema
            pkgs.bat
            pkgs.direnv
            pkgs.eza
            pkgs.fd
            pkgs.fzf
            pkgs.git
            pkgs.delta
            pkgs.go
            pkgs.terraform
            pkgs.netmask  # pure C implementation for IP calculations
            pkgs.jq
            pkgs.libffi
            pkgs.stow
            pkgs.uv
            pkgs.speedtest-cli
            pkgs.sshpass
            pkgs.starship
            pkgs.tldr
            pkgs.tree
            pkgs.wget
            pkgs.zoxide
            pkgs.zsh
            pkgs.lazygit
            pkgs.inetutils
        ];

      # fonts.packages = with pkgs; [
      #   (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
      # ];

      homebrew = {
        enable = true;
        taps = [
            "nikitabobko/tap"
            "FelixKratz/formulae"
            "zkondor/dist"
            "pulumi/tap"
            "theboredteam/boring-notch"
        ];
        brews = [
            "utf8proc" # needed for tmux
            "ansible"
            "tmux"
            "ruff"
            "stow"
            "mas"
            "tmux"
            "bash"
            "fastfetch"
            "yq"
            "ansible-lint"
            "kustomize"
            "kubectx"
            "awscli"
            "aws-sam-cli"
            "kubelogin"
            "gh"
            "openjdk@17"
            "gopass"
            "ollama"
            "presenterm"
            "gemini-cli"
            "aicommit2"
            "pulumi/tap/pulumi"
            "mole"
            "docker"
            "docker-compose"
            "docker-buildx"
            "colima"
        ];
        casks = [
            "container"
            "spokenly"
            "font-meslo-lg-nerd-font"
            "font-inconsolata-nerd-font"
            "font-fira-code-nerd-font"
            "font-iosevka-nerd-font"
            "font-jetbrains-mono-nerd-font"
            "font-sauce-code-pro-nerd-font"
            "font-space-mono-nerd-font"
            "font-ubuntu-nerd-font"
            "font-victor-mono-nerd-font"
            "font-monaspace"
            # "bettertouchtool"
            "drawio"
            "dockdoor"
            "boring-notch"
            "cursor"
            "firefox"
            "zen"
            "appcleaner"
            "slack"
            "discord"
            "visual-studio-code"
            "zed"
            "whatsapp"
            "postman"
            "raycast"
            "sf-symbols"
            "chatgpt"
            "warp"
            "iterm2"
            "postman"
            "ghostty"
            "voiceink"
            "bruno"
            "spotify"
        ];

        # execute `mas search <app name> to get the id`
        masApps = {
          # "Xnip" = 1221250572;
          };

        # Makes it declaritive
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
        };
      system.primaryUser = "sudarshanv";
      system.defaults = {
            dock = {
                autohide = false;
                orientation = "left";
                show-recents = false;
                mineffect = "scale";
                tilesize = 35;
                "minimize-to-application" = true;
                "mru-spaces" = false;
            };
            trackpad = {
                Clicking = true;
            };
            CustomUserPreferences = {
                "com.apple.trackpad" = {
                    forceClick = 1;
                    enableSecondaryClick = 1;
                    momentumScroll = 1;
                    pinchGesture = 1;
                    rotateGesture = 1;
                    twoFingerDoubleTapGesture = 1;
                };
                "com.apple.desktopservices" = {
                    # Avoid creating .DS_Store files on network or USB volumes
                    DSDontWriteNetworkStores = 1;
                    DSDontWriteUSBStores = 1;
                };
                "com.apple.screencapture" = {
                    location = "~/Desktop";
                    type = "png";
                };
                "com.apple.SoftwareUpdate" = {
                    AutomaticCheckEnabled = 1;
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
      # services.nix-daemon.enable = true;
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

                    # Use pinned taps so brew reads local Ruby DSL files
                    # instead of the Homebrew JSON API. This avoids the
                    # brew-5.1.7 `process_depends_on` nil crash on newer
                    # cask API responses.
                    taps = {
                      "homebrew/homebrew-core" = homebrew-core;
                      "homebrew/homebrew-cask" = homebrew-cask;
                      "nikitabobko/homebrew-tap" = nikitabobko-tap;
                      "FelixKratz/homebrew-formulae" = felixkratz-formulae;
                      "zkondor/homebrew-dist" = zkondor-dist;
                      "pulumi/homebrew-tap" = pulumi-tap;
                      "theboredteam/homebrew-boring-notch" = boring-notch-tap;
                    };
                    mutableTaps = false;
                  };
                }
        ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."macos".pkgs;
  };
}
