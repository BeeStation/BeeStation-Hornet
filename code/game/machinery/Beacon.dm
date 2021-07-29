/obj/machinery/bluespace_beacon

	icon = 'icons/obj/objects.dmi'
	icon_state = "floor_beaconf"
	name = "bluespace gigabeacon"
	desc = "A device that draws power from bluespace and creates a permanent tracking beacon."
	level = 1		// underfloor
	layer = LOW_OBJ_LAYER
	use_power = IDLE_POWER_USE
	idle_power_usage = 0
	var/obj/item/beacon/Beacon

/obj/machinery/bluespace_beacon/Initialize()
	. = ..()
	var/turf/T = loc
	Beacon = new(T)
	Beacon.invisibility = INVISIBILITY_MAXIMUM

	hide(T.intact)

/obj/machinery/bluespace_beacon/Destroy()
	QDEL_NULL(Beacon)
	return ..()

// update the invisibility and icon
/obj/machinery/bluespace_beacon/hide(intact)
	invisibility = intact ? INVISIBILITY_MAXIMUM : 0
	updateicon()

// update the icon_state
/obj/machinery/bluespace_beacon/proc/updateicon()
	if(invisibility)
		icon_state = "floor_beaconf"
	else
		icon_state = "floor_beacon"

/obj/machinery/bluespace_beacon/process()
	if(QDELETED(Beacon)) //Don't move it out of nullspace BACK INTO THE GAME for the love of god
		var/turf/T = loc
		Beacon = new(T)
		Beacon.invisibility = INVISIBILITY_MAXIMUM
	else if (Beacon.loc != loc)
		Beacon.forceMove(loc)
