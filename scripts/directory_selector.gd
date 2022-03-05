extends HBoxContainer

var directory

func _enter_tree() -> void:
	directory = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	validate_directory()

func open_directory_selection() -> void:
	$FileDialog.current_dir = directory
	$FileDialog.popup_centered()

func select_directory(path: String) -> void:
	if len(path) == 0:
		validate_directory()
	else:
		$DirectoryPath.text = path
		directory = path

func validate_directory(_text: String = "") -> void:
	# Set to documents if empty or invalid
	if len($DirectoryPath.text) == 0 or not Directory.new().dir_exists($DirectoryPath.text):
		$DirectoryPath.text = directory

	directory = $DirectoryPath.text
