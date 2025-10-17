#!/usr/bin/env bash

# ===============================================================
#   ____  _               _                      _             
#  / ___|| |__   ___  ___| | _____ _ __ ___  ___| |_ ___  _ __ 
#  \___ \| '_ \ / _ \/ __| |/ / _ \ '__/ __|/ _ \ __/ _ \| '__|
#   ___) | | | |  __/ (__|   <  __/ |  \__ \  __/ || (_) | |   
#  |____/|_| |_|\___|\___|_|\_\___|_|  |___/\___|\__\___/|_|   
#
#  Sherman - interactive uninstaller (live search)
#  v2.0  - Removes user-installed services/packages thoroughly
#  Usage: sherman.sh [options]
# ===============================================================


set -euo pipefail
IFS=$'\n\t'

# Defaults
DRY_RUN=0
AUTO_CONFIRM=0
BACKUP=1
LOGFILE="$HOME/sherman_uninstall.log"
MODE="interactive"

CORE_SERVICES_REGEX="^(dbus|systemd|cron|network|udev|ssh|rsyslog|apparmor|snapd|cups|gdm|lightdm|nginx|apache2|postgresql|mysql|avahi|bluetooth|ModemManager|ufw|polkit|NetworkManager|systemd-).*"

usage(){
  cat <<USAGE
Sherman - Uninstall tool with live fuzzy search

Usage: $(basename "$0") [options]

Options:
  -h, --help          Show this help
  -l, --list          List detected user-installed services & packages
  -i, --interactive   Interactive mode with live search (default)
  --dry-run           Show actions without deleting
  --yes               Auto confirm destructive actions
  --no-backup         Skip config backup
USAGE
  exit 0
}

log(){ echo "$(date '+%F %T') | $*" >> "$LOGFILE"; }
run_cmd(){ [[ $DRY_RUN -eq 1 ]] && echo "[DRY-RUN] $*" || { echo "+ $*"; eval "$@"; }; log "$*"; }

ensure_tmp(){ mkdir -p "/tmp/sherman-$$"; trap 'rm -rf "/tmp/sherman-$$"' EXIT; }

detect_systemd_user_services(){ systemctl list-unit-files --type=service --no-pager --no-legend 2>/dev/null | awk '{print $1}' | grep -v -E "$CORE_SERVICES_REGEX" | sort -u; }
detect_snap_packages(){ command -v snap >/dev/null 2>&1 && snap list --all 2>/dev/null | awk 'NR>1{print $1}' | sort -u || true; }
detect_flatpak_apps(){ command -v flatpak >/dev/null 2>&1 && flatpak list --app --columns=application 2>/dev/null || true; }

inspect_target(){ local name="$1"; echo "=== Inspecting: $name ==="; systemctl list-unit-files | grep -i "$name" || true; dpkg-query -W --showformat='${Package} ${Version}\n' 2>/dev/null | grep -i "$name" || true; command -v "$name" && echo "Executable: $(command -v $name)"; snap list --all 2>/dev/null | grep -i "$name" || true; flatpak list --app --columns=application 2>/dev/null | grep -i "$name" || true; }

backup_configs(){ local t="$1"; [[ $BACKUP -eq 0 ]] && return; for d in "/etc/$t" "$HOME/.config/$t" "$HOME/.local/share/$t" "/opt/$t" "/var/lib/$t"; do [[ -e "$d" ]] && cp -a "$d" "/tmp/sherman-$$/" && echo "Backed up $d"; done; }

ask_confirm(){ [[ $AUTO_CONFIRM -eq 1 ]] && return 0; read -rp "Proceed to uninstall '$1'? [y/N]: " ans; [[ "$ans" =~ ^[Yy] ]] || return 1; }

remove_systemd_unit(){ local u="$1"; run_cmd sudo systemctl stop "$u" || true; run_cmd sudo systemctl disable "$u" || true; frag=$(systemctl show -p FragmentPath "$u" 2>/dev/null | cut -d'=' -f2 || true); [[ -f "$frag" ]] && run_cmd sudo rm -f "$frag"; run_cmd sudo systemctl daemon-reload; }

remove_apt_package(){ local p="$1"; dpkg -s "$p" >/dev/null 2>&1 && run_cmd sudo apt-get remove --purge -y "$p" && run_cmd sudo apt-get autoremove -y || echo "No apt package $p"; }

remove_snap(){ local s="$1"; snap list --all 2>/dev/null | awk 'NR>1{print $1}' | grep -xq "$s" && run_cmd sudo snap remove "$s"; }
remove_flatpak(){ local f="$1"; flatpak list --app --columns=application 2>/dev/null | grep -xq "$f" && run_cmd flatpak uninstall -y "$f"; }

remove_files_by_find(){ local name="$1"; for p in /usr/local/bin /usr/bin /opt /etc "$HOME/.local/bin" "$HOME/.local/share" "$HOME/.config" /var/lib /var/log; do [[ -d "$p" ]] && find "$p" -maxdepth 3 -iname "*$name*" -exec bash -c 'run_cmd sudo rm -rf "$0"' {} \; ; done; }

main_uninstall(){ local t="$1"; echo "=== Uninstalling $t ==="; log "Uninstall $t"; inspect_target "$t"; backup_configs "$t"; ask_confirm "$t" || { echo "Aborted"; return 1; }; for u in $(systemctl list-unit-files --type=service --no-legend | awk '{print $1}' | grep -i "$t" || true); do remove_systemd_unit "$u"; done; remove_snap "$t"; remove_flatpak "$t"; if dpkg -s "$t" >/dev/null 2>&1; then remove_apt_package "$t"; else for p in $(dpkg-query -W -f='${Package}\n' | grep -i "$t" || true); do [[ $AUTO_CONFIRM -eq 0 ]] && read -rp "Purge $p? [y/N]: " a && [[ "$a" =~ ^[Yy] ]] && remove_apt_package "$p" || remove_apt_package "$p"; done; fi; remove_files_by_find "$t"; run_cmd sudo systemctl daemon-reload; echo "=== $t uninstall completed ==="; log "End $t"; }

# Parse arguments
[[ $# -eq 0 ]] && MODE="interactive"
POSITIONAL=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage ;;
    -l|--list) detect_systemd_user_services; detect_snap_packages; detect_flatpak_apps; exit 0 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --yes) AUTO_CONFIRM=1; shift ;;
    --no-backup) BACKUP=0; shift ;;
    -i|--interactive) MODE="interactive"; shift ;;
    -a|--auto) MODE="auto"; TARGET="$2"; shift 2 ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done
set -- "${POSITIONAL[@]}"

ensure_tmp

# Interactive with live search using fzf
if [[ "$MODE" == "interactive" ]]; then
  mapfile -t SERVICES < <(detect_systemd_user_services)
  mapfile -t SNAPS < <(detect_snap_packages)
  mapfile -t FLATPAKS < <(detect_flatpak_apps)
  CANDIDATES=("${SERVICES[@]}" "${SNAPS[@]}" "${FLATPAKS[@]}")
  [[ ${#CANDIDATES[@]} -eq 0 ]] && { echo "No candidates found"; exit 0; }
  TARGET=$(printf '%s\n' "${CANDIDATES[@]}" | fzf --prompt="Search> " --height 15 --border)
  [[ -z "$TARGET" ]] && { echo "No selection"; exit 0; }
  main_uninstall "$TARGET"
  exit 0
fi

# Auto mode
[[ "$MODE" == "auto" && -n "${TARGET:-}" ]] && main_uninstall "$TARGET"
