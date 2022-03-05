extends Popup


func _enter_tree() -> void:
	connect("popup_hide", self, "queue_free")
