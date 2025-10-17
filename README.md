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
