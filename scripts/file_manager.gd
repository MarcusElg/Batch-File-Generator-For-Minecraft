extends ItemList

export var current_file: NodePath

var files = []

const new_file_name = "New File"

func _enter_tree() -> void:
	add_new_file() # Default file

func add_new_file() -> void:
	add_new_named_file(new_file_name, "*input*_block", "{\n	\n}")

func add_new_named_file(name:String, path:String, template: String) -> void:
	if get_item_count() >= 50:
		return

	add_item(new_file_name)
	var file = GeneratedFile.new()
	file.name = name
	file.path = path
	file.template = template
	files.append(file)

	var file_id = get_item_count() - 1
	select(file_id) # Select in item list
	select_file(file_id) # Select in current file editor
	set_item_text(file_id, name)

func remove_all_files() -> void:
	files = []
	clear()

func remove_current_file() -> void:
	if len(get_selected_items()) > 0:
		var id = get_selected_items()[0]
		remove_item(id)
		files.remove(id)
		clear_file_properties()

func select_file(id: int) -> void:
	if len(get_selected_items()) > 0:
		# Select
		(get_file_input("CurrentFileName") as LineEdit).editable = true
		(get_file_input("CurrentFilePath") as LineEdit).editable = true
		(get_file_input("CurrentFileTemplate") as TextEdit).readonly = false

		# Update text
		update_file_properties(id)

func clear_file_properties() -> void:
	clear_line_edit("CurrentFileName")
	clear_line_edit("CurrentFilePath")
	clear_text_edit("CurrentFileTemplate")

func update_file_properties(id: int) -> void:
	(get_file_input("CurrentFileName") as LineEdit).text = files[id].name
	(get_file_input("CurrentFilePath") as LineEdit).text = files[id].path
	(get_file_input("CurrentFileTemplate") as TextEdit).text = files[id].template

func clear_line_edit(node_name: String) -> void:
	# Clear text and disable
	var node = get_file_input(node_name) as LineEdit
	node.editable = false
	node.text = ""

func clear_text_edit(node_name: String) -> void:
	# Clear text and disable
	var node = get_file_input(node_name) as TextEdit
	node.readonly = true
	node.text = ""

func get_file_input(name: String) -> Node:
	return get_node(current_file).get_node(NodePath(name))

# Edit file properties
func edit_file_name(text: String) -> void:
	if get_item_count() > 0:
		files[get_selected_items()[0]].name = text
		set_item_text(get_selected_items()[0], text)

func validate_file_name() -> void:
	# Prevent empty names
	if get_item_count() > 0 and len(get_item_text(get_selected_items()[0])) == 0:
		edit_file_name(new_file_name)
		(get_file_input("CurrentFileName") as LineEdit).text = new_file_name # Update input field

func edit_file_path(text: String) -> void:
	if get_item_count() > 0:
		files[get_selected_items()[0]].path = text

func edit_file_template() -> void:
	if get_item_count() > 0:
		files[get_selected_items()[0]].template = (get_file_input("CurrentFileTemplate") as TextEdit).text
