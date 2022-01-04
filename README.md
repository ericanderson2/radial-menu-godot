# radial-menu-godot
This is a Radial Menu class for the Godot game engine, written for my project Paramnesia. Feel free to use this code for your own projects.

The menu is rendered using Godot's `_draw()` function. It is customizable by default through global variables, but you may need to tweak some code to get it looking the way you want. The code is heavily commented, so it should be easy to understand.

## How to use
First, transfer the files `RadialMenu.tscn` and `RadialMenu.gd` to your project. The menu is setup as a class, so it is instantiated through code.

The following code creates a menu with three options:
```
var r: RadialMenu = RadialMenu.new(["item1", "item2", "item3"])
r.connect("selected", self, "selected_from_menu")
r.connect("closed", self, "menu_closed")
add_child(r)
 ```
Add the menu as a child of a control node.

The `RadialMenu.new()` function takes an array of strings, each representing a menu option, as its only parameter.

A RadialMenu has 2 signals: `selected` and `closed`.

`selected` is emitted when the user clicks on an option. It also passes one parameter, the string corresponding to the option selected.

The following code handles the selection of options:
```
func selected_from_menu(option: String):
  match option:
    "item1":
      print("Item1 selected")
    "item2":
      print("Item2 selected")
    "item3":
      print("Item3 selected")
```
`closed` is emitted when the user clicks outside of the menu circle, and the menu is closed.

See the file `RadialMenu.gd` for all the variables that can be changed. If all of the menus you are creating have the same visual style, you can edit the variables in this file. Otherwise, you can change the member variables of a specific menu object after instantiating it. You may need to write setter function for some of these changes (specifically, the font, if it is not declared in the .gd file).

An example implementation is seen in the files `Example.tscn` and `Example.gd`

## License
MIT License. Free to use, modify, and distribute. No attribution necessary.
