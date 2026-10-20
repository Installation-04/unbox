# ADR 001 : base technique

Statut : accepté

## Décision
- Base OS : Fedora bootc (image OCI, ostree, mises à jour A/B).
- Compositeur : gamescope, session unique.
- Shell : Godot 4 (GDScript).
- Daemon : Rust, API D-Bus.
- Test : QEMU/KVM + OVMF.

## Alternatives écartées
NixOS et Buildroot/Yocto (courbe d'apprentissage ou maintenance plus lourdes), cage (moins adapté au jeu), Qt/QML (plan B si Godot et gamescope ne s'entendent pas, à vérifier dès la Phase 1).

## Conséquences
Image immuable avec rollback. Risque connu : intégration Godot/gamescope, à prototyper tôt.
