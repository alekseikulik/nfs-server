# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Containerized NFS server for Docker and Kubernetes deployments. Alpine-based image with Helm chart for K8s deployment.

## Common Commands

```bash
# Build and run locally
make docker-build        # Build Docker image (nfs-server:latest)
make docker-run          # Run container with ./share mounted to /exports

# Testing
make test                # Run all tests (helm-test + docker-test)
make helm-test           # Lint Helm chart
make docker-test         # Security scan Dockerfile with Checkov

# Helm
make helm-build          # Package chart to dist/
make helm-docs           # Generate chart documentation

# Kind cluster
make kind-load           # Load image into Kind cluster
```

Note: Makefile uses `helm4` command (not `helm`).

## Architecture

```
Dockerfile              → Alpine + nfs-utils, runs rpcbind + rpc.nfsd + rpc.mountd
charts/nfs-server/      → Helm chart
  ├── templates/
  │   ├── statefulSet.yaml   → Single replica, privileged container, /exports volume
  │   ├── service.yaml       → Exposes ports 2049 (NFS), 20048 (mountd), 111 (rpcbind)
  │   └── serviceaccount.yaml
  └── values.yaml            → Image config, probes (exec-based), persistence settings
```

## Key Details

- Container requires `privileged: true` for NFS kernel modules
- Health checks use `rpcinfo -p localhost` to verify nfs, mountd, portmapper services
- Default export: `/exports *(rw,sync,no_subtree_check,all_squash,anonuid=65534)`
- Ports: 2049 (NFS), 111 (RPC), 20048 (mountd) - all TCP/UDP

## Release Process

Tag-based releases via GitHub Actions (`.github/workflows/release.yaml`):
- Push tag `v*` → builds/pushes Docker image and Helm chart to GHCR
