#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="${PROJECT_DIR:-$HOME/linux-server-monitor}"
CONFIG_FILE="${CONFIG_FILE:-$PROJECT_DIR/config/monitor.conf}"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: Config file not found: $CONFIG_FILE" >&2
    exit 1
fi

# shellcheck source=monitor.conf
# shellcheck disable=SC1091
source "$CONFIG_FILE"

mkdir -p "$LOG_DIR"

LOG_FILE="${LOG_FILE:-$LOG_DIR/monitor.log}"

log_message() {
    local level="$1"
    shift

    printf '%s [%s] %s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" \
        "$level" "$*" | tee -a "$LOG_FILE"
}
