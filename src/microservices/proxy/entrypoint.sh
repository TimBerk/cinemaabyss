#!/bin/sh
# entrypoint.sh

set -e

echo "Generating Kong configuration from environment variables..."
envsubst < /etc/kong/kong.yml.template > /etc/kong/kong.yml

echo "Generated Kong configuration:"
cat /etc/kong/kong.yml

exec /docker-entrypoint.sh "$@"