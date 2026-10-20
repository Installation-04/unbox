# UnboxOS

OS de console open source. Voir docs/architecture.md.

## Règles
- Jamais d'environnement desktop dans l'image.
- Le shell (Godot) ne touche jamais au système : tout passe par unboxd (D-Bus).
- Tout changement d'image doit booter dans la VM (tools/run-vm.sh) avant d'être jugé terminé.
- Toute décision d'architecture = un ADR dans docs/decisions/.
- Navigation 100 % manette : chaque écran doit être utilisable sans souris/clavier.
- Commits petits, un sujet par commit.

## Commandes
- tools/build-image.sh : build l'image OCI
- tools/run-vm.sh : boot l'image dans QEMU
- tools/build-iso.sh : génère l'ISO d'installation
- cargo test -p unboxd : tests du daemon

## Définition de "terminé"
Build OK + boot VM OK + screenshot de validation + tests qui passent.
