#!/usr/bin/env bash
# Build l'image OCI UnboxOS : exporte le shell Godot puis construit image/Containerfile.
# Usage: tools/build-image.sh [tag]   (défaut: localhost/unboxos:dev)
# Variables: GODOT (binaire Godot 4, défaut: godot), ENGINE (podman|docker)
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
tag="${1:-localhost/unboxos:dev}"
godot="${GODOT:-godot}"
engine="${ENGINE:-$(command -v podman || command -v docker || true)}"

[[ -n "$engine" ]] || { echo "podman ou docker requis" >&2; exit 1; }
command -v "$godot" >/dev/null || { echo "Godot 4 introuvable (définir GODOT=/chemin/godot)" >&2; exit 1; }

mkdir -p "$root/image/build"
echo ">> Export du shell Godot"
"$godot" --headless --path "$root/shell" --export-release Linux "$root/image/build/unbox-shell"

echo ">> Build de l'image $tag"
"$engine" build -t "$tag" -f "$root/image/Containerfile" "$root/image"
echo "Image prête: $tag"
