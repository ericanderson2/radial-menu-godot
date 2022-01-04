extends Control

# the first three functions below are an example of how to use the RadialMenu class

func _on_CreateButton_pressed():
	var options: Array = $TextEdit.text.split("\n")
	var r: RadialMenu = RadialMenu.new(options)
	r.title = "Radial Menu Test"
# warning-ignore:return_value_discarded
	r.connect("selected", self, "selected_from_menu")
# warning-ignore:return_value_discarded
	r.connect("closed", self, "menu_closed")
	
	add_child(r)

func selected_from_menu(item: String):
	$Output.text = "Option selected: " + item
	# normally, you would use a match statement here to handle the inputs

func menu_closed():
	$Output.text = "Option selected:"
