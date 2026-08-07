/obj/item/plant_tray/soil
	name = "soil"
	icon_state = "dirt"
	use_indicators = FALSE
	plumbing = FALSE
	density = FALSE
	use_substrate = FALSE
	can_scan = FALSE
	///Do we repel pests?
	var/repel_pests = FALSE

/obj/item/plant_tray/soil/Initialize(mapload)
	. = ..()
	tray_component.set_substrate(/datum/plant_subtrate/fairy)
	tray_component.allow_substrate_change = FALSE
	if(repel_pests)
		RegisterSignal(src, COMSIG_PLANTER_REPEL_PESTS, PROC_REF(repel_pests))

/obj/item/plant_tray/soil/proc/repel_pests(datum/source)
	SIGNAL_HANDLER

	return TRUE

/obj/item/plant_tray/soil/no_pests
	repel_pests = TRUE
