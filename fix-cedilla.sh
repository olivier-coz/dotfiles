#!/bin/bash

# Cedilha Setup Script for US Keyboard on ArchLinux
# Author: Nilo Dantas - n1lo
# Based on: https://bugs.launchpad.net/ubuntu/+source/ibus/+bug/518056

# Function to check if user is root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit
    fi
}

# Step 1: Set the system keyboard layout to "English(US, international with dead keys)"
echo "Ensure that the system keyboard layout is set to 'English(US, international with dead keys)'"

# Step 2: Modify immodules.cache files
echo "Modifying immodules.cache files..."

IMMODULES_PATHS=(
    "/usr/lib/gtk-3.0/3.0.0/immodules.cache"
    "/usr/lib/gtk-2.0/2.10.0/immodules.cache"
)

for file in "${IMMODULES_PATHS[@]}"; do
    if [[ -f "$file" ]]; then
        echo "Modifying $file"
        sed -i 's/"az:ca:co:fr:gv:oc:pt:sq:tr:wa"/"az:ca:co:fr:gv:oc:pt:sq:tr:wa:en"/g' "$file"
    else
        echo "$file not found, skipping..."
    fi
done

# Step 3: Replace "ć" to "ç" and "Ć" to "Ç" in the Compose file
echo "Modifying Compose file..."
COMPOSE_FILE="/usr/share/X11/locale/en_US.UTF-8/Compose"
COMPOSE_BACKUP="/usr/share/X11/locale/en_US.UTF-8/Compose.bak"

if [[ -f "$COMPOSE_FILE" ]]; then
    sudo cp "$COMPOSE_FILE" "$COMPOSE_BACKUP"
    sed 's/ć/ç/g' < "$COMPOSE_FILE" | sed 's/Ć/Ç/g' > Compose
    sudo mv Compose "$COMPOSE_FILE"
    echo "Compose file modified and backed up to $COMPOSE_BACKUP"
else
    echo "$COMPOSE_FILE not found!"
fi

# Step 4: Add environment variables to /etc/environment
echo "Adding environment variables to /etc/environment..."

ENVIRONMENT_FILE="/etc/environment"
if grep -q "GTK_IM_MODULE=cedilla" "$ENVIRONMENT_FILE"; then
    echo "GTK_IM_MODULE already exists in /etc/environment"
else
    echo "GTK_IM_MODULE=cedilla" | sudo tee -a "$ENVIRONMENT_FILE"
fi

if grep -q "QT_IM_MODULE=cedilla" "$ENVIRONMENT_FILE"; then
    echo "QT_IM_MODULE already exists in /etc/environment"
else
    echo "QT_IM_MODULE=cedilla" | sudo tee -a "$ENVIRONMENT_FILE"
fi

# Step 5: Restart computer prompt
echo "Cedilha setup is complete! Please restart your computer to apply the changes."
