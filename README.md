# macOS Developer Storage Cleaner (`mac-cleanup`)

[![Agent Skills Standard](https://img.shields.io/badge/Agent_Skills-Specification-blue?style=flat-square)](https://agentskills.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](LICENSE)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS-lightgrey.svg?style=flat-square)](https://apple.com)

An open-standard Agent Skill and automated CLI that safely reclaims 50–100+ GB of wasted developer and AI storage on macOS.

Works with any AI agent environment supporting the [Agent Skills standard](https://agentskills.io) (Antigravity, Claude Code, OpenAI Codex, Cursor, Windsurf, etc.), as well as standalone via the command line.

---

## What Gets Cleaned (100% Rebuildable)

| Category | Typical Reclaimed | Targets |
| :--- | :--- | :--- |
| **Developer Package Caches** | **15 – 35 GB** | `conda clean --all` (`~/anaconda3/pkgs`), `npm cache clean`, `uv cache`, `pnpm store` |
| **AI Runtimes & Simulators** | **20 – 40 GB** | Orphan iOS Simulator APFS disks (`/Library/Developer/CoreSimulator`), Claude Desktop VM bundles (`vm_bundles`), LM Studio extension caches (`~/.lmstudio/extensions`), Codex caches |
| **Media & Browser Caches** | **8 – 18 GB** | Spotify offline audio cache (`com.spotify.client`), Brave/Chrome disk & shader caches, Electron ShipIt updater caches |
| **Leftover Installers (Opt-in)** | **2 – 10 GB** | Downloaded `.dmg` files in `~/Downloads` (using `--include-dmgs`) |

---

## Installation

### Option 1: Install with `npx skills` (Recommended)
```bash
npx skills add MusayevAhmad/mac-cleanup-skill
```

### Option 2: Clone directly into your Agent Skills directory
```bash
# For Antigravity / universal agent setups:
git clone https://github.com/MusayevAhmad/mac-cleanup-skill.git ~/.agents/skills/mac-cleanup

# For Claude Code:
git clone https://github.com/MusayevAhmad/mac-cleanup-skill.git ~/.claude/skills/mac-cleanup
```

### Option 3: Use Standalone (No Agent Needed)
```bash
git clone https://github.com/MusayevAhmad/mac-cleanup-skill.git
cd mac-cleanup-skill

# Preview what can be cleaned without deleting anything:
./scripts/cleanup.sh --dry-run

# Run full safe cleanup:
./scripts/cleanup.sh

# Include downloaded .dmg files in ~/Downloads:
./scripts/cleanup.sh --include-dmgs
```

---

## Using with AI Agents

Once installed, your AI agent automatically activates this skill when you say:

> "Clean up my Mac storage"  
> "Analyze my disk space and free up room"  
> "I'm running out of storage, remove safe caches"  

The agent will first inspect your drive, show you a dry-run breakdown, and confirm what it can safely delete before proceeding.

---

## Safety Principles

1. **Zero Source Code Impact**: Never touches user codebases, git repositories, or uncommitted work.
2. **Never Breaks Environments**: Only cleans package download archives (`.tar.bz2`, index tarballs, cache layers) — installed libraries remain intact.
3. **Protected Downloads**: Downloaded `.dmg` installers are excluded by default and require the `--include-dmgs` flag.
4. **No Blind Deletions**: Provides an interactive `--dry-run` inspection mode so you see every byte that will be freed.

---

## License

MIT License — see [LICENSE](LICENSE) for details.
