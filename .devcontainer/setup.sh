#!/bin/bash

set -e

SOCK_PATH="/var/run/docker.sock"
USERNAME="vscode"

if [ -S "$SOCK_PATH" ]; then
    DOCKER_GID=$(stat -c '%g' "$SOCK_PATH")

    if [ "$DOCKER_GID" -eq 0 ]; then
        echo "⚠️  Docker socket is owned by root (GID 0); cannot safely allow non-root access."
        echo "    You can use 'sudo docker' inside the container."
    else
        # Create group if it doesn't exist
        if ! getent group "$DOCKER_GID" >/dev/null; then
            groupadd -g "$DOCKER_GID" docker-host
        fi

        usermod -aG "$DOCKER_GID" "$USERNAME"
        echo "✅ Added $USERNAME to group with GID $DOCKER_GID for Docker access."
    fi
else
    echo "❌ Docker socket not found at $SOCK_PATH."
fi
