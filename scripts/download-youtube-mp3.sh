#!/bin/bash
# ========================================
# YouTube/Video to MP3 Downloader Script
# This script downloads audio from online videos and converts to MP3 format
# It automatically installs Homebrew, yt-dlp, and ffmpeg if needed
# Usage: ./download-youtube-mp3.sh <video_url> [output_filename]
#        ./download-youtube-mp3.sh --uninstall (to remove dependencies)
# Examples:
#   ./download-youtube-mp3.sh "https://youtube.com/watch?v=VIDEO_ID"
#   ./download-youtube-mp3.sh "https://youtube.com/watch?v=VIDEO_ID" "my_audio"
#   ./download-youtube-mp3.sh "https://vimeo.com/123456789"
#   ./download-youtube-mp3.sh --uninstall
# ========================================

source "$(dirname "$0")/utils.sh"

# Check if Homebrew is installed
check_homebrew() {
  if ! command -v brew &>/dev/null; then
    print_warning "Homebrew is not installed. Installing now..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    print_info "Homebrew is already installed"
  fi
}

install_homebrew() {
    if ! command -v brew &> /dev/null; then
        print_warning "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for current session
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        print_info "Homebrew installed successfully ✓"
    else
        print_info "Homebrew found ✓"
    fi
}

# Install yt-dlp using Homebrew
install_yt_dlp() {
  if ! command -v yt-dlp &>/dev/null; then
    print_info "Installing yt-dlp..."
    brew install yt-dlp
    print_info "yt-dlp installed successfully!"
  else
    print_info "yt-dlp is already installed"
  fi
}

# Install ffmpeg using Homebrew
install_ffmpeg() {
  if ! command -v ffmpeg &>/dev/null; then
    print_info "Installing ffmpeg..."
    brew install ffmpeg
    print_info "ffmpeg installed successfully!"
  else
    print_info "ffmpeg is already installed"
  fi
}

# Install Homebrew and required packages
install_dependencies() {
  print_info "Checking and installing dependencies..."
  install_homebrew
  install_yt_dlp
  install_ffmpeg
  print_info "All dependencies installed successfully!"
  echo
}

# Uninstall dependencies
uninstall_dependencies() {
  print_warning "This will remove yt-dlp and ffmpeg (Homebrew will be kept)"
  echo
  read -p "Are you sure you want to uninstall? (y/N): " -n 1 -r
  echo
  
  if [[ ! ${REPLY} =~ ^[Yy]$ ]]; then
    print_info "Uninstall cancelled"
    exit 0
  fi

  if command -v yt-dlp &>/dev/null; then
    print_info "Uninstalling yt-dlp..."
    brew uninstall yt-dlp
    print_info "yt-dlp removed ✓"
  else
    print_info "yt-dlp not installed"
  fi

  if command -v ffmpeg &>/dev/null; then
    print_info "Uninstalling ffmpeg..."
    brew uninstall ffmpeg
    print_info "ffmpeg removed ✓"
  else
    print_info "ffmpeg not installed"
  fi

  echo
  print_info "Dependencies removed successfully!"
  print_warning "Note: Homebrew was not removed as it may be used by other applications"
}

# Download audio from video URL
download_audio() {
  local url="${1}"
  local output_name="${2:-}"

  print_info "Downloading audio from: ${url}"

  if [[ -z "${output_name}" ]]; then
    yt-dlp -x --audio-format mp3 "${url}"
  else
    yt-dlp -x --audio-format mp3 -o "${output_name}.%(ext)s" "${url}"
  fi

  print_info "Audio download and conversion complete!"
}

# Show usage information
show_usage() {
  print_error "Usage: ./download-youtube-mp3.sh <video_url> [output_filename]"
  echo "       ./download-youtube-mp3.sh --uninstall"
  echo
  echo "Examples:"
  echo "  ./download-youtube-mp3.sh 'https://youtube.com/watch?v=VIDEO_ID'"
  echo "  ./download-youtube-mp3.sh 'https://youtube.com/watch?v=VIDEO_ID' 'custom_name'"
  echo "  ./download-youtube-mp3.sh --uninstall"
  echo
  echo "Supported platforms: YouTube, Vimeo, TikTok, Instagram, Facebook, and 1000+ others"
}

# Main script execution
main() {
  # Check for uninstall flag
  if [ "${1}" = "--uninstall" ]; then
    uninstall_dependencies
    exit 0
  fi

  if [ ${#} -eq 0 ]; then
    show_usage
    exit 1
  fi

  local url="${1}"
  local output_name="${2:-}"

  if [[ ! "${url}" =~ ^https?:// ]]; then
    print_error "Invalid URL: must start with http:// or https://"
    show_usage
    exit 1
  fi

  install_dependencies
  download_audio "${url}" "${output_name}"
}

# Only run main when executed directly, not when sourced by other scripts.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi