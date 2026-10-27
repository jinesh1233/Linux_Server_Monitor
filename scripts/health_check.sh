#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="${PROJECT_DIR:-$HOME/linux-server-monitor}"
# shellcheck source=./scripts/common.sh
source "$PROJECT_DIR/scripts/common.sh"

log_message INFO "Health check started"

load_1m="$(awk '{print $1}' /proc/loadavg)"

memory_used="$(free | awk '/^Mem:/ {
    if ($2 > 0) printf "%.0f", $3 * 100 / $2
}')"

disk_used="$(df -P "$PROJECT_DIR" |
    awk 'NR==2 {gsub("%","",$5); print $5}')"

printf '\n%s\n' "--- SERVER HEALTH REPORT ---"
printf 'CPU load (1 min): %s\n' "$load_1m"
printf 'Memory usage: %s%%\n' "$memory_used"
printf 'Disk usage: %s%%\n' "$disk_used"

status=0

if awk -v a="$load_1m" -v b="$CPU_LOAD_WARN" \
    'BEGIN {exit !(a > b)}'; then
    log_message WARN "CPU load threshold exceeded: $load_1m"
    status=1
fi

if (( memory_used > MEMORY_WARN_PERCENT )); then
    log_message WARN "Memory threshold exceeded: ${memory_used}%"
    status=1
fi

if (( disk_used > DISK_WARN_PERCENT )); then
    log_message WARN "Disk threshold exceeded: ${disk_used}%"
    status=1
fi

if (( status == 0 )); then
    log_message INFO "All configured thresholds are healthy"
fi

printf '%s\n' "-----------------------------"

exit "$status"
