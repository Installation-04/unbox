#!/usr/bin/env bash
# Génère un disque/ISO bootable depuis l'image OCI avec bootc-image-builder.
# Usage: tools/build-iso.sh [tag] [type]   (défaut: localhost/unboxos:dev, qcow2)
# Pour l'ISO d'installation finale (type anaconda-iso), voir Phase 5.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
tag="${1:-localhost/unboxos:dev}"
type="${2:-qcow2}"
out="$root/build/output"
mkdir -p "$out"

command -v podman >/dev/null || { echo "podman requis (bootc-image-builder, rootful)" >&2; exit 1; }

sudo podman run --rm -it --privileged --pull=newer \
  --security-opt label=type:unconfined_t \
  -v "$out":/output \
  -v /var/lib/containers/storage:/var/lib/containers/storage \
  quay.io/centos-bootc/bootc-image-builder:latest \
  --type "$type" --local "$tag"

echo "Sortie dans $out"
