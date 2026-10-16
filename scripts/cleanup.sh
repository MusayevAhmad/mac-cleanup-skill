#!/usr/bin/env bash
set -e

DRY_RUN=false
if [[ "$1" == "--dry-run" || "$1" == "-n" ]]; then
  DRY_RUN=true
  echo "🔍 [DRY RUN MODE] - No files will be deleted."
fi

echo "=========================================="
echo "🧹 macOS Developer Storage Cleaner"
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
clean_item "Codex Runtimes" "$HOME/.cache/codex-runtimes"
clean_item "Codex Worktrees" "$HOME/.codex/worktrees"

echo "2. App & Browser Caches..."
clean_item "Spotify Audio Cache" "$HOME/Library/Caches/com.spotify.client"
clean_item "Brave Cache" "$HOME/Library/Caches/BraveSoftware"
clean_item "Brave Browser Cache" "$HOME/Library/Caches/com.brave.Browser"
clean_item "ShipIt Updater Cache" "$HOME/Library/Caches/com.todesktop.230313mzl4w4u92.ShipIt"
clean_item "Homebrew Download Cache" "$HOME/Library/Caches/Homebrew"
clean_item "Google Caches" "$HOME/Library/Caches/Google"
clean_item "Codebuff/Opencode Updaters" "$HOME/Library/Caches/@opencode-aidesktop-updater"
clean_item "Codebuff Freebuff Updaters" "$HOME/Library/Caches/@codebufffreebuff-desktop-updater"
clean_item "Notion Updater" "$HOME/Library/Caches/notion-updater"

echo "3. System & Simulator Leftovers..."
clean_item "Docker Installer Backup" "$HOME/Library/Application Support/com.docker.install"
clean_item "macOS Dynamic Wallpapers" "$HOME/Library/Application Support/com.apple.wallpaper"
clean_item "Claude Desktop VM Bundles" "$HOME/Library/Application Support/Claude/vm_bundles"
clean_item "LM Studio Extensions" "$HOME/.lmstudio/extensions"

# Check for mounted simulator
if diskutil list | grep -q "iOS.*Simulator"; then
  if [ "$DRY_RUN" = true ]; then
    echo "  [Would Eject] iOS Simulator runtime volume"
  else
    echo "  [Ejecting] iOS Simulator runtime volume..."
    pkill -f "SimLaunch" 2>/dev/null || true
    diskutil eject /dev/disk4 2>/dev/null || true
  fi
fi

echo "4. Leftover .dmg files in Downloads..."
find "$HOME/Downloads" -maxdepth 1 -type f -name "*.dmg" | while read -r dmg; do
  size=$(du -sh "$dmg" 2>/dev/null | cut -f1)
  if [ "$DRY_RUN" = true ]; then
    echo "  [Would Delete DMG] $dmg ($size)"
  else
    echo "  [Deleting DMG] $(basename "$dmg") ($size)"
    rm -f "$dmg" 2>/dev/null || true
  fi
done

echo "------------------------------------------"
echo "✅ Finished!"
df -h /System/Volumes/Data | tail -1 | awk '{printf "Updated Storage: %s used, %s available (%s capacity)\n", $3, $4, $5}'
echo "=========================================="
