#!/usr/bin/env bash
# Production Docker bootstrap: same flow as docker-setup.sh, but uses
# docker-compose.production.yml and never enables agent sandbox / docker.sock.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export OPENCLAW_COMPOSE_FILE="$SCRIPT_DIR/docker-compose.production.yml"
export OPENCLAW_SKIP_SANDBOX_BOOTSTRAP=1
export OPENCLAW_IMAGE="${OPENCLAW_IMAGE:-ghcr.io/openclaw/openclaw:latest}"

exec "$SCRIPT_DIR/docker-setup.sh"
