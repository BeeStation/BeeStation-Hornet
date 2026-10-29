/*
	Plant substrate, the stuff you plant plants in. Stuff like dirt.
*/
/datum/plant_subtrate
	var/name = "generic substrate"
	var/tooltip = "It has no special effects!"
	///What kinds of substrate is this substrate
	var/substrate_flags = PLANT_SUBSTRATE_DIRT | PLANT_SUBSTRATE_SAND |  PLANT_SUBSTRATE_CLAY | PLANT_SUBSTRATE_DEBRIS
///The appearance for this substrate, usually a flat texture
	var/icon = 'icons/obj/hydroponics/features/substrate.dmi'
	var/icon_state = "dirt"
	var/mutable_appearance/substrate_appearance

/datum/plant_subtrate/New(_tray)
	. = ..()
	substrate_appearance = mutable_appearance(icon, icon_state, BELOW_OBJ_LAYER+0.01)
