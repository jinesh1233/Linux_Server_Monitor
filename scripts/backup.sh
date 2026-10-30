#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="${PROJECT_DIR:-$HOME/linux-server-monitor}"
# shellcheck source=./scripts/common.sh
source "$PROJECT_DIR/scripts/common.sh"

source_dir="${BACKUP_SOURCE:-$PROJECT_DIR/sample-data}"

if [[ ! -d "$source_dir" ]]; then
    log_message ERROR "Backup source not found: $source_dir"
    exit 1
fi

mkdir -p "$BACKUP_DIR"

timestamp="$(date +%Y%m%d_%H%M%S)"
archive="$BACKUP_DIR/backup_${timestamp}.tar.gz"
tmp_archive="$BACKUP_DIR/.backup_${timestamp}.tmp"

cleanup() {
    rm -f "$tmp_archive"
}
trap cleanup EXIT

tar -czf "$tmp_archive" -C "$source_dir" .

if ! tar -tzf "$tmp_archive" >/dev/null; then
    log_message ERROR "Backup integrity verification failed"
    exit 1
fi

mv "$tmp_archive" "$archive"

log_message INFO "Verified backup created: $archive"
