/obj/item/plant_tray/soil
	name = "soil"
	icon_state = "dirt"
	use_indicators = FALSE
	plumbing = FALSE
	density = FALSE

/obj/item/plant_tray/soil/priate

/obj/item/plant_tray/soil/priate/Initialize(mapload)
	. = ..()
	tray_component.set_substrate(/datum/plant_subtrate/fairy)
	tray_component.allow_substrate_change = FALSE
