/obj/machinery/door/poddoor/shutters
	gender = PLURAL
	name = "shutters"
	desc = "Heavy duty metal shutters that open mechanically."
	icon = 'icons/obj/doors/blastdoors/shutters.dmi'
	base_icon_state = "shut"
	icon_state = "shut_closed"
	layer = SHUTTER_LAYER
	closingLayer = SHUTTER_LAYER
	damage_deflection = 20
	armor_type = /datum/armor/poddoor_shutters
	recipe_type = /datum/crafting_recipe/shutters
	pod_open_sound  = 'sound/machines/shutter_open.ogg'
	pod_close_sound = 'sound/machines/shutter_close.ogg'

/datum/armor/poddoor_shutters
	melee = 20
	bullet = 20
	laser = 20
	energy = 75
	bomb = 25
	fire = 100
	acid = 70

/obj/machinery/door/poddoor/shutters/preopen
	icon_state = "shut_open"
	density = FALSE
	z_flags = NONE // reset zblock
	opacity = FALSE

/obj/machinery/door/poddoor/shutters/preopen/deconstructed
	deconstruction = BLASTDOOR_NEEDS_WIRES

/obj/machinery/door/poddoor/shutters/indestructible
	name = "hardened shutters"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/door/poddoor/shutters/bumpopen(mob/user)
	return

/obj/machinery/door/poddoor/shutters/radiation
	name = "radiation shutters"
	desc = "Depleted uranium-lined shutters with a radiation hazard symbol. Whilst this won't stop you getting irradiated, especially by a supermatter crystal, it will stop the majority of radiation."
	base_icon_state = "rad"
	icon_state = "rad_closed"
	rad_insulation = RAD_EXTREME_INSULATION
	recipe_type = /datum/crafting_recipe/radshutters

/obj/machinery/door/poddoor/shutters/radiation/preopen
	icon_state = "rad_open"
	density = FALSE
	opacity = FALSE
	rad_insulation = RAD_NO_INSULATION
	z_flags = NONE // reset zblock

/obj/machinery/door/poddoor/shutters/radiation/open()
	. = ..()
	rad_insulation = RAD_NO_INSULATION

/obj/machinery/door/poddoor/shutters/radiation/close()
	. = ..()
	rad_insulation = RAD_EXTREME_INSULATION

/obj/machinery/door/poddoor/shutters/window
	name = "windowed shutters"
	desc = "A shutter with a thick see-through polycarbonate window."
	base_icon_state = "win"
	icon_state = "win_closed"
	opacity = FALSE
	glass = TRUE
	recipe_type = /datum/crafting_recipe/glassshutters

/obj/machinery/door/poddoor/shutters/window/preopen
	icon_state = "win_open"
	density = FALSE
	z_flags = NONE // reset zblock
