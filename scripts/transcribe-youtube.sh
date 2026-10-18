#!/bin/bash
# ========================================
# YouTube/Video to Transcription Script
# Downloads audio from an online video and transcribes it, reusing the
# functions from download-youtube-mp3.sh and transcribe-mp3.sh.
# Usage: ./transcribe-youtube.sh <video_url> [output_filename] [whisper_model]
# Examples:
#   ./transcribe-youtube.sh "https://youtube.com/watch?v=VIDEO_ID"
#   ./transcribe-youtube.sh "https://youtube.com/watch?v=VIDEO_ID" "my_audio" large
# Available models: tiny, base, small, medium, large (default: medium)
# ========================================

set -euo pipefail
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/utils.sh"

# Sourcing is guarded with BASH_SOURCE checks in both scripts, so this only
# pulls in their functions without running their own main().
source "${SCRIPT_DIR}/download-youtube-mp3.sh"
source "${SCRIPT_DIR}/transcribe-mp3.sh"

show_usage() {
  print_error "Usage: ./transcribe-youtube.sh <video_url> [output_filename] [whisper_model]"
  echo "Example: ./transcribe-youtube.sh 'https://youtube.com/watch?v=VIDEO_ID'"
  echo "         ./transcribe-youtube.sh 'https://youtube.com/watch?v=VIDEO_ID' 'my_audio' large"
  echo "Available models: tiny, base, small, medium, large (default: medium)"
}

main() {
  if [ ${#} -eq 0 ]; then
    show_usage
    exit 1
  fi

  local url="${1}"
  # An explicit output name is required so we know the resulting mp3 filename to transcribe.
  local output_name="${2:-youtube_audio_$(date +%Y%m%d_%H%M%S)}"
  local model="${3:-medium}"

  if [[ ! "${url}" =~ ^https?:// ]]; then
    print_error "Invalid URL: must start with http:// or https://"
    show_usage
    exit 1
  fi

  validate_model "${model}"

  install_dependencies
  download_audio "${url}" "${output_name}"

  process_input "${output_name}.mp3" "${model}"
}

main "$@"
