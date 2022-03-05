extends Panel

export var constants: NodePath
export var directory_selection_dialog: NodePath
export var files_list: NodePath
export var directory_selection: NodePath
export var generation_name_list: NodePath

func generate_files() -> void:
	var files_list_node = get_node(files_list) as ItemList

	# Create files
	if validate(files_list_node):
		for file in files_list_node.get("files"):
			# Check for empty path
			if len(file.path) == 0:
				PopupManager.open_popup(self, "ERROR", "File \"" + file.name + "\" has an empty path")
				return

			# Check for invalid JSON
			var result = JSON.parse(file.template)

			if result.error != OK:
				var error_message = result.error_string
				if len(error_message) == 0:
					PopupManager.open_popup(self, "ERROR", "Invalid JSON in file \"" + file.name + "\":\nFile is empty")
				else:
					PopupManager.open_popup(self, "ERROR", "Invalid JSON in file \"" + file.name + "\":\n" + error_message)
				return

			var file_path = get_node(directory_selection).get("directory") + "/" + file.path.trim_prefix("/").trim_suffix(".json").replace(" ", "") + ".json"

			# Replace constants
			var parsed_constants = []
			for constant in get_node(constants).get_children():
				var name = (constant.get_node("Name") as LineEdit).text
				var value = (constant.get_node("Value") as LineEdit).text

				# Replace with previous constants
				for parsed_constant in parsed_constants:
					value = value.replace("*" + parsed_constant[0] + "*", parsed_constant[1])

				parsed_constants.append([name, value])

			# Create actual files
			for generation_name in (get_node(generation_name_list) as TextEdit).text.split(" "):
				# Replace {input}
				var new_parsed_constants = parsed_constants.duplicate(true) # Create copy so every output has correct name
				var path = file_path.replace("*input*", generation_name)

				for i in range(0, len(new_parsed_constants)):
					new_parsed_constants[i][1] = new_parsed_constants[i][1].replace("*input*", generation_name) # Replace {input} in constant
					path = path.replace("*" + new_parsed_constants[i][0] + "*", new_parsed_constants[i][1]) # Replace path with constant

				if "*" in path:
					PopupManager.open_popup(self, "ERROR", "File \"" + file.name + "\"s path variable references invalid constant (contains * after constant replacement)")
					return

				# Check if constant still has {}
				for constant in new_parsed_constants:
					if "*" in constant[1]:
						PopupManager.open_popup(self, "ERROR", "Constant \"" + constant[0] + "\" references invalid constant (contains * after constant replacement)")
						return

				# Create string to write
				var output = file.template.replace("*input*", generation_name)

				for constant in new_parsed_constants:
					output = output.replace("*" + constant[0] + "*", constant[1])

				if "*" in output:
					PopupManager.open_popup(self, "ERROR", "File \"" + file.name + "\"s output references invalid constant (contains * after constant replacement), check your the files template variable")
					return

				var generated_file = File.new()
				var generated_directory = Directory.new()
				generated_directory.make_dir_recursive(path.get_base_dir())

				var err = generated_file.open(path, generated_file.WRITE)

				if err != OK:
					PopupManager.open_popup(self, "ERROR", "File \"" + path + "\" could not be created")
					return

				generated_file.store_string(output)
				generated_file.close()

		PopupManager.open_popup(self, "Success", "Successfully generated files")

func validate(files_list_node: ItemList) -> bool:
	# Check constants
	for i in range (0, get_node(constants).get_child_count()):
		var constant = get_node(constants).get_child(i)
		var name = constant.get_node("Name") as LineEdit
		var value = constant.get_node("Value") as LineEdit

		if len(name.text) == 0:
			PopupManager.open_popup(self, "ERROR", "Constant #" + str(i+1) + " has an empty name")
			return false

		if len(value.text) == 0:
			PopupManager.open_popup(self, "ERROR", "Constant #" + str(i+1) + " has an empty value")
			return false

	# Check for no files
	if files_list_node.get_item_count() == 0:
		PopupManager.open_popup(self, "ERROR", "No files have been created")
		return false

	# Check for no names
	if len((get_node(generation_name_list) as TextEdit).text) == 0:
		PopupManager.open_popup(self, "ERROR", "No names for generating have been entered")
		return false

	return true
