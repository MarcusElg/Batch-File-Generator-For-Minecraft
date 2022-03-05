extends VBoxContainer

var constant_node = load("res://constant_input.tscn")
export var constants_help_popup: NodePath

func add_contant_input():
	if get_child_count() < 10:
		var instance = constant_node.instance()
		add_child(instance)
		return instance

func open_constants_help_popup() -> void:
	(get_node(constants_help_popup) as AcceptDialog).popup_centered()
