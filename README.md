## Overview

This repository stores configuration files and scripts used to set up and manage a Linux desktop environment.

## Structure

- `home/`: user config files for applications.
- `rc/`: shell and editor configs (e.g. `.zshrc`, `.vimrc`) and themes.
- `scripts/`: helper scripts to deploy the configuration.

## Deployment

#### 1. Automatic
Run: 
```bash
curl -sSL https://raw.githubusercontent.com/almostlight/dotfiles/main/scripts/setup.sh | bash
```
It will install necessary packages, clone the repository, and deploy the config.
The script asks whether the system is WSL/headless so graphical packages and
desktop services can be skipped. Choosing `r` at the first prompt removes the
packages installed by the script and restores the most recent configuration
backup.
#### 2. Manual
Review the files under `home/` and `rc/` and adapt as you see fit. Run `./scripts/deploy.sh` to symlink configuration files into your home directory.

## Contributing

Feel free to open issues or submit improvements! 

## Notes

- The deploy script creates a backup of your configuration, but if you're worried about your files you should manually back up the existing configuration before running any of these scripts.
- This repository is tailored to the original author's environment; adapt as needed for your system.
- You might need to log out or reboot for all changes to be applied.
