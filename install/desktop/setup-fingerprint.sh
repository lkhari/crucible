#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Source utils.sh from parent directory
source "$SCRIPT_DIR/../../utils.sh"

# Check if running with remove flag
if [[ "$1" == "--remove" ]]; then
  echo "Removing fingerprint authentication..."
  
  # Remove PAM configuration
  if command -v pam-auth-update &>/dev/null; then
    sudo pam-auth-update --remove fprintd
  else
    # Fallback for systems without pam-auth-update
    sudo sed -i '/pam_fprintd.so/d' /etc/pam.d/sudo
    sudo sed -i '/pam_fprintd.so/d' /etc/pam.d/login
  fi
  
  # Disable and stop service
  sudo systemctl disable fprintd.service 2>/dev/null || true
  sudo systemctl stop fprintd.service 2>/dev/null || true
  
  echo "Fingerprint authentication removed."
  exit 0
fi

# Check if fingerprints are already enrolled
if fprintd-list "$USER" &>/dev/null; then
  echo "Fingerprints are already enrolled for user $USER."
  echo "Skipping fingerprint setup."
  exit 0
fi

# Check if fingerprint hardware is available
if ! lsusb | grep -i fingerprint &>/dev/null && ! ls /dev/bus/usb/*/0* 2>/dev/null | xargs -I {} sh -c 'lsusb -D {} 2>/dev/null | grep -i fingerprint' &>/dev/null; then
  echo "Warning: No fingerprint hardware detected. This setup may not work on your system."
  read -p "Continue anyway? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Fingerprint setup cancelled."
    exit 0
  fi
fi

# Install required packages
echo "Installing fingerprint packages..."
install_packages fprintd libfprint

# Enable the service
echo "Enabling fingerprint service..."
sudo systemctl enable fprintd.service
sudo systemctl start fprintd.service

# Wait for service to be ready
sleep 2

# Check if service is running
if ! systemctl is-active --quiet fprintd.service; then
  echo "Warning: fprintd service is not running. Attempting to start..."
  sudo systemctl start fprintd.service
  sleep 2
fi

# Enroll fingerprint
echo "Please scan your fingerprint to enroll it..."
echo "You will need to scan the same finger multiple times."
if ! fprintd-enroll; then
  echo "Fingerprint enrollment failed. Please check your hardware and try again."
  exit 1
fi

# Test the fingerprint
echo "Testing fingerprint authentication..."
echo "Please scan your enrolled finger when prompted:"
if fprintd-verify; then
  echo "Fingerprint verification successful!"
else
  echo "Fingerprint verification failed. You may need to re-enroll."
fi

# Configure PAM to use fingerprint
echo "Configuring PAM for fingerprint authentication..."
if command -v pam-auth-update &>/dev/null; then
  sudo pam-auth-update --enable fprintd
else
  # Fallback for systems without pam-auth-update
  # Add fingerprint auth to sudo
  if ! grep -q "pam_fprintd.so" /etc/pam.d/sudo; then
    sudo sed -i '1i auth sufficient pam_fprintd.so' /etc/pam.d/sudo
  fi
  
  # Add fingerprint auth to login
  if ! grep -q "pam_fprintd.so" /etc/pam.d/login; then
    sudo sed -i '1i auth sufficient pam_fprintd.so' /etc/pam.d/login
  fi
fi

echo ""
echo "Fingerprint authentication setup complete!"
echo "You can now use your fingerprint for:"
echo "- sudo commands"
echo "- System authentication prompts"
echo "- Login (depending on your display manager)"
echo ""
echo "To remove fingerprint authentication, run:"
echo "powerkey-setup-fingerprint --remove"