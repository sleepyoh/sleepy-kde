#!/usr/bin/bash
# Daily build on the home server VM (192.168.1.40), pushed to the TrueNAS registry.
# Run by local-build.service, which updates the clone before this starts.
set -euo pipefail

REGISTRY_IMAGE="192.168.1.10:5000/plasma"
DATE_TAG="$REGISTRY_IMAGE:$(date +%Y%m%d)"
LATEST_TAG="$REGISTRY_IMAGE:latest"

just build # -> localhost/sleepy-kde:latest

# The registry is plain HTTP and the VM has no registries.conf.d entry for it
for TARGET in "$DATE_TAG" "$LATEST_TAG"; do
    podman tag localhost/sleepy-kde:latest "$TARGET"
    podman push --tls-verify=false "$TARGET"
done

# Remove today's build only. The base image and the dnf cache mounts stay.
podman rmi "$DATE_TAG" "$LATEST_TAG" localhost/sleepy-kde:latest
podman image prune -f
