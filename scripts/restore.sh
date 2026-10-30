#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="${PROJECT_DIR:-$HOME/linux-server-monitor}"
# shellcheck source=./scripts/common.sh
source "$PROJECT_DIR/scripts/common.sh"

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 /path/to/backup.tar.gz" >&2
    exit 2
fi

archive="$(realpath "$1")"
backup_real="$(realpath "$BACKUP_DIR")"

if [[ ! -f "$archive" ]]; then
    log_message ERROR "Backup archive not found"
    exit 1
fi

case "$archive" in
    "$backup_real"/*) ;;
    *)
        log_message ERROR "Archive must be inside the backup directory"
        exit 2
        ;;
esac

if ! tar -tzf "$archive" >/dev/null; then
    log_message ERROR "Archive integrity check failed"
    exit 1
fi

while IFS= read -r member; do
    normalized="${member#./}"

    case "$normalized" in
        /*|..|../*|*/../*|*/..)
            log_message ERROR "Unsafe archive path detected"
            exit 1
            ;;
    esac
done < <(tar -tzf "$archive")

restore_dir="$PROJECT_DIR/restore-test"
mkdir -p "$restore_dir"

if [[ -n "$(find "$restore_dir" -mindepth 1 -print -quit)" ]]; then
    log_message ERROR "Restore directory is not empty"
    exit 1
fi

tar -xzf "$archive" -C "$restore_dir"

log_message INFO "Restore completed: $restore_dir"
