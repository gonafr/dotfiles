#!/bin/bash
# =================================
# Audio Transcription Script using OpenAI's Whisper
# This script transcribes audio from MP3 files using OpenAI's Whisper
# It automatically installs dependencies if they are not already installed
# Usage: ./transcribe-mp3.sh <audio_file.mp3> [whisper_model]
# Examples: 
#   ./transcribe-mp3.sh "audio.mp3" medium
#   ./transcribe-mp3.sh "/path/to/podcast.mp3" large
# Available models: tiny, base, small, medium, large (default: medium)

# For debugging, run with bash -x and log output:
# bash -x ./transcribe-mp3.sh your_file.mp3 2>&1 | tee debug.log
# =================================

set -euo pipefail
source "$(dirname "$0")/utils.sh"


# Show usage information
show_usage() {
    print_error "Usage: ./transcribe-mp3.sh <audio_file.mp3> [whisper_model]"
    echo "Example: ./transcribe-mp3.sh 'audio.mp3' medium"
    echo "         ./transcribe-mp3.sh '/path/to/podcast.mp3' large"
    echo "Available models: tiny, base, small, medium, large (default: medium)"
    echo
    echo "Supported formats: MP3"
    echo
    echo "Additional commands:"
    echo "  - Install dependencies only: ./transcribe-mp3.sh install"
    echo "  - Uninstall dependencies: ./transcribe-mp3.sh uninstall"
}

# Dependency installation functions
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

install_python() {
    if ! command -v python3 &> /dev/null; then
        print_warning "Python3 not found. Installing Python..."
        brew install python
        print_info "Python3 installed successfully ✓"
    else
        print_info "Python3 found ✓"
    fi
}

check_pip3() {
    if ! command -v pip3 &> /dev/null; then
        print_error "pip3 not found. Please install Python3 properly."
        exit 1
    else
        print_info "pip3 found ✓"
    fi
}

install_pipx() {
    if ! command -v pipx &> /dev/null; then
        print_warning "pipx not found. Installing pipx..."
        brew install pipx
        print_info "pipx installed successfully ✓"
    else
        print_info "pipx found ✓"
    fi
}

install_whisper() {
    # First check if whisper command exists but is broken
    if command -v whisper &> /dev/null; then
        # Try to run whisper to see if it's actually working
        if ! whisper --help &> /dev/null; then
            print_warning "Whisper found but appears to be broken. Reinstalling..."
            pipx uninstall openai-whisper 2>/dev/null || true
        fi
    fi
    
    if ! command -v whisper &> /dev/null || ! whisper --help &> /dev/null; then
        print_warning "OpenAI Whisper not found or broken. Installing Whisper..."
        
        # Ensure pipx is installed first
        install_pipx
        
        # Uninstall any broken installation
        pipx uninstall openai-whisper 2>/dev/null || true
        
        # Install whisper using pipx
        print_info "Installing Whisper via pipx..."
        pipx install openai-whisper
        
        # Ensure pipx paths are in the current session
        pipx ensurepath
        
        # Add pipx bin directory to PATH for current session
        export PATH="${PATH}:${HOME}/.local/bin"
        
        # Also try the pipx bin path
        if [[ -d "${HOME}/.local/share/pipx/venvs/openai-whisper/bin" ]]; then
            export PATH="${PATH}:${HOME}/.local/share/pipx/venvs/openai-whisper/bin"
        fi
        
        # Test if whisper is now available and working
        if command -v whisper &> /dev/null && whisper --help &> /dev/null; then
            print_info "OpenAI Whisper installed successfully via pipx ✓"
            
            # Make PATH change permanent by adding to shell profile
            local shell_profile=""
            if [[ -n "${ZSH_VERSION}" ]]; then
                shell_profile="${HOME}/.zshrc"
            elif [[ -n "${BASH_VERSION}" ]]; then
                shell_profile="${HOME}/.bash_profile"
            fi
            
            if [[ -n "${shell_profile}" ]] && [[ -f "${shell_profile}" ]]; then
                if ! grep -q "pipx ensurepath" "${shell_profile}"; then
                    echo "" >> "${shell_profile}"
                    echo "# Added by transcribe-mp3.sh" >> "${shell_profile}"
                    echo 'export PATH="${PATH}:${HOME}/.local/bin"' >> "${shell_profile}"
                    print_info "Added pipx to PATH in ${shell_profile}"
                fi
            fi
        else
            print_error "Whisper installation failed!"
            print_error "Current PATH: ${PATH}"
            print_error "Please try manually:"
            print_error "  pipx uninstall openai-whisper"
            print_error "  pipx install openai-whisper"
            print_error "  pipx ensurepath"
            print_error "  source ~/.zshrc  # or source ~/.bash_profile"
            exit 1
        fi
    else
        print_info "OpenAI Whisper found ✓"
    fi
}

install_all_dependencies() {
    print_info "Checking and installing dependencies..."
    install_homebrew
    install_python
    check_pip3
    install_whisper
    print_info "All dependencies installed successfully!"
    echo
}

uninstall_dependencies() {
    print_warning "This will remove OpenAI Whisper (Homebrew, Python, and pipx will be kept)"
    echo
    read -p "Are you sure you want to uninstall? (y/N): " -n 1 -r
    echo
    
    if [[ ! ${REPLY} =~ ^[Yy]$ ]]; then
        print_info "Uninstall cancelled"
        exit 0
    fi

    if command -v whisper &> /dev/null; then
        print_info "Uninstalling OpenAI Whisper..."
        pipx uninstall openai-whisper 2>/dev/null || pip3 uninstall -y openai-whisper 2>/dev/null || true
        print_info "OpenAI Whisper removed ✓"
    else
        print_info "OpenAI Whisper not installed"
    fi
    
    echo
    print_info "Dependencies removed successfully!"
    print_warning "Note: Homebrew, Python3, and pipx were not removed as they may be used by other applications"
}

# Transcription functions
check_existing_transcription() {
    local audio_basename="${1}"
    local txt_file="${audio_basename}.txt"
    local srt_file="${audio_basename}.srt"
    local formatted_txt="${audio_basename}_formatted.txt"
    
    local txt_exists=false
    local srt_exists=false
    local formatted_exists=false
    
    [[ -f "${txt_file}" ]] && txt_exists=true
    [[ -f "${srt_file}" ]] && srt_exists=true
    [[ -f "${formatted_txt}" ]] && formatted_exists=true
    
    if [[ "${txt_exists}" == true ]] && [[ "${srt_exists}" == true ]]; then
        print_warning "Both transcription files already exist:"
        echo "  - Text file: ${txt_file}"
        echo "  - Subtitle file: ${srt_file}"
        [[ "${formatted_exists}" == true ]] && echo "  - Formatted text file: ${formatted_txt}"
        echo
        
        read -p "Do you want to re-transcribe? (y/N): " -n 1 -r
        echo
        if [[ ! ${REPLY} =~ ^[Yy]$ ]]; then
            print_info "Using existing transcription files."
            print_info "Process completed!"
            exit 0
        else
            print_info "Re-transcribing..."
            rm "${txt_file}" "${srt_file}"
            [[ -f "${formatted_txt}" ]] && rm "${formatted_txt}"
        fi
    elif [[ "${srt_exists}" == true ]] && [[ "${txt_exists}" == false ]]; then
        print_warning "SRT file already exists but no TXT file found:"
        echo "  - Subtitle file: ${srt_file}"
        echo "  - Missing: ${txt_file}"
        [[ "${formatted_exists}" == true ]] && echo "  - Formatted text file: ${formatted_txt}"
        echo
        
        read -p "Do you want to create a TXT file from the existing SRT file? (y/N): " -n 1 -r
        echo
        if [[ ${REPLY} =~ ^[Yy]$ ]]; then
            print_info "Creating text file from existing SRT file..."
            
            [[ -f "${formatted_txt}" ]] && rm "${formatted_txt}"
            
            sed -e '/^[0-9]*$/d' -e '/^[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/d' -e '/^$/d' "${srt_file}" > "${txt_file}"
            
            if [[ -f "${txt_file}" ]]; then
                print_info "Text file created from SRT: ${txt_file}"
                format_transcription "${txt_file}"
                print_info "Process completed!"
                exit 0
            else
                print_error "Failed to create text file from SRT"
                exit 1
            fi
        else
            print_info "Skipping TXT file creation."
            print_info "Process completed!"
            exit 0
        fi
    elif [[ "${txt_exists}" == true ]] && [[ "${srt_exists}" == false ]]; then
        print_warning "TXT file already exists but no SRT file found:"
        echo "  - Text file: ${txt_file}"
        echo "  - Missing: ${srt_file}"
        [[ "${formatted_exists}" == true ]] && echo "  - Formatted text file: ${formatted_txt}"
        echo
        
        read -p "Do you want to re-transcribe to create the SRT file? (y/N): " -n 1 -r
        echo
        if [[ ! ${REPLY} =~ ^[Yy]$ ]]; then
            print_info "Using existing TXT file."
            print_info "Process completed!"
            exit 0
        else
            print_info "Re-transcribing to create SRT file..."
            rm "${txt_file}"
            [[ -f "${formatted_txt}" ]] && rm "${formatted_txt}"
        fi
    else
        print_info "No existing transcription files found. Proceeding with transcription..."
    fi
}

run_transcription() {
    local audio_file="${1}"
    local model="${2}"
    
    print_info "Starting transcription with Whisper (${model} model)..."
    print_info "Audio file to transcribe: ${audio_file}"
    
    if [[ ! -f "${audio_file}" ]]; then
        print_error "Audio file not found: ${audio_file}"
        exit 1
    fi
    
    print_info "Audio file size: $(du -h "${audio_file}" | cut -f1)"
    print_info "Current working directory: $(pwd)"
    
    # Check if whisper command exists
    if ! command -v whisper &> /dev/null; then
        print_error "Whisper command not found in PATH"
        print_error "Current PATH: ${PATH}"
        print_error "Please run: ./transcribe-mp3.sh install"
        exit 1
    fi
    
    print_info "Whisper location: $(which whisper)"
    print_info "Running Whisper transcription..."
    
    # Run Whisper with error handling
    if whisper "${audio_file}" --model "${model}" --output_format txt --output_format srt; then
        print_info "Whisper transcription completed successfully"
    else
        print_error "Whisper transcription failed with exit code $?"
        exit 1
    fi
    
    # Wait for files to be written
    wait_for_files "${audio_file%.*}"
    
    print_info "Files after transcription:"
    ls -la "${audio_file%.*}"* 2>/dev/null || echo "No files found"
}

format_transcription() {
    local input_file="${1}"
    local output_file="${input_file%.txt}_formatted.txt"
    
    print_info "Formatting transcription for better readability..."
    
    sed 's/$//' "${input_file}" | tr '\n' ' ' | \
    sed 's/\. /.\n/g' | \
    sed 's/\? /?\n/g' | \
    sed 's/\! /!\n/g' | \
    sed 's/^[ \t]*//' > "${output_file}"
    
    print_info "Formatted version created: ${output_file}"
}

wait_for_files() {
    local audio_basename="${1}"
    local timeout=30
    local elapsed=0

    print_info "Waiting for output files to be written..."
    while [[ ${elapsed} -lt ${timeout} ]]; do
        if [[ -f "${audio_basename}.txt" ]] || [[ -f "${audio_basename}.srt" ]]; then
            return 0
        fi
        sleep 1
        (( elapsed++ ))
    done

    print_warning "Timed out waiting for output files after ${timeout}s"
}

extract_text_from_srt() {
  local srt_file="${1}"
  local txt_file="${2}"
  sed -e '/^[0-9]*$/d' \
      -e '/^[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/d' \
      -e '/^$/d' \
      "${srt_file}" > "${txt_file}"
}

create_txt_from_srt() {
    local srt_file="${1}"
    local audio_basename="${2}"
    local txt_file="${audio_basename}.txt"

    print_warning "SRT file found but no TXT file exists."
    echo "SRT file: ${srt_file}"
    echo "Potential TXT file: ${txt_file}"
    echo

    # Prompt with 10-second countdown, defaulting to Y
    local timeout=10
    local reply=""

    echo -n "Do you want to create a text file from the existing SRT file? (Y/n) [auto-yes in ${timeout}s]: "
    while [[ ${timeout} -gt 0 ]]; do
        if read -t 1 -n 1 reply 2>/dev/null; then
            echo
            break
        fi
        timeout=$(( timeout - 1 ))
        echo -ne "\rDo you want to create a text file from the existing SRT file? (Y/n) [auto-yes in ${timeout}s]: "
    done

    if [[ ${timeout} -eq 0 ]]; then
        echo
        print_info "No input received — defaulting to Yes."
        reply="y"
    fi

    if [[ "${reply}" =~ ^[Nn]$ ]]; then
        print_info "Skipping TXT file creation."
        return 1
    fi
    
    print_info "Creating text file from subtitle file..."
    
    sed -e '/^[0-9]*$/d' -e '/^[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/d' -e '/^$/d' "${srt_file}" > "${txt_file}"
    
    if [[ -f "${txt_file}" ]]; then
        print_info "Text file created from SRT: ${txt_file}"
        format_transcription "${txt_file}"
        echo "  - Text transcript (created from SRT): ${txt_file}"
        return 0
    else
        print_error "Failed to create text file from SRT"
        return 1
    fi
}

handle_transcription_results() {
    local audio_file="${1}"
    local audio_basename
    audio_basename="$(basename "${audio_file%.*}")"
    
    print_info "Looking for output files:"
    print_info "Expected TXT file: ${audio_basename}.txt"
    print_info "Expected SRT file: ${audio_basename}.srt"
    
    print_info "Files created by Whisper:"
    ls -la "${audio_basename}"* 2>/dev/null || echo "No files found with basename ${audio_basename}"
    
    local found_txt=""
    local found_srt=""
    
    for file in "${audio_basename}"*.txt; do
        if [[ -f "${file}" ]]; then
            found_txt="${file}"
            break
        fi
    done
    
    for file in "${audio_basename}"*.srt; do
        if [[ -f "${file}" ]]; then
            found_srt="${file}"
            break
        fi
    done
    
    if [[ -n "${found_txt}" ]] || [[ -n "${found_srt}" ]]; then
        print_info "Transcription completed successfully!"
        print_info "Files created:"
        
        if [[ -n "${found_txt}" ]]; then
            echo "  - Text transcript: ${found_txt}"
            format_transcription "${found_txt}"
        fi
        
        if [[ -n "${found_srt}" ]]; then
            echo "  - Subtitle file: ${found_srt}"
        fi
        
        echo "  - Audio file: ${audio_file}"
        echo
        
        if [[ -n "${found_srt}" ]] && [[ -z "${found_txt}" ]]; then
            if create_txt_from_srt "${found_srt}" "${audio_basename}"; then
                print_info "TXT file successfully created from SRT."
            else
                print_warning "TXT file was not created."
            fi
        fi
        
        print_info "Process completed!"
    else
        print_error "Transcription failed - no output files created!"
        print_error "Files in directory:"
        ls -la *.txt *.srt 2>/dev/null || echo "No .txt or .srt files found"
        exit 1
    fi
}

process_input() {
    local audio_file="${1}"
    local model="${2}"
    
    print_info "Starting transcription process..."
    print_info "Audio file: ${audio_file}"
    print_info "Whisper model: ${model}"
    
    install_all_dependencies
    
    # Verify audio file exists and is MP3
    if [[ ! -f "${audio_file}" ]]; then
        print_error "Audio file does not exist: ${audio_file}"
        exit 1
    fi
    
    local extension="${audio_file##*.}"
    extension=$(echo "${extension}" | tr '[:upper:]' '[:lower:]')
    
    local valid_extensions=("mp3" "mp4" "m4a" "wav" "ogg" "flac" "webm")
    local is_valid=false

    for ext in "${valid_extensions[@]}"; do
      [[ "${extension}" == "${ext}" ]] && is_valid=true && break
    done

    if [[ "${is_valid}" == false ]]; then
      print_error "Unsupported format: ${extension}. Supported: ${valid_extensions[*]}"
      exit 1
    fi
    
    print_info "Audio file verified: ${audio_file}"
    
    local audio_basename
    audio_basename="$(basename "${audio_file%.*}")"
    print_info "Audio basename for transcription: ${audio_basename}"
    check_existing_transcription "${audio_basename}"
    
    run_transcription "${audio_file}" "${model}"
    
    handle_transcription_results "${audio_file}"
}

validate_model() {
  local model="${1}"
  local valid_models=("tiny" "base" "small" "medium" "large")

  for valid in "${valid_models[@]}"; do
    [[ "${model}" == "${valid}" ]] && return 0
  done

  print_error "Invalid model: '${model}'. Valid options: ${valid_models[*]}"
  exit 1
}

main() {
  case "${1:-}" in
    --install|install) install_all_dependencies; exit 0 ;;
    --uninstall|uninstall) uninstall_dependencies; exit 0 ;;
    "") show_usage; exit 1 ;;
  esac

    local audio_file="${1}"
    local model="${2:-medium}"
    
    process_input "${audio_file}" "${model}"
}

# Only run main when executed directly, not when sourced by other scripts.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi