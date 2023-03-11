/obj/machinery/elevator_indicator
	name = "floor indicator"
	icon = 'icons/obj/elevator.dmi'
	icon_state = "elevator_indicator"
	density = FALSE
	desc = "An indicator for the current floor level."
	//Helps us group elevator components
	var/id
	//The current level we're displaying
	var/mutable_appearance/level_display
	///Do we call the elevator down or up to us
	var/preset_z = FALSE
	//The detail offset for the level indicator
	var/z_offset = -1
	///Do we add the standing overlay?
	var/standing = FALSE

/obj/machinery/elevator_indicator/primary
	id = "primary"

/obj/machinery/elevator_indicator/Initialize(mapload)
	. = ..()
	update_display(force = TRUE)
	RegisterSignal(SSelevator_controller, COMSIG_ELEVATOR_MOVE, PROC_REF(update_display))
	if(standing)
		var/mutable_appearance/M = mutable_appearance('icons/obj/elevator.dmi', "elevator_stand")
		add_overlay(M)

/obj/machinery/elevator_indicator/examine(mob/user)
	. = ..()
	. += "\nIt reads, level [get_virtual_z_level() + z_offset]"

/obj/machinery/elevator_indicator/proc/update_display(datum/source, _id, z_destination, force = FALSE)
	if(_id != id && !force)
		return
	if(level_display)
		cut_overlay(level_display)
		QDEL_NULL(level_display)
	level_display = mutable_appearance('icons/obj/elevator.dmi', "[icon_state]_[(preset_z || !z_destination ? get_virtual_z_level() : z_destination) + z_offset]")
	add_overlay(level_display)
