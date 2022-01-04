extends Control

class_name RadialMenu

# RadialMenu by Eric Anderson
# Free to use, distribute, modify. No attribution necessary

# for menus with different styles, you may need to write a setter for some variables
# for one theme for all menus, just change the values below
# the menu is redrawn dynamically so only things like fonts, font color, etc. that interface with Godot control nodes need setters

# weight of the slice outlines
# default value: 8.0
var outline_width: float = 8.0
# how far the mouse can be from the menu and still pop a slice up
# the value is calculated with menu_radius + mouse_proximity_leeway, so pop_amount should generally be included in the leeway
# default value: 20.0
var mouse_proximity_leeway: float = 20.0
# how much the slices pop up
# default value: 10.0
var pop_amount: float = 10.0
# the outer radius of the menu
#default value: 100.0
var menu_radius: float = 200.0
# width of the menu (expands inward). must be less than menu_radius
# default value: 70.0
var menu_width: float = 130.0
# pop animation speed multiplier
# default value: 100.0
var slice_pop_speed: float = 100.0
# how smooth the circle is (how many points define curve)
# default value: 200
var detail: int = 200
# the center of the menu (screen coordinates)
# default value: center of screen
var center: Vector2 = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height")) / 2
# whether or not to use antialiasing in draw commands
# default value: true
var antialiased: bool = true
# the minimum number of options that will be displayed. pads out the menu with blank options if there are not enough
# set to 0 to disable (not recommended, menu gets weird with only 1 option)
# default value: 2
var min_options: int = 2
# title of the menu, displayed at the center
# default value: null
var title: String = "" setget set_title
# the offset in radians from which slices are drawn. Offset 0r = 3 o'clock. Slices are drawn clockwise
# default value: 0
var angle_offset: float = 0.0
# if true, align_first_item overrides angle offset
# sets angle offset so that the first item is centered at 0 o'clock
# default value: true
var align_first_item: bool = true

# color of the outlines (this works best if not transparent because of how the outline is rendered)
# default value: Color8(22, 22, 22, 255)
var outline_color: Color = Color8(22, 22, 22, 255)
# normal slice color
# default value: Color8(62, 62, 62, 200)
var back_color: Color = Color8(62, 62, 62, 200)
# color of slice when the mouse is over
# default value: Color8(139, 139, 139, 200)
var hover_color: Color = Color8(139, 139, 139, 200)

# for custom font, declare it like this and remove var declaration
# const font = preload("res://font.tres")
var font: Font = null

# do not touch these
var slice_heights: Array = [] # array of floats (0 to 1)
var slice_labels: Array = [] # array of labels
var slices: Array = [] # array of strings
var selected_item: int = -1
var inner_radius: float
var middle_radius: float
var title_label: Label
var num_items: int
var item_size: float # size of each slice in radians

signal selected # emitted when an option is clicked on
signal closed # emitted when the user clicks outside of the menu

func _init(passed_slices: Array):
	slices = passed_slices.duplicate()
	
	# calculate constants based on inputs
	num_items = slices.size()
	if num_items < min_options:
		num_items = min_options

	item_size = 2 * PI / num_items
	inner_radius = menu_radius - menu_width
	middle_radius = menu_radius - menu_width / 2
	
	if align_first_item:
		angle_offset = -PI/2 - item_size/2
	
	# create title
	title_label = Label.new()
	title_label.align = Label.ALIGN_CENTER
	title_label.valign = Label.ALIGN_CENTER
	title_label.grow_horizontal = Label.GROW_DIRECTION_BOTH
	title_label.grow_vertical = Label.GROW_DIRECTION_BOTH
	title_label.autowrap = true
	title_label.rect_min_size = Vector2((menu_radius - menu_width) * 1.8, (menu_radius - menu_width) * 1.8)
	title_label.rect_position = center - Vector2(0, 8) # adjust as necessary, needs to be brought up by 1/2 the font height to be centered
	title_label.text = title
	add_child(title_label)
	
	# create option labels
	for i in range(num_items):
		slice_heights.append(0)
		if i > slices.size() - 1:
			slices.append("")
		
		var l = Label.new()
		l.align = Label.ALIGN_CENTER
		l.valign = Label.ALIGN_CENTER
		l.grow_horizontal = Label.GROW_DIRECTION_BOTH
		l.grow_vertical = Label.GROW_DIRECTION_BOTH
		l.autowrap = true
		l.rect_min_size = Vector2(menu_width * 0.8, menu_width * 0.8)
		if (font != null):
			l.set("custom_fonts/font", font)
		var middle_angle: float = i * item_size + item_size / 2 + angle_offset
		l.rect_position = center + Vector2(cos(middle_angle) * middle_radius, sin(middle_angle) * middle_radius)
		l.text = slices[i]
		add_child(l)
		slice_labels.append(l)

func _process(delta):
	# to increase performance, consider only processing when at least one slice is raised above baseline
	for i in range(slice_heights.size()):
		# to change the way slices are raised and lowered, change the number in the ease function
		# this forum thread shows the curves: https://godotengine.org/qa/59172/how-do-i-properly-use-the-ease-function
		if (i == selected_item):
			# raise (pop) slice with easing function
			slice_heights[i] += delta * slice_pop_speed * (ease(slice_heights[i], 0.4) - slice_heights[i])
			# see the min() line below for why this clamp is here. only the clamp should be necessary, but I haven't done enough testing yet
			slice_heights[i] = clamp(slice_heights[i], 0.0, 0.99) 
		else:
			# lower slice with easing function
			# min(0.99) because ease transforms 1 into 1. this would be smoother with even more precision probably (0.999+)
			slice_heights[i] = min(0.99, slice_heights[i])
			slice_heights[i] -= delta * slice_pop_speed * (slice_heights[i] - ease(slice_heights[i], 2.5))
	update() # erases screen and calls _draw()

func _draw():
	for i in range(num_items):
		var start_angle: float = i * item_size + angle_offset
		var end_angle: float = (i + 1) * item_size + angle_offset
		var color: Color = back_color
		if i == selected_item:
			color = hover_color
		# draw slice
		draw_arc(center, middle_radius + slice_heights[i] * pop_amount, start_angle, end_angle, detail, color, menu_width, antialiased)
		# draw inner radius outline
		draw_arc(center, inner_radius + slice_heights[i] * pop_amount, start_angle, end_angle, detail, outline_color, outline_width, antialiased)
		
		var true_outer_radius: float = menu_radius + slice_heights[i] * pop_amount # radius of the slice, accounting for it being popped out
		var true_inner_radius: float = inner_radius - outline_width / 2 # radius of inner circle, accounting for outline
		
		# draw a border outline on both edges of the slice
		var starting_coord: Vector2 = center + Vector2(cos(start_angle) * true_outer_radius, sin(start_angle) * true_outer_radius)
		var ending_coord: Vector2 = center + Vector2(cos(start_angle) * true_inner_radius, sin(start_angle) * true_inner_radius)
		draw_line(starting_coord, ending_coord, outline_color, outline_width, antialiased)
		
		starting_coord = center + Vector2(cos(end_angle) * true_outer_radius, sin(end_angle) * true_outer_radius)
		ending_coord = center + Vector2(cos(end_angle) * true_inner_radius, sin(end_angle) * true_inner_radius)
		draw_line(starting_coord, ending_coord, outline_color, outline_width, antialiased)
		
		# calculate slice label position
		var middle_angle: float = i * item_size + item_size / 2 + angle_offset
		var radius: float = middle_radius + clamp(slice_heights[i], 0.1, 0.9) * pop_amount
		slice_labels[i].rect_position = center + Vector2(cos(middle_angle) * radius, sin(middle_angle) * radius) - slice_labels[i].rect_size / 2

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		if mouse_pos.distance_to(center) < menu_radius + mouse_proximity_leeway:
			# convert mouse position to slice number
			var transformed_angle = (mouse_pos - center).angle() - angle_offset
			if transformed_angle < 0:
				transformed_angle += 2 * PI
			selected_item = int(transformed_angle / item_size)
			# the max(0.01) is necessary because ease() of 0 returns 0
			slice_heights[selected_item] = max(0.01, slice_heights[selected_item])
		else:
			selected_item = -1
		update()
		get_tree().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed:
		if selected_item > -1:
			emit_signal("selected", slices[selected_item])
		else:
			emit_signal("closed")
			queue_free()
		get_tree().set_input_as_handled()

# setter function for title
func set_title(new_title: String):
	title = new_title
	title_label.text = title
