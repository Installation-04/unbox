#!/usr/bin/env bash
# Boote une image disque (qcow2/raw) ou une ISO dans QEMU avec OVMF (UEFI).
# Usage: tools/run-vm.sh [options] <image>
#   --screenshot FILE   attend --wait secondes, sauvegarde un screenshot (PPM/PNG) et quitte
#   --wait SECONDS      délai avant le screenshot (défaut 20)
#   --headless          pas de fenêtre (VNC désactivé, écran virtuel seulement)
#   --mem MB            RAM (défaut 4096)
#   --cpus N            CPU (défaut 4)
set -euo pipefail

mem=4096 cpus=4 wait_s=20 shot="" headless=0 image=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --screenshot) shot="$2"; shift 2 ;;
    --wait)       wait_s="$2"; shift 2 ;;
    --headless)   headless=1; shift ;;
    --mem)        mem="$2"; shift 2 ;;
    --cpus)       cpus="$2"; shift 2 ;;
    -h|--help)    sed -n '2,9p' "$0"; exit 0 ;;
    -*)           echo "Option inconnue: $1" >&2; exit 2 ;;
    *)            image="$1"; shift ;;
  esac
done

[[ -n "$image" ]] || { echo "Image manquante (voir --help)" >&2; exit 2; }
[[ -f "$image" ]] || { echo "Introuvable: $image" >&2; exit 2; }
command -v qemu-system-x86_64 >/dev/null || { echo "qemu-system-x86_64 absent (dnf/apt install qemu-system-x86)" >&2; exit 1; }

# Firmware UEFI : chemins courants Fedora/Debian/Arch
ovmf=""
for f in /usr/share/edk2/ovmf/OVMF_CODE.fd /usr/share/OVMF/OVMF_CODE.fd \
         /usr/share/edk2-ovmf/x64/OVMF_CODE.fd /usr/share/qemu/OVMF.fd; do
  [[ -f "$f" ]] && ovmf="$f" && break
done
[[ -n "$ovmf" ]] || { echo "OVMF introuvable (installer edk2-ovmf / ovmf)" >&2; exit 1; }

# KVM si disponible, sinon émulation (lent)
accel=(-accel tcg)
cpu=(-cpu max)
if [[ -w /dev/kvm ]]; then
  accel=(-enable-kvm); cpu=(-cpu host)
else
  echo "Avertissement: /dev/kvm indisponible, émulation logicielle (lent)." >&2
fi

case "$image" in
  *.iso)   drive=(-cdrom "$image" -boot d) ;;
  *.qcow2) drive=(-drive "file=$image,if=virtio,format=qcow2") ;;
  *)       drive=(-drive "file=$image,if=virtio,format=raw") ;;
esac

display=(-display gtk)
[[ $headless -eq 1 || -n "$shot" ]] && display=(-display none)

args=(-machine q35 "${accel[@]}" "${cpu[@]}" -m "$mem" -smp "$cpus"
      -drive "if=pflash,format=raw,readonly=on,file=$ovmf"
      "${drive[@]}" -device virtio-vga -device qemu-xhci -device usb-tablet
      -device virtio-net-pci,netdev=n0 -netdev user,id=n0
      "${display[@]}")

if [[ -z "$shot" ]]; then
  exec qemu-system-x86_64 "${args[@]}"
fi

# Mode screenshot : moniteur sur socket, capture puis arrêt
sock="$(mktemp -u)"
qemu-system-x86_64 "${args[@]}" -monitor "unix:$sock,server,nowait" &
qpid=$!
trap 'kill "$qpid" 2>/dev/null || true; rm -f "$sock"' EXIT
sleep "$wait_s"
ppm="${shot%.*}.ppm"
printf 'screendump %s\nquit\n' "$ppm" | nc -U "$sock" >/dev/null
wait "$qpid" || true
if command -v convert >/dev/null && [[ "$shot" == *.png ]]; then convert "$ppm" "$shot" && rm -f "$ppm"; fi
echo "Screenshot: $shot"
