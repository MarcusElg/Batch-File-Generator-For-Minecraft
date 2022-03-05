extends HBoxContainer

export var constants:NodePath
export var files:NodePath
export var files_generator:NodePath

func save_template() -> void:
	# Open file selection dialog
	var file_selection = create_file_dialog()

	get_tree().root.add_child(file_selection)
	file_selection.popup_centered()
	file_selection.connect("file_selected", self, "create_template_file") # Wait until selection

func load_template() -> void:
	# Open file selection dialog
	var file_selection = create_file_dialog()
	file_selection.mode = FileDialog.MODE_OPEN_FILE

	get_tree().root.add_child(file_selection)
	file_selection.popup_centered()
	file_selection.connect("file_selected", self, "read_template_file") # Wait until selection

func create_file_dialog() -> FileDialog:
	var file_selection = FileDialog.new()
	file_selection.set_size(Vector2(500, 500))
	file_selection.access = FileDialog.ACCESS_FILESYSTEM
	file_selection.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	file_selection.filters = ["*.json"]
	file_selection.set_script(load("res://scripts/self_removing_dialog.gd"))

	return file_selection

func create_template_file(path: String) -> void:
	var output_constants = []
	var output_files = []

	# Constants
	for constant in get_node(constants).get_children():
		var name = (constant.get_node("Name") as LineEdit).text
		var value = (constant.get_node("Value") as LineEdit).text
		output_constants.append({"Name": name, "Value": value})

	# Files
	for file in get_node(files).get("files"):
		output_files.append({"Name": file.name, "Path": file.path, "Template": file.template})

	var output = to_json({"Constants": output_constants, "Files": output_files})

	# Create file
	path = path.trim_suffix(".json") + ".json" # Don't have json twice
	var generated_file = File.new()
	var err = generated_file.open(path, generated_file.WRITE)

	if err != OK:
		PopupManager.open_popup(self, "ERROR", "File \"" + path + "\" could not be created")
		return

	generated_file.store_string(output)
	generated_file.close()

func read_template_file(path: String) -> void:
	var generated_file = File.new()
	var err = generated_file.open(path, generated_file.READ)

	if err != OK:
		PopupManager.open_popup(self, "ERROR", "File \"" + path + "\" could not be opened")
		return

	var json = JSON.parse(generated_file.get_as_text())
	if json.error != OK:
		PopupManager.open_popup(self, "ERROR", "File \"" + path + "\" contains invalid JSON")
		return

	var saved_data = json.result

	# Remove existing constants
	while get_node(constants).get_child_count() > 0:
		get_node(constants).remove_child(get_node(constants).get_child(get_node(constants).get_child_count() - 1))

	# Remove existing files
	get_node(files).remove_all_files()

	# Read constants
	if "Constants" in saved_data:
		for input in saved_data["Constants"]:
			if len(input) != 2 or not "Name" in input or not "Value" in input:
				PopupManager.open_popup(self, "WARNING", "File \"" + path + "\" has a malformatted constant, skipping affected constant")
				continue

			# Add constant
			var constant = get_node(constants).add_contant_input()
			(constant.get_node("Name") as LineEdit).text = input["Name"]
			(constant.get_node("Value") as LineEdit).text = input["Value"]

	# Read files
	if "Files" in saved_data:
		for input in saved_data["Files"]:
			if len(input) != 3 or not "Name" in input or not "Path" in input or not "Template" in input:
				PopupManager.open_popup(self, "WARNING", "File \"" + path + "\" has a malformatted file, skipping affected file")
				continue

			# Add file
			get_node(files).add_new_named_file(input["Name"], input["Path"], input["Template"])

	# Prevent empty file list
	if len(get_node(files).files) == 0:
		get_node(files).add_new_file()

	generated_file.close()
