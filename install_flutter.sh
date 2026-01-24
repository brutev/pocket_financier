#!/usr/bin/env bash
# Flutter SDK auto-installer for macOS, Linux, and Windows (manual for Windows)
# Usage: ./install_flutter.sh 3.38.0

set -e

FLUTTER_VERSION=${1:-3.38.0}
INSTALL_DIR="$HOME/flutter"

# Detect OS
OS="$(uname -s)"
case "$OS" in
  Darwin)
    PLATFORM="macos"
    ARCHIVE="flutter_macos_${FLUTTER_VERSION}-stable.zip"
    ;;
  Linux)
    PLATFORM="linux"
    ARCHIVE="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
    ;;
  *)
    echo "Unsupported OS: $OS"
    echo "For Windows, please download flutter_windows_${FLUTTER_VERSION}-stable.zip manually from flutter.dev and extract to C:\\flutter."
    exit 1
    ;;
esac

# Remove old Flutter SDK if exists
if [ -d "$INSTALL_DIR" ]; then
  echo "Removing existing Flutter SDK at $INSTALL_DIR..."
  rm -rf "$INSTALL_DIR"
fi

# Download Flutter SDK
URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/$PLATFORM/$ARCHIVE"
echo "Downloading Flutter $FLUTTER_VERSION for $PLATFORM..."
curl -L "$URL" -o "$ARCHIVE"

# Extract
echo "Extracting..."
if [ "$PLATFORM" = "macos" ]; then
  unzip -q "$ARCHIVE" -d "$HOME"
else
  tar xf "$ARCHIVE" -C "$HOME"
fi

# Clean up archive
rm "$ARCHIVE"

# Add to PATH (for current session)
export PATH="$INSTALL_DIR/bin:$PATH"
echo "\nAdd this line to your ~/.zshrc or ~/.bashrc to make it permanent:"
echo "export PATH=\"$INSTALL_DIR/bin:\$PATH\""

# Verify
flutter --version
