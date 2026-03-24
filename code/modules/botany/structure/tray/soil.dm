/obj/item/plant_tray/soil
	name = "soil"
	icon_state = "dirt"
	use_indicators = FALSE
	plumbing = FALSE
	density = FALSE
	use_substrate = FALSE

/obj/item/plant_tray/soil/Initialize(mapload)
	. = ..()
	tray_component.set_substrate(/datum/plant_subtrate/fairy)
	tray_component.allow_substrate_change = FALSE

/obj/item/plant_tray/soil/priate
	//if you want to make pirates lives easier add it here
