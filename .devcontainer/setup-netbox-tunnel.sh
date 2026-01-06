#!/bin/bash
# Setup SSH tunnel to NetBox server for DevContainer proxy access

set -e

NETBOX_IP="${NETBOX_SERVER_IP:-192.168.99.11}"
SSH_KEY="/workspaces/demo-netbox-builder/.ssh/id_ed25519"
LOCAL_PORT="8888"

echo "Setting up SSH tunnel to NetBox server..."

# Check if SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    echo "Error: SSH key not found at $SSH_KEY"
    exit 1
fi

# Kill any existing SSH tunnel on the port
pkill -f "ssh.*${LOCAL_PORT}:localhost:80.*${NETBOX_IP}" 2>/dev/null || true
sleep 1

# Set up SSH tunnel in the background, listening on all interfaces (0.0.0.0)
# This is required for VS Code port proxy to work correctly
ssh -f -N \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o ServerAliveInterval=60 \
    -o ServerAliveCountMax=3 \
    -o GatewayPorts=yes \
    -L 0.0.0.0:${LOCAL_PORT}:localhost:80 \
    -i "$SSH_KEY" \
    ubuntu@"$NETBOX_IP"

echo "✅ SSH tunnel established: 0.0.0.0:${LOCAL_PORT} -> ${NETBOX_IP}:80"
echo ""
echo "Access NetBox at:"
echo "  - DevContainer: http://localhost:${LOCAL_PORT}"
echo "  - Via Proxy: https://ws.demo.ops-frontier.dev/proxy/${LOCAL_PORT}/"
echo ""
echo "Login credentials:"
echo "  - Username: admin"
echo "  - Password: admin"
