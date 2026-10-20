# Architecture

UnboxOS tient en trois couches. Chacune peut planter ou être remplacée sans toucher aux autres.

| Couche | Rôle | Techno |
|---|---|---|
| Image | Base système immuable : Fedora minimale, gamescope, Mesa, PipeWire, NetworkManager, BlueZ. Aucun DE. | Fedora bootc (OCI/ostree) |
| Daemon `unboxd` | Seul à toucher au système : réseau, Bluetooth, power, mises à jour, profils, lancement de jeux. Expose une API D-Bus. | Rust |
| Shell `unbox-shell` | UI plein écran 100 % manette. Ne parle qu'à `unboxd`, aucune logique système. | Godot 4 |

## Session au boot (Phase 1)

```
systemd → auto-login (utilisateur unbox, tty1)
        → unbox-session.service
            → gamescope (compositeur, session unique)
                → unbox-shell (Godot)
```

`unbox-session.service` est en `Restart=always` avec `RestartSec` court : un shell qui plante revient en moins de 2 s.

## Règles
- Le shell n'appelle jamais de commande système : tout passe par D-Bus vers `unboxd`.
- Tout changement d'image doit booter en VM (`tools/run-vm.sh`).
- Chaque décision d'architecture a son ADR dans `docs/decisions/`.
