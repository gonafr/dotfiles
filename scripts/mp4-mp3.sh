#!/bin/bash
# ========================================
# Convert MP4/MKV video files to MP3 audio using ffmpeg
# Usage: ./mp4-mp3.sh <video_file> [video_file...]
#        ./mp4-mp3.sh --all   (convert every .mp4/.mkv file in the current directory)
#        ./mp4-mp3.sh --uninstall
# Examples:
#   ./mp4-mp3.sh "movie.mp4"
#   ./mp4-mp3.sh "movie.mp4" "episode.mkv"
#   ./mp4-mp3.sh --all
# ========================================

set -euo pipefail
source "$(dirname "$0")/utils.sh"

# Install ffmpeg using Homebrew
install_homebrew() {
  if ! command -v brew &>/dev/null; then
    print_warning "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

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

install_ffmpeg() {
  if ! command -v ffmpeg &>/dev/null; then
    print_warning "ffmpeg not found. Installing ffmpeg..."
    brew install ffmpeg
    print_info "ffmpeg installed successfully ✓"
  else
    print_info "ffmpeg found ✓"
  fi
}

install_dependencies() {
  print_info "Checking and installing dependencies..."
  install_homebrew
  install_ffmpeg
  print_info "All dependencies installed successfully!"
  echo
}

uninstall_dependencies() {
  print_warning "This will remove ffmpeg (Homebrew will be kept)"
  echo
  read -p "Are you sure you want to uninstall? (y/N): " -n 1 -r
  echo

  if [[ ! ${REPLY} =~ ^[Yy]$ ]]; then
    print_info "Uninstall cancelled"
    exit 0
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

# Convert a single video file to MP3
convert_to_mp3() {
  local input_file="${1}"

  if [[ ! -f "${input_file}" ]]; then
    print_error "File not found: ${input_file}"
    return 1
  fi

  local extension="${input_file##*.}"
  extension="$(echo "${extension}" | tr '[:upper:]' '[:lower:]')"
  if [[ "${extension}" != "mp4" && "${extension}" != "mkv" ]]; then
    print_error "Unsupported file type: ${input_file} (only .mp4 and .mkv are supported)"
    return 1
  fi

  local output_file="${input_file%.*}.mp3"

  if [[ -f "${output_file}" ]]; then
    print_warning "Output file already exists: ${output_file}"
    read -p "Overwrite? (y/N): " -n 1 -r
    echo
    if [[ ! ${REPLY} =~ ^[Yy]$ ]]; then
      print_info "Skipping ${input_file}"
      return 0
    fi
  fi

  print_info "Converting: ${input_file} -> ${output_file}"
  if ffmpeg -y -i "${input_file}" -vn -acodec libmp3lame -q:a 2 "${output_file}" &>/dev/null; then
    print_ok "Converted ${input_file} to ${output_file}"
  else
    print_error "Failed to convert ${input_file}"
    return 1
  fi
}

# Show usage information
show_usage() {
  print_error "Usage: ./mp4-mp3.sh <video_file> [video_file...]"
  echo "       ./mp4-mp3.sh --all"
  echo "       ./mp4-mp3.sh --uninstall"
  echo
  echo "Examples:"
  echo "  ./mp4-mp3.sh 'movie.mp4'"
  echo "  ./mp4-mp3.sh 'movie.mp4' 'episode.mkv'"
  echo "  ./mp4-mp3.sh --all"
  echo
  echo "Supported formats: MP4, MKV"
}

# Main script execution
main() {
  if [[ "${1:-}" == "--uninstall" ]]; then
    uninstall_dependencies
    exit 0
  fi

  if [[ ${#} -eq 0 ]]; then
    show_usage
    exit 1
  fi

  install_dependencies

  local files=()
  if [[ "${1}" == "--all" ]]; then
    for file in ./*.mp4 ./*.mkv; do
      [[ -f "${file}" ]] && files+=("${file}")
    done

    if [[ ${#files[@]} -eq 0 ]]; then
      print_warning "No .mp4 or .mkv files found in the current directory"
      exit 0
    fi
  else
    files=("${@}")
  fi

  local failures=0
  for file in "${files[@]}"; do
    convert_to_mp3 "${file}" || ((failures++))
  done

  echo
  if [[ ${failures} -eq 0 ]]; then
    print_info "All conversions completed successfully!"
  else
    print_error "${failures} conversion(s) failed"
    exit 1
  fi
}

main "$@"

