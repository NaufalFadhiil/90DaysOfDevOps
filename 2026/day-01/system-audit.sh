#!/usr/bin/env bash
# ==============================================================================
# Script Name : system-audit.sh
# Purpose     : Baseline System Audit for DevOps Host Environment
# Author      : Naufal Fadhiil
# ==============================================================================

set -euo pipefail

echo "=================================================="
echo "        DEVOPS LINUX BASELINE SYSTEM AUDIT        "
echo "=================================================="
echo "Timestamp    : $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "Hostname     : $(hostname)"
echo "Current User : $(whoami)"
echo "OS / Distro  : $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"')"
echo "Kernel       : $(uname -r)"
echo "Uptime       : $(uptime -p)"
echo "--------------------------------------------------"
echo "[*] CPU Information:"
lscpu | grep -E 'Model name|Socket|Thread|NUMA|CPU\(s\):' | sed 's/^[ \t]*/   /'
echo "--------------------------------------------------"
echo "[*] Memory (RAM) Usage:"
free -h | awk 'NR<=2 {print "   " $0}'
echo "--------------------------------------------------"
echo "[*] Root Storage Usage:"
df -h / | awk 'NR<=2 {print "   " $0}'
echo "--------------------------------------------------"
echo "[*] Network Interfaces & IP:"
ip -br addr show | awk '{print "   " $1, "(" $2 ") :", $3}'
echo "=================================================="
echo "[+] Audit completed successfully."
