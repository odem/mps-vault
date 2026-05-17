#!/bin/bash
# Health check for Bitwarden CLI service
# Ensure the Bitwarden CLI wrapper is in PATH (installed as /usr/local/bin/bw)
if ! command -v bw >/dev/null 2>&1; then
    echo "Bitwarden CLI not found"
    exit 1
fi

# Get status output (JSON) from bw status
status_output=$(bw status 2>/dev/null)
if [ -z "$status_output" ]; then
    echo "Failed to get status output"
    exit 1
fi

# Extract the "status" field (unlocked, locked, unauthenticated)
vault_status=$(echo "$status_output" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
case "$vault_status" in
    "unlocked"|"locked"|"unauthenticated")
        echo "Healthy: Bitwarden service is running (status: $vault_status)"
        exit 0
        ;;
    *)
        echo "Unhealthy: Unknown status - $vault_status"
        exit 1
        ;;
esac
