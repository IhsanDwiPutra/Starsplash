extends Node
## Pindah scene. Transisi (fade) ditambahkan di fase berikutnya.


func go_to(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
