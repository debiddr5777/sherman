<<<<<<< HEAD
# Sherman - Interactive Linux Uninstaller Tool

**Sherman** is a sophisticated, interactive uninstaller for Linux.  
It detects non-core services, APT packages, Snap packages, and Flatpak apps.  
It provides **live fuzzy search**, safe backup of configs, and fully purges selected software.

---

## 🚀 One-line Installation & Setup

Copy and paste the following in your terminal. It will:

1. Download `sherman.sh` into `~/tools/`
2. Make it executable
3. Add it to your PATH
4. Display the help menu

```bash
# Install fzf if not already installed
sudo apt update && sudo apt install -y fzf

# Download Sherman, make it executable, add to PATH, and show help
mkdir -p ~/sherman && curl -fsSL https://raw.githubusercontent.com/debiddr5777/sherman/main/sherman.sh -o ~/tools/sherman.sh && chmod +x ~/tools/sherman.sh && echo 'export PATH=$PATH:~/tools' >> ~/.bashrc && source ~/.bashrc && sherman.sh --help
=======
# Sherman

Sherman is a command-line uninstaller helper for Debian/Ubuntu-like systems. It helps you find and remove user-installed services, snaps, flatpaks, and packages using a fuzzy search UI (fzf) or in auto mode. It tries to stop/disable systemd units, remove packages (apt/snap/flatpak), and back up common config locations before removal.

⚠️ Important: Sherman is powerful and can remove services or packages. Always preview with --dry-run and read the Safety notes below before using it.

Features
- Interactive fuzzy search (requires fzf) to pick targets
- Supports systemd units, apt packages, snap packages, flatpak apps
- Dry-run mode to preview actions
- Optional automatic confirmations
- Backs up config directories to /tmp during operation (can be disabled)

Quick install (copy-paste)

This one-liner will:
- install `sherman.sh` to `~/.local/bin/sherman`
- make it executable
- ensure `~/.local/bin` is in your PATH by appending an export to `~/.bashrc` if missing
- show the help menu

Copy and paste the single command below into a bash shell:

```bash
install -Dm755 sherman.sh "$HOME/.local/bin/sherman" && \
grep -q "export PATH=\"\$HOME/.local/bin:\$PATH\"" "$HOME/.bashrc" || \
echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc" && \
echo "Installed to $HOME/.local/bin/sherman" && \
exec bash -lc 'sherman --help'
```

Usage

After installation (open a new shell or run `source ~/.bashrc`), run:

Sherman — simple interactive uninstaller

Want to quickly install Sherman and try it? Run the single command below from any directory. It will clone this repo into your current folder and run the small installer.

Copy & paste this one-liner into your terminal:

```bash
git clone https://github.com/debiddr5777/sherman.git && cd sherman && bash install.sh
```

After the installer finishes, open a new terminal (or run `source ~/.bashrc`) and run:

  sherman

That's it — simple and quick.
---

## 🚀 One-line Installation & Setup

Copy and paste the following in your terminal. It will:

1. Install (copy) the local `sherman.sh` into `~/.local/bin/` (you can change the path)
2. Make it executable
3. Add `~/.local/bin` to your PATH in `~/.bashrc` if missing
4. Display the help menu

```bash
# Optional: install fzf if you plan to use interactive mode
sudo apt update && sudo apt install -y fzf || true

# Install the local script into ~/.local/bin and show help
install -Dm755 sherman.sh "$HOME/.local/bin/sherman" && \
grep -q "export PATH=\"\$HOME/.local/bin:\$PATH\"" "$HOME/.bashrc" || \
echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc" && \
echo "Installed to $HOME/.local/bin/sherman" && \
exec bash -lc 'sherman --help'
```

> Note: the command above assumes you already have the repository checked out and are running it from the repo root. If you prefer to download the latest remote script instead, replace the install step with a curl command that fetches the raw file from the repository.

Usage

After installation (open a new shell or run `source ~/.bashrc`), run:

- Interactive mode (default):

  sherman

  This opens a fuzzy search list (requires `fzf`) combining detected systemd user services, snap packages and flatpaks.

- Auto mode (uninstall specific target):

  sherman --auto <target>

- List detected candidates:

  sherman --list

- Other options:

  --dry-run    Show actions without actually removing anything
  --yes        Auto confirm destructive actions
  --no-backup  Skip backing up config files
  -h, --help   Show help and exit

Examples

- Preview what Sherman would do to the package `example` without removing:

  sherman --dry-run --auto example

- Uninstall a snap named `spotify` with automatic yes:

  sherman --yes --auto spotify

Safety and notes
- Sherman attempts to avoid removing core system services using an internal regex, but it may still remove essential packages if you choose them. Always review the detected items and use `--dry-run` first.
- Backups are copied to `/tmp/sherman-<pid>` during run and removed on exit. If you set `--no-backup`, config files will not be saved.
- The script uses `sudo` for package/service removal. You'll be prompted for your password if required.
- The interactive mode requires `fzf` to be installed to present a searchable list. Install it with your package manager, e.g. `sudo apt install fzf`.

Troubleshooting
- "No candidates found": install `fzf` or check you have user-installed services/packages.
- Permission denied when removing: ensure your user is in sudoers or run the script with privileges where appropriate.

Contributing and development
- The script is a single-file tool `sherman.sh` located in the project root. Edit it and run it directly for testing.

License
- See repository or project owner for license information.

Acknowledgements
- Uses system tools: systemctl, dpkg, apt, snap, flatpak, fzf.

--
Sherman — use carefully.
