extends GridContainer

func init(powerups: Array):
	for powerup in powerups:
		var checkbox = CheckBox.new()
		checkbox.text = powerup
		add_child(checkbox)

func get_selected_powerups() -> Array:
	var powerups = []
	for child in get_children():
		if child.pressed:
			powerups.append(AUTO.ATTACK.get(child.text))
	return powerups
