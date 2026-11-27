#!/usr/bin/bash
# Daily build on the home server VM (192.168.1.40), pushed to the TrueNAS registry.
# Run by local-build.service, which updates the clone before this starts.
set -euo pipefail

TARGET="192.168.1.10:5000/plasma:$(date +%Y%m%d)"

just build # -> localhost/sleepy-kde:latest

podman tag localhost/sleepy-kde:latest "$TARGET"
# The registry is plain HTTP and the VM has no registries.conf.d entry for it
podman push --tls-verify=false "$TARGET"

# Remove today's build only. The base image and the dnf cache mounts stay.
podman rmi "$TARGET" localhost/sleepy-kde:latest
podman image prune -f
