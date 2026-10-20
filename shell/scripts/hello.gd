extends Control

# Phase 1 : écran bidon pour valider la chaîne gamescope + Godot.
# Aucune logique système ici : tout passera par unboxd (D-Bus).

func _ready() -> void:
	print("unbox-shell: ready")
