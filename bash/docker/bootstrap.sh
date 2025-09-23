#!/usr/bin/env bash
# Modern Docker install (2025)
# - Ubuntu/Debian, RHEL/CentOS/Alma/Rocky/Fedora, openSUSE/SLES
# - Installs: docker-ce, docker-ce-cli, containerd.io, docker-buildx-plugin, docker-compose-plugin
# - Uses Compose v2 via `docker compose` (no legacy docker-compose)
# - Adds current user to 'docker' group (optional, default yes)

set -euo pipefail

### --- Config toggles ---
ADD_USER_TO_DOCKER_GROUP="${ADD_USER_TO_DOCKER_GROUP:-yes}"

### --- Helpers ---
log() { printf "\033[1;32m[INFO]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
err()  { printf "\033[1;31m[ERR ]\033[0m %s\n" "$*" >&2; }

need_cmd() { command -v "$1" >/dev/null 2>&1 || { err "Missing required command: $1"; exit 1; }; }

require_root() {
  if [ "$(id -u)" -ne 0 ]; then
    err "Please run as root or with sudo."
    exit 1
  fi
}

detect_distro() {
  if [ -r /etc/os-release ]; then
    . /etc/os-release
    DISTRO_ID="${ID,,}"
    DISTRO_VER="${VERSION_ID:-}"
    DISTRO_LIKE="${ID_LIKE:-}"
  else
    err "Unable to detect Linux distribution."
    exit 1
  fi
}

detect_arch() {
  case "$(uname -m)" in
    x86_64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) err "Unsupported architecture: $(uname -m)"; exit 1 ;;
  esac
}

enable_buildkit_defaults() {
  # Make BuildKit default for both client and daemon (daemon requires restart)
  mkdir -p /etc/docker
  if [ ! -f /etc/docker/daemon.json ]; then
    cat >/etc/docker/daemon.json <<'JSON'
{
  "features": { "buildkit": true }
}
JSON
  else
    # Merge-friendly: ensure features.buildkit true if file exists
    # (best-effort, no external deps)
    if ! grep -q '"features"' /etc/docker/daemon.json; then
      tmp=$(mktemp)
      sed '1 s|{$|{"features":{"buildkit":true},|; t; s|}|,"features":{"buildkit":true}}|' /etc/docker/daemon.json > "$tmp" || true
      cp "$tmp" /etc/docker/daemon.json
      rm -f "$tmp"
    fi
  fi
  # Client env for shells spawned after install
  grep -q 'DOCKER_BUILDKIT' /etc/environment || echo 'DOCKER_BUILDKIT=1' >> /etc/environment
}

install_ubuntu_debian() {
  need_cmd curl
  need_cmd gpg
  apt-get update -y
  apt-get install -y ca-certificates curl gnupg lsb-release

  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/"$DISTRO_ID"/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  CODENAME="$(. /etc/os-release && echo "${VERSION_CODENAME:-$(lsb_release -cs 2>/dev/null || echo)}")"
  echo \
"deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${DISTRO_ID} ${CODENAME} stable" \
    >/etc/apt/sources.list.d/docker.list

  apt-get update -y
  apt-get install -y \
    docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin

  systemctl enable --now docker
}

install_rhel_fedora() {
  need_cmd curl
  # Prefer dnf when available
  PKG_MGR="yum"
  command -v dnf >/dev/null 2>&1 && PKG_MGR="dnf"

  # Add Docker repo
  if [ ! -f /etc/yum.repos.d/docker-ce.repo ]; then
    curl -fsSL https://download.docker.com/linux/"$([ "$DISTRO_ID" = "fedora" ] && echo fedora || echo centos)"/docker-ce.repo \
      -o /etc/yum.repos.d/docker-ce.repo
  fi

  $PKG_MGR -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  systemctl enable --now docker
}

install_suse() {
  need_cmd curl
  zypper -n refresh
  # Add repo if missing
  if ! zypper lr | grep -qi docker-ce; then
    # openSUSE uses the CentOS/Fedora repo layout is not officially supported everywhere; fallback to get.docker.com
    warn "Using convenience script for openSUSE/SLES (official repo coverage varies)."
    curl -fsSL https://get.docker.com | sh
  else
    zypper -n install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || {
      warn "Falling back to convenience script."
      curl -fsSL https://get.docker.com | sh
    }
  fi
  systemctl enable --now docker
}

install_docker() {
  case "$DISTRO_ID" in
    ubuntu|debian)
      install_ubuntu_debian
      ;;
    rhel|centos|rocky|almalinux|fedora)
      install_rhel_fedora
      ;;
    opensuse*|sles*)
      install_suse
      ;;
    amzn)
      # Amazon Linux
      need_cmd yum
      yum -y install docker
      systemctl enable --now docker
      ;;
    *)
      # Try ID_LIKE hints
      if echo "$DISTRO_LIKE" | grep -qi "debian"; then
        install_ubuntu_debian
      elif echo "$DISTRO_LIKE" | grep -Eiq "rhel|fedora|centos"; then
        install_rhel_fedora
      else
        err "Unsupported distribution: $DISTRO_ID"
        exit 1
      fi
      ;;
  esac
}

verify_install() {
  if ! command -v docker >/dev/null 2>&1; then
    err "Docker CLI not found after install."
    exit 1
  fi

  log "Docker version:"
  docker --version || true

  # Compose v2 plugin should be available as `docker compose`
  if docker compose version >/dev/null 2>&1; then
    log "Docker Compose v2:"
    docker compose version
  else
    err "Docker Compose v2 plugin not detected. Check package install."
    exit 1
  fi

  # Buildx plugin should be present
  if docker buildx version >/dev/null 2>&1; then
    log "Docker Buildx:"
    docker buildx version
  else
    warn "Docker Buildx plugin not detected."
  fi
}

post_install() {
  enable_buildkit_defaults

  # Optional: add invoking user to docker group (if not root in non-CI)
  if [ "$ADD_USER_TO_DOCKER_GROUP" = "yes" ]; then
    # Choose a non-root user if script is run via sudo
    TARGET_USER="${SUDO_USER:-${USER}}"
    if id -nG "$TARGET_USER" 2>/dev/null | grep -qw docker; then
      log "User '$TARGET_USER' already in 'docker' group."
    else
      if ! getent group docker >/dev/null 2>&1; then
        groupadd docker
      fi
      usermod -aG docker "$TARGET_USER" || warn "Could not add $TARGET_USER to docker group."
      log "Added '$TARGET_USER' to 'docker' group. You must log out/in (or 'newgrp docker') to take effect."
    fi
  fi

  # Sanity: ensure service is alive
  if ! systemctl is-active --quiet docker; then
    err "Docker service is not active."
    journalctl -u docker --no-pager -n 50 || true
    exit 1
  fi

  log "Docker is installed and running."
}

### --- Main ---
require_root
detect_distro
detect_arch

log "Detected: ${DISTRO_ID} ${DISTRO_VER:-} (like: ${DISTRO_LIKE:-unknown}), arch: ${ARCH}"
install_docker
verify_install
post_install

log "Done. Use 'docker run hello-world' to test. Compose via 'docker compose ...'."