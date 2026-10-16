---
name: mac-cleanup
description: Analyzes and safely frees gigabytes of storage on macOS for developers and AI engineers. Cleans package manager caches (Conda pkgs, npm, uv, pnpm), AI/ML runtime artifacts (Claude VM bundles, LM Studio extensions, Codex caches), detached iOS simulator runtime disks, app/browser caches (Spotify, Brave, ShipIt updaters), and optional downloaded DMG installers. Use whenever the user is running low on disk space, wants to clean their Mac, or asks to free up storage.
license: MIT
compatibility: macOS (Apple Silicon & Intel)
metadata:
  author: Ahmad Musayev
  version: "1.0.1"
  tags:
    - macos
    - storage
    - disk-cleanup
    - developer-tools
    - ai-agents
---

# macOS Developer Storage Cleaner (`mac-cleanup`)

A safe, progressive cleanup skill tailored for software engineers, machine learning practitioners, and AI agent users on macOS.

---

## Why This Skill?

General cleaner utilities often delete files indiscriminately or miss modern developer and AI environment bloat. This skill targets strictly safe, rebuildable disk consumers that accumulate unnoticed:

- **Anaconda / Conda Package Archives (`conda clean --all`)**: Accumulates gigabytes of downloaded `.tar.bz2` and `.conda` archives after packages are installed. Active environments remain untouched.
- **Detached iOS Simulator APFS Runtimes**: Orphan runtime disk images (`/Library/Developer/CoreSimulator`) mounted in the background consuming 15–25 GB.
- **AI Agent & Local VM Artifacts**: Claude Desktop local VM bundles (`~/Library/Application Support/Claude/vm_bundles`), LM Studio extension caches (`~/.lmstudio/extensions`), and Codex runtime caches.
- **Media & Browser Streaming Caches**: Spotify offline audio cache (`com.spotify.client`), Brave/Chrome disk caches, and Electron updater archives.
- **Optional Installer Disk Images**: Downloaded `.dmg` files in `~/Downloads` (opt-in with `--include-dmgs`).

---

## Safety Guarantees

- **No Source Code Loss**: Never touches project directories, git repositories, worktrees, or personal documents.
- **No Broken Environments**: Only purges package caches (archives and index files), never the active packages or environments currently in use.
- **No Data Loss**: Does not delete user configurations, databases, or active application state.
- **Dry-Run by Default**: Provides a `--dry-run` inspection flag to review exact reclaimable paths and byte counts before any action is taken.
- **Protected Downloads**: Downloaded `.dmg` installer disk images require explicit opt-in (`--include-dmgs`) and are never deleted silently.

---

## Activation Triggers

Agents dynamically activate this skill when the user:
- Says *"free up space on my Mac"* or *"I'm running low on disk space"*.
- Says *"clean my laptop"* or *"clean developer caches"*.
- Experiences disk-full errors during Docker builds, `npm install`, `conda install`, or Xcode compilation.
- Mentions *"analyze my laptop storage"*.

---

## Execution Workflow

### Step 1: Diagnose Current Storage
Inspect the APFS data partition first:
```bash
df -h /System/Volumes/Data
```

### Step 2: Run Inspection in Dry-Run Mode
Execute the cleaner script with `--dry-run` to preview recoverable space:
```bash
./scripts/cleanup.sh --dry-run
```

Present discovered items and disk sizes clearly to the user before running cleanup operations.

### Step 3: Run Safe Cleanup
When authorized, execute the cleaner:
```bash
./scripts/cleanup.sh
```

To also clean downloaded `.dmg` disk images from `~/Downloads`:
```bash
./scripts/cleanup.sh --include-dmgs
```

### Step 4: Verify Reclaimed Space
Re-run `df -h /System/Volumes/Data` to confirm the total gigabytes recovered.

---

## Categories Cleaned

| Category | Typical Savings | Targets Cleaned |
| :--- | :--- | :--- |
| **Package Managers** | 10 – 30 GB | `conda pkgs`, `npm cache`, `uv cache`, `pnpm store` |
| **AI & Simulators** | 15 – 35 GB | Orphan iOS Simulator disks, Claude VM bundles, LM Studio extensions, Codex caches |
| **Streaming & Browsers** | 5 – 15 GB | Spotify audio cache, Brave cache, Google caches, ShipIt updater archives |
| **Installer Disk Images** | 2 – 10 GB | `.dmg` files in `~/Downloads` (opt-in with `--include-dmgs`) |

---

## Companion Script Details

The skill includes [`scripts/cleanup.sh`](scripts/cleanup.sh) which handles:
- Checking existing tools (`conda`, `npm`, `pnpm`, `uv`, `diskutil`) before attempting calls.
- Safely unmounting orphan simulator runtimes via `diskutil` without hard-killing running system processes.
- Skipping non-existent paths gracefully.
