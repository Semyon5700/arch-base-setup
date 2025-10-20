#!/bin/bash

# Arch Linux Base Setup
# Copyright (C) 2025 Semyon5700
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

set -e

# Default packages
DEFAULT_PACKAGES=(
    "grub"
    "linux"
    "nano" 
    "icewm"
    "ly"
    "networkmanager"
    "calc"
)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
SELECTED_PACKAGES=()
CUSTOM_PACKAGES=()

print_header() {
    clear
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                   Arch Linux Base Setup                     ║"
    echo "║                  Copyright (C) 2025 Semyon5700              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_help() {
    echo "Usage: ./install.sh"
    echo
    echo "Interactive Arch Linux base system setup"
    echo "Answer y/n for each package, add custom packages at the end"
    echo
    echo "License: GPL-3.0+"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Error: This script must be run as root${NC}"
        exit 1
    fi
}

check_arch() {
    if [[ ! -f /etc/arch-release ]]; then
        echo -e "${RED}Error: This script is designed for Arch Linux only${NC}"
        exit 1
    fi
}

is_package_installed() {
    local package="$1"
    pacman -Q "$package" &>/dev/null
}

ask_yes_no() {
    local question="$1"
    local default="${2:-}"
    local answer
    
    while true; do
        echo -en "${YELLOW}$question [y/n]${NC} "
        read -r answer
        
        case "${answer:-$default}" in
            [Yy]* ) return 0 ;;
            [Nn]* ) return 1 ;;
            * ) echo -e "${RED}Please answer y or n${NC}" ;;
        esac
    done
}

ask_package() {
    local package="$1"
    local description="$2"
    
    echo
    echo -e "${BLUE}Package: $package${NC}"
    echo -e "Description: $description"
    
    if is_package_installed "$package"; then
        echo -e "${GREEN}Status: Already installed${NC}"
        if ask_yes_no "Do you want to reinstall it?" "n"; then
            SELECTED_PACKAGES+=("$package")
            echo -e "${GREEN}Added to installation list${NC}"
        else
            echo -e "${YELLOW}Skipping${NC}"
        fi
    else
        if ask_yes_no "Do you want to install $package?" "y"; then
            SELECTED_PACKAGES+=("$package")
            echo -e "${GREEN}Added to installation list${NC}"
        else
            echo -e "${YELLOW}Skipping${NC}"
        fi
    fi
    
    sleep 1
}

ask_custom_packages() {
    echo
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                     Custom Packages                         ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    if ask_yes_no "Do you want to add custom packages?" "n"; then
        echo
        echo -e "${YELLOW}Enter package names separated by spaces:${NC}"
        echo -e "${YELLOW}Example: firefox vim git${NC}"
        echo -en "${GREEN}>> ${NC}"
        read -r custom_input
        
        if [[ -n "$custom_input" ]]; then
            for package in $custom_input; do
                package=$(echo "$package" | tr -d '[:space:]')
                if [[ -n "$package" ]]; then
                    CUSTOM_PACKAGES+=("$package")
                fi
            done
            echo -e "${GREEN}Added custom packages: ${CUSTOM_PACKAGES[*]}${NC}"
        else
            echo -e "${YELLOW}No custom packages added${NC}"
        fi
    fi
}

show_installation_summary() {
    echo
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                   Installation Summary                      ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    local all_packages=("${SELECTED_PACKAGES[@]}" "${CUSTOM_PACKAGES[@]}")
    
    if [[ ${#all_packages[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No packages selected for installation${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Packages to be installed:${NC}"
    for package in "${all_packages[@]}"; do
        if is_package_installed "$package"; then
            echo -e " ${GREEN}✓${NC} $package ${BLUE}(reinstall)${NC}"
        else
            echo -e " ${GREEN}✓${NC} $package"
        fi
    done
    
    echo
    echo -e "${YELLOW}Total packages: ${#all_packages[@]}${NC}"
    echo
    
    if ! ask_yes_no "Start installation?" "y"; then
        echo -e "${YELLOW}Installation cancelled${NC}"
        exit 0
    fi
}

update_pacman() {
    echo
    echo -e "${YELLOW}Updating package database...${NC}"
    if ! pacman -Sy; then
        echo -e "${RED}Error: Failed to update package database${NC}"
        exit 1
    fi
    echo -e "${GREEN}Package database updated successfully${NC}"
}

install_packages() {
    local all_packages=("${SELECTED_PACKAGES[@]}" "${CUSTOM_PACKAGES[@]}")
    
    if [[ ${#all_packages[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No packages to install${NC}"
        return
    fi
    
    echo
    echo -e "${YELLOW}Installing packages...${NC}"
    
    # Filter out packages that are already installed (unless they're in custom list and user wants them)
    local packages_to_install=()
    local reinstalling=()
    
    for package in "${all_packages[@]}"; do
        if is_package_installed "$package"; then
            reinstalling+=("$package")
        else
            packages_to_install+=("$package")
        fi
    done
    
    # Install new packages
    if [[ ${#packages_to_install[@]} -gt 0 ]]; then
        echo -e "${GREEN}Installing new packages: ${packages_to_install[*]}${NC}"
        if ! pacman -S --noconfirm "${packages_to_install[@]}"; then
            echo -e "${RED}Error: Failed to install packages${NC}"
            exit 1
        fi
    fi
    
    # Reinstall existing packages if any
    if [[ ${#reinstalling[@]} -gt 0 ]]; then
        echo -e "${BLUE}Reinstalling: ${reinstalling[*]}${NC}"
        if ! pacman -S --noconfirm "${reinstalling[@]}"; then
            echo -e "${RED}Error: Failed to reinstall packages${NC}"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}Package installation completed successfully!${NC}"
}

enable_services() {
    echo
    echo -e "${YELLOW}Enabling services...${NC}"
    
    local all_packages=("${SELECTED_PACKAGES[@]}" "${CUSTOM_PACKAGES[@]}")
    
    # Enable NetworkManager
    if [[ " ${all_packages[@]} " =~ " networkmanager " ]] && is_package_installed "networkmanager"; then
        if systemctl enable NetworkManager.service; then
            echo -e "${GREEN}Enabled NetworkManager service${NC}"
        else
            echo -e "${RED}Failed to enable NetworkManager service${NC}"
        fi
    fi
    
    # Enable ly display manager
    if [[ " ${all_packages[@]} " =~ " ly " ]] && is_package_installed "ly"; then
        if systemctl enable ly.service; then
            echo -e "${GREEN}Enabled ly display manager${NC}"
        else
            echo -e "${RED}Failed to enable ly display manager${NC}"
        fi
    fi
}

show_final_summary() {
    echo
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                     Setup Complete                          ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${GREEN}Arch Linux base setup completed successfully!${NC}"
    echo
    
    local all_packages=("${SELECTED_PACKAGES[@]}" "${CUSTOM_PACKAGES[@]}")
    
    echo -e "${YELLOW}Installed packages:${NC}"
    for package in "${all_packages[@]}"; do
        if is_package_installed "$package"; then
            echo -e " ${GREEN}✓${NC} $package"
        fi
    done
    
    echo
    echo -e "${YELLOW}Next steps:${NC}"
    echo " 1. Configure grub if installed:"
    echo "    grub-install /dev/this disk"
    echo "    grub-mkconfig -o /boot/grub/grub.cfg"
    echo " 2. Reboot system: reboot"
    echo " 3. Start graphical session if icewm and ly are installed"
    echo
}

main() {
    check_root
    check_arch
    
    print_header
    echo -e "${YELLOW}Starting Arch Linux base setup...${NC}"
    echo
    
    # Ask for each default package
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                   Default Packages                          ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    
    for package in "${DEFAULT_PACKAGES[@]}"; do
        case "$package" in
            "grub") ask_package "$package" "grub" ;;
            "linux") ask_package "$package" "Linux kernel" ;;
            "nano") ask_package "$package" "nano" ;;
            "icewm") ask_package "$package" "icewm" ;;
            "ly") ask_package "$package" "ly" ;;
            "networkmanager") ask_package "$package" "Networkmanager" ;;
            "calc") ask_package "$package" "calc" ;;
            *) ask_package "$package" "Software package" ;;
        esac
    done
    
    # Ask for custom packages
    ask_custom_packages
    
    # Show summary and confirm
    if ! show_installation_summary; then
        exit 0
    fi
    
    # Update pacman and install
    update_pacman
    install_packages
    enable_services
    show_final_summary
}

# Handle command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    *)
        main
        ;;
esac
