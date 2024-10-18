# Introduction

This repository contains all the dotfiles that I use on my macbook. The dotfiles are managed using [GNU Stow](https://www.gnu.org/software/stow/).

# Setting up a new Laptop

1. Install Nix
    ```sh
    sh <(curl -L https://nixos.org/nix/install)
    ```
2. Clone this repository
    ```sh
    git clone https://github.com/SudarshanVK/dotfiles.git ~/.dotfiles
    ```

3. Execute darwin rebuild to setup the system. This can take a while as it is installing all packages and setting up the system.
    ```sh
    darwin-rebuild switch --flake ~/dotfiles/nix#macos
    ```

4. STOW the dotfiles
    ```sh
    cd ~/.dotfiles
    stow .
    ```

5. Open iterm2 and let it install the shell integration.

This should setup the system with all the dotfiles and packages that I use.

# Author

Sudarshan Vijaya Kumar
