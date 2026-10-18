#!/bin/bash
# ========================================
# Script to Zip the Home Folder of the Current User and Optionally Encrypt It
# Creates a zip archive of ~ named home-<username>-YYYYMMDDHHMM.zip, optionally password-protected.
#
# If a password is entered, the zip is encrypted with GPG (AES256) producing a
# home-<username>-YYYYMMDDHHMM.zip.gpg file. Requires gpg (macOS: brew install gnupg).
#
# To decrypt:
#   gpg -d home-<username>-YYYYMMDDHHMM.zip.gpg > home-<username>-YYYYMMDDHHMM.zip
# (enter the same password when prompted), then unzip the resulting file as usual.
#
# This script will include iCloud Drive files if they are present in the home directory.
# Time Machine backups don't include iCloud Drive files, so this script can be used to back them up.
# ========================================

set -e

CURRENT_USER=$(whoami)
HOME_SRC="$HOME"
TIMESTAMP=$(date +%Y%m%d%H%M)
OUTPUT_FILE="home-${CURRENT_USER}-${TIMESTAMP}.zip"

EXCLUDES=(
  "*/.cache/*"
  "*/.npm/*"
  "*/.local/share/Trash/*"
  "*/node_modules/*"
  "*/.git/*"
)

echo "Preparing to zip ${HOME_SRC} into ${OUTPUT_FILE}"

# Prompt for optional password, default to no password after 15 seconds
PASSWORD=""
if read -t 15 -s -r -p "Enter password to protect the zip (leave empty and wait 15s for no password): " PASSWORD; then
  echo
else
  echo
  echo "No input received in time, proceeding without password."
fi

cd "$HOME_SRC"

zip -r "$OUTPUT_FILE" . -x "${EXCLUDES[@]}"

if [ -n "$PASSWORD" ]; then
  if ! command -v gpg &>/dev/null; then
    echo "gpg not found. Install it with 'brew install gnupg' (macOS) or your package manager, then re-run." >&2
    unset PASSWORD
    exit 1
  fi

  ENCRYPTED_FILE="${OUTPUT_FILE}.gpg"
  gpg --batch --yes --passphrase "$PASSWORD" --symmetric --cipher-algo AES256 -o "$ENCRYPTED_FILE" "$OUTPUT_FILE"
  rm -f "$OUTPUT_FILE"
  unset PASSWORD
  OUTPUT_FILE="$ENCRYPTED_FILE"
fi

echo "Backup created: ${HOME_SRC}/${OUTPUT_FILE}"
