# Linux Server Monitoring & Auto-Recovery

A Linux server monitoring and automation project built using Bash scripting and systemd on Ubuntu Linux. This project monitors server health, detects service failures, automatically recovers stopped services, and performs scheduled backups.

## Project Overview

The main objective of this project is to automate essential Linux server administration tasks.

It provides:

- Automated CPU, memory, and disk monitoring.
- Centralized logging with timestamps.
- Automatic systemd service recovery.
- Compressed backup and restore operations.
- Scheduled execution using systemd timers.
- Automated Bash script validation using GitHub Actions.

## Tech Stack

| Technology | Purpose |
|---|---|
| AWS EC2 | Cloud infrastructure |
| Ubuntu Linux | Operating system |
| Bash Scripting | Automation |
| systemd | Service and timer management |
| Git & GitHub | Version control |
| ShellCheck | Shell script analysis |
| GitHub Actions | CI automation |

## Project Features

### 1. Linux Server Health Monitoring

Monitors essential server resources:

- CPU load average (1 minute)
- Memory utilization
- Disk utilization

Warning thresholds are configurable through `config/monitor.conf`.

### 2. Centralized Logging

A reusable logging function records monitoring and recovery events.

Supported log levels:

- INFO
- WARN
- ERROR

All events are recorded in:

`logs/monitor.log`

### 3. Service Auto-Recovery

Monitors a dedicated systemd service:

`linux-monitor-demo.service`

When the service becomes inactive:

1. Detects the service failure.
2. Records the failure in the log file.
3. Attempts to restart the service.
4. Verifies the service status.
5. Records recovery success or failure.

The recovery script uses restricted sudo permissions to restart only the dedicated demo service.

### 4. Backup and Restore

Provides backup and restoration functionality:

- Creates timestamped compressed `.tar.gz` archives.
- Verifies backup archive integrity.
- Restores files into a separate directory.
- Compares restored files with original files.

### 5. systemd Timer Automation

Automates project scripts without requiring manual execution.

| systemd Timer | Schedule | Function |
|---|---|---|
| `health-monitor.timer` | Every 5 minutes | Server health monitoring |
| `service-recovery.timer` | Every 2 minutes | Service failure detection and recovery |
| `backup.timer` | Daily | Automated backup |

The systemd unit files are configured on the Ubuntu EC2 instance under `/etc/systemd/system/`.

### 6. GitHub Actions CI Pipeline

A GitHub Actions workflow performs automatic shell script validation when code is pushed to the `main` branch or a pull request targets `main`.

The pipeline includes:

- Repository checkout
- ShellCheck installation
- Bash syntax validation
- ShellCheck analysis

Workflow configuration:

`.github/workflows/shellcheck.yml`

## Repository Structure

```text
Linux_Server_Monitor/
│
├── .github/
│   └── workflows/
│       └── shellcheck.yml
│
├── backups/
│
├── config/
│   └── monitor.conf
│
├── sample-data/
│
├── scripts/
│   ├── common.sh
│   ├── health_check.sh
│   ├── service_monitor.sh
│   ├── backup.sh
│   └── restore.sh
│
├── .gitignore
├── .shellcheckrc
└── README.md
```

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/jinesh1233/Linux_Server_Monitor.git

cd Linux_Server_Monitor
```

### 2. Run Health Monitoring

```bash
bash scripts/health_check.sh
```

### 3. Run Service Monitoring

```bash
bash scripts/service_monitor.sh
```

### 4. Create a Backup

```bash
bash scripts/backup.sh
```

### 5. Restore a Backup

```bash
archive="$(find backups -maxdepth 1 -type f -name 'backup_*.tar.gz' | sort | tail -n 1)"

bash scripts/restore.sh "$archive"
```

## systemd Management

### Check All Timers

```bash
systemctl list-timers --all
```

### Check Individual Timers

```bash
systemctl status health-monitor.timer

systemctl status service-recovery.timer

systemctl status backup.timer
```

### Check Monitoring Logs

```bash
tail -f ~/linux-server-monitor/logs/monitor.log
```

### Check Recovery Logs

```bash
journalctl -u service-recovery.service -n 20 --no-pager
```

## Testing and Validation

### Bash Syntax Validation

```bash
for file in scripts/*.sh; do
    bash -n "$file" || exit 1
done

echo "All Bash scripts passed syntax validation"
```

### ShellCheck

```bash
shellcheck scripts/*.sh
```

### Service Auto-Recovery Test

Stop the demo service:

```bash
sudo systemctl stop linux-monitor-demo.service
```

Wait for the recovery timer to execute.

Verify the service:

```bash
systemctl is-active linux-monitor-demo.service
```

Expected output:

```text
active
```

### Backup Verification

List backup archives:

```bash
ls -lh backups/
```

Verify archive contents:

```bash
tar -tzf backups/backup_FILENAME.tar.gz
```

## Learning Outcomes

Through this project, I gained practical experience in:

- Linux server administration
- Bash scripting and automation
- CPU, memory, and disk monitoring
- systemd services and timers
- Automated service recovery
- Backup and restore operations
- Git and GitHub
- GitHub Actions CI workflows
- ShellCheck and Bash validation

## Project Completion

- [x] Day 1: Ubuntu server setup and health monitoring
- [x] Day 1: Centralized logging and configuration
- [x] Day 2: Service auto-recovery
- [x] Day 2: Backup and restore implementation
- [x] Day 3: systemd timer automation
- [x] Day 3: GitHub Actions workflow implementation
- [x] Day 3: Automated recovery testing

---

**Project:** Linux Server Monitoring & Auto-Recovery

**GitHub Repository:** [Linux_Server_Monitor](https://github.com/jinesh1233/Linux_Server_Monitor)
