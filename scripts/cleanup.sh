#!/usr/bin/env bash
set -e

DRY_RUN=false
CLEAN_DMGS=false

for arg in "$@"; do
  case "$arg" in
    --dry-run|-n)
      DRY_RUN=true
      ;;
    --include-dmgs)
      CLEAN_DMGS=true
      ;;
    --help|-h)
      echo "Usage: ./cleanup.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --dry-run, -n      Preview recoverable space without deleting anything"
      echo "  --include-dmgs     Include downloaded .dmg installer disk images in ~/Downloads"
      echo "  --help, -h         Show this help message"
      exit 0
      ;;
  esac
done

if [ "$DRY_RUN" = true ]; then
  echo "[DRY RUN MODE] - No files will be modified or deleted."
fi

echo "=========================================="
echo "macOS Developer Storage Cleaner"
echo "=========================================="
df -h /System/Volumes/Data | tail -1 | awk '{printf "Current Storage: %s used, %s available (%s capacity)\n", $3, $4, $5}'
echo "------------------------------------------"

clean_item() {
  local name="$1"
  local path="$2"
  if [[ -e "$path" ]]; then
    local size
    size=$(du -sh "$path" 2>/dev/null | cut -f1)
    if [[ -n "$size" ]]; then
      if [ "$DRY_RUN" = true ]; then
        echo "  [Would Clean] $name: $size ($path)"
      else
        echo "  [Cleaning] $name: $size..."
        rm -rf "$path" 2>/dev/null || true
      fi
    fi
  fi
}

echo "1. Package Manager & Developer Caches..."
if command -v conda &>/dev/null; then
  if [ "$DRY_RUN" = true ]; then
    echo "  [Would Clean] Conda package cache (pkgs)"
  else
    echo "  [Cleaning] Conda package cache..."
    conda clean --all -y &>/dev/null || true
  fi
fi

if command -v npm &>/dev/null; then
  if [ "$DRY_RUN" = true ]; then
    echo "  [Would Clean] NPM cache"
  else
    echo "  [Cleaning] NPM cache..."
    npm cache clean --force &>/dev/null || true
  fi
fi

clean_item "UV Cache" "$HOME/.cache/uv"
clean_item "pnpm Store/Cache" "$HOME/Library/pnpm"
clean_item "Codex Runtimes Cache" "$HOME/.cache/codex-runtimes"

echo "2. App & Browser Caches..."
clean_item "Spotify Audio Cache" "$HOME/Library/Caches/com.spotify.client"
clean_item "Brave Cache" "$HOME/Library/Caches/BraveSoftware"
clean_item "Brave Browser Cache" "$HOME/Library/Caches/com.brave.Browser"
clean_item "ShipIt Updater Cache" "$HOME/Library/Caches/com.todesktop.230313mzl4w4u92.ShipIt"
clean_item "Homebrew Download Cache" "$HOME/Library/Caches/Homebrew"
clean_item "Google Caches" "$HOME/Library/Caches/Google"
clean_item "Opencode Updater Cache" "$HOME/Library/Caches/@opencode-aidesktop-updater"
clean_item "Codebuff Freebuff Updater Cache" "$HOME/Library/Caches/@codebufffreebuff-desktop-updater"
clean_item "Notion Updater Cache" "$HOME/Library/Caches/notion-updater"

echo "3. System & Temporary VM Artifacts..."
clean_item "Docker Installer Backup" "$HOME/Library/Application Support/com.docker.install"
clean_item "macOS Dynamic Wallpapers" "$HOME/Library/Application Support/com.apple.wallpaper"
clean_item "Claude Desktop VM Bundles" "$HOME/Library/Application Support/Claude/vm_bundles"
clean_item "LM Studio Extensions" "$HOME/.lmstudio/extensions"

# Safely check for mounted iOS Simulator runtimes without killing Xcode or other developer processes
SIM_DISK=$(diskutil list 2>/dev/null | awk '/APFS Volume iOS.*Simulator/ {print $NF}' | head -n 1)
if [[ -n "$SIM_DISK" ]]; then
  if [ "$DRY_RUN" = true ]; then
    echo "  [Would Unmount] iOS Simulator runtime volume ($SIM_DISK)"
  else
    echo "  [Unmounting] iOS Simulator runtime volume ($SIM_DISK)..."
    diskutil unmount force "$SIM_DISK" 2>/dev/null || true
  fi
fi

if [ "$CLEAN_DMGS" = true ]; then
  echo "4. Downloaded .dmg Installers in ~/Downloads..."
  find "$HOME/Downloads" -maxdepth 1 -type f -name "*.dmg" | while read -r dmg; do
    size=$(du -sh "$dmg" 2>/dev/null | cut -f1)
    if [ "$DRY_RUN" = true ]; then
      echo "  [Would Delete DMG] $dmg ($size)"
    else
      echo "  [Deleting DMG] $(basename "$dmg") ($size)"
      rm -f "$dmg" 2>/dev/null || true
    fi
  done
else
  echo "4. Downloaded .dmg Installers in ~/Downloads (Skipped - pass --include-dmgs to clean)"
fi

echo "------------------------------------------"
echo "Finished."
df -h /System/Volumes/Data | tail -1 | awk '{printf "Updated Storage: %s used, %s available (%s capacity)\n", $3, $4, $5}'
echo "=========================================="
