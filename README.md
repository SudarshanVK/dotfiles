# Introduction

This repository contains a list of all dot files.

# Setting up a new Laptop

1. Install [Homebrew](https://brew.sh/)
``` bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
> [!NOTE]
> Remember to execute the command at the end of the installation to add brew to your path

2. Install Git
``` brew
brew install git
```
3. Copy the .ssh folder from the old laptop to the new laptop

4. Clone this repository to your home directory
```bash
git clone git@github.com:SudarshanVK/dotfiles.git ~/dotfiles
```

5. Install all brew packages
```bash
xargs brew install < brew.txt
```

6. Install all brew cask packages
``` bash
xargs brew cask install < brew_cask.txt
```

7. Navigate to the dotfiles directory and execute stow
``` bash
cd ~/dotfiles
stow .

# if there are failures try
stow --adopt .
```

# Author

Sudarshan Vijaya Kumar
