#!/bin/bash

# Check if LocalSend is already installed
if ! command -v localsend &>/dev/null; then
  echo "LocalSend will be installed via package manager..."
  
  # Create desktop entry for quick access
  mkdir -p "$HOME/.local/share/applications"
  
  cat > "$HOME/.local/share/applications/localsend.desktop" << EOF
[Desktop Entry]
Name=LocalSend
Comment=Share files to nearby devices
Exec=localsend
Icon=localsend
Terminal=false
Type=Application
Categories=Network;FileTransfer;
Keywords=share;transfer;airdrop;
EOF

  echo "LocalSend desktop entry created"
else
  echo "LocalSend is already installed"
fi