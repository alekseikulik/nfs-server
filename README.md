# NFS-SERVER

A lightweight, containerized NFS (Network File System) server for Docker and Kubernetes deployments.

## Features

- Alpine Linux base image (minimal footprint)
- Supports standalone Docker or Kubernetes (Helm) deployment
- Health checks for NFS, mountd, and portmapper services
- Configurable via Helm values

## Quick Start

### Docker

```bash
# Build the image
make docker-build

# Run locally (mounts ./share as /exports)
make docker-run
```

### Kubernetes (Helm)

```bash
# Build and install the Helm chart
make helm-build
helm upgrade --install nfs-server ./dist/nfs-server-0.1.0.tgz
```

## Ports

| Port  | Protocol | Service     |
|-------|----------|-------------|
| 2049  | TCP/UDP  | NFS         |
| 111   | TCP/UDP  | RPC Bind    |
| 20048 | TCP/UDP  | Mount Daemon|

## Configuration

### NFS Export Settings

Default export configuration in `/etc/exports`:

```text
/exports *(rw,sync,no_subtree_check,no_auth_nlm,insecure,all_squash,anonuid=65534,anongid=65534)
```

### Helm Values

Key configuration options in `values.yaml`:

| Parameter              | Description               | Default          |
| ---------------------- | ------------------------- | ---------------- |
| `image.repository`     | Docker image name         | `nfs-server`     |
| `image.tag`            | Image tag                 | Chart appVersion |
| `service.type`         | Kubernetes service type   | `ClusterIP`      |
| `persistence.enabled`  | Enable persistent storage | `false`          |

See [charts/nfs-server/values.yaml](charts/nfs-server/values.yaml) for all options.

## Make Targets

| Command             | Description                 |
| ------------------- | --------------------------- |
| `make docker-build` | Build Docker image          |
| `make docker-run`   | Run container locally       |
| `make docker-test`  | Security scan with Checkov  |
| `make helm-build`   | Package Helm chart          |
| `make helm-test`    | Lint Helm chart             |
| `make helm-docs`    | Generate Helm documentation |
| `make test`         | Run all tests               |

## Mounting the NFS Share

From a client machine:

```bash
# Install NFS client (Debian/Ubuntu)
sudo apt-get install nfs-common

# Mount the share
sudo mount -t nfs <nfs-server-ip>:/exports /mnt/nfs
```

## License

MIT
