/atom/movable/lighting_mask
	icon             = LIGHTING_ICON_BIG
	icon_state       = "light_big"

/atom/movable/lighting_mask/proc/set_colour(colour = "#ffffff")
	color = colour

/atom/movable/lighting_mask/proc/set_intensity(intensity = 1)
	if(intensity >= 0)
		alpha = ALPHA_TO_INTENSITY(intensity)
		blend_mode = BLEND_ADD
	else
		alpha = ALPHA_TO_INTENSITY(-intensity)
		blend_mode = BLEND_SUBTRACT

//The holder atom turned
/atom/movable/lighting_mask/proc/holder_turned(new_direction)
	return

//Flicker

/atom/movable/lighting_mask/flicker
	icon_state = "light_flicker"

//Conical Light

/atom/movable/lighting_mask/conical
	icon_state = "light_conical"

/atom/movable/lighting_mask/conical/holder_turned(new_direction)
	var/wanted_angle = dir2angle(new_direction) - 180
	rotate(wanted_angle)

//Rotating Light

/atom/movable/lighting_mask/rotating
	icon_state = "light_rotating-1"

/atom/movable/lighting_mask/rotating/Initialize(mapload, ...)
	. = ..()
	icon_state = "light_rotating-[rand(1, 3)]"

//Client light
//It just works
/atom/movable/lighting_mask/personal_light
	var/mob/owner

/atom/movable/lighting_mask/personal_light/proc/give_owner(mob/_owner)
	owner = _owner
	var/image/blank = image(loc = src)
	blank.override = TRUE
	remove_alt_appearance("nightvision")
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/allbutone, "nightvision", blank, owner)
