extends GridContainer

func init(powerups):
	for child in get_children():
		child.free()
	for powerup in powerups:
		var checkbox = CheckBox.new()
		checkbox.text = AUTO.ATTACK.keys()[powerup]
		add_child(checkbox)

func get_selected_powerups() -> Array:
	var powerups = []
	for child in get_children():
		if child.pressed:
			powerups.append(AUTO.ATTACK.get(child.text))
	return powerups
