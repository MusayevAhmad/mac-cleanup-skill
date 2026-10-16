---
name: mac-cleanup
description: Analyzes and safely frees gigabytes of storage on macOS for developers and AI engineers. Cleans package manager caches (Conda pkgs, npm, uv, pnpm), AI/ML runtime artifacts (Claude VM bundles, LM Studio extensions, Codex worktrees), detached iOS simulator runtime disks, app/browser caches (Spotify, Brave, ShipIt updaters), and downloaded DMG installers. Use whenever the user is running low on disk space, wants to clean their Mac, or asks to free up storage.
license: MIT
compatibility: macOS (Apple Silicon & Intel)
metadata:
  author: Ahmad Musayev
  version: "1.0.0"
  tags:
    - macos
    - storage
    - disk-cleanup
    - developer-tools
    - ai-agents
---

# macOS Developer Storage Cleaner (`mac-cleanup`)

A production-grade, safe, and progressive cleanup skill tailored for software engineers, machine learning practitioners, and AI agent users on macOS.

---

## 💡 Why This Skill?

General cleaner tools either delete files indiscriminately or miss modern developer and AI bloat. This skill specifically targets **safe, rebuildable disk consumers** that accumulate unnoticed:

- **Anaconda / Conda Package Archives (`conda clean --all`)**: Often hoards 10–30+ GB of downloaded `.tar.bz2` / `.conda` tarballs even after environments are deleted.
- **Detached iOS Simulator APFS Runtimes**: Orphan disk images (`/Library/Developer/CoreSimulator`) mounted in the background consuming 15–25 GB.
- **AI Agent & Local VM Artifacts**: Claude Desktop local VM bundles (`~/Library/Application Support/Claude/vm_bundles`), LM Studio extension caches (`~/.lmstudio/extensions`), and Codex worktrees.
- **Media & Browser Streaming Caches**: Spotify offline audio cache (`com.spotify.client`), Brave/Chrome shader/disk caches.
- **Orphan Installers**: Forgotten `.dmg` disk images sitting in `~/Downloads`.

---

## 🛡️ Safety Guarantees

- **NO Source Code Loss**: Never touches project source code, uncommitted files, or personal documents.
- **NO Broken Environments**: Only purges package caches (archives and index files), never the active environments or packages currently used.
- **NO Data Loss**: Does not delete user settings, databases, or active application states.
- **Dry-Run by Default**: Provides a `--dry-run` inspection flag to review exact reclaimable paths and byte counts before any deletion happens.

---

## 📋 Activation Triggers

Agents should dynamically activate this skill when the user:
- Says *"free up space on my Mac"* or *"I'm running low on disk space"*.
- Says *"clean my laptop"* or *"clean developer caches"*.
- Experiences disk-full errors during Docker builds, `npm install`, `conda install`, or Xcode compilation.
- Mentions *"analyze my laptop storage"*.

---

## 🚀 Execution Workflow

### Step 1: Diagnose & Triage Current Storage
Always inspect the APFS data partition first to ground analysis:
```bash
df -h /System/Volumes/Data
```

### Step 2: Run Inspection in Dry-Run Mode
Execute the bundled cleaner script with `--dry-run` to preview recoverable space:
```bash
./scripts/cleanup.sh --dry-run
```

Present the discovered items and disk sizes clearly to the user before running destructive operations.

### Step 3: Run Safe Cleanup
When authorized, execute the full cleaner:
```bash
./scripts/cleanup.sh
```

### Step 4: Verify Reclaimed Space
Re-run `df -h /System/Volumes/Data` to confirm the total gigabytes recovered.

---

## 🗂️ Categories Cleaned

| Category | Typical Savings | Targets Cleaned |
| :--- | :--- | :--- |
| **Package Managers** | 10 – 30 GB | `conda pkgs`, `npm cache`, `uv cache`, `pnpm store` |
| **AI & Simulators** | 15 – 35 GB | Orphan iOS Simulator disks, Claude VM bundles, LM Studio extensions, Codex worktrees |
| **Streaming & Browsers**| 5 – 15 GB | Spotify audio cache, Brave cache, Google caches, ShipIt updater archives |
| **Installer Disk Images**| 2 – 10 GB | `.dmg` files in `~/Downloads` |

---

## 🛠️ Companion Script Details

The skill includes [`scripts/cleanup.sh`](scripts/cleanup.sh) which handles:
- Checking existing tools (`conda`, `npm`, `pnpm`, `uv`, `diskutil`) before attempting calls.
- Force-ejecting stale simulator runtimes gracefully without rebooting.
- Graceful handling of missing files and permission boundary fallbacks.
