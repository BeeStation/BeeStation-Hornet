/**
 * # Light Component
 *
 * Emits a light of a specific brightness and colour. Requires a shell.
 */
/obj/item/circuit_component/light
	display_name = "Light"
	display_desc = "A component that emits a light of a specific brightness and colour. Requires a shell."

	/// The colours of the light
	var/datum/port/input/red
	var/datum/port/input/green
	var/datum/port/input/blue

	/// The brightness
	var/datum/port/input/brightness

	/// Whether the light is on or not
	var/datum/port/input/on

	var/max_power = 5
	var/min_lightness = 0.4
	var/shell_light_color

/obj/item/circuit_component/light/get_ui_notices()
	. = ..()
	. += create_ui_notice("Maximum Brightness: [max_power]", "orange", "lightbulb")

/obj/item/circuit_component/light/Initialize()
	. = ..()
	red = add_input_port("Red", PORT_TYPE_NUMBER)
	green = add_input_port("Green", PORT_TYPE_NUMBER)
	blue = add_input_port("Blue", PORT_TYPE_NUMBER)
	brightness = add_input_port("Brightness", PORT_TYPE_NUMBER)

	on = add_input_port("On", PORT_TYPE_NUMBER)


/obj/item/circuit_component/light/Destroy()
	red = null
	green = null
	blue = null
	brightness = null
	on = null
	return ..()

/obj/item/circuit_component/light/register_shell(atom/movable/shell)
	. = ..()
	TRIGGER_CIRCUIT_COMPONENT(src, null)

/obj/item/circuit_component/light/unregister_shell(atom/movable/shell)
	shell.set_light(0, 0)
	return ..()

/obj/item/circuit_component/light/input_received(datum/port/input/port)
	. = ..()
	brightness.set_input(clamp(brightness.input_value || 0, 0, max_power), FALSE)
	red.set_input(clamp(red.input_value, 0, 255), FALSE)
	blue.set_input(clamp(blue.input_value, 0, 255), FALSE)
	green.set_input(clamp(green.input_value, 0, 255), FALSE)
	var/list/hsl = rgb2hsl(red.input_value || 0, green.input_value || 0, blue.input_value || 0)
	var/list/light_col = hsl2rgb(hsl[1], hsl[2], max(min_lightness, hsl[3]))
	shell_light_color = rgb(light_col[1], light_col[2], light_col[3])
	if(.)
		return

	if(parent.shell)
		set_atom_light(parent.shell)

/obj/item/circuit_component/light/proc/set_atom_light(atom/movable/target_atom)
	// Clamp anyways just for safety
	var/bright_val = min(max(brightness.input_value || 0, 0), max_power)

	if(on.input_value)
		target_atom.set_light(bright_val, bright_val, shell_light_color)
	else
		target_atom.set_light(0, 0)
