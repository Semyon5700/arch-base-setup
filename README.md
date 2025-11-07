# Arch-Base-Setup

Interactive package management utility for Arch Linux systems.

## Description

A bash script designed for streamlined package installation on Arch Linux. The utility provides an interactive interface for selecting base system packages and adding custom packages, suitable for both new installations and existing systems.

## Features

- Interactive package selection with yes/no prompts
- Handles already installed packages (skip or reinstall)
- Custom package addition
- Automatic package database synchronization
- Service auto-configuration for relevant packages
- Clear terminal interface with color coding

## Installation

```bash
git clone https://github.com/Semyon5700/arch-base-setup
cd arch-base-setup
chmod +x install.sh
./install.sh
```

## Default Package Selection

- grub: Bootloader
- linux: Linux kernel
- nano: Text editor
- icewm: Window manager
- ly: Display manager
- networkmanager: Network connection manager
- calc: Command-line calculator

## Usage

Execute with root privileges:

```bash
./install.sh
```

The script will:
1. Prompt for each default package (y/n)
2. Offer custom package addition
3. Display installation summary
4. Update package database
5. Install selected packages
6. Enable relevant services

## Use Cases

- New Arch Linux system setup
- Bulk package installation on existing systems
- Quick deployment of common software collections
- System provisioning and configuration

## License

Copyright (C) 2025 Semyon5700

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
