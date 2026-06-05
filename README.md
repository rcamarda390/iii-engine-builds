# iii-engine v0.11.2 Docker Build

Automated GitHub Actions build for **iii-engine v0.11.2** required by [agentmemory](https://github.com/rohitg00/agentmemory).

## Quick Start

1. Push to main branch (or manually trigger):
   ```bash
   git push origin main
   ```

2. Go to **Actions** → **Build & Push iii-engine v0.11.2** → **Run workflow**

3. Download image from artifacts when build completes

4. Load and push to your private artifactory:
   ```bash
   docker load < iii-engine-0.11.2.tar
   docker tag iiidev/iii:0.11.2 artifactory.DOMAIN/docker-local/iiidev/iii:0.11.2
   docker push artifactory.DOMAIN/docker-local/iiidev/iii:0.11.2
   ```

## Why This Repo?

- **iii-engine v0.11.2 is not on Docker Hub** (only v0.8.3 and older are published)
- **agentmemory strictly requires v0.11.2** (v0.11.6+ introduced breaking changes)
- This repo automates building v0.11.2 from GitHub source

## Build Details

- **Build time:** 15-25 minutes (first run), 2-5 minutes (cached)
- **Image size:** ~200-400 MB compressed
- **Base image:** `distroless/cc-debian12:nonroot` (production-safe)
- **Ports:** 3111 (REST), 49134 (WebSocket), 3112 (Streams), 9464 (Metrics)

## What's Included

```
iii-engine v0.11.2 binary built from source
├── iii-config.yaml (default config)
├── Health check (--version endpoint)
└── Non-root execution (security)
```

## Files

- **Dockerfile** - Multi-stage build: Rust → distroless
- **.github/workflows/build-iii-0.11.2.yml** - GitHub Actions CI
- **README.md** - This file

## For Airgapped Deployments

If you're in an airgapped environment:

1. Build here (internet-connected GitHub)
2. Download `.tar` artifact
3. Transfer to airgapped host
4. Load: `docker load < iii-engine-0.11.2.tar`
5. Push to private artifactory
6. Use in agentmemory Dockerfile

See `III-ENGINE-GITHUB-BUILD-SETUP.md` for full setup guide.

## Links

- **iii-engine:** https://github.com/iii-hq/iii
- **v0.11.2 release:** https://github.com/iii-hq/iii/releases/tag/iii/v0.11.2
- **agentmemory:** https://github.com/rohitg00/agentmemory
- **Why v0.11.2?** agentmemory README → "agentmemory currently pins iii-engine to v0.11.2"
