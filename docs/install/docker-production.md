---

## summary: "Run OpenClaw gateway in Docker for production without agent sandbox mounts"

read_when:

- You want a containerized gateway on a server with the production Compose layout
- You prefer a pulled GHCR image over local builds
  title: "Docker production"

# Docker production

This path uses **`docker-compose.production.yml`** and **`docker-setup.production.sh`**: prebuilt image by default, log rotation on the gateway service, and **no** Docker socket mount or agent sandbox bootstrap (see [Sandboxing](/gateway/sandboxing) for what that means elsewhere).

For the general Docker install options (sandbox opt-in, extra mounts, dev image builds), see [Docker](/install/docker).

## Requirements

- Docker Engine (or Docker Desktop) and Docker Compose v2
- Network and disk comparable to a small VPS if that is where you run it
- On a public host, read [Network exposure](/gateway/security#04-network-exposure-bind--port--firewall) and firewall Docker correctly

## What you get

| Item          | Production layout                                                   |
| ------------- | ------------------------------------------------------------------- |
| Default image | `ghcr.io/openclaw/openclaw:latest` (override with `OPENCLAW_IMAGE`) |
| Agent sandbox | Not enabled by setup (`OPENCLAW_SKIP_SANDBOX_BOOTSTRAP=1`)          |
| `docker.sock` | Not mounted                                                         |
| Reverse proxy | Not included; publish ports or place a proxy in front yourself      |
| Logs          | `json-file` with rotation on gateway and CLI services               |

Data still lives on the host via bind mounts:

- `OPENCLAW_CONFIG_DIR` → `/home/node/.openclaw` in the container
- `OPENCLAW_WORKSPACE_DIR` → `/home/node/.openclaw/workspace`

Defaults match **`docker-setup.sh`**: config under `~/.openclaw` and workspace under `~/.openclaw/workspace` when those variables are unset.

## Quick start

From the repository root (the scripts expect the repo layout):

```bash
./docker-setup.production.sh
```

The wrapper:

1. Sets `OPENCLAW_COMPOSE_FILE` to `docker-compose.production.yml`
2. Sets `OPENCLAW_SKIP_SANDBOX_BOOTSTRAP=1`
3. Defaults `OPENCLAW_IMAGE` to `ghcr.io/openclaw/openclaw:latest` if unset
4. Runs **`docker-setup.sh`** (build or pull, permissions fix, onboarding, gateway `up -d`)

After onboarding, open the Control UI (for example `http://127.0.0.1:18789/` from the host, or via SSH tunnel) and use the gateway token from your env file (default: `.env` in the repo directory, or `OPENCLAW_ENV_FILE` if set).

## Pin a release image

`latest` tracks the latest stable tag on GHCR. To pin:

```bash
export OPENCLAW_IMAGE="ghcr.io/openclaw/openclaw:2026.2.26"
./docker-setup.production.sh
```

Tags are listed in [Docker](/install/docker#use-a-remote-image-skip-local-build).

## Environment variables

All variables supported by **`docker-setup.sh`** still apply. For production you commonly set:

- `OPENCLAW_IMAGE` — image reference (default `ghcr.io/openclaw/openclaw:latest` when using the production wrapper)
- `OPENCLAW_CONFIG_DIR` / `OPENCLAW_WORKSPACE_DIR` — host paths for persistence
- `OPENCLAW_GATEWAY_PORT` / `OPENCLAW_BRIDGE_PORT` — host port mapping (defaults `18789` / `18790`)
- `OPENCLAW_GATEWAY_BIND` — `lan` or `loopback` for `gateway.bind` (default `lan`); use values [documented for gateway bind](/install/docker), not raw `0.0.0.0` aliases
- `OPENCLAW_GATEWAY_TOKEN` — optional; if unset, the script reuses config or `.env` or generates one
- `OPENCLAW_ENV_FILE` — where to read/write persisted compose-related env (default `.env` next to the scripts)
- `OPENCLAW_TZ` — IANA timezone for the containers

Optional extras such as `OPENCLAW_EXTRA_MOUNTS` and `OPENCLAW_HOME_VOLUME` behave like the main Docker guide; rerun setup after changing generated compose fragments.

## Compose-only commands

When using the files this repo provides, pass the same compose file the setup used:

```bash
docker compose -f docker-compose.production.yml logs -f openclaw-gateway
docker compose -f docker-compose.production.yml run --rm openclaw-cli gateway probe
```

If **`docker-setup.sh`** merged **`docker-compose.extra.yml`** (extra mounts or named home volume), include those `-f` flags in the same order the script printed in its hint.

## TLS and hostnames

`docker-compose.production.yml` publishes HTTP ports to the host. Terminate TLS on a reverse proxy (Traefik, Caddy, nginx, etc.) or connect over a private network. Configure `gateway.controlUi.allowedOrigins` if the Control UI is served from a different origin than loopback (the setup script may set allowlists when `OPENCLAW_GATEWAY_BIND` is not `loopback`; see [Docker](/install/docker)).

## Related

- [Docker](/install/docker) — full Docker options, CI `-T` usage, sandbox opt-in
- [Security](/gateway/security) — exposure and trust boundaries
- [Updating](/install/updating) — version policy and release channels
