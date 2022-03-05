class_name PopupManager

static func open_popup(node: Node, title: String, text: String) -> void:
	var popup = AcceptDialog.new()
	popup.window_title = title
	popup.dialog_text = text
	popup.set_script(load("res://scripts/self_removing_dialog.gd"))

	node.get_tree().root.add_child(popup)
	popup.popup_centered()
