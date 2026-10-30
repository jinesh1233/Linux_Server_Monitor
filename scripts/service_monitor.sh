#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="${PROJECT_DIR:-$HOME/linux-server-monitor}"
# shellcheck source=./scripts/common.sh
source "$PROJECT_DIR/scripts/common.sh"

service="${MONITORED_SERVICE:-}"

if [[ "$service" != "linux-monitor-demo.service" ]]; then
    log_message ERROR "Only the dedicated demo service is allowed"
    exit 2
fi

if systemctl is-active --quiet "$service"; then
    log_message INFO "Service is healthy: $service"
    exit 0
fi

log_message WARN "Service is down: $service"

for ((attempt=1; attempt<=MAX_RESTART_ATTEMPTS; attempt++)); do
    log_message INFO "Restart attempt $attempt"

    if sudo -n /usr/bin/systemctl restart "$service"; then
        sleep 2

        if systemctl is-active --quiet "$service"; then
            log_message INFO "Recovery successful: $service"
            exit 0
        fi
    else
        log_message ERROR "Restart command failed"
    fi

    if (( attempt < MAX_RESTART_ATTEMPTS )); then
        sleep "$RESTART_COOLDOWN_SECONDS"
    fi
done

log_message ERROR "Recovery failed after maximum attempts"
exit 1
