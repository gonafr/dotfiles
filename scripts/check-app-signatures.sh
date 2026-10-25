#!/bin/bash
#
# check-app-signatures.sh
# Checks the code signature and Gatekeeper status of macOS apps.
#
# Usage:
#   ./check-app-signatures.sh                 # scan /Applications and ~/Applications
#   ./check-app-signatures.sh --system        # also scan /System/Applications
#   ./check-app-signatures.sh --only-issues   # only print apps that need attention
#   ./check-app-signatures.sh /path/to/A.app  # check specific apps or folders
#
# Exit code: 0 if every app was accepted by Gatekeeper, 1 otherwise.
#
# Labels (the Gatekeeper verdict from `spctl --assess`):
#   Apple           Built into macOS and signed by Apple.
#   App Store       Downloaded from the Mac App Store, signed by Apple on publish.
#   Notarized       Signed with a Developer ID and scanned by Apple's notary service.
#                   The normal, safe state for apps downloaded from the web.
#   Not notarized   Signed with a Developer ID but never sent to Apple for scanning.
#                   Usually an older app; modern macOS may warn about it.
#   Accepted (...)  Accepted for another reason, e.g. a local Gatekeeper rule.
#   REJECTED        Unsigned, ad-hoc signed, damaged or revoked. macOS blocks it on a
#                   normal launch unless allowed in System Settings > Privacy & Security.

source "$(dirname "$0")/utils.sh"
set -u

include_system=false
only_issues=false
targets=()

for arg in "$@"; do
  case "$arg" in
    --system) include_system=true ;;
    --only-issues) only_issues=true ;;
    -h|--help) sed -n '3,23p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) targets+=("$arg") ;;
  esac
done

if [ ${#targets[@]} -eq 0 ]; then
  targets=("/Applications" "$HOME/Applications")
  $include_system && targets+=("/System/Applications")
fi

if [ -t 1 ]; then
  green=$'\033[32m'; yellow=$'\033[33m'; red=$'\033[31m'; dim=$'\033[2m'; reset=$'\033[0m'
else
  green=""; yellow=""; red=""; dim=""; reset=""
fi

# Collect .app bundles (top level of each folder, plus one level of subfolders like /Applications/Utilities)
apps=()
for target in "${targets[@]}"; do
  if [[ "$target" == *.app ]]; then
    [ -d "$target" ] && apps+=("$target")
  elif [ -d "$target" ]; then
    while IFS= read -r app; do
      apps+=("$app")
    done < <(find "$target" -maxdepth 2 -name "*.app" -type d -prune 2>/dev/null | sort)
  fi
done

if [ ${#apps[@]} -eq 0 ]; then
  print_warning "No apps found."
  exit 0
fi

count_apple=0; count_store=0; count_notarized=0; count_devid=0; count_rejected=0; count_other=0

print_step "Checking ${#apps[@]} apps..."

for app in "${apps[@]}"; do
  name=$(basename "$app" .app)
  # spctl exits non-zero for rejected apps; don't let set -e (from utils.sh) abort the scan
  assessment=$(spctl --assess --type execute -vv "$app" 2>&1) || true
  source=$(printf '%s\n' "$assessment" | sed -n 's/^source=//p' | head -1)
  signer=$(codesign -dv --verbose=2 "$app" 2>&1 | sed -n 's/^Authority=//p' | head -1)

  if printf '%s' "$assessment" | grep -q ': accepted'; then
    case "$source" in
      "Apple System")           color=$green;  label="Apple";             count_apple=$((count_apple + 1)) ;;
      "Mac App Store")          color=$green;  label="App Store";         count_store=$((count_store + 1)) ;;
      "Notarized Developer ID") color=$green;  label="Notarized";         count_notarized=$((count_notarized + 1)) ;;
      "Developer ID")           color=$yellow; label="Not notarized";     count_devid=$((count_devid + 1)) ;;
      *)                        color=$yellow; label="Accepted ($source)"; count_other=$((count_other + 1)) ;;
    esac
  else
    color=$red
    if [ -z "$signer" ]; then
      label="REJECTED (unsigned or ad-hoc)"
    else
      label="REJECTED"
    fi
    count_rejected=$((count_rejected + 1))
  fi

  if $only_issues && [ "$color" = "$green" ]; then
    continue
  fi

  printf '%s%-28s%s %-40s %s%s%s\n' "$color" "$label" "$reset" "$name" "$dim" "${signer:-no signer}" "$reset"
done

echo
print_info "Checked ${#apps[@]} apps:"
echo "  ${green}Apple:${reset} $count_apple  ${green}App Store:${reset} $count_store  ${green}Notarized:${reset} $count_notarized"
echo "  ${yellow}Not notarized:${reset} $count_devid  ${yellow}Other:${reset} $count_other  ${red}Rejected:${reset} $count_rejected"

if [ "$count_rejected" -eq 0 ]; then
  print_ok "All apps were accepted by Gatekeeper."
else
  print_error "$count_rejected app(s) were rejected by Gatekeeper."
  exit 1
fi
