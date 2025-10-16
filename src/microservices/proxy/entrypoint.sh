#!/bin/sh
# entrypoint.sh

set -e
# Clean up any dangling sockets before starting
if [ -d "/usr/local/kong/sockets" ]; then
    echo "Cleaning up leftover socket files..."
    rm -f /usr/local/kong/sockets/*
fi

# Template kong.yml with environment variables
if [ -f /etc/kong/kong.yml.template ]; then
    echo "Templating kong.yml..."
    envsubst < /etc/kong/kong.yml.template > /etc/kong/kong.yml
    echo "kong.yml templated successfully"
else
    echo "Warning: kong.yml.template not found"
fi

# Execute the Kong command
exec /docker-entrypoint.sh "$@"