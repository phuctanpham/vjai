#!/bin/bash

set -euo pipefail

BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
POWERSYNC_DIR="$BASE_DIR/powersync"
PROXY_DIR="$BASE_DIR/nginx-proxy"
NETWORK_NAME="powersync_network"
COMPOSE="docker-compose"

if ! command -v "$COMPOSE" >/dev/null 2>&1; then
    echo "ERROR: docker-compose is required." >&2
    exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: docker is required." >&2
    exit 1
fi

for directory in "$POWERSYNC_DIR" "$PROXY_DIR"; do
    if [ ! -f "$directory/docker-compose.yaml" ]; then
        echo "ERROR: missing compose file in $directory." >&2
        exit 1
    fi
done

for certificate in "$PROXY_DIR/certs/fullchain.pem" "$PROXY_DIR/certs/privkey.pem"; do
    if [ ! -f "$certificate" ]; then
        echo "ERROR: missing TLS certificate file: $certificate" >&2
        echo "Install a certificate trusted for sync.phamtanph.uk before starting." >&2
        exit 1
    fi
done

chmod 600 "$PROXY_DIR/certs/privkey.pem" \
    "$POWERSYNC_DIR/config/service.yaml" \
    "$POWERSYNC_DIR/config/service.yaml".bak.* 2>/dev/null || true
chmod 644 "$PROXY_DIR/certs/fullchain.pem" \
    "$POWERSYNC_DIR/config/sync-config.yaml"

(
    cd "$POWERSYNC_DIR"
    "$COMPOSE" config --quiet
)
(
    cd "$PROXY_DIR"
    "$COMPOSE" config --quiet
)

if ! docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
    echo "Creating Docker network: $NETWORK_NAME"
    docker network create "$NETWORK_NAME" >/dev/null
fi

echo "Starting PowerSync..."
(
    cd "$POWERSYNC_DIR"
    "$COMPOSE" up -d
)

echo "Starting Nginx..."
(
    cd "$PROXY_DIR"
    "$COMPOSE" up -d
)

echo "Waiting for containers..."
for container in powersync-server nginx-proxy; do
    for _ in {1..30}; do
        [ "$(docker inspect --format '{{.State.Running}}' "$container" 2>/dev/null || true)" = "true" ] && break
        sleep 1
    done
    if [ "$(docker inspect --format '{{.State.Running}}' "$container" 2>/dev/null || true)" != "true" ]; then
        echo "ERROR: $container did not stay running." >&2
        docker logs --tail 50 "$container" >&2 || true
        exit 1
    fi
done

if docker inspect cloudflare-tunnel >/dev/null 2>&1; then
    docker rm -f cloudflare-tunnel >/dev/null
fi

docker exec nginx-proxy nginx -t
docker ps --filter name='^/powersync-server$' --filter name='^/nginx-proxy$'
