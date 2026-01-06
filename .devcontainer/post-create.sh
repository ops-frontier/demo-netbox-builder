#!/bin/bash
set -e

echo "=== Starting post-create setup ==="

# 1. Install Ansible
echo "Installing Ansible..."
pip install --user ansible ansible-lint

# 2. Generate SSH key (ed25519 format) in .ssh directory
echo "Generating SSH key..."
mkdir -p /workspaces/demo-netbox-builder/.ssh
if [ ! -f /workspaces/demo-netbox-builder/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -f /workspaces/demo-netbox-builder/.ssh/id_ed25519 -N "" -C "netbox-builder"
    echo "SSH key generated at /workspaces/demo-netbox-builder/.ssh/id_ed25519"
else
    echo "SSH key already exists"
fi

# 3. Start Squid proxy container for public repository access
echo "Starting Squid proxy container..."
docker pull ubuntu/squid:latest
docker rm -f squid-proxy 2>/dev/null || true
docker run -d \
    --name squid-proxy \
    --restart unless-stopped \
    -p 127.0.0.1:3128:3128 \
    ubuntu/squid:latest

# Wait for Squid to be ready
echo "Waiting for Squid proxy to be ready..."
sleep 5
for i in {1..30}; do
    if curl -s -o /dev/null -x http://localhost:3128 http://www.google.com; then
        echo "Squid proxy is ready"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "Warning: Squid proxy may not be ready"
    fi
    sleep 1
done

# 4. Set up Terraform environment variables
# CodeSpaces does not allow lowercase in environment variable names,
# so we need to copy them to TF_VAR_ prefixed variables
echo "Setting up Terraform environment variables..."

# Create .env file for Terraform variables
cat > /workspaces/demo-netbox-builder/.env << 'EOF'
# Sakura Cloud credentials
# Set these in GitHub Codespaces Secrets with uppercase names:
# SAKURACLOUD_ACCESS_TOKEN
# SAKURACLOUD_ACCESS_TOKEN_SECRET
# SAKURACLOUD_ZONE (e.g., is1a, is1b, tk1a, tk1v)
# INTERNAL_SWITCH_NAME (name of the internal switch)
# INTERNAL_NIC_IP (IP address in CIDR format, e.g., 192.168.1.10/24)

export TF_VAR_sakuracloud_access_token="${SAKURACLOUD_ACCESS_TOKEN}"
export TF_VAR_sakuracloud_access_token_secret="${SAKURACLOUD_ACCESS_TOKEN_SECRET}"
export TF_VAR_sakuracloud_zone="${SAKURACLOUD_ZONE:-is1a}"
export TF_VAR_internal_switch_name="${INTERNAL_SWITCH_NAME}"
export TF_VAR_internal_nic_ip="${INTERNAL_NIC_IP}"
EOF

# Source the .env file to make variables available
source /workspaces/demo-netbox-builder/.env

# Add to bashrc for future shells
if ! grep -q "source /workspaces/demo-netbox-builder/.env" ~/.bashrc; then
    echo "source /workspaces/demo-netbox-builder/.env" >> ~/.bashrc
fi

# 5. Install Claude Code CLI
echo "Installing Claude Code CLI..."
npm install -g @anthropic-ai/claude-code || true

echo "=== Post-create setup completed ==="
echo ""
echo "Next steps:"
echo "1. Set the following secrets in GitHub Codespaces:"
echo "   - SAKURACLOUD_ACCESS_TOKEN"
echo "   - SAKURACLOUD_ACCESS_TOKEN_SECRET"
echo "   - SAKURACLOUD_ZONE (e.g., is1a)"
echo "   - INTERNAL_SWITCH_NAME"
echo "   - INTERNAL_NIC_IP (e.g., 192.168.1.10/24)"
echo "2. Reload the terminal to apply environment variables"
echo "3. Run 'terraform init' in the terraform directory"
echo "4. Run 'terraform apply' to provision the infrastructure"
