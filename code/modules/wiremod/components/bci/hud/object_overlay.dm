/**
 * # Object Overlay Component
 *
 * Shows an overlay ontop of an object. Toggleable.
 * Requires a BCI shell.
 */

#define OBJECT_OVERLAY_LIMIT 10

/obj/item/circuit_component/object_overlay
	display_name = "Object Overlay"
	desc = "Requires a BCI shell. A component that shows an overlay on top of an object."

	required_shells = list(/obj/item/organ/cyberimp/bci)

	var/datum/port/input/option/object_overlay_options

	/// Target atom
	var/datum/port/input/target

	var/datum/port/input/image_pixel_x
	var/datum/port/input/image_pixel_y
	var/datum/port/input/image_rotation


	/// On/Off signals
	var/datum/port/input/signal_on
	var/datum/port/input/signal_off

	var/obj/item/organ/cyberimp/bci/bci
	var/list/active_overlays = list()
	var/list/options_map

/obj/item/circuit_component/object_overlay/populate_ports()
	target = add_input_port("Target", PORT_TYPE_ATOM)

	signal_on = add_input_port("Create Overlay", PORT_TYPE_SIGNAL)
	signal_off = add_input_port("Remove Overlay", PORT_TYPE_SIGNAL)

	image_pixel_x = add_input_port("X-Axis Shift", PORT_TYPE_NUMBER)
	image_pixel_y = add_input_port("Y-Axis Shift", PORT_TYPE_NUMBER)
	image_rotation = add_input_port("Overlay Rotation", PORT_TYPE_NUMBER)

/obj/item/circuit_component/object_overlay/Destroy()
	for(var/active_overlay in active_overlays)
		QDEL_NULL(active_overlay)
	return ..()

/obj/item/circuit_component/object_overlay/populate_options()
	var/static/list/component_options = list(
		"Corners (Blue)" = "hud_corners",
		"Corners (Red)" = "hud_corners_red",
		"Circle (Blue)" = "hud_circle",
		"Circle (Red)" = "hud_circle_red",
		"Small Corners (Blue)" = "hud_corners_small",
		"Small Corners (Red)" = "hud_corners_small_red",
		"Triangle (Blue)" = "hud_triangle",
		"Triangle (Red)" = "hud_triangle_red",
		"HUD mark (Blue)" = "hud_mark",
		"HUD mark (Red)" = "hud_mark_red"
	)
	object_overlay_options = add_option_port("Object", component_options)
	options_map = component_options

/obj/item/circuit_component/object_overlay/register_shell(atom/movable/shell)
	if(istype(shell, /obj/item/organ/cyberimp/bci))
		bci = shell
		RegisterSignal(shell, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_organ_removed))

/obj/item/circuit_component/object_overlay/unregister_shell(atom/movable/shell)
	bci = null
	UnregisterSignal(shell, COMSIG_CARBON_LOSE_ORGAN)

/obj/item/circuit_component/object_overlay/input_received(datum/port/input/port)
	if(!bci)
		return

	var/mob/living/owner = bci.owner
	var/atom/target_atom = target.value

	if(!owner || !istype(owner) || !owner.client || !target_atom)
		return

	if(COMPONENT_TRIGGERED_BY(signal_on, port))
		show_to_owner(target_atom, owner)

	if(COMPONENT_TRIGGERED_BY(signal_off, port) && (target_atom in active_overlays))
		QDEL_NULL(active_overlays[target_atom])
		active_overlays.Remove(target_atom)

/obj/item/circuit_component/object_overlay/proc/show_to_owner(atom/target_atom, mob/living/owner)
	if(LAZYLEN(active_overlays) >= OBJECT_OVERLAY_LIMIT)
		return

	if(active_overlays[target_atom])
		QDEL_NULL(active_overlays[target_atom])

	var/image/cool_overlay = image(icon = 'icons/mob/screen_bci.dmi', loc = target_atom, icon_state = options_map[object_overlay_options.value], layer = RIPPLE_LAYER)

	if(image_pixel_x.value)
		cool_overlay.pixel_x = image_pixel_x.value

	if(image_pixel_y.value)
		cool_overlay.pixel_y = image_pixel_y.value

	if(image_rotation.value)
		var/matrix/turn_matrix = cool_overlay.transform
		turn_matrix.Turn(image_rotation.value)
		cool_overlay.transform = turn_matrix

	var/alt_appearance = WEAKREF(target_atom.add_alt_appearance(
		/datum/atom_hud/alternate_appearance/basic/one_person,
		"object_overlay_[REF(src)]",
		cool_overlay,
		owner,
	))

	active_overlays[target_atom] = alt_appearance

/obj/item/circuit_component/object_overlay/proc/on_organ_removed(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER

	for(var/atom/target_atom in active_overlays)
		QDEL_NULL(active_overlays[target_atom])
		active_overlays.Remove(target_atom)

#undef OBJECT_OVERLAY_LIMIT
