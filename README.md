# Unbox / UnboxOS

**Unbox. Unleash.** — *Any PC. Your console.*

Une image installable par USB qui transforme n'importe quel PC en console :
boot direct dans une UI 100 % manette, jamais de desktop, jamais de clavier requis.

> État : Phase 0-1 (fondations et boot console). Rien d'utilisable pour l'instant.

## Principes
1. Zéro desktop, zéro terminal exposé.
2. Tout se fait à la manette.
3. Le système ne peut pas se briser (image immuable, mises à jour A/B).
4. Le shell qui plante redémarre seul en moins de 2 s.
5. Chaque étape est testable en VM avant le vrai matériel.

## Démarrer
```
tools/build-image.sh      # image OCI
tools/run-vm.sh <image>   # boot dans QEMU
```
Architecture : [docs/architecture.md](docs/architecture.md).

## Licence
Provisoire : MIT (voir [ADR 002](docs/decisions/002-licence.md)).
